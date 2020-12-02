inherited SourceModule_KO: TSourceModule_KO
  OldCreateOrder = True
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 245
  Width = 295
  inherited conn: TUniConnection
    Left = 56
    Top = 24
  end
  inherited SqliteProvider: TSQLiteUniProvider
    Left = 120
    Top = 88
  end
  inherited qry: TUniQuery
    SpecificOptions.Strings = (
      'SQLite.FetchAll=True')
    Left = 104
    Top = 24
  end
  object conItem: TUniConnection
    ProviderName = 'SQLite'
    Connected = True
    LoginPrompt = False
    Left = 56
    Top = 152
  end
  object qryItem: TUniQuery
    Connection = conItem
    ReadOnly = True
    Options.LongStrings = False
    SpecificOptions.Strings = (
      'SQLite.FetchAll=True')
    Left = 112
    Top = 152
  end
end
