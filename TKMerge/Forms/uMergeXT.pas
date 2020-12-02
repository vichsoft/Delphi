unit uMergeXT;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, dxCustomWizardControl, dxWizardControl, cxCustomData,
  cxStyles, cxTL, cxTLdxBarBuiltInMenu, Vcl.Menus, Vcl.StdCtrls, cxButtons,
  cxInplaceContainer, cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxButtonEdit,
  Data.DB, kbmMemTable, cxMemo, cxCheckBox, cxLabel,
  //
  uSourceModule_XT, QWorker, qmsgpack;

type
  TfrmMergeXT = class(TForm)
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
    edtFile: TcxButtonEdit;
    dlgOpen: TOpenDialog;
    mt: TkbmMemTable;
    tcolSubjectID: TcxTreeListColumn;
    tcolSubjectTitle: TcxTreeListColumn;
    tcolSubjectParentID: TcxTreeListColumn;
    tcolCatalogID: TcxTreeListColumn;
    tcolCatalogTitle: TcxTreeListColumn;
    tlItem: TcxTreeList;
    tcolItemID: TcxTreeListColumn;
    tcolItemCatalogID: TcxTreeListColumn;
    tcolItemTypeID: TcxTreeListColumn;
    tcolItemData: TcxTreeListColumn;
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
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtFilePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnGetSubjectListClick(Sender: TObject);
    procedure btnGetCatalogListClick(Sender: TObject);
    procedure btnGetItemListClick(Sender: TObject);
    procedure btnMergeClick(Sender: TObject);
    procedure tlCatalogCustomDrawIndicatorCell(Sender: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListIndicatorCellViewInfo; var ADone: Boolean);
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
  frmMergeXT: TfrmMergeXT;
  SourceModule: TSourceModule_XT;

implementation

uses
  uGlobalObject, uDBConnect, MessageDlg;

{$R *.dfm}

procedure TfrmMergeXT.FormDestroy(Sender: TObject);
begin
  FSubjectJobGroup.Free;
  FCatalogJobGroup.Free;
  FItemJobGroup.Free;
end;

procedure TfrmMergeXT.FormCreate(Sender: TObject);
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

procedure TfrmMergeXT.edtFilePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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

procedure TfrmMergeXT.ConnectDatabase;
begin
  SourceModule := TSourceModule_XT.Create(nil);
  if FileExists(edtFile.Text) then
  begin
    SourceModule.SetDataBase(edtFile.Text);
  end
  else
  begin
    edtFile.Clear;
  end;
end;

procedure TfrmMergeXT.btnGetSubjectListClick(Sender: TObject);
var
  lvParentID: string;
  lvParentNode: TcxTreeListNode;
begin
  try
    SourceModule.GetSubjectList(mt);
    tlSubject.BeginUpdate;
    tlSubject.Clear;
    //绑定一级目录
    mt.First;
    while not mt.Eof do
    begin
      if mt.FieldByName('FParentID').AsString = '0' then
      begin
        with tlSubject.Add do
        begin
          Texts[tcolSubjectID.ItemIndex] := mt.FieldByName('FID').AsString;
          Texts[tcolSubjectTitle.ItemIndex] := mt.FieldByName('FName').AsString;
          Texts[tcolSubjectParentID.ItemIndex] := mt.FieldByName('FParentID').AsString;
        end;
      end;
      mt.Next;
    end;
   //绑定二级目录
    mt.First;
    while not mt.Eof do
    begin
      if mt.FieldByName('FParentID').AsString <> '0' then
      begin
        lvParentID := mt.FieldByName('FParentID').AsString;
        lvParentNode := tlSubject.FindNodeByText(lvParentID, tcolSubjectID);
        if Assigned(lvParentNode) then
        begin
          with lvParentNode.AddChild do
          begin
            Texts[tcolSubjectID.ItemIndex] := mt.FieldByName('FID').AsString;
            Texts[tcolSubjectTitle.ItemIndex] := mt.FieldByName('FName').AsString;
            Texts[tcolSubjectParentID.ItemIndex] := mt.FieldByName('FParentID').AsString;
          end;
        end;
      end;
      mt.Next;
    end;
  finally
    tlSubject.FullExpand;
    tlSubject.EndUpdate;
  end;
end;

procedure TfrmMergeXT.btnGetCatalogListClick(Sender: TObject);
var
  lvSubjectID: string;
begin
  if tlSubject.SelectionCount = 0 then
    Exit;

  if tlSubject.Selections[0].HasChildren then
    Exit;

  lvSubjectID := tlSubject.Selections[0].Texts[tcolSubjectID.ItemIndex];
  try
    SourceModule.GetCatalogList(lvSubjectID, mt);
    tlCatalog.BeginUpdate;
    tlCatalog.Clear;
    //绑定一级目录
    mt.First;
    while not mt.Eof do
    begin
      with tlCatalog.Add do
      begin
        Texts[tcolCatalogID.ItemIndex] := mt.FieldByName('FID').AsString;
        Texts[tcolCatalogTitle.ItemIndex] := SourceModule.ParseCatalogTitle(mt.FieldByName('FName').AsString);
        Texts[tcolCatalogType.ItemIndex] := SourceModule.ParseCatalogType(mt.FieldByName('FName').AsString);
      end;
      mt.Next;
    end;
  finally
    tlCatalog.EndUpdate;
  end;
end;

procedure TfrmMergeXT.btnGetItemListClick(Sender: TObject);
var
  lvItemTypeID: string;
  lvCatalogID: string;
begin
  try
    tlItem.BeginUpdate;
    tlItem.Clear;
    if tlCatalog.Count = 0 then
      Exit;
    lvCatalogID := tlCatalog.Items[0].Texts[tcolCatalogID.ItemIndex];
    SourceModule.GetItemList(lvCatalogID, mt);
    mt.First;
    while not mt.Eof do
    begin
      lvItemTypeID := mt.FieldByName('FLable').AsString;
      with tlItem.Add do
      begin
        Texts[tcolItemID.ItemIndex] := mt.FieldByName('FTestID').AsString;
        Texts[tcolItemCatalogID.ItemIndex] := mt.FieldByName('FChapterID').AsString;
        Texts[tcolItemTypeID.ItemIndex] := SourceModule.ParseItemType(mt.FieldByName('FLable').AsString);
        Texts[tcolItemData.ItemIndex] := SourceModule.ParseItemData(lvItemTypeID, mt.FieldByName('FData').AsString);
      end;
      mt.Next;
    end;
  finally
    tlItem.EndUpdate;
  end;
end;

function TfrmMergeXT.GetParent(ANode: TcxTreeListNode): string;
var
  lvTitle: string;
begin
  lvTitle := '';
  while ANode.Parent <> tlSubject.Root do
  begin
    ANode := ANode.Parent;
    if lvTitle = '' then
      lvTitle := ANode.Texts[tcolSubjectTitle.ItemIndex]
    else
      lvTitle := ANode.Texts[tcolSubjectTitle.ItemIndex] + '>' + lvTitle;
  end;
  Result := lvTitle;
end;

procedure TfrmMergeXT.btnMergeClick(Sender: TObject);
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

  for I := 0 to tlSubject.AbsoluteCount - 1 do
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

procedure TfrmMergeXT.DoMergeSubject(AJob: PQJob);
begin
  DestModule.AddSubject(TQMsgPack(AJob.Data));
  Workers.Post(DoReportSubject, TQMsgPack(AJob.Data).Copy, True, jdfFreeAsObject);
  FCatalogJobGroup.Add(DoMergeCatalog, TQMsgPack(AJob.Data).Copy, False, jdfFreeAsObject);
end;

procedure TfrmMergeXT.DoReportSubject(AJob: PQJob);
var
  lvSubjectID, lvSubjectTitle: string;
begin
  lvSubjectID := TQMsgPack(AJob.Data).ItemByName('SubjectID').AsString;
  lvSubjectTitle := TQMsgPack(AJob.Data).ItemByName('SubjectTitle').AsString;
  mmoSubject.Lines.Add(lvSubjectID + '-' + lvSubjectTitle);
end;

procedure TfrmMergeXT.DoneMergeSubject(Sender: TObject);
begin
  FCatalogJobGroup.Run;
end;

procedure TfrmMergeXT.DoMergeCatalog(AJob: PQJob);
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
      lvCatalog.Add('CatalogID', mtCatalog.FieldByName('FID').AsString);
      lvCatalog.Add('CatalogTitle', SourceModule.ParseCatalogTitle(mtCatalog.FieldByName('FName').AsString));
      lvCatalog.Add('CatalogType', SourceModule.ParseCatalogType(mtCatalog.FieldByName('FName').AsString));
      lvCatalog.Add('CatalogSubjectID', lvSubjectID);
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

procedure TfrmMergeXT.DoReportCatalog(AJob: PQJob);
var
  lvCatalogID, lvCatalogTitle: string;
begin
  lvCatalogID := TQMsgPack(AJob.Data).ItemByName('CatalogID').AsString;
  lvCatalogTitle := TQMsgPack(AJob.Data).ItemByName('CatalogTitle').AsString;
  mmoCatalog.Lines.Add(lvCatalogID + '-' + lvCatalogTitle);
end;

procedure TfrmMergeXT.DoneMergeCatalog(Sender: TObject);
begin
  //开始下一任务
  FItemJobGroup.Run;
end;

procedure TfrmMergeXT.DoMergeItem(AJob: PQJob);
var
  lvCatalogID, lvSubjectID: string;
  lvItemTypeID: string;
  lvItem: TQMsgPack;
  mtItem: TkbmMemTable;
begin
  mtItem := TkbmMemTable.Create(nil);
  try
    lvCatalogID := TQMsgPack(AJob.Data).ItemByName('CatalogID').AsString;
    lvSubjectID := TQMsgPack(AJob.Data).ItemByName('CatalogSubjectID').AsString;
    SourceModule.GetItemList(lvCatalogID, mtItem);
    mtItem.First;
    while not mtItem.Eof do
    begin
      lvItemTypeID := mtItem.FieldByName('FLable').AsString;

      lvItem := TQMsgPack.Create;
      lvItem.Add('FItemID', mtItem.FieldByName('FTestID').AsString);
      //章节编号前添加科目编号，以保持和章节表中一致
      lvItem.Add('FItemCatalogID', lvSubjectID + ':' + mtItem.FieldByName('FChapterID').AsString);
      lvItem.Add('FItemTypeID', SourceModule.ParseItemType(lvItemTypeID));
      lvItem.Add('FItemData', SourceModule.ParseItemData(lvItemTypeID, mtItem.FieldByName('FData').AsString));
      lvItem.Add('FFavorite', False);
      lvItem.Add('FHotspot', False);
      lvItem.Add('FFallible', False);
      lvItem.Add('FNote', '');
      lvItem.Add('FExplain', '');

      DestModule.AddItem(lvItem);
      Workers.Post(DoReportItem, lvItem, True, jdfFreeAsObject);
      mtItem.Next;
    end;
  finally
    mtItem.Free;
  end;
end;

procedure TfrmMergeXT.DoReportItem(AJob: PQJob);
var
  lvItemID: string;
begin
  lvItemID := TQMsgPack(AJob.Data).ItemByName('FItemID').AsString;
  mmoItem.Lines.Add(lvItemID);
end;

procedure TfrmMergeXT.DoneMergeItem(Sender: TObject);
begin
  lblFinished.Caption := '完成时间:' + DateTimeToStr(Now);
  lblSubjectCount.Caption := Format('科目数量:%d', [mmoSubject.Lines.Count]);
  lblCatalogCount.Caption := Format('章节数量:%d', [mmoCatalog.Lines.Count]);
  lblItemCount.Caption := Format('题目数量:%d', [mmoItem.Lines.Count]);
  mmoItem.Lines.Add('任务完成');
end;

procedure TfrmMergeXT.tlCatalogCustomDrawIndicatorCell(Sender: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListIndicatorCellViewInfo; var ADone: Boolean);
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

