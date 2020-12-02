unit uSourceModule;

interface

uses
  System.SysUtils, System.Classes, Data.DB, MemDS, DBAccess, Uni, UniProvider,
  SQLiteUniProvider, kbmMemTable, uType;

type
  TSourceModule = class(TDataModule)
    conn: TUniConnection;
    SqliteProvider: TSQLiteUniProvider;
    qry: TUniQuery;
  public
    procedure SetDataBase(const ADataBase: string);
    procedure GetSubjectList(var AList: TkbmMemTable); virtual; abstract;
    procedure GetCatalogList(const ASubjectID: string; var AList: TkbmMemTable); virtual; abstract;
  end;

implementation

{$R *.dfm}

procedure TSourceModule.SetDataBase(const ADataBase: string);
begin
  conn.Database := ADataBase;
end;

end.

