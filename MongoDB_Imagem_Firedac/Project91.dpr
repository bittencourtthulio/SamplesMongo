program Project91;

uses
  Vcl.Forms,
  Unit91 in 'Unit91.pas' {Form91};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm91, Form91);
  Application.Run;
end.
