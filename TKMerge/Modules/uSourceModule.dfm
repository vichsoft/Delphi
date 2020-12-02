object SourceModule: TSourceModule
  OldCreateOrder = False
  Height = 346
  Width = 488
  object conn: TUniConnection
    ProviderName = 'SQLite'
    Left = 184
    Top = 120
  end
  object SqliteProvider: TSQLiteUniProvider
    Left = 184
    Top = 192
  end
  object qry: TUniQuery
    Connection = conn
    Left = 176
    Top = 56
  end
end
