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
    FRecNo: Integer;
    FOffset: Integer;
    FGetImageUrlJobGroup: TQJobGroup;
    FGetImageDataJobGroup: TQJobGroup;
    procedure DoGetUrl(AJob: PQJob);
    procedure DoGetData(AJob: PQJob);
    procedure DoneGetUrl(Sender: TObject);
    procedure DoneGetData(Sender: TObject);
    procedure ParseImageUrl(const AData: string; var ATagList, AUrlList, ANameList: TStringList);
    procedure ReportGetUrl(AJob: PQJob);
    procedure ReportGetData(AJob: PQJob);
  public
  end;

var
  frmImageXT: TfrmImageXT;

const
  PageSize = 100;

implementation

uses
  uDestModule, uDBConnect, uGlobalObject, RegularExpressions;

{$R *.dfm}

procedure TfrmImageXT.FormCreate(Sender: TObject);
begin
  FRecNo := 0;
  FOffset := 0;
  //
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
  I: Integer;
  lvImageItem: TQMsgPack;
  lvImageTagList, lvImageUrlList, lvImageNameList: TStringList;
  lvItemID, lvCatalogID, lvItemData: string;
begin
  if not DestModule.Connect then
    frmDbConnect.ShowModal;

  mmoImageUrl.Clear;
  mmoImageData.Clear;

  lblStartTime.Caption := '开始时间:' + DateTimeToStr(Now);
  // 此步骤一定要在添加任务前完成，否则会有漏项
  FGetImageUrlJobGroup.Prepare;
  FGetImageDataJobGroup.Prepare;
  //
    //
  DestModule.GetItemImageList(mtImage, FOffset, PageSize);
  // 任务中止
  if mtImage.RecordCount = 0 then
  begin
    mmoImageData.Lines.Add('全部任务完成');
    Exit;
  end;

  mtImage.First;
  while not mtImage.Eof do
  begin
    lvImageTagList := TStringList.Create;
    lvImageUrlList := TStringList.Create;
    lvImageNameList := TStringList.Create;
    //
    lvItemID := mtImage.FieldByName('FID').AsString;
    lvCatalogID := mtImage.FieldByName('FCatalogID').AsString;
    lvItemData := mtImage.FieldByName('FItemData').AsString;
    try
      ParseImageUrl(lvItemData, lvImageTagList, lvImageUrlList, lvImageNameList);
      for I := 0 to lvImageUrlList.Count - 1 do
      begin
        Inc(FRecNo);
        lvImageItem := TQMsgPack.Create;
        lvImageItem.Add('ImageID', Format('I%.6d', [FRecNo]));
        lvImageItem.Add('ItemID', lvItemID);
        lvImageItem.Add('CatalogID', lvCatalogID);
        lvImageItem.Add('ImageTag', lvImageTagList[I]);
        lvImageItem.Add('ImageUrl', lvImageUrlList[I]);
        lvImageItem.Add('ImageName', lvImageNameList[I]);
        FGetImageUrlJobGroup.Add(DoGetUrl, lvImageItem, False, jdfFreeAsObject);
      end;
    finally
      lvImageTagList.Free;
      lvImageUrlList.Free;
      lvImageNameList.Free;
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
  //进行下一 轮任务
  FOffset := FOffset + PageSize;
  btnStart.Click;
end;

procedure TfrmImageXT.ParseImageUrl(const AData: string; var ATagList, AUrlList, ANameList: TStringList);
const
  BaseUrl = 'http://60.205.163.175:8090';
  RegexUrl = '<img src=\\"(.*?)\\".*?/>';
  RegexName = '\d/(.*?\.gif|.*?\.jpg|.*?\.png|.*?\.jpeg|.*?\.bmp)';
var
  I: Integer;
  lvUrl: string;
  lvList: TMatchCollection;
begin
  lvList := TRegEx.Matches(AData, RegexUrl);

  for I := 0 to lvList.Count - 1 do
  begin
    ATagList.Add(lvList[I].Value);
    lvUrl := TRegEx.Replace(lvList[I].Groups[1].Value, BaseUrl, '');
    AUrlList.Add(BaseUrl + lvUrl);
    ANameList.Add(TRegEx.Match(lvUrl, RegexName).Groups[1].Value);
  end;
end;

end.

