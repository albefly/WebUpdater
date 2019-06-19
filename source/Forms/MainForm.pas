unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  UpdateHelper, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
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

    procedure UpdateInfoReceived(info: string);

    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
    StaticHelper;

{$R *.dfm}

procedure TForm1.btnCallUpdateClick(Sender: TObject);
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

procedure TForm1.FormCreate(Sender: TObject);
begin

    updateHelper := UpdateHelperClass.Create; // can provide all init info in constructor if needed

end;

procedure TForm1.UpdateInfoReceived(info: string);
begin
    memo.Lines.Add(info);
    memo.Lines.Add('');
    memo.Lines.Add('Request Completed...');
end;

end.
