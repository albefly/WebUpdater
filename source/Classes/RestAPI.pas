// RESTful API class

unit RestAPI;

interface

uses
    Windows, SysUtils, Classes, Forms, Graphics, Controls,
    System.JSON, System.JSON.Builders, System.JSON.Readers,
    REST.Utils, REST.Types, REST.Client, REST.Response.Adapter;

type

    RestTaskCallback = procedure(resultCode: Integer; response: TJSONValue) of object;
    RestAPIClass = class(TObject)

    public

        WebURL: string;
        AppID: string;
        AppVersion: string;
        ResponseCallback: RestTaskCallback;

        constructor Create();
        destructor Destroy(); override;

        procedure GetRest();

    private

        restClient      : TRESTClient;
        restRequest     : TRESTRequest;
        restResponse    : TRESTResponse;

    end;

implementation

uses Dialogs;

{ RestAPIClass }

constructor RestAPIClass.Create;
begin

    restClient              := TRESTClient.Create(nil);
    restRequest             := TRESTRequest.Create(nil);
    restResponse            := TRESTResponse.Create(nil);

    restRequest.Client      := restClient;
    restRequest.Response    := restResponse;

end;

destructor RestAPIClass.Destroy;
begin

  inherited;
end;

procedure RestAPIClass.GetRest();

begin

    // hardcoded to use just 1 request
    restRequest.Params.Clear;

    restRequest.Params.AddItem;
    restRequest.Params[0].name     := 'type';
    restRequest.Params[0].value    := 'json';

    restRequest.Params.AddItem;
    restRequest.Params[1].name     := 'versionInfo';
    restRequest.Params[1].value    := AppVersion;

    restClient.BaseURL := WebURL + '/api/AppUpdate/GetAppInfo/' + AppID;

    try

        try
           restRequest.Execute;
        except
            // on E : Exception do
            // ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
        end;

    finally
        ResponseCallback(restResponse.StatusCode,  restResponse.JSONValue);
    end;

end;

end.
