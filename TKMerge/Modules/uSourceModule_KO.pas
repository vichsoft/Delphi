unit uSourceModule_KO;

interface

uses
  System.SysUtils, System.Classes, uSourceModule, Data.DB, MemDS, DBAccess, Uni,
  UniProvider, SQLiteUniProvider, kbmMemTable, uType, qmsgpack, qjson;

type
  TSourceModule_KO = class(TSourceModule)
    conItem: TUniConnection;
    qryItem: TUniQuery;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  strict private
  private
    FKeyWord: string;
    FItemDatabasePath: string;
    FItemList: TQMsgPackList;
    function GetDbKey: string;
    procedure ParseDataA(const AID, AChapterID, AItemType, AData: string);
    procedure ParseDataA3(const AID, AChapterID, AItemType, AData: string);
    function ParseDataX(const AID, AChapterID, AItemType, AData: string): string;
    procedure ParseData(const AID, AChapterID, AItemType, AData, AItemTypeID: string);
    procedure ParseDataUnknow(const AID, AChapterID, AItemType, AData: string);
    function ParseItemData(const AItemID, AChapterID, AItemType: string): string;
    function ParseOption(const AData: string): TQJson;
    procedure SetItemDb(const AItemID: string);
  public
    procedure GetCatalogList(const ASubjectID: string; var AList: TkbmMemTable); override;
    procedure GetItemList(const AChapterID, ASubjectID: string; var AList: TQMsgPackList); overload;
    procedure GetSubjectList(var AList: TkbmMemTable); override;
    property ItemDatabasePath: string write FItemDatabasePath;
  end;

implementation

uses
  qstring, uFunction, MessageDlg, FMX.Forms;

{$R *.dfm}

procedure TSourceModule_KO.DataModuleDestroy(Sender: TObject);
begin
  inherited;
  FItemList.Clear;
  FItemList.Free;
end;

procedure TSourceModule_KO.DataModuleCreate(Sender: TObject);
begin
  inherited;
  FItemList := TQMsgPackList.Create;
end;

procedure TSourceModule_KO.GetSubjectList(var AList: TkbmMemTable);
begin
  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('Select * from T_Json where FID>1 and FID<27');
      Open;
      AList.LoadFromDataSet(qry, [mtcpoStructure]);
    finally
      Close;
    end;
  end;
end;

procedure TSourceModule_KO.GetCatalogList(const ASubjectID: string; var AList: TkbmMemTable);
begin
  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('Select * from T_ChapterID where FExam=''' + ASubjectID + '''');
      Open;
      AList.LoadFromDataSet(qry, [mtcpoStructure]);
    finally
      Close;
    end;
  end;
end;

function TSourceModule_KO.GetDbKey: string;
begin
  with qryItem do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('Select time from DBVersion');
      Open;
      Result := FieldByName('time').AsString;
    finally
      Close;
    end;
  end;
end;

procedure TSourceModule_KO.GetItemList(const AChapterID, ASubjectID: string; var AList: TQMsgPackList);
var
  I: Integer;
  lvIDs, lvItemType: string;
  lvIDList: TStrings;
begin
  lvIDList := TStringList.Create;

  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('Select * from T_TestID where FChapterID=:FChapterID and FExam=:FExam');
      ParamByName('FExam').AsString := ASubjectID;
      ParamByName('FChapterID').AsString := AChapterID;
      Open;
      First;
      FItemList.Clear;
      //
      while not Eof do
      begin
        lvIDs := FieldByName('FTestIDFull').AsString;
        lvIDList.Clear;
        SplitByStrW(lvIDList, lvIDs, ',', False);
        lvItemType := FieldByName('FStyle').AsString;
        //
        for I := 0 to lvIDList.Count - 1 do
        begin
          SetItemDb(ASubjectID);
          ParseItemData(lvIDList[I], ASubjectID + ':' + Format('%.6d', [StrToInt(AChapterID)]), lvItemType);
        end;
        Next;
      end;
      //
      AList := FItemList;
    finally
      Close;
      lvIDList.Clear;
      lvIDList.Free;
    end;
  end;
end;

procedure TSourceModule_KO.ParseDataUnknow(const AID, AChapterID, AItemType, AData: string);
var
  lvItemInfo: TQMsgPack;
begin
  lvItemInfo := TQMsgPack.Create;
  with lvItemInfo do
  begin
    Add('FItemID', AID);
    Add('FItemCatalogID', AChapterID);
    Add('FItemTypeID', AItemType);
    Add('FItemData', AData);
    Add('FFavorite', False);
    Add('FHotspot', False);
    Add('FFallible', False);
    Add('FNote', '题型未知');
    Add('FExplain', '');
  end;
  FItemList.Add(lvItemInfo);
end;

procedure TSourceModule_KO.ParseDataA(const AID, AChapterID, AItemType, AData: string);
var
  lvSource, lvDest: TQJson;
  lvItemData, lvExplain: string;
  lvItemInfo: TQMsgPack;
  lvFavorite: Boolean;
begin
  try
    lvSource := TQJson.Create;
    lvDest := TQJson.Create;

    try
      lvSource.Parse(AData);
      lvFavorite := lvSource.ItemByName('Isfav').AsBoolean;
      lvExplain := lvSource.ItemByName('Explain').AsString.Trim;
      //
      lvDest.ForcePath('Title').AsString := lvSource.ItemByName('Title').AsString.Trim;
      lvDest.Add(ParseOption(lvSource.ItemByName('Items').AsString));
      lvDest.ForcePath('Answer').AsString := lvSource.ItemByName('Answer').AsString.Trim;
      lvItemData := lvDest.AsString.Trim;
    finally
      lvSource.Free;
      lvDest.Free;
    end;

    lvItemInfo := TQMsgPack.Create;
    with lvItemInfo do
    begin
      Add('FItemID', AID);
      Add('FItemCatalogID', AChapterID);
      Add('FItemTypeID', AItemType);
      Add('FItemData', lvItemData);
      Add('FFavorite', lvFavorite);
      Add('FHotspot', False);
      Add('FFallible', False);
      Add('FNote', '');
      Add('FExplain', lvExplain);
    end;
    FItemList.Add(lvItemInfo);
  except
    ParseDataUnknow(AID, AChapterID, AItemType, AData);
  end;
end;

procedure TSourceModule_KO.ParseDataA3(const AID, AChapterID, AItemType, AData: string);
var
  I: Integer;
  lvSource, lvDest: TQJson;
  lvSubID, lvItemData, lvTitle, lvExplain: string;
  lvItemInfo: TQMsgPack;
  lvFavorite: Boolean;
begin
  try
    lvSource := TQJson.Create;
    lvSource.Parse(AData);
    lvFavorite := lvSource.ItemByName('Isfav').AsBoolean;
    lvTitle := lvSource.ItemByName('FrontTitle').AsString;
    for I := 0 to lvSource.ItemByName('Items').Count - 1 do
    begin
      lvDest := TQJson.Create;
      try
        lvDest.ForcePath('Title').AsString := lvTitle.Trim;
        lvDest.ForcePath('ChildTitle').AsString := lvSource.ItemByName('Items').Items[I].ItemByName('Title').AsString.Trim;
         //
        lvDest.Add(ParseOption(lvSource.ItemByName('Items').Items[I].ItemByName('Items').AsString));
        lvDest.ForcePath('Answer').AsString := lvSource.ItemByName('Items').Items[I].ItemByName('Answer').AsString.Trim;
        lvItemData := lvDest.AsString.Trim;
        //
        lvSubID := lvSource.ItemByName('Items').Items[I].ItemByName('ID').AsString.Trim;
        lvExplain := lvSource.ItemByName('Items').Items[I].ItemByName('Explain').AsString.Trim;
      finally
        lvDest.Free;
      end;

      lvItemInfo := TQMsgPack.Create;
      with lvItemInfo do
      begin
        Add('FItemID', AID + '_' + lvSubID);
        Add('FItemCatalogID', AChapterID);
        Add('FItemTypeID', AItemType);
        Add('FItemData', lvItemData);
        Add('FFavorite', lvFavorite);
        Add('FHotspot', False);
        Add('FFallible', False);
        Add('FNote', '');
        Add('FExplain', lvExplain);
      end;
      FItemList.Add(lvItemInfo);
    end;
    lvSource.Free;
  except
    ParseDataUnknow(AID, AChapterID, AItemType, AData);
  end;
end;

function TSourceModule_KO.ParseDataX(const AID, AChapterID, AItemType, AData: string): string;
var
  lvSource, lvDest: TQJson;
  lvItemData, lvExplain: string;
  lvItemInfo: TQMsgPack;
  lvFavorite: Boolean;
begin
  try
    lvSource := TQJson.Create;
    lvDest := TQJson.Create;
    try
      lvSource.Parse(AData);
      lvFavorite := lvSource.ItemByName('Isfav').AsBoolean;
      lvExplain := lvSource.ItemByName('Explain').AsString.Trim;
      //
      lvDest.ForcePath('Title').AsString := lvSource.ItemByName('Title').AsString.Trim;
      lvDest.Add(ParseOption(lvSource.ItemByName('Items').AsString));
      lvDest.ForcePath('Answer').AsString := lvSource.ItemByName('Answer').AsString.Trim;
      lvItemData := lvDest.AsString.Trim;
    finally
      lvSource.Free;
      lvDest.Free;
    end;
     //
    lvItemInfo := TQMsgPack.Create;
    with lvItemInfo do
    begin
      Add('FItemID', AID);
      Add('FItemCatalogID', AChapterID);
      Add('FItemTypeID', AItemType);
      Add('FItemData', lvItemData);
      Add('FFavorite', lvFavorite);
      Add('FHotspot', False);
      Add('FFallible', False);
      Add('FNote', '');
      Add('FExplain', lvExplain);
    end;
    FItemList.Add(lvItemInfo);
  except
    ParseDataUnknow(AID, AChapterID, AItemType, AData);
  end;
end;

procedure TSourceModule_KO.ParseData(const AID, AChapterID, AItemType, AData, AItemTypeID: string);
begin
  if ((AItemTypeID = 'ATEST') or (AItemTypeID = 'A')) then
    ParseDataA(AID, AChapterID, AItemTypeID + ':' + AItemType, AData)
  else if AItemTypeID = 'A3TEST' then
    ParseDataA3(AID, AChapterID, AItemTypeID + ':' + AItemType, AData)
  else if AItemTypeID = 'XTEST' then
    ParseDataX(AID, AChapterID, AItemTypeID + ':' + AItemType, AData)
  else // 未知题型
    ParseDataUnknow(AID, AChapterID, AItemTypeID + ':' + AItemType, AData);
end;

function TSourceModule_KO.ParseItemData(const AItemID, AChapterID, AItemType: string): string;
var
  lvItem, lvTypeID: string;
begin
  with qryItem do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('Select Type,TestContent from Test where AID=:ID');
      ParamByName('ID').AsString := AItemID.trim;
      Open;
      lvItem := FieldByName('TestContent').AsString;
      lvTypeID := FieldByName('Type').AsString;
      lvItem := Decrypt(FKeyWord, lvItem.Trim + '=');
      ParseData(AItemID, AChapterID, AItemType, lvItem, lvTypeID);
    finally
      Close;
    end;
  end;
end;

function TSourceModule_KO.ParseOption(const AData: string): TQJson;
const
  S = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
var
  I: Integer;
  lvSource, lvNode: TQJson;
begin
  lvNode := TQJson.Create;
  lvSource := TQJson.Create;
  try
    lvSource.Parse(AData);
    lvNode := lvNode.Add('Option');
    for I := 0 to lvSource.Count - 1 do
    begin
      lvNode.Add(S[I + 1]).AsString := lvSource.Items[I].ItemByName('Text').AsString.Trim;
    end;
  finally
    lvSource.Free;
    Result := lvNode;
  end;
end;

procedure TSourceModule_KO.SetItemDb(const AItemID: string);
var
  lvDBPath: string;
  lvKey: string;
begin
  lvDBPath := IncludeTrailingBackslash(FItemDatabasePath) + AItemID + '\' + AItemID + '.db';
  if not FileExists(lvDBPath) then
  begin
    Exit;
  end;
  conItem.Database := lvDBPath;
  lvKey := GetDbKey;
  FKeyWord := Decrypt('74185263', lvKey);
end;

end.

