object frmDbConnect: TfrmDbConnect
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #25968#25454#24211#36830#25509
  ClientHeight = 244
  ClientWidth = 288
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lbServer: TcxLabel
    Left = 8
    Top = 17
    Caption = #26381#21153#22120#65306
  end
  object edtServer: TcxTextEdit
    Left = 66
    Top = 15
    Style.LookAndFeel.NativeStyle = False
    StyleDisabled.LookAndFeel.NativeStyle = False
    StyleFocused.LookAndFeel.NativeStyle = False
    StyleHot.LookAndFeel.NativeStyle = False
    TabOrder = 1
    Text = 'localhost'
    Width = 215
  end
  object lbUserName: TcxLabel
    Left = 8
    Top = 57
    Caption = #29992#25143#21517#65306
  end
  object edtUserName: TcxTextEdit
    Left = 66
    Top = 55
    Style.LookAndFeel.NativeStyle = False
    StyleDisabled.LookAndFeel.NativeStyle = False
    StyleFocused.LookAndFeel.NativeStyle = False
    StyleHot.LookAndFeel.NativeStyle = False
    TabOrder = 3
    Text = 'sa'
    Width = 215
  end
  object lbPassWord: TcxLabel
    Left = 20
    Top = 105
    Caption = #23494#30721#65306
  end
  object edtPassWord: TcxTextEdit
    Left = 66
    Top = 103
    Style.LookAndFeel.NativeStyle = False
    StyleDisabled.LookAndFeel.NativeStyle = False
    StyleFocused.LookAndFeel.NativeStyle = False
    StyleHot.LookAndFeel.NativeStyle = False
    TabOrder = 5
    Text = 'sa'
    Width = 215
  end
  object lbDatabase: TcxLabel
    Left = 8
    Top = 161
    Caption = #25968#25454#24211#65306
  end
  object btnConnect: TcxButton
    Left = 88
    Top = 200
    Width = 89
    Height = 33
    Caption = #36830#25509
    TabOrder = 7
    OnClick = btnConnectClick
  end
  object cbbTK: TcxComboBox
    Left = 66
    Top = 160
    Properties.CharCase = ecUpperCase
    Properties.DropDownListStyle = lsEditFixedList
    Properties.Items.Strings = (
      'TK-XT'
      'TK-KO'
      'TK-KN'
      'TK-TEST')
    Properties.ReadOnly = False
    Style.LookAndFeel.NativeStyle = False
    Style.ButtonTransparency = ebtHideUnselected
    StyleDisabled.LookAndFeel.NativeStyle = False
    StyleFocused.LookAndFeel.NativeStyle = False
    StyleHot.LookAndFeel.NativeStyle = False
    TabOrder = 8
    Text = 'TK-XT'
    Width = 215
  end
end
