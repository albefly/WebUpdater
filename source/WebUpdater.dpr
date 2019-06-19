program WebUpdater;

uses
  Vcl.Forms,
  MainForm in 'Forms\MainForm.pas' {Form1},
  UpdateHelper in 'Classes\UpdateHelper.pas',
  UpdateForm in 'Forms\UpdateForm.pas' {Form2},
  RestAPI in 'Classes\RestAPI.pas',
  StaticHelper in 'Classes\StaticHelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
