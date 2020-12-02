program TKMerge;

uses
  Vcl.Forms,
  uMain in 'Forms\uMain.pas' {frmMain},
  uGlobalObject in 'Objects\uGlobalObject.pas',
  uDestModule in 'Modules\uDestModule.pas' {DestModule: TDataModule},
  uDBConnect in 'Forms\uDBConnect.pas' {frmDbConnect},
  uType in 'Common\uType.pas',
  uSourceModule in 'Modules\uSourceModule.pas' {SourceModule: TDataModule},
  uSourceModule_XT in 'Modules\uSourceModule_XT.pas' {SourceModule_XT: TDataModule},
  uMergeKO in 'Forms\uMergeKO.pas' {frmMergeKO},
  uMergeKN in 'Forms\uMergeKN.pas' {frmMergeKN},
  uMergeXT in 'Forms\uMergeXT.pas' {frmMergeXT},
  uSourceModule_KO in 'Modules\uSourceModule_KO.pas' {SourceModule_KO: TDataModule},
  FlyUtils.CnDES in 'Common\FlyUtils.CnDES.pas',
  FlyUtils.CnXXX.Common in 'Common\FlyUtils.CnXXX.Common.pas',
  uFunction in 'Common\uFunction.pas',
  uWebDecode in 'Forms\uWebDecode.pas' {frmWebDecode},
  uSourceModule_KN in 'Modules\uSourceModule_KN.pas' {SourceModule_KN: TDataModule},
  uImageKN in 'Forms\uImageKN.pas' {frmImageKN},
  uImageXT in 'Forms\uImageXT.pas' {frmImageXT};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  try
    InitObjects;
    Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmMergeKN, frmMergeKN);
  Application.CreateForm(TfrmMergeXT, frmMergeXT);
  Application.CreateForm(TfrmMergeKO, frmMergeKO);
  Application.CreateForm(TfrmDbConnect, frmDbConnect);
  Application.CreateForm(TfrmWebDecode, frmWebDecode);
  Application.CreateForm(TfrmImageKN, frmImageKN);
  Application.CreateForm(TfrmImageXT, frmImageXT);
  Application.Run;
  finally
    UnInitObjects;
  end;
end.

