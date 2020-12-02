unit uImageXT;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxLookAndFeels, cxLookAndFeelPainters, Vcl.Menus, dxSkinsCore,
  dxSkinsDefaultPainters, cxControls, cxContainer, cxEdit, Vcl.StdCtrls, cxLabel,
  System.IOUtils, cxButtons, Data.DB, kbmMemTable,
  //
  QWorker, qmsgpack, OverbyteIcsWndControl, OverbyteIcsHttpProt;

type
  TfrmImageXT = class(TForm)
    btnStart: TcxButton;
    lblFinishedTime: TcxLabel;
    lblFinishedCount: TcxLabel;
    lblStartTime: TcxLabel;
    lblImageCount: TcxLabel;
    mmoImageData: TMemo;
    mmoImageUrl: TMemo;
    mtImage: TkbmMemTable;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
  private
    FGetImageUrlJobGroup: TQJobGroup;
    FGetImageDataJobGroup: TQJobGroup;
    procedure DoGetUrl(AJob: PQJob);
    procedure DoGetData(AJob: PQJob);
    procedure DoneGetUrl(Sender: TObject);
    procedure DoneGetData(Sender: TObject);
    procedure ParseImageUrl(const AData: string; var ATagList, AUrlList: TStringList);
    procedure ReportGetUrl(AJob: PQJob);
    procedure ReportGetData(AJob: PQJob);
  public
  end;

var
  frmImageXT: TfrmImageXT;

implementation

uses
  uDestModule, uDBConnect, uGlobalObject, RegularExpressions;

{$R *.dfm}

procedure TfrmImageXT.FormCreate(Sender: TObject);
begin
  FGetImageUrlJobGroup := TQJobGroup.Create(True);
  FGetImageUrlJobGroup.AfterDone := DoneGetUrl;
  FGetImageUrlJobGroup.FreeAfterDone := False;

  FGetImageDataJobGroup := TQJobGroup.Create(True);
  FGetImageDataJobGroup.AfterDone := DoneGetData;
  FGetImageDataJobGroup.FreeAfterDone := False;
end;

procedure TfrmImageXT.FormDestroy(Sender: TObject);
begin
  FGetImageUrlJobGroup.Free;
  FGetImageDataJobGroup.Free;
end;

procedure TfrmImageXT.btnStartClick(Sender: TObject);
var
  I, RecNo: Integer;
  lvImageItem: TQMsgPack;
  lvImageUrlList, lvImageTagList: TStringList;
  lvItemID, lvCatalogID, lvItemData: string;
begin
  if not DestModule.Connect then
    frmDbConnect.ShowModal;

  RecNo := 0;
  mmoImageUrl.Clear;
  mmoImageData.Clear;

  lblStartTime.Caption := '开始时间:' + DateTimeToStr(Now);
  // 此步骤一定要在添加任务前完成，否则会有漏项
  FGetImageUrlJobGroup.Prepare;
  FGetImageDataJobGroup.Prepare;
  //
  DestModule.GetItemImageList(mtImage);
  mtImage.First;
  I := mtImage.RecordCount;
  while not mtImage.Eof do
  begin
    lvImageTagList := TStringList.Create;
    lvImageUrlList := TStringList.Create;
    lvItemID := mtImage.FieldByName('FID').AsString;
    lvCatalogID := mtImage.FieldByName('FCatalogID').AsString;
    lvItemData := mtImage.FieldByName('FItemData').AsString;
    try
      ParseImageUrl(lvItemData, lvImageTagList, lvImageUrlList);
      for I := 0 to lvImageUrlList.Count - 1 do
      begin
        Inc(RecNo);
        lvImageItem := TQMsgPack.Create;
        lvImageItem.Add('ImageID', Format('I%.6d', [RecNo]));
        lvImageItem.Add('ItemID', lvItemID);
        lvImageItem.Add('CatalogID', lvCatalogID);
        lvImageItem.Add('ImageTag', lvImageTagList[I]);
        lvImageItem.Add('ImageUrl', lvImageUrlList[I]);
        lvImageItem.Add('ImageName', TPath.GetFileName(lvImageUrlList[I]));
        FGetImageUrlJobGroup.Add(DoGetUrl, lvImageItem, False, jdfFreeAsObject);
      end;
    finally
      lvImageUrlList.Free;
      lvImageTagList.Free;
    end;
    mtImage.Next;
  end;
  FGetImageUrlJobGroup.Run;
end;

procedure TfrmImageXT.DoGetUrl(AJob: PQJob);
begin
  DestModule.AddImage(TQMsgPack(AJob.Data));
  Workers.Post(ReportGetUrl, TQMsgPack(AJob.Data).Copy, True, jdfFreeAsObject);
  FGetImageDataJobGroup.Add(DoGetData, TQMsgPack(AJob.Data).Copy, False, jdfFreeAsObject);
end;

procedure TfrmImageXT.ReportGetUrl(AJob: PQJob);
var
  lvImageUrl: string;
begin
  lvImageUrl := TQMsgPack(AJob.Data).ItemByName('ImageTag').AsString;
  mmoImageUrl.Lines.Add(lvImageUrl);
end;

procedure TfrmImageXT.DoneGetUrl(Sender: TObject);
begin
  FGetImageDataJobGroup.Run;
end;

procedure TfrmImageXT.DoGetData(AJob: PQJob);
var
  lvImage: TQMsgPack;
  lvHttp: THttpCli;
  lvStream: TMemoryStream;
begin
  lvHttp := THttpCli.Create(nil);
  lvImage := TQMsgPack.Create;
  lvStream := TMemoryStream.Create;
  // 下载图片并存入数据库
  try
    try
      lvHttp.RcvdStream := lvStream;
      lvHttp.URL := TQMsgPack(AJob.Data).ItemByName('ImageUrl').AsString;
      lvHttp.Get;
      DestModule.UpdateImage(TQMsgPack(AJob.Data).ItemByName('ImageID').AsString, lvStream);
      lvImage.Add('FinishedStatus', '【成功】');
    except
      lvImage.Add('FinishedStatus', '【失败】');
    end;
  finally
    lvStream.Free;
    lvHttp.Free;
  end;
  lvImage.Add('ImageName', TQMsgPack(AJob.Data).ItemByName('ImageName').AsString);
  Workers.Post(ReportGetData, lvImage, True, jdfFreeAsObject);
end;

procedure TfrmImageXT.ReportGetData(AJob: PQJob);
var
  lvImageName, lvStatus: string;
begin
  lvImageName := TQMsgPack(AJob.Data).ItemByName('ImageName').AsString;
  lvStatus := TQMsgPack(AJob.Data).ItemByName('FinishedStatus').AsString;
  mmoImageData.Lines.Add(lvImageName + '--------' + lvStatus);
end;

procedure TfrmImageXT.DoneGetData(Sender: TObject);
begin
  lblFinishedTime.Caption := '完成时间:' + DateTimeToStr(Now);
  lblImageCount.Caption := Format('图片数量:%d', [mmoImageUrl.Lines.Count]);
  lblFinishedCount.Caption := Format('完成数量:%d', [mmoImageData.Lines.Count]);
  mmoImageData.Lines.Add('任务完成');
end;

procedure TfrmImageXT.ParseImageUrl(const AData: string; var ATagList, AUrlList: TStringList);
const
  BaseUrl = 'http://60.205.163.175:8090';
  Regex = '<img src=\\"(.*?[jpg|gif])\\".*?/>';
var
  I: Integer;
  lvList: TMatchCollection;
begin
  lvList := TRegEx.Matches(AData, Regex);

  for I := 0 to lvList.Count - 1 do
  begin
    ATagList.Add(lvList[I].Value);
    AUrlList.Add(BaseUrl + TRegEx.Replace(lvList[I].Groups[1].Value, BaseUrl, ''));
  end;
end;

end.

