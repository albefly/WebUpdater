unit NoPresizeFileStream;

interface

uses
    Classes;

type
  TNoPresizeFileStream = class(TFileStream)
    procedure SetSize(const NewSize: Int64); override;
  end;

implementation

procedure TNoPresizeFileStream.SetSize(const NewSize: Int64);
begin
end;

end.
