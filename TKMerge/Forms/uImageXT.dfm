object frmImageXT: TfrmImageXT
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = #22270#29255#23548#20837'-'#20064#39064#38598
  ClientHeight = 569
  ClientWidth = 931
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnStart: TcxButton
    Left = 0
    Top = 544
    Width = 931
    Height = 25
    Align = alBottom
    Caption = #24320#22987#23548#20837#22270#29255
    TabOrder = 0
    OnClick = btnStartClick
  end
  object lblFinishedTime: TcxLabel
    Left = 490
    Top = 2
    Caption = #23436#25104#26102#38388':'
  end
  object lblFinishedCount: TcxLabel
    Left = 490
    Top = 25
    Caption = #23436#25104#25968#37327':'
  end
  object lblStartTime: TcxLabel
    Left = 7
    Top = 2
    Caption = #24320#22987#26102#38388':'
  end
  object lblImageCount: TcxLabel
    Left = 7
    Top = 25
    Caption = #22270#29255#25968#37327':'
  end
  object mmoImageData: TMemo
    Left = 490
    Top = 48
    Width = 433
    Height = 490
    ScrollBars = ssVertical
    TabOrder = 5
    WordWrap = False
  end
  object mmoImageUrl: TMemo
    Left = 8
    Top = 48
    Width = 474
    Height = 490
    ScrollBars = ssBoth
    TabOrder = 6
    WordWrap = False
  end
  object mtImage: TkbmMemTable
    DesignActivation = True
    AttachedAutoRefresh = True
    AttachMaxCount = 1
    FieldDefs = <>
    IndexDefs = <>
    SortOptions = []
    PersistentBackup = False
    ProgressFlags = [mtpcLoad, mtpcSave, mtpcCopy]
    LoadedCompletely = False
    SavedCompletely = False
    FilterOptions = []
    Version = '7.74.00 Professional Edition'
    LanguageID = 0
    SortID = 0
    SubLanguageID = 1
    LocaleID = 1024
    Left = 248
    Top = 200
  end
end
