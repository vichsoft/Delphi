object frmMergeKN: TfrmMergeKN
  Left = 549
  Top = 309
  Caption = #25968#25454#23548#20837'-'#32771#35797#23453#20856'('#26032#29256')'
  ClientHeight = 661
  ClientWidth = 978
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object wizard: TdxWizardControl
    Left = 0
    Top = 25
    Width = 978
    Height = 636
    Buttons.Back.Caption = #19978#19968#27493
    Buttons.Cancel.Visible = False
    Buttons.CustomButtons.Buttons = <>
    Buttons.Finish.Caption = #23436#25104
    Buttons.Help.Visible = False
    Buttons.Next.Caption = #19979#19968#27493
    Header.AssignedValues = [wchvDescriptionVisibility, wchvVisible]
    Header.DescriptionVisibility = wcevAlwaysHidden
    Header.Visible = wcevAlwaysHidden
    object wpageSubject: TdxWizardControlPage
      Header.AssignedValues = [wchvDescriptionVisibility]
      Header.DescriptionVisibility = wcevAlwaysHidden
      Header.Title = #31185#30446#21015#34920
      object tlSubject: TcxTreeList
        Left = 0
        Top = 0
        Width = 956
        Height = 540
        Align = alClient
        Bands = <
          item
          end>
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = False
        Navigator.Buttons.CustomButtons = <>
        OptionsData.Editing = False
        OptionsSelection.CellSelect = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GridLines = tlglBoth
        OptionsView.Indicator = True
        TabOrder = 0
        object tcolSubjectID: TcxTreeListColumn
          Caption.Text = #32534#21495
          DataBinding.ValueType = 'String'
          Width = 116
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolSubjectTitle: TcxTreeListColumn
          Caption.Text = #26631#39064
          DataBinding.ValueType = 'String'
          Width = 487
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolSubjectName: TcxTreeListColumn
          Caption.Text = #29238#28857
          DataBinding.ValueType = 'String'
          Width = 100
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
      object btnGetSubjectList: TcxButton
        Left = 0
        Top = 540
        Width = 956
        Height = 25
        Align = alBottom
        Caption = #33719#21462#31185#30446#21015#34920'('#24517#39035')'
        Colors.Default = clRed
        TabOrder = 1
        OnClick = btnGetSubjectListClick
      end
    end
    object wpageCatalog: TdxWizardControlPage
      Header.AssignedValues = [wchvDescriptionVisibility]
      Header.DescriptionVisibility = wcevAlwaysHidden
      Header.Title = #31456#33410#21015#34920
      object tlCatalog: TcxTreeList
        Left = 0
        Top = 0
        Width = 956
        Height = 540
        Align = alClient
        Bands = <
          item
          end>
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = False
        Navigator.Buttons.CustomButtons = <>
        OptionsView.Buttons = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GridLines = tlglBoth
        OptionsView.Indicator = True
        OptionsView.ShowRoot = False
        TabOrder = 0
        object tcolCatalogSubjectID: TcxTreeListColumn
          Caption.Text = #31185#30446#32534#21495
          DataBinding.ValueType = 'String'
          Width = 105
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolCatalogID: TcxTreeListColumn
          Caption.Text = #31456#33410#32534#21495
          DataBinding.ValueType = 'String'
          Width = 130
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolCatalogTitle: TcxTreeListColumn
          Caption.Text = #26631#39064
          DataBinding.ValueType = 'String'
          Width = 378
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolCatalogType: TcxTreeListColumn
          Caption.Text = #31867#22411
          DataBinding.ValueType = 'String'
          Width = 164
          Position.ColIndex = 3
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolCatalogSubjectTitle: TcxTreeListColumn
          Caption.Text = #31185#30446#21517#31216
          DataBinding.ValueType = 'String'
          Width = 163
          Position.ColIndex = 4
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
      object btnGetCatalogList: TcxButton
        Left = 0
        Top = 540
        Width = 956
        Height = 25
        Align = alBottom
        Caption = #33719#21462#31456#33410#21015#34920'('#27979#35797')'
        TabOrder = 1
        OnClick = btnGetCatalogListClick
      end
    end
    object wpageItem: TdxWizardControlPage
      Header.Title = #39064#30446#21015#34920
      object btnGetItemList: TcxButton
        Left = 0
        Top = 540
        Width = 956
        Height = 25
        Align = alBottom
        Caption = #33719#21462#39064#30446#21015#34920'('#27979#35797')'
        TabOrder = 0
        OnClick = btnGetItemListClick
      end
      object tlItem: TcxTreeList
        Left = 0
        Top = 0
        Width = 956
        Height = 540
        Align = alClient
        Bands = <
          item
          end>
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = False
        LookAndFeel.ScrollbarMode = sbmClassic
        Navigator.Buttons.CustomButtons = <>
        OptionsView.Buttons = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GridLines = tlglBoth
        OptionsView.Indicator = True
        OptionsView.ShowRoot = False
        TabOrder = 1
        object tcolItemID: TcxTreeListColumn
          Caption.Text = #39064#30446#32534#21495' '
          DataBinding.ValueType = 'String'
          Width = 104
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolItemCatalogID: TcxTreeListColumn
          Caption.Text = #30446#24405#32534#21495
          DataBinding.ValueType = 'String'
          Width = 58
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolItemTypeID: TcxTreeListColumn
          Caption.Text = #39064#30446#31867#22411
          DataBinding.ValueType = 'String'
          Width = 63
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolItemData: TcxTreeListColumn
          PropertiesClassName = 'TcxMemoProperties'
          Properties.ReadOnly = True
          Caption.Text = #39064#30446#20869#23481
          DataBinding.ValueType = 'String'
          Width = 412
          Position.ColIndex = 3
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolItemFavorite: TcxTreeListColumn
          PropertiesClassName = 'TcxCheckBoxProperties'
          Caption.Text = #25910#34255#39064#30446
          DataBinding.ValueType = 'String'
          Width = 71
          Position.ColIndex = 4
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolItemHotspot: TcxTreeListColumn
          PropertiesClassName = 'TcxCheckBoxProperties'
          Caption.Text = #28909#28857#39064#30446
          DataBinding.ValueType = 'String'
          Width = 73
          Position.ColIndex = 5
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolItemFallible: TcxTreeListColumn
          PropertiesClassName = 'TcxCheckBoxProperties'
          Caption.Text = #26131#38169#39064#30446
          DataBinding.ValueType = 'String'
          Width = 57
          Position.ColIndex = 6
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolItemNote: TcxTreeListColumn
          Caption.Text = #31508#35760
          DataBinding.ValueType = 'String'
          Width = 35
          Position.ColIndex = 7
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolItemExplain: TcxTreeListColumn
          Caption.Text = #35299#26512
          DataBinding.ValueType = 'String'
          Width = 33
          Position.ColIndex = 8
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
    end
    object wpageMerge: TdxWizardControlPage
      Header.Title = #21512#24182#25968#25454#24211
      object mmoCatalog: TMemo
        Left = 256
        Top = 48
        Width = 297
        Height = 460
        ScrollBars = ssVertical
        TabOrder = 0
        WordWrap = False
      end
      object mmoSubject: TMemo
        Left = 0
        Top = 48
        Width = 250
        Height = 460
        ScrollBars = ssVertical
        TabOrder = 1
        WordWrap = False
      end
      object lblCatalogCount: TcxLabel
        Left = 256
        Top = 25
        Caption = #31456#33410#25968#37327':'
      end
      object lblItemCount: TcxLabel
        Left = 568
        Top = 25
        Caption = #39064#30446#25968#37327':'
      end
      object mmoItem: TMemo
        Left = 568
        Top = 48
        Width = 385
        Height = 460
        ScrollBars = ssVertical
        TabOrder = 4
        WordWrap = False
      end
      object lblStart: TcxLabel
        Left = 256
        Top = 2
        Caption = #24320#22987#26102#38388':'
      end
      object lblFinished: TcxLabel
        Left = 568
        Top = 3
        Caption = #23436#25104#26102#38388':'
      end
      object lblSubjectCount: TcxLabel
        Left = 0
        Top = 24
        Caption = #31185#30446#25968#37327':'
      end
      object lblRange: TcxLabel
        Left = 0
        Top = 2
        Caption = #33539#22260'(0-1200):'
      end
      object edtStart: TcxSpinEdit
        Left = 80
        Top = 0
        Properties.Increment = 100.000000000000000000
        Properties.LargeIncrement = 100.000000000000000000
        TabOrder = 9
        Width = 65
      end
      object lblTo: TcxLabel
        Left = 151
        Top = 2
        Caption = #21040
      end
      object edtEnd: TcxSpinEdit
        Left = 176
        Top = 0
        Properties.Increment = 100.000000000000000000
        Properties.LargeIncrement = 100.000000000000000000
        TabOrder = 11
        Width = 65
      end
      object lbHint: TcxLabel
        Left = 0
        Top = 548
        Align = alBottom
        Caption = #25552#31034#65306'1'#12289#24320#22987#21512#24182#21069#24517#39035#20445#25345#35299#30721#31383#21475#21487#35265#24182#32622#21069'         2'#12289#28165#31354#21407#26377#25968#25454#24211
        Style.LookAndFeel.NativeStyle = False
        Style.TextColor = clRed
        StyleDisabled.LookAndFeel.NativeStyle = False
        StyleFocused.LookAndFeel.NativeStyle = False
        StyleHot.LookAndFeel.NativeStyle = False
      end
      object pnlRange: TPanel
        Left = 0
        Top = 513
        Width = 956
        Height = 35
        Align = alBottom
        TabOrder = 13
        object cbbRange: TcxComboBox
          Left = 1
          Top = 1
          Align = alLeft
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            #25152#26377#39064#30446
            #28909#28857#39064#30446
            #26131#38169#39064#30446)
          Style.LookAndFeel.NativeStyle = False
          Style.ButtonTransparency = ebtAlways
          StyleDisabled.LookAndFeel.NativeStyle = False
          StyleFocused.LookAndFeel.NativeStyle = False
          StyleHot.LookAndFeel.NativeStyle = False
          TabOrder = 0
          Text = #25152#26377#39064#30446
          Width = 81
        end
        object btnMerge: TcxButton
          Left = 82
          Top = 1
          Width = 873
          Height = 33
          Align = alClient
          Caption = #24320#22987#21512#24182#39064#24211
          TabOrder = 1
          OnClick = btnMergeClick
        end
      end
    end
  end
  object pnlFilePath: TPanel
    Left = 0
    Top = 0
    Width = 978
    Height = 25
    Align = alTop
    TabOrder = 1
    object edtTK: TcxButtonEdit
      Left = 579
      Top = 1
      Align = alRight
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end
        item
          Caption = #36830#25509#25968#25454#24211
          Kind = bkText
        end>
      Properties.OnButtonClick = edtFilePropertiesButtonClick
      Style.LookAndFeel.NativeStyle = False
      StyleDisabled.LookAndFeel.NativeStyle = False
      StyleFocused.LookAndFeel.NativeStyle = False
      StyleHot.LookAndFeel.NativeStyle = False
      TabOrder = 0
      Text = 'P:\TK\KN\TK.db'
      Width = 398
    end
    object edtSource: TcxButtonEdit
      Left = 1
      Top = 1
      Align = alLeft
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = edtSourcePropertiesButtonClick
      Style.LookAndFeel.NativeStyle = False
      StyleDisabled.LookAndFeel.NativeStyle = False
      StyleFocused.LookAndFeel.NativeStyle = False
      StyleHot.LookAndFeel.NativeStyle = False
      TabOrder = 1
      Text = 'P:\TK\KN\'#20998#31867#21015#34920'.json'
      Width = 280
    end
    object edtSubject: TcxButtonEdit
      Left = 281
      Top = 1
      Align = alClient
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = edtSubjectPropertiesButtonClick
      Style.LookAndFeel.NativeStyle = False
      StyleDisabled.LookAndFeel.NativeStyle = False
      StyleFocused.LookAndFeel.NativeStyle = False
      StyleHot.LookAndFeel.NativeStyle = False
      TabOrder = 2
      Text = 'P:\TK\KN\'#39064#24211#21015#34920'.json'
      Width = 298
    end
  end
  object dlgOpen: TOpenDialog
    Left = 651
    Top = 128
  end
  object mt: TkbmMemTable
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
    Left = 707
    Top = 128
  end
end
