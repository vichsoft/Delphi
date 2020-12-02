unit uMergeKN;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, dxCustomWizardControl, dxWizardControl, cxCustomData,
  cxStyles, cxTL, cxTLdxBarBuiltInMenu, Vcl.Menus, Vcl.StdCtrls, cxButtons,
  cxInplaceContainer, cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxButtonEdit,
  Data.DB, kbmMemTable, cxMemo, cxCheckBox,
  //
  uSourceModule_KN, QWorker, qmsgpack, cxLabel, Vcl.ExtCtrls, qjson, cxSpinEdit,
  cxDropDownEdit;

type
  TfrmMergeKN = class(TForm)
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
    edtTK: TcxButtonEdit;
    dlgOpen: TOpenDialog;
    mt: TkbmMemTable;
    tcolSubjectID: TcxTreeListColumn;
    tcolSubjectTitle: TcxTreeListColumn;
    tcolSubjectName: TcxTreeListColumn;
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
    pnlFilePath: TPanel;
    edtSource: TcxButtonEdit;
    edtSubject: TcxButtonEdit;
    tcolCatalogSubjectID: TcxTreeListColumn;
    tcolCatalogSubjectTitle: TcxTreeListColumn;
    lblRange: TcxLabel;
    edtStart: TcxSpinEdit;
    lblTo: TcxLabel;
    edtEnd: TcxSpinEdit;
    lbHint: TcxLabel;
    pnlRange: TPanel;
    cbbRange: TcxComboBox;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtFilePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnGetSubjectListClick(Sender: TObject);
    procedure btnGetCatalogListClick(Sender: TObject);
    procedure btnGetItemListClick(Sender: TObject);
    procedure btnMergeClick(Sender: TObject);
    procedure edtSourcePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure edtSubjectPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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
  frmMergeKN: TfrmMergeKN;
  SourceModule: TSourceModule_KN;

implementation

uses
  uGlobalObject, uDBConnect, uWebDecode, MessageDlg;

{$R *.dfm}

procedure TfrmMergeKN.FormDestroy(Sender: TObject);
begin
  FSubjectJobGroup.Free;
  FCatalogJobGroup.Free;
  FItemJobGroup.Free;
end;

procedure TfrmMergeKN.FormCreate(Sender: TObject);
begin
  if edtTK.Text <> '' then
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

procedure TfrmMergeKN.edtFilePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin

  case AButtonIndex of
    0:
      begin
        dlgOpen.Filter := '数据库文件|*.db';
        if dlgOpen.Execute then
        begin
          edtTK.Text := dlgOpen.FileName;
          ConnectDatabase;
        end;
      end;
    1:
      ConnectDatabase;
  end;
end;

procedure TfrmMergeKN.edtSourcePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  dlgOpen.Filter := 'JSON数据文件|*.json';
  if dlgOpen.Execute then
  begin
    edtSource.Text := dlgOpen.FileName;
  end;
end;

procedure TfrmMergeKN.edtSubjectPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  dlgOpen.Filter := 'JSON数据文件|*.json';
  if dlgOpen.Execute then
  begin
    edtSubject.Text := dlgOpen.FileName;
  end;
end;

procedure TfrmMergeKN.ConnectDatabase;
begin
  SourceModule := TSourceModule_KN.Create(nil);
  if FileExists(edtTK.Text) then
  begin
    SourceModule.SetDataBase(edtTK.Text);
  end
  else
  begin
    edtTK.Clear;
  end;
end;

procedure TfrmMergeKN.btnGetSubjectListClick(Sender: TObject);

  procedure AddChildNode(ANode: TcxTreeListNode; AJsonNode: TQJson);
  var
    J: Integer;
    lvChildJson: TQJson;
    lvChildNode: TcxTreeListNode;
  begin
    for J := 0 to AJsonNode.Count - 1 do
    begin
      lvChildJson := AJsonNode.Items[J];
      lvChildNode := ANode.AddChild;
      with lvChildNode do
      begin
        Texts[tcolSubjectTitle.ItemIndex] := lvChildJson.ItemByName('KsbClassName').AsString;
        Texts[tcolSubjectName.ItemIndex] := lvChildJson.ItemByName('KsbClassID').AsString;
      end;
      //递归
      if lvChildJson.ItemByName('Childs').Count > 0 then
      begin
        AddChildNode(lvChildNode, lvChildJson.ItemByName('Childs'));
      end;
    end;
  end;

var
  I, J: Integer;
  lvJson: TQJson;
  lvSourceID: string;
  lvNode: TcxTreeListNode;
  lvSource, lvSubject: TQJson;
begin
  lvSource := TQJson.Create;
  lvSubject := TQJson.Create;
  tlSubject.BeginUpdate;
  try
    tlSubject.Clear;
    lvSource.LoadFromFile(edtSource.Text);
    //一级列表
    for I := 0 to lvSource.Count - 1 do
    begin
      lvJson := lvSource.Items[I];
      lvNode := tlSubject.Add;
      with lvNode do
      begin
        Texts[tcolSubjectTitle.ItemIndex] := lvJson.ItemByName('KsbClassName').AsString;
        Texts[tcolSubjectName.ItemIndex] := lvJson.ItemByName('KsbClassID').AsString;
      end;
      //次级列表
      if lvJson.ItemByName('Childs').Count > 0 then
      begin
        AddChildNode(lvNode, lvJson.ItemByName('Childs'));
      end;
    end;
    //科目列表
    lvSubject.LoadFromFile(edtSubject.Text);
    for J := 0 to lvSubject.Count - 1 do
    begin
      lvSourceID := lvSubject.Items[J].ItemByName('KsbClassID').AsString;
      lvNode := tlSubject.FindNodeByText(lvSourceID, tcolSubjectName);
      if Assigned(lvNode) then
      begin
        with lvNode.AddChild do
        begin
          Texts[tcolSubjectTitle.ItemIndex] := lvSubject.Items[J].ItemByName('Name').AsString;
          Texts[tcolSubjectID.ItemIndex] := lvSubject.Items[J].ItemByName('AppID').AsString;
          Texts[tcolSubjectName.ItemIndex] := lvSubject.Items[J].ItemByName('AppEName').AsString;
        end;
      end;
    end;
  finally
    lvSource.Free;
    lvSubject.Free;
    edtStart.Value := 0;
    edtEnd.Value := tlSubject.AbsoluteCount;
    edtStart.Properties.MaxValue := tlSubject.AbsoluteCount;
    edtEnd.Properties.MaxValue := tlSubject.AbsoluteCount;
    lblRange.Caption := Format('范围(0-%d):', [tlSubject.AbsoluteCount]);
    if tlSubject.Count > 0 then
      tlSubject.items[0].Expand(true);
    tlSubject.EndUpdate;
  end;
end;

procedure TfrmMergeKN.btnGetCatalogListClick(Sender: TObject);
var
  I: Integer;
  lvChapterList: TQMsgPackList;
  lvSubjectID, lvSubjectTitle: string;
begin
  if tlSubject.SelectionCount = 0 then
    Exit;

  if tlSubject.Selections[0].HasChildren then
    Exit;

  tlCatalog.BeginUpdate;
  lvChapterList := TQMsgPackList.Create;
  try
    tlCatalog.Clear;
    lvChapterList.Clear;
    lvSubjectID := tlSubject.Selections[0].Texts[tcolSubjectID.ItemIndex] + ':' + tlSubject.Selections[0].Texts[tcolSubjectName.ItemIndex];
    lvSubjectTitle := tlSubject.Selections[0].Texts[tcolSubjectTitle.ItemIndex];
    SourceModule.GetCatalogList(lvSubjectID, lvChapterList);
    //绑定一级目录
    for I := 0 to lvChapterList.Count - 1 do
    begin
      with tlCatalog.Add do
      begin
        Texts[tcolCatalogSubjectID.ItemIndex] := lvSubjectID;
        Texts[tcolCatalogSubjectTitle.ItemIndex] := lvSubjectTitle;
        Texts[tcolCatalogID.ItemIndex] := lvChapterList.Items[I].ItemByName('FID').AsString;
        Texts[tcolCatalogTitle.ItemIndex] := lvChapterList.Items[I].ItemByName('FTitle').AsString;
        Texts[tcolCatalogType.ItemIndex] := lvChapterList.Items[I].ItemByName('FType').AsString;
      end;
    end;
  finally
    tlCatalog.EndUpdate;
    lvChapterList.Clear;
    lvChapterList.Free;
  end;
end;

procedure TfrmMergeKN.btnGetItemListClick(Sender: TObject);
var
  I: Integer;
  lvCatalogID, lvSubjectID: string;
  lvItemList: TQMsgPackList;
begin
  tlItem.BeginUpdate;
  lvItemList := TQMsgPackList.Create;
  try
    tlItem.Clear;
    lvItemList.Clear;
    if tlCatalog.Count = 0 then
      Exit;
    lvCatalogID := tlCatalog.Items[0].Texts[tcolCatalogID.ItemIndex];
    lvSubjectID := tlCatalog.Items[0].Texts[tcolCatalogSubjectID.ItemIndex];
    SourceModule.GetItemList(lvSubjectID, lvCatalogID, lvItemList);
    //绑定一级目录
    for I := 0 to lvItemList.Count - 1 do
    begin
      with tlItem.Add do
      begin
        Texts[tcolItemID.ItemIndex] := lvItemList.Items[I].ItemByName('FItemID').AsString;
        Texts[tcolItemCatalogID.ItemIndex] := lvSubjectID + ':' + lvItemList.Items[I].ItemByName('FItemCatalogID').AsString;
        Texts[tcolItemTypeID.ItemIndex] := lvItemList.Items[I].ItemByName('FItemTypeID').AsString;
        Texts[tcolItemData.ItemIndex] := lvItemList.Items[I].ItemByName('FItemData').AsString;
        Values[tcolItemFavorite.ItemIndex] := lvItemList.Items[I].ItemByName('FFavorite').AsBoolean;
        Values[tcolItemHotspot.ItemIndex] := lvItemList.Items[I].ItemByName('FHotspot').AsBoolean;
        Values[tcolItemFallible.ItemIndex] := lvItemList.Items[I].ItemByName('FFallible').AsBoolean;
        Texts[tcolItemNote.ItemIndex] := lvItemList.Items[I].ItemByName('FNote').AsString;
        Texts[tcolItemExplain.ItemIndex] := lvItemList.Items[I].ItemByName('FExplain').AsString;
      end;
    end;
  finally
    tlItem.EndUpdate;
    lvItemList.Clear;
    lvItemList.Free;
  end;
end;

function TfrmMergeKN.GetParent(ANode: TcxTreeListNode): string;
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

procedure TfrmMergeKN.btnMergeClick(Sender: TObject);
var
  I: Integer;
  lvSubject: TQMsgPack;
begin
  if not frmWebDecode.Visible then
    frmWebDecode.Show;
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
    lvSubject.Add('SubjectID', tlSubject.AbsoluteItems[I].Texts[tcolSubjectID.ItemIndex] + ':' + tlSubject.AbsoluteItems[I].Texts[tcolSubjectName.ItemIndex]);
    lvSubject.Add('SubjectTitle', tlSubject.AbsoluteItems[I].Texts[tcolSubjectTitle.ItemIndex]);
    lvSubject.Add('SubjectParent', GetParent(tlSubject.AbsoluteItems[I]));
    FSubjectJobGroup.Add(DoMergeSubject, lvSubject, False, jdfFreeAsObject);

  end;
  FSubjectJobGroup.Run;
end;

procedure TfrmMergeKN.DoMergeSubject(AJob: PQJob);
begin
  if cbbRange.ItemIndex = 0 then
  begin
    DestModule.AddSubject(TQMsgPack(AJob.Data));
    FCatalogJobGroup.Add(DoMergeCatalog, TQMsgPack(AJob.Data).Copy, False, jdfFreeAsObject);
  end
  else
  begin
    FSubjectJobGroup.Add(DoMergeItem, TQMsgPack(AJob.Data).Copy, False, jdfFreeAsObject);
  end;
  Workers.Post(DoReportSubject, TQMsgPack(AJob.Data).Copy, True, jdfFreeAsObject);
end;

procedure TfrmMergeKN.DoReportSubject(AJob: PQJob);
var
  lvSubjectID, lvSubjectName: string;
begin
  lvSubjectID := TQMsgPack(AJob.Data).ItemByName('SubjectID').AsString;
  lvSubjectName := TQMsgPack(AJob.Data).ItemByName('SubjectTitle').AsString;
  mmoSubject.Lines.Add(lvSubjectID + '-' + lvSubjectName);
end;

procedure TfrmMergeKN.DoneMergeSubject(Sender: TObject);
begin
  FCatalogJobGroup.Run;
end;

procedure TfrmMergeKN.DoMergeCatalog(AJob: PQJob);
var
  I: Integer;
  lvSubjectID: string;
  lvCatalog: TQMsgPack;
  lvPackList: TQMsgPackList;
begin
  lvPackList := TQMsgPackList.Create;
  try
    lvPackList.Clear;
    lvSubjectID := TQMsgPack(AJob.Data).ItemByName('SubjectID').AsString;
    SourceModule.GetCatalogList(lvSubjectID, lvPackList);
    for I := 0 to lvPackList.Count - 1 do
    begin
      lvCatalog := TQMsgPack.Create;
      lvCatalog.Add('CatalogID', lvPackList.Items[I].ItemByName('FID').AsString);
      lvCatalog.Add('CatalogTitle', lvPackList.Items[I].ItemByName('FTitle').AsString);
      lvCatalog.Add('CatalogType', lvPackList.Items[I].ItemByName('FType').AsString);
      lvCatalog.Add('CatalogSubjectID', lvSubjectID);

      DestModule.AddCatalog(lvCatalog);
      //
      Workers.Post(DoReportCatalog, lvCatalog, True, jdfFreeAsObject);
      //
      FItemJobGroup.Add(DoMergeItem, lvCatalog.Copy, True, jdfFreeAsObject);
    end;
  finally
    lvPackList.Clear;
    lvPackList.Free;
  end;
end;

procedure TfrmMergeKN.DoReportCatalog(AJob: PQJob);
var
  lvCatalogID, lvCatalogName: string;
begin
  if mmoCatalog.Lines.Count > 1000 then
    mmoCatalog.Lines.Clear;

  lvCatalogID := TQMsgPack(AJob.Data).ItemByName('CatalogSubjectID').AsString + ':' + TQMsgPack(AJob.Data).ItemByName('CatalogID').AsString;
  lvCatalogName := TQMsgPack(AJob.Data).ItemByName('CatalogTitle').AsString;
  mmoCatalog.Lines.Add(lvCatalogID + '-' + lvCatalogName);
end;

procedure TfrmMergeKN.DoneMergeCatalog(Sender: TObject);
begin
  //开始下一任务
  FItemJobGroup.Run;
end;

procedure TfrmMergeKN.DoMergeItem(AJob: PQJob);
var
  I: Integer;
  lvTable: string;
  lvSubjectID, lvCatalogID: string;
  lvItemList: TQMsgPackList;
begin
  lvItemList := TQMsgPackList.Create;
  try
    case cbbRange.ItemIndex of
      0:
        begin
          lvTable := 'All';      //去格式化将0017变化17的形式
          lvCatalogID := IntToStr(TQMsgPack(AJob.Data).ItemByName('CatalogID').AsInteger);
          lvSubjectID := TQMsgPack(AJob.Data).ItemByName('CatalogSubjectID').AsString;
          SourceModule.GetItemList(lvSubjectID, lvCatalogID, lvItemList);
        end;
      1:
        begin
          lvTable := 'T_Hotspot';
          lvSubjectID := TQMsgPack(AJob.Data).ItemByName('SubjectID').AsString;
          SourceModule.GetHotSpotItemList(lvSubjectID, lvItemList);
        end;
      2:
        begin
          lvTable := 'T_Fallible';
          lvSubjectID := TQMsgPack(AJob.Data).ItemByName('SubjectID').AsString;
          SourceModule.GetFallibleItemList(lvSubjectID, lvItemList);
        end;
    end;

    for I := 0 to lvItemList.Count - 1 do
    begin
      DestModule.AddItem(lvItemList[I], lvTable);
      Workers.Post(DoReportItem, lvItemList[I], True, jdfFreeAsObject);
    end;
  finally
    lvItemList.Clear;
    lvItemList.Free;
  end;
end;

procedure TfrmMergeKN.DoReportItem(AJob: PQJob);
var
  lvItemID: string;
begin
  if mmoItem.Lines.Count > 1000 then
    mmoItem.Lines.Clear;
  lvItemID := TQMsgPack(AJob.Data).ItemByName('FItemID').AsString;
  mmoItem.Lines.Add(lvItemID);
end;

procedure TfrmMergeKN.DoneMergeItem(Sender: TObject);
begin
  lblFinished.Caption := '完成时间:' + DateTimeToStr(Now);
  lblSubjectCount.Caption := Format('科目数量:%d', [mmoSubject.Lines.Count]);
  lblCatalogCount.Caption := Format('章节数量:%d', [mmoCatalog.Lines.Count]);
  lblItemCount.Caption := Format('题目数量:%d', [mmoItem.Lines.Count]);
  mmoItem.Lines.Add('任务完成');
end;

end.

