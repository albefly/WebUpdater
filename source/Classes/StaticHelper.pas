unit StaticHelper;

interface

type

    StaticHelperClass = class(TObject)

public

    class function GetAppVersion(): string;
    class function GetTempFile(const Extension: string): string;

private

    class procedure GetBuildInfo(var V1, V2, V3, V4: word);

end;

implementation

uses
    Windows, Classes, SysUtils;

{ StaticHelperClass }

class function StaticHelperClass.GetAppVersion: string;
var
  V1, V2, V3, V4: word;
begin
  GetBuildInfo(V1, V2, V3, V4);
  Result := IntToStr(V1) + '.' + IntToStr(V2) + '.' +
    IntToStr(V3) + '.' + IntToStr(V4);
end;

class procedure StaticHelperClass.GetBuildInfo(var V1, V2, V3, V4: word);
var
  VerInfoSize, VerValueSize, Dummy: DWORD;
  VerInfo: Pointer;
  VerValue: PVSFixedFileInfo;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if VerInfoSize > 0 then
  begin
      GetMem(VerInfo, VerInfoSize);
      try
        if GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo) then
        begin
          VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
          with VerValue^ do
          begin
            V1 := dwFileVersionMS shr 16;
            V2 := dwFileVersionMS and $FFFF;
            V3 := dwFileVersionLS shr 16;
            V4 := dwFileVersionLS and $FFFF;
          end;
        end;
      finally
        FreeMem(VerInfo, VerInfoSize);
      end;
  end;
end;

class function StaticHelperClass.GetTempFile(const Extension: string): string;
var
  charBuffer: array[0..MAX_PATH - 1] of Char;
  filename: string;
  aFile: string;
begin

    GetTempPath(MAX_PATH, charBuffer);
    GetTempFileName(charBuffer, '~', 0, charBuffer);
    Result := ChangeFileExt(charBuffer, Extension);

end;

end.
