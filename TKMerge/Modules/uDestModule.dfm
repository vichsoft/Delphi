object DestModule: TDestModule
  OldCreateOrder = False
  Height = 330
  Width = 372
  object con: TUniConnection
    ProviderName = 'SQL Server'
    Pooling = True
    Left = 64
    Top = 48
  end
  object MsSqlProvider: TSQLServerUniProvider
    Left = 88
    Top = 120
  end
  object qry: TUniQuery
    Connection = con
    Left = 120
    Top = 48
  end
end
