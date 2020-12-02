unit uDestModule;

interface

uses
  System.SysUtils, System.Classes, UniProvider, SQLServerUniProvider, Data.DB,
  DBAccess, Uni,
  //
  qmsgpack, MemDS, kbmMemTable;

type
  TDestModule = class(TDataModule)
    con: TUniConnection;
    qry: TUniQuery;
    MsSqlProvider: TSQLServerUniProvider;
  private
    FDatabase: string;
    FHost: string;
    FPassWord: string;
    FUserName: string;
  public
    procedure AddSubject(AItem: TQMsgPack);
    procedure AddCatalog(AItem: TQMsgPack);
    procedure AddImage(AItem: TQMsgPack);
    procedure AddItem(AItem: TQMsgPack); overload;
    procedure AddItem(AItem: TQMsgPack; const ATable: string); overload;
    function Connect: Boolean;
    procedure GetItemImageList(var AList: TkbmMemTable; const Offset: Integer = 0; const Pagesize: Integer = 1000);
    procedure UpdateImage(const AID: string; var AData: TMemoryStream);
    property Database: string write FDatabase;
    property Host: string write FHost;
    property PassWord: string write FPassWord;
    property UserName: string write FUserName;
  end;

var
  DestModule: TDestModule;

implementation


{$R *.dfm}

function TDestModule.Connect: Boolean;
begin
  con.Server := FHost;
  con.Username := FUserName;
  con.Password := FPassWord;
  con.Database := FDatabase;
  try
    con.Connect;
    Result := con.Connected;
  except
    Result := False;
  end;
end;

procedure TDestModule.AddSubject(AItem: TQMsgPack);
var
  m_sql: string;
  m_field: string;
  m_value: string;
begin
  m_field := 'FID,FSubject,FSource';
  m_value := ':FID,:FSubject,:FSource';
  m_sql := Format('Insert  INTO  T_Subject (%s)  Values (%s)', [m_field, m_value]);

  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add(m_sql);
      ParamByName('FID').AsString := AItem.ItemByName('SubjectID').AsString;
      ParamByName('FSubject').AsString := AItem.ItemByName('SubjectTitle').AsString;
      ParamByName('FSource').AsString := AItem.ItemByName('SubjectParent').AsString;
      Execute;
    finally
      Close;
    end;
  end;
end;

procedure TDestModule.AddCatalog(AItem: TQMsgPack);
var
  m_sql: string;
  m_field: string;
  m_value: string;
begin
  m_field := 'FID,FCatalog,FCatalogType,FSubjectID';
  m_value := ':FID,:FCatalog,:FCatalogType,:FSubjectID';
  m_sql := Format('Insert  INTO  T_Catalog (%s)  Values (%s)', [m_field, m_value]);

  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add(m_sql);
      //为保证章节编号唯一，将科目编号加在前面
      ParamByName('FID').AsString := AItem.ItemByName('CatalogSubjectID').AsString + ':' + AItem.ItemByName('CatalogID').AsString;
      ParamByName('FCatalog').AsString := AItem.ItemByName('CatalogTitle').AsString;
      ParamByName('FCatalogType').AsString := AItem.ItemByName('CatalogType').AsString;
      ParamByName('FSubjectID').AsString := AItem.ItemByName('CatalogSubjectID').AsString;
      Execute;
    finally
      Close;
    end;
  end;
end;

procedure TDestModule.AddImage(AItem: TQMsgPack);
var
  m_sql: string;
  m_field: string;
  m_value: string;
begin
  m_field := 'FID,FItemID,FCatalogID,FImageTag,FImageUrl,FImageName';
  m_value := ':FID,:FItemID,:FCatalogID,:FImageTag,:FImageUrl,:FImageName';
  m_sql := Format('Insert  INTO  T_Image (%s)  Values (%s)', [m_field, m_value]);

  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add(m_sql);
      ParamByName('FID').AsString := AItem.ItemByName('ImageID').AsString;
      ParamByName('FItemID').AsString := AItem.ItemByName('ItemID').AsString;
      ParamByName('FCatalogID').AsString := AItem.ItemByName('CatalogID').AsString;
      ParamByName('FImageTag').AsString := AItem.ItemByName('ImageTag').AsString;
      ParamByName('FImageUrl').AsString := AItem.ItemByName('ImageUrl').AsString;
      ParamByName('FImageName').AsString := AItem.ItemByName('ImageName').AsString;
      Execute;
    finally
      Close;
    end;
  end;
end;

procedure TDestModule.AddItem(AItem: TQMsgPack);
var
  m_sql: string;
  m_field: string;
  m_value: string;
begin
  m_field := 'FID,FCatalogID,FItemTypeID,FItemData,FFavorite,FHotspot,FFallible,FNote,FExplain';
  m_value := ':FID,:FCatalogID,:FItemTypeID,:FItemData,:FFavorite,:FHotspot,:FFallible,:FNote,:FExplain';
  m_sql := Format('Insert  INTO  T_Item (%s)  Values (%s)', [m_field, m_value]);

  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add(m_sql);
      ParamByName('FID').AsString := AItem.ItemByName('FItemID').AsString;
      ParamByName('FCatalogID').AsString := AItem.ItemByName('FItemCatalogID').AsString;
      ParamByName('FItemTypeID').AsString := AItem.ItemByName('FItemTypeID').AsString;
      ParamByName('FItemData').AsString := AItem.ItemByName('FItemData').AsString;
      ParamByName('FFavorite').AsBoolean := AItem.ItemByName('FFavorite').AsBoolean;
      ParamByName('FHotspot').AsBoolean := AItem.ItemByName('FHotspot').AsBoolean;
      ParamByName('FFallible').AsBoolean := AItem.ItemByName('FFallible').AsBoolean;
      ParamByName('FNote').AsString := AItem.ItemByName('FNote').AsString;
      ParamByName('FExplain').AsString := AItem.ItemByName('FExplain').AsString;
      Execute;
    finally
      Close;
    end;
  end;
end;

//专门给考试宝典中的热点题目和易错题目用的
procedure TDestModule.AddItem(AItem: TQMsgPack; const ATable: string);
var
  m_sql: string;
  m_field: string;
  m_value: string;
begin
  if ATable = 'All' then
  begin
    AddItem(AItem);
    Exit;
  end;

  m_field := 'FID,FCatalogID,FItemTypeID,FItemData,FFavorite,FHotspot,FFallible,FNote,FExplain';
  m_value := ':FID,:FCatalogID,:FItemTypeID,:FItemData,:FFavorite,:FHotspot,:FFallible,:FNote,:FExplain';
  m_sql := Format('Insert  INTO  %s (%s)  Values (%s)', [ATable, m_field, m_value]);
  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add(m_sql);
      ParamByName('FID').AsString := AItem.ItemByName('FItemID').AsString;
      ParamByName('FCatalogID').AsString := AItem.ItemByName('FItemCatalogID').AsString;
      ParamByName('FItemTypeID').AsString := AItem.ItemByName('FItemTypeID').AsString;
      ParamByName('FItemData').AsString := AItem.ItemByName('FItemData').AsString;
      ParamByName('FFavorite').AsBoolean := AItem.ItemByName('FFavorite').AsBoolean;
      if ATable = 'T_Hotspot' then
      begin
        ParamByName('FHotspot').AsBoolean := True;
        ParamByName('FFallible').AsBoolean := AItem.ItemByName('FFallible').AsBoolean;
      end
      else if ATable = 'T_Fallible' then
      begin
        ParamByName('FHotspot').AsBoolean := AItem.ItemByName('FHotspot').AsBoolean;
        ParamByName('FFallible').AsBoolean := True;
      end;
      ParamByName('FNote').AsString := AItem.ItemByName('FNote').AsString;
      ParamByName('FExplain').AsString := AItem.ItemByName('FExplain').AsString;
      Execute;
    finally
      Close;
    end;
  end;
end;

procedure TDestModule.GetItemImageList(var AList: TkbmMemTable; const Offset: Integer = 0; const Pagesize: Integer = 1000);
begin
  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('Select *, 0 AS FOrder from T_Item where [FItemData] LIKE ''%jpg%'' OR [FItemData] LIKE ''%gif%'' ORDER BY FOrder ');
      SQL.Add(Format('OFFSET %d ROWS FETCH NEXT %d ROWS ONLY', [Offset, Pagesize]));
      Open;
      AList.LoadFromDataSet(qry, [mtcpoStructure]);
    finally
      Close;
    end;
  end;
end;

procedure TDestModule.UpdateImage(const AID: string; var AData: TMemoryStream);
begin
  with qry do
  begin
    try
      Close;
      SQL.Clear;
      SQL.Add('Update T_Image set FImageData=:FImageData where FID=:FID');
      ParamByName('FID').AsString := AID;
      ParamByName('FImageData').LoadFromStream(AData, ftBlob);
      Execute;
    finally
      Close;
    end;
  end;
end;

end.

