unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, dxNavBar, dxNavBarCollns, cxClasses, dxNavBarBase,
  System.ImageList, Vcl.ImgList, cxImageList, dxStatusBar
  //
;

type
  TfrmMain = class(TForm)
    nbarMain: TdxNavBar;
    navGroupDatabase: TdxNavBarGroup;
    navItemConnect: TdxNavBarItem;
    navItemDataview: TdxNavBarItem;
    navItemExport: TdxNavBarItem;
    navGroupImport: TdxNavBarGroup;
    navGroupCOmmunity: TdxNavBarGroup;
    navGroupModify: TdxNavBarGroup;
    imgList: TcxImageList;
    statusBar: TdxStatusBar;
    navItemMergeXT: TdxNavBarItem;
    navItemMergeKO: TdxNavBarItem;
    navItemMergeKN: TdxNavBarItem;
    navGroupImage: TdxNavBarGroup;
    navItemImageXT: TdxNavBarItem;
    navItemImageKO: TdxNavBarItem;
    navItemImageKN: TdxNavBarItem;
    procedure FormCreate(Sender: TObject);
    procedure navItemConnectClick(Sender: TObject);
    procedure navItemImageKNClick(Sender: TObject);
    procedure navItemImageXTClick(Sender: TObject);
    procedure navItemMergeKNClick(Sender: TObject);
    procedure navItemMergeKOClick(Sender: TObject);
    procedure navItemMergeXTClick(Sender: TObject);
  private
    procedure OnDbConnected;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uGlobalObject, uDBConnect, uMergeXT, uMergeKO, uMergeKN, uImageXT, uImageKN,
  //
  MessageDlg;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  DoConnectEvent := OnDbConnected;
end;

procedure TfrmMain.navItemConnectClick(Sender: TObject);
begin
  frmDbConnect.ShowModal;
end;

procedure TfrmMain.navItemImageKNClick(Sender: TObject);
begin
  frmImageKN.Show;
end;

procedure TfrmMain.navItemImageXTClick(Sender: TObject);
begin
  frmImageXT.Show;
end;

procedure TfrmMain.navItemMergeKNClick(Sender: TObject);
begin
  frmMergeKN.Show;
end;

procedure TfrmMain.navItemMergeKOClick(Sender: TObject);
begin
  frmMergeKO.Show;
end;

procedure TfrmMain.navItemMergeXTClick(Sender: TObject);
begin
  frmMergeXT.Show;
end;

procedure TfrmMain.OnDbConnected;
begin
  statusBar.Panels[1].Text := '已连接';
  ShowMessage('连接成功!', '提示');
end;

end.

