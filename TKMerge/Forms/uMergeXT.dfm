object frmMergeXT: TfrmMergeXT
  Left = 0
  Top = 0
  Caption = #25968#25454#23548#20837'-'#20064#39064#38598
  ClientHeight = 661
  ClientWidth = 978
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object wizard: TdxWizardControl
    Left = 0
    Top = 21
    Width = 978
    Height = 640
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
        Height = 544
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
        object tcolSubjectParentID: TcxTreeListColumn
          Visible = False
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
        Top = 544
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
        Height = 544
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
        OptionsView.IndicatorWidth = 35
        OptionsView.ShowRoot = False
        TabOrder = 0
        OnCustomDrawIndicatorCell = tlCatalogCustomDrawIndicatorCell
        object tcolCatalogID: TcxTreeListColumn
          Caption.Text = #32534#21495
          DataBinding.ValueType = 'String'
          Width = 123
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolCatalogTitle: TcxTreeListColumn
          Caption.Text = #26631#39064
          DataBinding.ValueType = 'String'
          Width = 468
          Position.ColIndex = 1
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
        object tcolCatalogType: TcxTreeListColumn
          Caption.Text = #31867#22411
          DataBinding.ValueType = 'String'
          Width = 100
          Position.ColIndex = 2
          Position.RowIndex = 0
          Position.BandIndex = 0
          Summary.FooterSummaryItems = <>
          Summary.GroupFooterSummaryItems = <>
        end
      end
      object btnGetCatalogList: TcxButton
        Left = 0
        Top = 544
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
        Top = 544
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
        Height = 544
        Align = alClient
        Bands = <
          item
          end>
        LookAndFeel.Kind = lfStandard
        LookAndFeel.NativeStyle = False
        LookAndFeel.ScrollbarMode = sbmClassic
        Navigator.Buttons.CustomButtons = <>
        OptionsView.CellAutoHeight = True
        OptionsView.Buttons = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GridLines = tlglBoth
        OptionsView.Indicator = True
        OptionsView.IndicatorWidth = 35
        OptionsView.ShowRoot = False
        TabOrder = 1
        OnCustomDrawIndicatorCell = tlCatalogCustomDrawIndicatorCell
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
      end
    end
    object wpageMerge: TdxWizardControlPage
      Header.Title = #21512#24182#25968#25454#24211
      object btnMerge: TcxButton
        Left = 0
        Top = 544
        Width = 956
        Height = 25
        Align = alBottom
        Caption = #24320#22987#21512#24182#39064#24211
        TabOrder = 0
        OnClick = btnMergeClick
      end
      object mmoCatalog: TMemo
        Left = 256
        Top = 48
        Width = 297
        Height = 490
        ScrollBars = ssVertical
        TabOrder = 1
        WordWrap = False
      end
      object mmoSubject: TMemo
        Left = 0
        Top = 48
        Width = 250
        Height = 490
        ScrollBars = ssVertical
        TabOrder = 2
        WordWrap = False
      end
      object lblSubjectCount: TcxLabel
        Left = 0
        Top = 25
        Caption = #31185#30446#25968#37327':'
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
        Height = 490
        ScrollBars = ssVertical
        TabOrder = 6
        WordWrap = False
      end
      object lblStart: TcxLabel
        Left = 0
        Top = 2
        Caption = #24320#22987#26102#38388':'
      end
      object lblFinished: TcxLabel
        Left = 256
        Top = 3
        Caption = #23436#25104#26102#38388':'
      end
    end
  end
  object edtFile: TcxButtonEdit
    Left = 0
    Top = 0
    Align = alTop
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
    TabOrder = 1
    Text = 'P:\TK\XT\TK.db'
    Width = 978
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
