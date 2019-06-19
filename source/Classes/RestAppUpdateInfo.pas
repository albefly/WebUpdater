unit RestAppUpdateInfo;

interface
uses
    Windows, SysUtils, Classes;

type

    RestAppUpdateInfoClass = class(TObject)

    public

        UpdateInfoAvailable: boolean;
        Version: string;
        URL: string;
        Description: string;
        UpgradeToVersion: string;
        UpgradeToDescription: string;
        UpgradeToURL: string;
        DowngradeToVersion: string;
        DowngradeToURL: string;
        DowngradeToDescription: string;

        constructor Create();

    end;


implementation

{ RestAppUpdateInfoClass }

constructor RestAppUpdateInfoClass.Create;
begin
        UpdateInfoAvailable := false;
        Version := '';
        URL := '';
        Description := '';
        UpgradeToVersion := '';
        UpgradeToDescription := '';
        UpgradeToURL := '';
        DowngradeToVersion := '';
        DowngradeToURL := '';
        DowngradeToDescription := '';

end;

end.
