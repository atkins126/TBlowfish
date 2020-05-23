program Sample;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {Form2},
  uBlowfish in '..\src\uBlowfish.pas',
  uBlowfishFunctions in '..\src\uBlowfishFunctions.pas',
  uBlowfishHeader in '..\src\uBlowfishHeader.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
