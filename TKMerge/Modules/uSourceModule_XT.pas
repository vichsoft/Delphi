unit uSourceModule_XT;

interface

uses
  System.SysUtils, System.Classes, uSourceModule, Data.DB, MemDS, DBAccess, Uni,
  UniProvider, SQLiteUniProvider, kbmMemTable, qjson;

type
  TSourceModule_XT = class(TSourceModule)
  private
    function ParseA1Data(const AData: string): string;
    function ParseA2Data(const AData: string): string;
    function ParseA3Data(const AData: string): string;
    function ParseBData(const AData: string): string;
    function ParseOption(const AData: string): TQJson;
  public
    procedure GetSubjectList(var AList: TkbmMemTable); override;
    procedure GetCatalogList(const ASubjectID: string; var AList: TkbmMemTable); override;
    procedure GetItemList(const ACatatlogID: string; var AList: TkbmMemTable);
    function ParseCatalogTitle(const ATitle: string): string;
    function ParseCatalogType(const AData: string): string;
    function ParseItemData(const AType, AData: string): string;
    function ParseItemType(const AType: string): string;
  end;

implementation

{$R *.dfm}

procedure TSourceModule_XT.GetSubjectList(var AList: TkbmMemTable);
begin
  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('Select * from T_Exam where FType=''Book'' or FType=''Source'' ');
      Open;
      AList.LoadFromDataSet(qry, [mtcpoStructure]);
    finally
      Close;
    end;
  end;
end;

procedure TSourceModule_XT.GetCatalogList(const ASubjectID: string; var AList: TkbmMemTable);
begin
  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('Select * from T_Exam where FParentID=:FParentID');
      ParamByName('FParentID').AsString := ASubjectID;
      Open;
      AList.LoadFromDataSet(qry, [mtcpoStructure]);
    finally
      Close;
    end;
  end;
end;

procedure TSourceModule_XT.GetItemList(const ACatatlogID: string; var AList: TkbmMemTable);
begin
  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('Select * from T_Test where FChapterID=:FChapterID');
      ParamByName('FChapterID').AsString := ACatatlogID;
      Open;
      AList.LoadFromDataSet(qry, [mtcpoStructure]);
    finally
      Close;
    end;
  end;
end;

function TSourceModule_XT.ParseItemType(const AType: string): string;
begin
  if AType = '1' then
    Result := 'A1'
  else if AType = '11' then
    Result := 'A2'
  else if AType = '3' then
    Result := 'A3'
  else if AType = '20' then
    Result := 'B';
end;

function TSourceModule_XT.ParseItemData(const AType, AData: string): string;
begin
  if AType = '1' then
    Result := ParseA1Data(AData)
  else if AType = '11' then
    Result := ParseA2Data(AData)
  else if AType = '3' then
    Result := ParseA3Data(AData)
  else if AType = '20' then
    Result := ParseBData(AData);
end;

function TSourceModule_XT.ParseOption(const AData: string): TQJson;
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
      lvNode.Add(S[I + 1]).AsString := lvSource.Items[I].AsString.Trim;
    end;
    Result := lvNode;
  finally
    lvSource.Free;
  end;
end;

function TSourceModule_XT.ParseA1Data(const AData: string): string;
var
  lvSource, lvDest: TQJson;
begin
  lvDest := TQJson.Create;
  lvSource := TQJson.Create;
  try
    lvSource.Parse(AData);
    lvDest.ForcePath('Title').AsString := lvSource.ItemByName('title').AsString.Trim;
    lvDest.Add(ParseOption(lvSource.ItemByName('option').AsString));
    lvDest.ForcePath('Answer').AsString := lvSource.ItemByName('analyse').AsString.Trim;
    Result := lvDest.AsString;
  finally
    lvDest.Free;
    lvSource.Free;
  end;
end;

function TSourceModule_XT.ParseA2Data(const AData: string): string;
var
  lvSource, lvDest: TQJson;
begin
  lvDest := TQJson.Create;
  lvSource := TQJson.Create;

  try
    lvSource.Parse(AData);
    lvDest.ForcePath('Title').AsString := lvSource.ItemByName('title').AsString.Trim;
    lvDest.Add(ParseOption(lvSource.ItemByName('option').AsString));
    lvDest.ForcePath('Answer').AsString := lvSource.ItemByName('analyse').AsString.Trim;
    Result := lvDest.AsString;
  finally
    lvDest.Free;
    lvSource.Free;
  end;
end;

function TSourceModule_XT.ParseA3Data(const AData: string): string;
var
  lvSource, lvDest: TQJson;
begin
  lvDest := TQJson.Create;
  lvSource := TQJson.Create;

  try
    lvSource.Parse(AData);
    lvDest.ForcePath('Title').AsString := lvSource.ItemByName('title').AsString.Trim;
    lvDest.ForcePath('ChildTitle').AsString := lvSource.ItemByName('children').Items[0].ItemByName('title').AsString.Trim;
    lvDest.Add(ParseOption(lvSource.ItemByName('children').Items[0].ItemByName('option').AsString));
    lvDest.ForcePath('Answer').AsString := lvSource.ItemByName('children').Items[0].ItemByName('analyse').AsString.Trim;
    Result := lvDest.AsString;
  finally
    lvDest.Free;
    lvSource.Free;
  end;
end;

function TSourceModule_XT.ParseBData(const AData: string): string;
var
  lvSource, lvDest: TQJson;
begin
  lvSource := TQJson.Create;
  lvDest := TQJson.Create;
  try
    lvSource.Parse(AData);
    lvDest.ForcePath('Title').AsString := lvSource.ItemByName('title').AsString.Trim;
    lvDest.ForcePath('ChildTitle').AsString := lvSource.ItemByName('children').Items[0].ItemByName('title').AsString.Trim;
    lvDest.Add(ParseOption(lvSource.ItemByName('children').Items[0].ItemByName('option').AsString));
    lvDest.ForcePath('Answer').AsString := lvSource.ItemByName('children').Items[0].ItemByName('analyse').AsString.Trim;
    Result := lvDest.AsString;
  finally
    lvDest.Free;
    lvSource.Free;
  end;
end;

function TSourceModule_XT.ParseCatalogType(const AData: string): string;
begin
  Result := 'T01';
  if Copy(LowerCase(AData), 1, 1) = 'm' then
    Result := 'T03';
end;

function TSourceModule_XT.ParseCatalogTitle(const ATitle: string): string;
begin
  if Copy(LowerCase(ATitle), 1, 1) = 'm' then
    Result := StringReplace(ATitle, 'm', 'ƒ£ƒ‚ ‘Ã‚', [rfReplaceAll])
  else
    Result := ATitle;
end;

end.

