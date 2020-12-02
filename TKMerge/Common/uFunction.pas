unit uFunction;

interface

uses
  System.SysUtils, RegularExpressions, System.StrUtils, FlyUtils.CnDES,
  FlyUtils.CnXXX.Common, Clipbrd;

function GetAppPath: string;

function GetDbPath: string;

function NewID(AID: string): string;

function Calc(C: Char): Integer;

function Decode(const lvSource: string): string;

function Decrypt(const AKey, AText: string): string;

procedure SaveToClipboard(const AText: string);

function Decode_KSBNew(const AText: string; const IsEncode: Boolean): string;

implementation

uses
  uWebDecode;

function GetAppPath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

function GetDbPath: string;
begin
  Result := GetAppPath + 'DB\';
end;

function NewID(AID: string): string;
var
  m_Pre: string;
  m_New: string;
begin
  m_Pre := TRegEx.Match(AID, '\D').Value;
  m_New := '1' + RightStr(AID, Length(AID) - 1);
  m_New := IntToStr(StrToInt(m_New) + 1);
  result := m_Pre + RightStr(m_New, Length(m_New) - 1);
end;

function Calc(C: Char): Integer;
var
  I: Integer;
begin
  if ((C >= 'A') and (C <= 'Z')) then
  begin
    I := Ord(C) - 65;
  end
  else if ((C >= 'a') and (C <= 'z')) then
  begin
    I := Ord(C) - 97 + 26;
  end
  else if ((C >= '0') and (C <= '9')) then
  begin
    I := Ord(C) - 48 + 26 + 26;
  end
  else
  begin
    case C of
      '+':
        I := 62;
      '/':
        I := 63;
      '=':
        I := 0;
    end;
  end;
  Result := I;
end;

function Decode(const lvSource: string): string;
var
  c, l: Integer;
  a, b: Integer;
  s: string;
begin

  s := '';

  c := 1;
  l := Length(lvSource);

  while (True) do
  begin
    while ((c < l) and (lvSource[c] <= ' ')) do
    begin
      Inc(c);
    end;

    if c = l then
      Break;

    a := (Calc(lvSource[c]) shl 18) + (Calc(lvSource[c + 1]) shl 12) + (Calc(lvSource[c + 2]) shl 6) + Calc(lvSource[c + 3]);
    //
    b := a shr 16 and 255;
    s := s + IntToHex(b, 2);

    if (lvSource[c + 2] = '=') then
      Break;

    b := a shr 8 and 255;
    s := s + IntToHex(b, 2);
    if (lvSource[c + 3] = '=') then
      Break;

    b := a and 255;
    s := s + IntToHex(b, 2);
    //
    c := c + 4;
  end;

  Result := s;
end;

function Decrypt(const AKey, AText: string): string;
begin
  Result := DESDecryptStrFromHex(Decode(AText), AKey, TEncoding.UTF8, TEncoding.UTF8, rlCRLF, rlCRLF, nil);
end;

procedure SaveToClipboard(const AText: string);
var
  clip: TClipboard;
begin
  clip := TClipboard.Create; {½¨Á¢}
  try
    clip.AsText := AText;
  finally
    clip.Free;  {ÊÍ·Å}
  end;

end;

function Decode_KSBNew(const AText: string; const IsEncode: Boolean): string;
begin
  if not IsEncode then
    Result := AText
  else
  begin
    frmWebDecode.SourceString := AText;
    Result := frmWebDecode.DestString;
  end;
end;

end.

