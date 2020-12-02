unit uSourceModule_KN;

interface

uses
  System.SysUtils, System.Classes, uSourceModule, Data.DB, MemDS, DBAccess, Uni,
  UniProvider, SQLiteUniProvider, kbmMemTable, uType, qmsgpack, qjson;

type
  TSourceModule_KN = class(TSourceModule)
  private
    procedure ParseCatalog(const AData: string; var AList: TQMsgPackList);
    procedure ParseDataA(const ASubjectID: string; var AData: TQJson; var AList: TQMsgPackList; const IsEncode: Boolean);
    procedure ParseDataA3(const ASubjectID: string; var AData: TQJson; var AList: TQMsgPackList; const IsEncode: Boolean);
    procedure ParseDataUnknow(const ASubjectID: string; var AData: TQJson; var AList: TQMsgPackList; const IsEncode: Boolean);
    function ParseDataX(const ASubjectID: string; var AData: TQJson; var AList: TQMsgPackList; const IsEncode: Boolean): string;
    procedure ParseItemData(const ASubjectID, AData: string; var AList: TQMsgPackList);
    function ParseOption(AData: TQJson): TQJson;
    function SplitSubjectID(const AFullSubjectID: string): string;
  public
    procedure GetCatalogList(const ASubjectID: string; var AList: TQMsgPackList);
    procedure GetItemList(const ASubjectID, AChapterID: string; var AList: TQMsgPackList);
    procedure GetFallibleItemList(const ASubjectID: string; var AList: TQMsgPackList);
    procedure GetHotSpotItemList(const ASubjectID: string; var AList: tqMsgPackList);
    procedure GetSubjectList(var AList: TkbmMemTable); override;
  end;

implementation

uses
  MessageDlg, uFunction;

{$R *.dfm}

procedure TSourceModule_KN.GetCatalogList(const ASubjectID: string; var AList: TQMsgPackList);
var
  lvData: string;
begin
  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('Select * from T_Chapter where FID=' + SplitSubjectID(ASubjectID));
      SQL.Add(' UNION ');
      SQL.Add('Select * from T_Exam where FID=' + SplitSubjectID(ASubjectID));
      Open;
      First;
      while not Eof do
      begin
        lvData := FieldByName('FData').AsString;
        ParseCatalog(lvData, AList);
        Next;
      end;
    finally
      Close;
    end;
  end;
end;

procedure TSourceModule_KN.GetItemList(const ASubjectID, AChapterID: string; var AList: TQMsgPackList);
var
  lvData: string;
begin
  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('SELECT * FROM T_Test WHERE FSourceID=:SubjectID AND FChapterID=:ChapterID UNION ');
      SQL.Add('SELECT * FROM T_Exam_data WHERE FSourceID=:SubjectID AND FChapterID=:ChapterID');
      //此处传入的ASubjectID格式为 lvSubjectID + ':' + lvSubejctName，查询的时候只前面的lvSubjectID部分。
      ParamByName('SubjectID').AsString := SplitSubjectID(ASubjectID);
      ParamByName('ChapterID').AsString := AChapterID;
      Open;
      First;
      while not Eof do
      begin
        lvData := FieldByName('FData').AsString;
        ParseItemData(ASubjectID, lvData, AList);
        Next;
      end;
    finally
      Close;
    end;
  end;
end;

procedure TSourceModule_KN.GetHotSpotItemList(const ASubjectID: string; var AList: tqMsgPackList);
var
  lvData: string;
begin
  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('SELECT * FROM T_HotSpot WHERE FSourceID=:SubjectID');
      ParamByName('SubjectID').AsString := SplitSubjectID(ASubjectID);
      Open;
      First;
      while not Eof do
      begin
        lvData := FieldByName('FData').AsString;
        ParseItemData(ASubjectID, lvData, AList);
        Next;
      end;
    finally
      Close;
    end;
  end;
end;

procedure TSourceModule_KN.GetFallibleItemList(const ASubjectID: string; var AList: TQMsgPackList);
var
  lvData: string;
begin
  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('SELECT * FROM T_Fallible WHERE FSourceID=:SubjectID');
      ParamByName('SubjectID').AsString := SplitSubjectID(ASubjectID);
      Open;
      First;
      while not Eof do
      begin
        lvData := FieldByName('FData').AsString;
        ParseItemData(ASubjectID, lvData, AList);
        Next;
      end;
    finally
      Close;
    end;
  end;
end;

procedure TSourceModule_KN.GetSubjectList(var AList: TkbmMemTable);
begin
  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('Select * from T_Chapter');
      Open;
      AList.LoadFromDataSet(qry, [mtcpoStructure]);
    finally
      Close;
    end;
  end;
end;

procedure TSourceModule_KN.ParseCatalog(const AData: string; var AList: TQMsgPackList);
var
  I, J, M: Integer;
  lvSource, lvSubject: string;
  lvJson, lvSourceJson, lvSubjectJson, lvChapterJson: TQJson;
  lvCatalogInfo: TQMsgPack;
begin
  lvJson := TQJson.Create;
  try
    lvJson.Parse(AData);
    for I := 0 to lvJson.ItemByName('Childs').Count - 1 do
    begin
      lvSourceJson := lvJson.ItemByName('Childs').Items[I];
      lvSource := lvSourceJson.ItemByName('Name').AsString;
      for J := 0 to lvSourceJson.ItemByName('Childs').Count - 1 do
      begin
        lvSubjectJson := lvSourceJson.ItemByName('Childs').Items[J];
        lvSubject := lvSubjectJson.ItemByName('Name').AsString;
        for M := 0 to lvSubjectJson.ItemByName('Childs').Count - 1 do
        begin
          lvChapterJson := lvSubjectJson.ItemByName('Childs').Items[M];
          lvCatalogInfo := TQMsgPack.Create;
          lvCatalogInfo.Add('FID', Format('%.4d', [lvChapterJson.ItemByName('ID').AsInteger]));
          lvCatalogInfo.Add('FTitle', lvChapterJson.ItemByName('Name').AsString);
          lvCatalogInfo.Add('FType', lvSource);
          lvCatalogInfo.Add('FSubjectID', lvSubject);
          AList.Add(lvCatalogInfo);
        end;
      end;
    end;
  finally
    lvJson.Free;
  end;
end;

procedure TSourceModule_KN.ParseDataA(const ASubjectID: string; var AData: TQJson; var AList: TQMsgPackList; const IsEncode: Boolean);
var
  I: Integer;
  lvData, lvDest: TQJson;
  lvItemInfo: TQMsgPack;
  lvID, lvChapterID, lvItemTypeID, lvItemType, lvExplain, lvNote: string;
  lvItemData: string;
  lvFavorite: Boolean;
begin
  try
    lvItemType := AData.ItemByName('Style').AsString.Trim;
    lvItemTypeID := AData.ItemByName('Type').AsString.Trim;

    for I := 0 to AData.ItemByName('TestItems').Count - 1 do
    begin
      lvData := AData.ItemByName('TestItems').Items[I];
      lvID := lvData.ItemByName('AllTestID').AsString.Trim;
      lvChapterID := Format('%.4d', [lvData.ItemByName('CptID').AsInteger]);
      lvFavorite := lvData.ItemByName('IsFav').AsBoolean;
      lvExplain := lvData.ItemByName('Explain').AsString.Trim;
      lvNote := lvData.ItemByName('UserNoteContent').AsString.Trim;

      lvDest := TQJson.Create;
      try
        lvDest.ForcePath('Title').AsString := Decode_KSBNew(lvData.ItemByName('Title').AsString, IsEncode);
        lvDest.Add(ParseOption(lvData.ItemByName('SelectedItems')));
        lvDest.ForcePath('Answer').AsString := lvData.ItemByName('Answer').AsString.Trim;
        lvItemData := lvDest.AsString.Trim;
      finally
        lvDest.Free;
      end;

      lvItemInfo := TQMsgPack.Create;
      with lvItemInfo do
      begin
        Add('FItemID', lvID);
        Add('FItemCatalogID', ASubjectID + ':' + lvChapterID);
        Add('FItemTypeID', lvItemTypeID + ':' + lvItemType);
        Add('FItemData', lvItemData);
        Add('FFavorite', lvFavorite);
        Add('FHotspot', False);
        Add('FFallible', False);
        Add('FNote', '');
        Add('FExplain', lvExplain);
      end;
      AList.Add(lvItemInfo);
    end;
  except
    ParseDataUnknow(ASubjectID, AData, AList, IsEncode);
  end;
end;

procedure TSourceModule_KN.ParseDataA3(const ASubjectID: string; var AData: TQJson; var AList: TQMsgPackList; const IsEncode: Boolean);
var
  I, J: Integer;
  lvData, lvSubData, lvDest: TQJson;
  lvItemInfo: TQMsgPack;
  lvID, lvSubID, lvChapterID, lvTitle, lvItemTypeID, lvItemType, lvExplain, lvNote: string;
  lvItemData: string;
  lvFavorite: Boolean;
begin
  try
    lvItemType := AData.ItemByName('Style').AsString.Trim;
    lvItemTypeID := AData.ItemByName('Type').AsString.Trim;

    for I := 0 to AData.ItemByName('TestItems').Count - 1 do
    begin
      lvData := AData.ItemByName('TestItems').Items[I];
      //
      lvID := lvData.ItemByName('AllTestID').AsString.Trim;
      lvChapterID := Format('%.4d', [lvData.ItemByName('CptID').AsInteger]);
      lvFavorite := lvData.ItemByName('IsFav').AsBoolean;
      lvNote := lvData.ItemByName('UserNoteContent').AsString.Trim;
      lvTitle := lvData.ItemByName('FrontTitle').AsString.Trim;
      //
      for J := 0 to lvData.ItemByName('A3TestItems').Count - 1 do
      begin

        lvSubData := lvData.ItemByName('A3TestItems').Items[J];
        lvSubID := lvSubData.ItemByName('A3TestItemID').AsString.Trim;
        lvExplain := lvSubData.ItemByName('Explain').AsString.Trim;

        lvDest := TQJson.Create;
        try
          lvDest.ForcePath('Title').AsString := Decode_KSBNew(lvTitle, IsEncode);
          lvDest.ForcePath('ChildTitle').AsString := Decode_KSBNew(lvSubData.ItemByName('Title').AsString, IsEncode);
          lvDest.Add(ParseOption(lvSubData.ItemByName('SelectedItems')));
          lvDest.ForcePath('Answer').AsString := lvSubData.ItemByName('Answer').AsString.Trim;
          lvItemData := lvDest.AsString.Trim;
        finally
          lvDest.Free;
        end;

        lvItemInfo := TQMsgPack.Create;
        with lvItemInfo do
        begin
          Add('FItemID', lvID + '_' + lvSubID);
          Add('FItemCatalogID', ASubjectID + ':' + lvChapterID);
          Add('FItemTypeID', lvItemTypeID + ':' + lvItemType);
          Add('FItemData', lvItemData);
          Add('FFavorite', lvFavorite);
          Add('FHotspot', False);
          Add('FFallible', False);
          Add('FNote', '');
          Add('FExplain', lvExplain);
        end;
        AList.Add(lvItemInfo);
      end;
    end;
  except
    ParseDataUnknow(ASubjectID, AData, AList, IsEncode);
  end;
end;

procedure TSourceModule_KN.ParseDataUnknow(const ASubjectID: string; var AData: TQJson; var AList: TQMsgPackList; const IsEncode: Boolean);
var
  I: Integer;
  lvItemInfo: TQMsgPack;
  lvID, lvChapterID, lvItemType, lvItemTypeID: string;
begin
  lvItemType := AData.ItemByName('Style').AsString.Trim;
  lvItemTypeID := AData.ItemByName('Type').AsString.Trim;
  for I := 0 to AData.ItemByName('TestItems').Count - 1 do
  begin
    lvID := AData.ItemByName('TestItems').Items[I].ItemByName('AllTestID').AsString.Trim;
    lvChapterID := Format('%.4d', [AData.ItemByName('TestItems').Items[I].ItemByName('CptID').AsInteger]);
    lvItemInfo := TQMsgPack.Create;
    with lvItemInfo do
    begin
      Add('FItemID', lvID);
      Add('FItemCatalogID', ASubjectID + ':' + lvChapterID);
      Add('FItemTypeID', lvItemTypeID + ':' + lvItemType);
      Add('FItemData', AData.ItemByName('TestItems').Items[I].AsString);
      Add('FFavorite', False);
      Add('FHotspot', False);
      Add('FFallible', False);
      Add('FNote', '题型未知');
      Add('FExplain', '');
    end;
    AList.Add(lvItemInfo);
  end;
end;

function TSourceModule_KN.ParseDataX(const ASubjectID: string; var AData: TQJson; var AList: TQMsgPackList; const IsEncode: Boolean): string;
var
  I: Integer;
  lvData, lvDest: TQJson;
  lvItemInfo: TQMsgPack;
  lvID, lvChapterID, lvItemTypeID, lvItemType, lvExplain, lvNote: string;
  lvItemData: string;
  lvFavorite: Boolean;
begin
  try
    lvItemType := AData.ItemByName('Style').AsString.Trim;
    lvItemTypeID := AData.ItemByName('Type').AsString.Trim;
    for I := 0 to AData.ItemByName('TestItems').Count - 1 do
    begin
      lvData := AData.ItemByName('TestItems').Items[I];
      lvID := lvData.ItemByName('AllTestID').AsString.Trim;
      lvChapterID := Format('%.4d', [lvData.ItemByName('CptID').AsInteger]);
      lvFavorite := lvData.ItemByName('IsFav').AsBoolean;
      lvExplain := lvData.ItemByName('Explain').AsString.Trim;
      lvNote := lvData.ItemByName('UserNoteContent').AsString.Trim;

      lvDest := TQJson.Create;
      try
        lvDest.ForcePath('Title').AsString := Decode_KSBNew(lvData.ItemByName('Title').AsString.Trim, IsEncode);
        lvDest.Add(ParseOption(lvData.ItemByName('SelectedItems')));
        lvDest.ForcePath('Answer').AsString := lvData.ItemByName('Answer').AsString.Trim;
        lvItemData := lvDest.AsString.Trim;
      finally
        lvDest.Free;
      end;

      lvItemInfo := TQMsgPack.Create;
      with lvItemInfo do
      begin
        Add('FItemID', lvID);
        Add('FItemCatalogID', ASubjectID + ':' + lvChapterID);
        Add('FItemTypeID', lvItemTypeID + ':' + lvItemType);
        Add('FItemData', lvItemData);
        Add('FFavorite', lvFavorite);
        Add('FHotspot', False);
        Add('FFallible', False);
        Add('FNote', '');
        Add('FExplain', lvExplain);
      end;
      AList.Add(lvItemInfo);
    end;
  except
    ParseDataUnknow(ASubjectID, AData, AList, IsEncode);
  end;
end;

procedure TSourceModule_KN.ParseItemData(const ASubjectID, AData: string; var AList: TQMsgPackList);
var
  lvJson, lvStyleJson, lvItemJson: TQJson;
  lvStytle: string;
  lvEncode: Boolean;
  I: Integer;
begin
  lvJson := TQJson.Create;
  try
    lvJson.Parse(AData);
    if Assigned(lvJson.ItemByPath('data.encoded')) then
      lvEncode := lvJson.ItemByPath('data.encoded').AsBoolean
    else
      lvEncode := False;

    lvStyleJson := lvJson.ItemByPath('data.test.StyleItems');
    for I := 0 to lvStyleJson.Count - 1 do
    begin
      lvItemJson := lvStyleJson.Items[I];
      lvStytle := lvItemJson.ItemByPath('Type').AsString;

      if lvStytle = 'ATEST' then
        ParseDataA(ASubjectID, lvItemJson, AList, lvEncode)
      else if lvStytle = 'A3TEST' then
        ParseDataA3(ASubjectID, lvItemJson, AList, lvEncode)
      else if lvStytle = 'XTEST' then
        ParseDataX(ASubjectID, lvItemJson, AList, lvEncode)
      else // 未知题型
        ParseDataUnknow(ASubjectID, lvItemJson, AList, lvEncode);
    end;
  finally
    lvJson.Free;
  end;

end;

function TSourceModule_KN.ParseOption(AData: TQJson): TQJson;
const
  S = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
var
  I: Integer;
  lvNode: TQJson;
begin
  lvNode := TQJson.Create;
  try
    lvNode := lvNode.Add('Option');
    for I := 0 to AData.Count - 1 do
    begin
      lvNode.Add(S[I + 1]).AsString := AData.Items[I].ItemByName('Content').AsString.Trim;
    end;
  finally
    Result := lvNode;
  end;
end;

function TSourceModule_KN.SplitSubjectID(const AFullSubjectID: string): string;
var
  lvSplitCharPos: Integer;
begin
  Result := Copy(AFullSubjectID, 0, Pos(':', AFullSubjectID) - 1);
end;

end.

