unit uMergeKO;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, dxCustomWizardControl, dxWizardControl, cxCustomData,
  cxStyles, cxTL, cxTLdxBarBuiltInMenu, Vcl.Menus, Vcl.StdCtrls, cxButtons,
  cxInplaceContainer, cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxButtonEdit,
  Data.DB, kbmMemTable, cxMemo, cxCheckBox, cxLabel, Vcl.ExtCtrls, Vcl.FileCtrl,
  //
  uSourceModule_KO,
  //
  QWorker, qmsgpack, qjson, cxSpinEdit;

type
  TfrmMergeKO = class(TForm)
    wizard: TdxWizardControl;
    wpageSubject: TdxWizardControlPage;
    wpageCatalog: TdxWizardControlPage;
    wpageItem: TdxWizardControlPage;
    tlSubject: TcxTreeList;
    btnGetSubjectList: TcxButton;
    tlCatalog: TcxTreeList;
    btnGetCatalogList: TcxButton;
    btnGetItemList: TcxButton;
    wpageMerge: TdxWizardControlPage;
    dlgOpen: TOpenDialog;
    mt: TkbmMemTable;
    tcolSubjectID: TcxTreeListColumn;
    tcolSubjectTitle: TcxTreeListColumn;
    tcolCatalogID: TcxTreeListColumn;
    tcolCatalogTitle: TcxTreeListColumn;
    tlItem: TcxTreeList;
    tcolItemID: TcxTreeListColumn;
    tcolItemCatalogID: TcxTreeListColumn;
    tcolItemTypeID: TcxTreeListColumn;
    tcolItemData: TcxTreeListColumn;
    tcolItemFavorite: TcxTreeListColumn;
    tcolItemHotspot: TcxTreeListColumn;
    tcolItemFallible: TcxTreeListColumn;
    tcolItemNote: TcxTreeListColumn;
    tcolItemExplain: TcxTreeListColumn;
    tcolCatalogType: TcxTreeListColumn;
    btnMerge: TcxButton;
    mmoCatalog: TMemo;
    mmoSubject: TMemo;
    lblSubjectCount: TcxLabel;
    lblCatalogCount: TcxLabel;
    lblItemCount: TcxLabel;
    mmoItem: TMemo;
    lblStart: TcxLabel;
    lblFinished: TcxLabel;
    tcolCatalogSubjectID: TcxTreeListColumn;
    lblRange: TcxLabel;
    edtStart: TcxSpinEdit;
    edtEnd: TcxSpinEdit;
    lblTo: TcxLabel;
    pnlFilePath: TPanel;
    edtFolder: TcxButtonEdit;
    edtFile: TcxButtonEdit;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtFilePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnGetSubjectListClick(Sender: TObject);
    procedure btnGetCatalogListClick(Sender: TObject);
    procedure btnGetItemListClick(Sender: TObject);
    procedure btnMergeClick(Sender: TObject);
    procedure tlCatalogCustomDrawIndicatorCell(Sender: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListIndicatorCellViewInfo; var ADone: Boolean);
    procedure edtSourcePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
  private
    FSubjectJobGroup: TQJobGroup;
    FCatalogJobGroup: TQJobGroup;
    FItemJobGroup: TQJobGroup;
    procedure ConnectDatabase;
    function GetParent(ANode: TcxTreeListNode): string;
    procedure DoMergeSubject(AJob: PQJob);
    procedure DoneMergeSubject(Sender: TObject);
    procedure DoMergeCatalog(AJob: PQJob);
    procedure DoReportSubject(AJob: PQJob);
    procedure DoMergeItem(AJob: PQJob);
    procedure DoneMergeCatalog(Sender: TObject);
    procedure DoneMergeItem(Sender: TObject);
    procedure DoReportCatalog(AJob: PQJob);
    procedure DoReportItem(AJob: PQJob);
  end;

var
  frmMergeKO: TfrmMergeKO;
  SourceModule: TSourceModule_KO;

implementation

uses
  uGlobalObject, uDBConnect, MessageDlg, System.IOUtils;

{$R *.dfm}

procedure TfrmMergeKO.FormCreate(Sender: TObject);
begin
  if edtFile.Text <> '' then
    ConnectDatabase;

  FSubjectJobGroup := TQJobGroup.Create(True);
  FSubjectJobGroup.AfterDone := DoneMergeSubject;
  FSubjectJobGroup.FreeAfterDone := False;

  FCatalogJobGroup := TQJobGroup.Create(True);
  FCatalogJobGroup.AfterDone := DoneMergeCatalog;
  FCatalogJobGroup.FreeAfterDone := False;

  FItemJobGroup := TQJobGroup.Create(True);
  FItemJobGroup.AfterDone := DoneMergeItem;
  FItemJobGroup.FreeAfterDone := False;
end;

procedure TfrmMergeKO.FormDestroy(Sender: TObject);
begin
  FSubjectJobGroup.Free;
  FCatalogJobGroup.Free;
  FItemJobGroup.Free;
end;

procedure TfrmMergeKO.edtFilePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  case AButtonIndex of
    0:
      if dlgOpen.Execute then
      begin
        edtFile.Text := dlgOpen.FileName;
        ConnectDatabase;
      end;
    1:
      ConnectDatabase;
  end;
end;

procedure TfrmMergeKO.edtSourcePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  strPath: string;
begin
  strPath := '';
  if (SelectDirectory('选择目录', '', strPath)) then
  begin
    edtFolder.Text := strPath;
    SourceModule.ItemDatabasePath := strPath;
  end;
end;

procedure TfrmMergeKO.ConnectDatabase;
begin
  SourceModule := TSourceModule_KO.Create(nil);
  //结构题库位置
  if FileExists(edtFile.Text) then
    SourceModule.SetDataBase(edtFile.Text)
  else
    edtFile.Clear;
  //子题库目录
  if TDirectory.Exists(edtFolder.Text) then
    SourceModule.ItemDatabasePath := edtFolder.Text
  else
    edtFolder.Clear;
end;

procedure TfrmMergeKO.btnGetSubjectListClick(Sender: TObject);
var
  I, J: Integer;
  lvData: TQjson;
  lvExam, lvProvince: TcxTreeListNode;
begin
  try
    lvData := TQjson.Create;
    tlSubject.BeginUpdate;
    tlSubject.Clear;
    SourceModule.GetSubjectList(mt);
    mt.First;
    tlSubject.Root.CheckGroupType := ncgCheckGroup;
    while not mt.Eof do
    begin
      lvExam := tlSubject.Add;
      with lvExam do
      begin
        Texts[tcolSubjectTitle.ItemIndex] := mt.FieldByName('FTitle').AsString;
        //
        lvData.Parse(mt.FieldByName('FContent').AsString);
        if lvData.ItemByName('Body').Count = 1 then
        begin
          CheckGroupType := ncgCheckGroup;
          for I := 0 to lvData.ItemByName('Body').Items[0].ItemByName('QuoteDetails').Count - 1 do
          begin
            with lvExam.AddChild do
            begin
              Texts[tcolSubjectTitle.ItemIndex] := lvData.ItemByName('Body').Items[0].ItemByName('QuoteDetails').Items[I].ItemByName('Key').AsString;
              Texts[tcolSubjectID.ItemIndex] := lvData.ItemByName('Body').Items[0].ItemByName('QuoteDetails').Items[I].ItemByName('Value').AsString;
            end;
          end;
        end
        else
        begin
          for I := 0 to lvData.ItemByName('Body').Count - 1 do
          begin
            lvProvince := lvExam.AddChild;
            with lvProvince do
            begin
              CheckGroupType := ncgCheckGroup;
              Texts[tcolSubjectTitle.ItemIndex] := lvData.ItemByName('Body').Items[I].ItemByName('Province').AsString;
              for J := 0 to lvData.ItemByName('Body').Items[I].ItemByName('QuoteDetails').Count - 1 do
              begin
                with lvProvince.AddChild do
                begin
                  Texts[tcolSubjectTitle.ItemIndex] := lvData.ItemByName('Body').Items[I].ItemByName('QuoteDetails').Items[J].ItemByName('Key').AsString;
                  Texts[tcolSubjectID.ItemIndex] := lvData.ItemByName('Body').Items[I].ItemByName('QuoteDetails').Items[J].ItemByName('Value').AsString;
                end;
              end;
            end;
          end;
        end;
      end;
      mt.Next;
    end;
  finally
    edtStart.Value := 0;
    edtEnd.Value := tlSubject.AbsoluteCount;
    edtStart.Properties.MaxValue := tlSubject.AbsoluteCount;
    edtEnd.Properties.MaxValue := tlSubject.AbsoluteCount;
    lblRange.Caption := Format('范围(0-%d):', [tlSubject.AbsoluteCount]);
    if tlSubject.Count > 0 then
      tlSubject.Items[0].Expand(True);
    tlSubject.EndUpdate;
  end;
end;

procedure TfrmMergeKO.btnGetCatalogListClick(Sender: TObject);
var
  lvSubjectID: string;
begin
  if tlSubject.SelectionCount = 0 then
    Exit;

  if tlSubject.Selections[0].Texts[tcolSubjectID.ItemIndex] = '' then
    Exit;

  lvSubjectID := tlSubject.Selections[0].Texts[tcolSubjectID.ItemIndex];
  try
    SourceModule.GetCatalogList(lvSubjectID, mt);
    tlCatalog.BeginUpdate;
    tlCatalog.Clear;
    mt.First;
    while not mt.Eof do
    begin
      with tlCatalog.Add do
      begin
        Texts[tcolCatalogID.ItemIndex] := mt.FieldByName('FChapterID').AsString;
        Texts[tcolCatalogTitle.ItemIndex] := mt.FieldByName('FChapter').AsString;
        Texts[tcolCatalogType.ItemIndex] := mt.FieldByName('FSourceType').AsString + '>' + mt.FieldByName('FSource').AsString;
        Texts[tcolCatalogSubjectID.ItemIndex] := mt.FieldByName('FExam').AsString;
      end;
      mt.Next;
    end;
  finally
    tlCatalog.EndUpdate;
  end;
end;

procedure TfrmMergeKO.btnGetItemListClick(Sender: TObject);
var
  I: Integer;
  lvItemList: TQMsgPackList;
  lvSubjectID, lvCatalogID: string;
begin
  try
    tlItem.BeginUpdate;
    tlItem.Clear;

    if tlCatalog.Count = 0 then
      Exit;
    tlSubject.items[0].Expand(true);
    //只取第一第，作测试用
    lvCatalogID := tlCatalog.Items[0].Texts[tcolCatalogID.ItemIndex];
    lvSubjectID := tlSubject.Selections[0].Texts[tcolSubjectID.ItemIndex];
    SourceModule.GetItemList(lvCatalogID, lvSubjectID, lvItemList);
    for I := 0 to lvItemList.Count - 1 do
    begin
      with tlItem.Add do
      begin
        Texts[tcolItemID.ItemIndex] := lvItemList[I].ItemByName('FItemID').AsString;
        Texts[tcolItemCatalogID.ItemIndex] := lvItemList[I].ItemByName('FItemCatalogID').AsString;
        Texts[tcolItemTypeID.ItemIndex] := lvItemList[I].ItemByName('FItemTypeID').AsString;
        Texts[tcolItemData.ItemIndex] := lvItemList[I].ItemByName('FItemData').AsString;
        Values[tcolItemFavorite.ItemIndex] := lvItemList[I].ItemByName('FFavorite').AsBoolean;
        Values[tcolItemHotspot.ItemIndex] := lvItemList[I].ItemByName('FHotspot').AsBoolean;
        Values[tcolItemFallible.ItemIndex] := lvItemList[I].ItemByName('FFallible').AsBoolean;
        Texts[tcolItemNote.ItemIndex] := lvItemList[I].ItemByName('FNote').AsString;
        Texts[tcolItemExplain.ItemIndex] := lvItemList[I].ItemByName('FExplain').AsString;
      end;
    end;
  finally
    tlItem.EndUpdate;
  end;
end;

function TfrmMergeKO.GetParent(ANode: TcxTreeListNode): string;
var
  lvName: string;
begin
  lvName := '';
  while ANode.Parent <> tlSubject.Root do
  begin
    ANode := ANode.Parent;
    if lvName = '' then
      lvName := ANode.Texts[tcolSubjectTitle.ItemIndex]
    else
      lvName := ANode.Texts[tcolSubjectTitle.ItemIndex] + '>' + lvName;
  end;
  Result := lvName;
end;

procedure TfrmMergeKO.btnMergeClick(Sender: TObject);
var
  I: Integer;
  lvSubject: TQMsgPack;
begin
  if not DestModule.Connect then
    frmDbConnect.ShowModal;

  mmoSubject.Clear;
  mmoCatalog.Clear;
  mmoItem.Clear;
  lblStart.Caption := '开始时间:' + DateTimeToStr(Now);
  //此步骤一定要在添加任务前完成，否则会有漏项
  FSubjectJobGroup.Prepare;
  FCatalogJobGroup.Prepare;
  FItemJobGroup.Prepare;

  for I := edtStart.Value to (edtEnd.Value - 1) do
  begin
    if tlSubject.AbsoluteItems[I].HasChildren then
      Continue;
    lvSubject := TQMsgPack.Create;
    lvSubject.Add('SubjectID', tlSubject.AbsoluteItems[I].Texts[tcolSubjectID.ItemIndex]);
    lvSubject.Add('SubjectTitle', tlSubject.AbsoluteItems[I].Texts[tcolSubjectTitle.ItemIndex]);
    lvSubject.Add('SubjectParent', GetParent(tlSubject.AbsoluteItems[I]));
    FSubjectJobGroup.Add(DoMergeSubject, lvSubject, False, jdfFreeAsObject);
  end;
  FSubjectJobGroup.Run;
end;

procedure TfrmMergeKO.DoMergeSubject(AJob: PQJob);
begin
  DestModule.AddSubject(TQMsgPack(AJob.Data));
  Workers.Post(DoReportSubject, TQMsgPack(AJob.Data).Copy, True, jdfFreeAsObject);
  FCatalogJobGroup.Add(DoMergeCatalog, TQMsgPack(AJob.Data).Copy, False, jdfFreeAsObject);
end;

procedure TfrmMergeKO.DoReportSubject(AJob: PQJob);
var
  lvSubjectID, lvSubjectTitle: string;
begin
  lvSubjectID := TQMsgPack(AJob.Data).ItemByName('SubjectID').AsString;
  lvSubjectTitle := TQMsgPack(AJob.Data).ItemByName('SubjectTitle').AsString;
  mmoSubject.Lines.Add(lvSubjectID + '-' + lvSubjectTitle);
end;

procedure TfrmMergeKO.DoneMergeSubject(Sender: TObject);
begin
  FCatalogJobGroup.Run;
end;

procedure TfrmMergeKO.DoMergeCatalog(AJob: PQJob);
var
  lvSubjectID: string;
  lvCatalog: TQMsgPack;
  mtCatalog: TkbmMemTable;
begin
  mtCatalog := TkbmMemTable.Create(nil);
  try
    lvSubjectID := TQMsgPack(AJob.Data).ItemByName('SubjectID').AsString;
    SourceModule.GetCatalogList(lvSubjectID, mtCatalog);
    mtCatalog.First;
    while not mtCatalog.Eof do
    begin
      lvCatalog := TQMsgPack.Create;
      lvCatalog.Add('CatalogID', Format('%.6d', [mtCatalog.FieldByName('FChapterID').AsInteger]));
      lvCatalog.Add('CatalogTitle', mtCatalog.FieldByName('FChapter').AsString);
      lvCatalog.Add('CatalogType', mtCatalog.FieldByName('FSourceType').AsString + '>' + mtCatalog.FieldByName('FSource').AsString);
      lvCatalog.Add('CatalogSubjectID', mtCatalog.FieldByName('FExam').AsString);
      DestModule.AddCatalog(lvCatalog);
      //
      Workers.Post(DoReportCatalog, lvCatalog, True, jdfFreeAsObject);
      //
      FItemJobGroup.Add(DoMergeItem, lvCatalog.Copy, False, jdfFreeAsObject);
      mtCatalog.Next;
    end;
  finally
    mtCatalog.Free;
  end;
end;

procedure TfrmMergeKO.DoReportCatalog(AJob: PQJob);
var
  lvCatalogID, lvCatalogName: string;
begin
  if mmoCatalog.Lines.Count > 1000 then
    mmoCatalog.Lines.Clear;
  lvCatalogID := TQMsgPack(AJob.Data).ItemByName('CatalogID').AsString;
  lvCatalogName := TQMsgPack(AJob.Data).ItemByName('CatalogTitle').AsString;
  mmoCatalog.Lines.Add(lvCatalogID + '-' + lvCatalogName);
end;

procedure TfrmMergeKO.DoneMergeCatalog(Sender: TObject);
begin
  //开始下一任务
  FItemJobGroup.Run;
end;

procedure TfrmMergeKO.DoMergeItem(AJob: PQJob);
var
  I: Integer;
  lvSubjectID, lvCatalogID: string;
  lvItemList: TQMsgPackList;
begin
  try
    lvCatalogID := IntToStr(TQMsgPack(AJob.Data).ItemByName('CatalogID').AsInteger);
    lvSubjectID := TQMsgPack(AJob.Data).ItemByName('CatalogSubjectID').AsString;
    SourceModule.GetItemList(lvCatalogID, lvSubjectID, lvItemList);
    for I := 0 to lvItemList.Count - 1 do
    begin
      DestModule.AddItem(lvItemList[I]);
      Workers.Post(DoReportItem, lvItemList[I], True, jdfFreeAsObject);
    end;
  finally
  end;
end;

procedure TfrmMergeKO.DoReportItem(AJob: PQJob);
var
  lvItemID: string;
begin
  if mmoItem.Lines.Count > 1000 then
    mmoItem.Lines.Clear;
  lvItemID := TQMsgPack(AJob.Data).ItemByName('FItemID').AsString;
  mmoItem.Lines.Add(lvItemID);
end;

procedure TfrmMergeKO.DoneMergeItem(Sender: TObject);
begin
  lblFinished.Caption := '完成时间:' + DateTimeToStr(Now);
  lblSubjectCount.Caption := Format('科目数量:%d', [mmoSubject.Lines.Count]);
  lblCatalogCount.Caption := Format('章节数量:%d', [mmoCatalog.Lines.Count]);
  lblItemCount.Caption := Format('题目数量:%d', [mmoItem.Lines.Count]);
  mmoItem.Lines.Add('任务完成');
end;

procedure TfrmMergeKO.tlCatalogCustomDrawIndicatorCell(Sender: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListIndicatorCellViewInfo; var ADone: Boolean);
var
  ARect: TRect;
  AText: string;
begin
  if not (AViewInfo is TcxTreeListIndicatorCellViewInfo) then
    Exit;

  if not Assigned(AViewInfo.Node) then
    Exit;

  ARect := AViewInfo.BoundsRect;
  InflateRect(ARect, -2, -1);

  AText := Format('%.4d', [AViewInfo.Node.Index + 1]);
  ACanvas.Font.Color := Canvas.Font.Color;
  ACanvas.Font.Style := Canvas.Font.Style + [fsBold];
  ACanvas.DrawTexT(AText, ARect, 1, False);
  ADone := True;
end;

end.

