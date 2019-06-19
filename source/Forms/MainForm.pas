unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  UpdateHelper, Vcl.StdCtrls, RestAppUpdateInfo;

type
  TMainFormClass = class(TForm)
    Label1: TLabel;
    edtURL: TEdit;
    btnCallUpdate: TButton;
    lblAppGUID: TLabel;
    edtAppGUID: TEdit;
    memo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btnCallUpdateClick(Sender: TObject);
  private

    updateHelper: UpdateHelperClass;

    procedure UpdateInfoReceived(updateInfo: RestAppUpdateInfoClass);

    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainFormClass: TMainFormClass;

implementation

uses
    StaticHelper;

{$R *.dfm}

procedure TMainFormClass.btnCallUpdateClick(Sender: TObject);
begin

    memo.Lines.Add('Request Invoked...');
    updateHelper.UpdateAllowed := true;
    updateHelper.AppGUID := edtAppGUID.Text;
    updateHelper.CurrentVersion := StaticHelperClass.GetAppVersion;
    updateHelper.WebURL := edtURL.Text;
    updateHelper.GetUpdateInfo(UpdateInfoReceived);
    memo.Lines.Add('Request Sent...');
    memo.Lines.Add('');


end;

procedure TMainFormClass.FormCreate(Sender: TObject);
begin

    updateHelper := UpdateHelperClass.Create; // can provide all init info in constructor if needed
    memo.Lines.Add('App version: ' + StaticHelperClass.GetAppVersion);

end;

procedure TMainFormClass.UpdateInfoReceived(updateInfo: RestAppUpdateInfoClass);
begin
    // memo.Lines.Add(info);

    memo.Lines.Add('Request Completed...');
    memo.Lines.Add('');

    if (updateInfo.UpdateInfoAvailable = false) then
    begin
        MessageDlg('Update server error.', mtInformation, [mbOK], 0);
    end;

    if (updateInfo.UpgradeToVersion <> '') or (updateInfo.DowngradeToVersion <> '') then
        updateHelper.AppUpdate(updateInfo);


end;

end.
