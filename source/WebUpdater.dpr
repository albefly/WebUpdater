program WebUpdater;

uses
  Vcl.Forms,
  MainForm in 'Forms\MainForm.pas' {MainFormClass},
  UpdateHelper in 'Classes\UpdateHelper.pas',
  UpdateForm in 'Forms\UpdateForm.pas' {UpdateFormClass},
  RestAPI in 'Classes\RestAPI.pas',
  StaticHelper in 'Classes\StaticHelper.pas',
  RestAppUpdateInfo in 'Classes\RestAppUpdateInfo.pas',
  NoPresizeFileStream in 'Classes\NoPresizeFileStream.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFormClass, MainFormClass);
  Application.Run;
end.
