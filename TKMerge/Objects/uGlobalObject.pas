unit uGlobalObject;

interface

uses
  uType, uDestModule;

procedure InitObjects;
procedure UnInitObjects();

var
  DoConnectEvent: TDbConnectEvent;
  DestModule: TDestModule;

implementation

procedure InitObjects;
begin
  DestModule := TDestModule.Create(nil);
end;

procedure UnInitObjects();
begin
  DestModule.Free;
end;

end.

