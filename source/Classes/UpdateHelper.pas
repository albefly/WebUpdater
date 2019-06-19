// no additional checks for now
// let's assume everything is prepared

unit UpdateHelper;

interface

uses
    Windows, SysUtils, Classes, Forms, Graphics, Controls;

type

    GetUpdateInfoCallback = procedure(info: string) of object;

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

    private

        getInfoCompleted: GetUpdateInfoCallback;
        procedure restCallCompleted(response: string);

    end;

implementation

uses
    RestAPI, System.Threading;

{ RestAPIClass }

constructor UpdateHelperClass.Create;
begin

end;

destructor UpdateHelperClass.Destroy;
begin

  inherited;
end;

procedure UpdateHelperClass.GetUpdateInfo(callback: GetUpdateInfoCallback);

var

    restAPI: RestAPIClass;
    restTask: ITask;

begin

    if (UpdateAllowed = false) then
        exit;

    getInfoCompleted := callback;

    restAPI := RestAPIClass.Create;
    restAPI.WebURL := WebURL;
    restAPI.AppID := AppGUID;
    restAPI.AppVersion := CurrentVersion;
    restAPI.ResponseCallback := restCallCompleted;
    restTask := TTask.Create(restAPI.GetRest);
    restTask.Start;


end;

procedure UpdateHelperClass.restCallCompleted(response: string);

var

    a: Integer;

begin

    TThread.Synchronize(nil, procedure
        begin
            getInfoCompleted(response);
        end);

end;

end.

