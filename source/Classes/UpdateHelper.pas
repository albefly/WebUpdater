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

  DownloadInfoUICallback = procedure (bytesTrnsferred: Int64; percentDone: Integer) of object;
  GetUpdateInfoCallback = procedure(updateInfo: RestAppUpdateInfoClass) of object;

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
    lastWorkCount: Int64;
    lastTicks: LongWord;


    procedure Download (URL: string; filePath: string);
    procedure HttpWorkBegin(sender: TObject; workMode: TWorkMode;
      workCountMax: Int64);
    procedure HttpWork(sender: TObject; workMode: TWorkMode;
      workCount: Int64);
    procedure HttpWorkEnd(sender: TObject; workMode: TWorkMode);

    procedure StartUpdate(URL: string);
    procedure restCallCompleted(resultCode: Integer; response: TJSONValue);

  end;

implementation

uses
  RestAPI, System.Threading, UpdateForm, NoPresizeFileStream, System.TimeSpan, StaticHelper, ShellApi;

{ RestAPIClass }

procedure UpdateHelperClass.AppUpdate(updateInfo: RestAppUpdateInfoClass);

var
  updateForm: TUpdateFormClass;

begin

  try

    updateForm := TUpdateFormClass.Create(nil);
    updateForm.updateInfo := updateInfo;
    updateForm.StartUpdate := StartUpdate;
    updateDownloadInfoCallback := updateForm.UpdateDownloadInfo;
    updateForm.ShowModal

  finally

    updateDownloadInfoCallback := nil;
    FreeAndNil(updateForm);

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

// download file and start update
procedure UpdateHelperClass.StartUpdate(URL: string);

var
    fileName: string;

begin

    fileName := StaticHelperClass.GetTempFile('.exe');
    Download(URL, fileName);
    if (FileExists(fileName)) then
    begin
        ShellExecute(0, 'open', PWideChar(fileName), nil, nil, SW_SHOWNORMAL);
        Application.Terminate;
        Exit;
    end;

end;

procedure UpdateHelperClass.Download(URL: string; filePath: string);

var
  buffer: TNoPresizeFileStream;
  httpClient: TIdHttp;

begin

  buffer := TNoPresizeFileStream.Create(filePath, fmCreate or fmShareDenyWrite);

  try
    httpClient := TIdHttp.Create(nil);
    try
      httpClient.OnWorkBegin := HttpWorkBegin;
      httpClient.OnWork := HttpWork;
      httpClient.OnWorkEnd := HttpWorkEnd;

      httpClient.Get(URL, buffer);
      // wait until it is done
    finally
      httpClient.Free;
    end;
  finally
    buffer.Free;
  end;
end;

procedure UpdateHelperClass.HttpWorkBegin(sender: TObject;
workMode: TWorkMode; workCountMax: Int64);
begin
  if workMode <> wmRead then
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

  totalBytes := workCountMax;
  lastWorkCount := 0;
  lastTicks := Ticks64;

end;

procedure UpdateHelperClass.HttpWork(sender: TObject; workMode: TWorkMode;
workCount: Int64);
var
  percentDone: Integer;
  elapsedMS: LongWord;
  bytesTransferred: Int64;
  bytesPerSec: Int64;

begin
  if workMode <> wmRead then
    exit;

  elapsedMS := GetTickDiff64(lastTicks, Ticks64);
  if elapsedMS = 0 then
    elapsedMS := 1; // avoid EDivByZero error

  if totalBytes > 0 then
    percentDone := Round((Double(workCount) / totalBytes) * 100.0)
  else
    percentDone := 0;

  bytesTransferred := workCount - lastWorkCount;

  // using just BytesTransferred and ElapsedMS, you can calculate
  // all kinds of speed stats - b/kb/mb/gm per sec/min/hr/day ...
  bytesPerSec := Round((Double(bytesTransferred) * 1000) / elapsedMS);

  if Assigned(updateDownloadInfoCallback) then
  begin
    updateDownloadInfoCallback(bytesTransferred, percentDone);
    Application.ProcessMessages;
  end;



  lastWorkCount := workCount;
  lastTicks := Ticks64;

end;

procedure UpdateHelperClass.HttpWorkEnd(sender: TObject; workMode: TWorkMode);
begin
  if workMode <> wmRead then
    exit;

  // finalize the status UI as needed...
end;

end.
