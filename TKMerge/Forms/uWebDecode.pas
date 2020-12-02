unit uWebDecode;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.OleCtrls, SHDocVw, activex, MSHTML;

type
  TfrmWebDecode = class(TForm)
    wb: TWebBrowser;
    procedure FormCreate(Sender: TObject);
  strict private
  private
    FDestString: string;
    function Decode(const AText: string): string;
    procedure SetSourceString(const Value: string);
  public
    property SourceString: string write SetSourceString;
    property DestString: string read FDestString;
  end;

var
  frmWebDecode: TfrmWebDecode;

implementation

uses
  uFunction, System.Win.ComObj;

{$R *.dfm}

function TfrmWebDecode.Decode(const AText: string): string;
begin
  try
    wb.OleObject.Document.getElementByID('txtSrc').innerText := AText;
    wb.OleObject.Document.getElementByID('btnDecode').click;
    Result := wb.OleObject.Document.getElementByID('txtDest').innerText;
  except
    Result := 'Ω‚√‹¥ÌŒÛ:' + AText;
  end;
end;

procedure TfrmWebDecode.FormCreate(Sender: TObject);
var
  lvUrl: string;
begin
  lvUrl := GetAppPath + 'Encode.html';
  wb.Navigate(lvUrl);
end;

procedure TfrmWebDecode.SetSourceString(const Value: string);
begin
  FDestString := Decode(Value);
end;

end.

