unit uDBConnect;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  dxSkinsCore, dxSkinsDefaultPainters, Vcl.Menus, Vcl.StdCtrls, cxButtons,
  cxTextEdit, cxLabel, cxMaskEdit, cxDropDownEdit;

type
  TfrmDbConnect = class(TForm)
    lbServer: TcxLabel;
    edtServer: TcxTextEdit;
    lbUserName: TcxLabel;
    edtUserName: TcxTextEdit;
    lbPassWord: TcxLabel;
    edtPassWord: TcxTextEdit;
    lbDatabase: TcxLabel;
    btnConnect: TcxButton;
    cbbTK: TcxComboBox;
    procedure btnConnectClick(Sender: TObject);
  end;

var
  frmDbConnect: TfrmDbConnect;

implementation

uses
  uGlobalObject, MessageDlg;

{$R *.dfm}

procedure TfrmDbConnect.btnConnectClick(Sender: TObject);
begin
  DestModule.Host := edtServer.Text;
  DestModule.UserName := edtUserName.Text;
  DestModule.PassWord := edtPassWord.Text;
  DestModule.Database := cbbTK.Text;
  if DestModule.Connect then
  begin
    DoConnectEvent;
    Self.Close;
  end;
end;

end.

