inherited SourceModule_XT: TSourceModule_XT
  OldCreateOrder = True
  inherited conn: TUniConnection
    Pooling = True
  end
  inherited qry: TUniQuery
    SpecificOptions.Strings = (
      'SQLite.FetchAll=True')
  end
end
