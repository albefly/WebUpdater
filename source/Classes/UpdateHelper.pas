// no additional checks for now
// let's assume everything is prepared

unit UpdateHelper;

interface

uses
  Windows, SysUtils, Classes, Forms, Graphics, Controls,
  System.JSON, System.JSON.Builders, System.JSON.Readers,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdGlobal,
  RestAppUpdateInfo;

type

    DownloadInfoUICallback = procedure (bytesTrnsferred: Int64; percentDone: Integer);

  GetUpdateInfoCallback = procedure(updateInfo: RestAppUpdateInfoClass)
    of object;

  UpdateHelperClass = class(TObject)

  public

    UpdateAllowed: Boolean; // Nothing will be done if false
    CurrentVersion: string; // current app version
    AppGUID: string;
    WebURL: string; // for the release
    WebDebugURL: string; // for the updating process debugging

    Parent: TObject;

    constructor Create();
    destructor Destroy(); override;

    procedure GetUpdateInfo(callback: GetUpdateInfoCallback);
    procedure AppUpdate(updateInfo: RestAppUpdateInfoClass);

  private

    updateInfoReceivedCallback: GetUpdateInfoCallback;
    updateDownloadInfoCallback: DownloadInfoUICallback;

    totalBytes: Int64;
    LastWorkCount: Int64;
    LastTicks: LongWord;


    procedure Download (URL: string; filePath: string);
    procedure HttpWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure HttpWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure HttpWorkEnd(ASender: TObject; AWorkMode: TWorkMode);

    procedure restCallCompleted(resultCode: Integer; response: TJSONValue);

  end;

implementation

uses
  RestAPI, System.Threading, UpdateForm, NoPresizeFileStream, System.TimeSpan;

{ RestAPIClass }

procedure UpdateHelperClass.AppUpdate(updateInfo: RestAppUpdateInfoClass);

var
  UpdateForm: TUpdateFormClass;

begin

  try

    UpdateForm := TUpdateFormClass.Create(nil);
    UpdateForm.updateInfo := updateInfo;
    UpdateForm.ShowModal;

  finally

    FreeAndNil(UpdateForm);

  end;

end;

constructor UpdateHelperClass.Create;
begin

end;

destructor UpdateHelperClass.Destroy;
begin

  inherited;
end;

procedure UpdateHelperClass.GetUpdateInfo(callback: GetUpdateInfoCallback);

var

  RestAPI: RestAPIClass;
  restTask: ITask;

begin

  if (UpdateAllowed = false) then
    exit;

  updateInfoReceivedCallback := callback;

  RestAPI := RestAPIClass.Create;
  RestAPI.WebURL := WebURL;
  RestAPI.AppID := AppGUID;
  RestAPI.AppVersion := CurrentVersion;
  RestAPI.ResponseCallback := restCallCompleted;
  restTask := TTask.Create(RestAPI.GetRest);
  restTask.Start;

end;

procedure UpdateHelperClass.restCallCompleted(resultCode: Integer;
  response: TJSONValue);

var

  a: Integer;
  updateInfo: RestAppUpdateInfoClass;
  tempString: string;

begin

  // Decode JSON
  updateInfo := RestAppUpdateInfoClass.Create;

  try

    if (resultCode = 200) and (response is TJSONObject) then // 200 OK; proceed
    begin

      updateInfo.Version := response.GetValue<string>('Version');
      updateInfo.Description := response.GetValue<string>('Description');
      updateInfo.URL := response.GetValue<string>('URL');

      updateInfo.UpgradeToVersion := response.GetValue<string>
        ('UpgradeToVersion');
      updateInfo.UpgradeToDescription := response.GetValue<string>
        ('UpgradeToDescription');
      updateInfo.UpgradeToURL := response.GetValue<string>('UpgradeToURL');

      updateInfo.DowngradeToVersion := response.GetValue<string>
        ('DowngradeToVersion');
      updateInfo.DowngradeToDescription := response.GetValue<string>
        ('DowngradeToDescription');
      updateInfo.DowngradeToURL := response.GetValue<string>('DowngradeToURL');

      updateInfo.UpdateInfoAvailable := true;

    end;

  except
  end;

  if (Assigned(updateInfoReceivedCallback)) then
    TThread.Synchronize(nil,
      procedure
      begin
        updateInfoReceivedCallback(updateInfo);
      end);
end;

procedure UpdateHelperClass.Download(URL: string; filePath: string);

var
  Buffer: TNoPresizeFileStream;
  HttpClient: TIdHttp;

begin

  Buffer := TNoPresizeFileStream.Create(filePath, fmCreate or fmShareDenyWrite);

  try
    HttpClient := TIdHttp.Create(nil);
    try
      HttpClient.OnWorkBegin := HttpWorkBegin;
      HttpClient.OnWork := HttpWork;
      HttpClient.OnWorkEnd := HttpWorkEnd;

      HttpClient.Get(URL, Buffer);
      // wait until it is done
    finally
      HttpClient.Free;
    end;
  finally
    Buffer.Free;
  end;
end;

procedure UpdateHelperClass.HttpWorkBegin(ASender: TObject;
AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  if AWorkMode <> wmRead then
    exit;

  // initialize the status UI as needed...
  //
  // If TIdHTTP is running in the main thread, update your UI
  // components directly as needed and then call the Form's
  // Update() method to perform a repaint, or Application.ProcessMessages()
  // to process other UI operations, like button presses (for
  // cancelling the download, for instance).
  //
  // If TIdHTTP is running in a worker thread, use the TIdNotify
  // or TIdSync class to update the UI components as needed, and
  // let the OS dispatch repaints and other messages normally...

  totalBytes := AWorkCountMax;
  LastWorkCount := 0;
  LastTicks := Ticks;

end;

procedure UpdateHelperClass.HttpWork(ASender: TObject; AWorkMode: TWorkMode;
AWorkCount: Int64);
var
  PercentDone: Integer;
  ElapsedMS: LongWord;
  BytesTransferred: Int64;
  BytesPerSec: Int64;

begin
  if AWorkMode <> wmRead then
    exit;

  ElapsedMS := GetTickDiff(LastTicks, Ticks);
  if ElapsedMS = 0 then
    ElapsedMS := 1; // avoid EDivByZero error

  if totalBytes > 0 then
    PercentDone := (Double(AWorkCount) / totalBytes) * 100.0
  else
    PercentDone := 0.0;

  BytesTransferred := AWorkCount - LastWorkCount;

  // using just BytesTransferred and ElapsedMS, you can calculate
  // all kinds of speed stats - b/kb/mb/gm per sec/min/hr/day ...
  BytesPerSec := (Double(BytesTransferred) * 1000) / ElapsedMS;

  if Assigned(updateDownloadInfoCallback) then
  begin
    updateDownloadInfoCallback(BytesTransferred, PercentDone);
    Application.ProcessMessages;
  end;



  LastWorkCount := AWorkCount;
  LastTicks := Ticks;

end;

procedure UpdateHelperClass.HttpWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  if AWorkMode <> wmRead then
    exit;

  // finalize the status UI as needed...
end;

end.
