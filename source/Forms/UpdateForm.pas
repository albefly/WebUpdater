unit UpdateForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  RestAppUpdateInfo, Vcl.ComCtrls;

type
  TUpdateFormClass = class(TForm)
    lblNewVersion: TLabel;
    mmoNewVersion: TMemo;
    lblOldVersion: TLabel;
    mmoOldVersion: TMemo;
    btnUpgrade: TButton;
    btnDowngrade: TButton;
    prgDownload: TProgressBar;
    procedure FormActivate(Sender: TObject);
    procedure btnUpgradeClick(Sender: TObject);
    procedure btnDowngradeClick(Sender: TObject);
  private
    { Private declarations }
  public
    UpdateInfo:  RestAppUpdateInfoClass;
    procedure UpdateUI();
    { Public declarations }
  end;

var
  UpdateFormClass: TUpdateFormClass;

implementation

{$R *.dfm}

procedure TUpdateFormClass.btnDowngradeClick(Sender: TObject);
begin

   if (MessageDlg('Downgrade now?',mtConfirmation, [mbYes, mbNo], 0)) = mrYes then
   begin

   end;

end;

procedure TUpdateFormClass.btnUpgradeClick(Sender: TObject);
begin

   if (MessageDlg('Upgrade now?',mtConfirmation, [mbYes, mbNo], 0)) = mrYes then
   begin

   end;

end;

procedure TUpdateFormClass.FormActivate(Sender: TObject);
begin

    UpdateUI();

end;

procedure TUpdateFormClass.UpdateUI();

var
    enableUpgrade: Boolean;
    enableDowngrade: Boolean;


begin

    if (UpdateInfo = nil) then
        exit;

    lblNewVersion.Caption := 'New version available: ' + UpdateInfo.UpgradeToVersion;
    mmoNewVersion.Lines.Clear;
    mmoNewVersion.Lines.Add(UpdateInfo.UpgradeToDescription);

    lblOldVersion.Caption := 'Old version available: ' + UpdateInfo.DowngradeToVersion;
    mmoOldVersion.Lines.Clear;
    mmoOldVersion.Lines.Add(UpdateInfo.DowngradeToDescription);

    enableUpgrade := false;
    enableDowngrade := false;


    if (UpdateInfo.UpgradeToVersion <> '') then
        enableUpgrade := true;

    if (UpdateInfo.DowngradeToVersion <> '') then
        enableDowngrade := true;

    btnUpgrade.Enabled := enableUpgrade;
    mmoNewVersion.Enabled := enableUpgrade;

    btnDowngrade.Enabled := enableDowngrade;
    mmoOldVersion.Enabled := enableDowngrade;

end;

end.
