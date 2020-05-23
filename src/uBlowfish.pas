unit uBlowfish;

interface

uses uBlowfishHeader, uBlowfishFunctions;

type
  TBlowfish = class (TObject)
    private
      pArray: TPArray;
      s_boxes: TSBOXGroup;
      constructor Create(); overload;
    public
      constructor Create(const key: string); overload;
      function cipher(const plain: string): string; // encode plain
      function plain(const cipher: string): string; // decode cipher
      class function fromExisting(blowfish: TBlowfish): TBlowfish; // create a copy of an existing blowfish object
        // fromExisting is intended to use in multi-threaded applications. With copies of __initialized__ blowfish, you
        // don't need to do creation again (initialization can be overhead) or block cipher() and plain() with
        // critical section/mutex. However, the amount of memory used by the program will increase.
        // Every TBlowfish instance consumes 4.168 bytes of memory.
  end;

implementation

uses
  System.SysUtils;

{ TBlowfish }

function TBlowfish.cipher(const plain: string): string;
begin
  result := __cipher(plain, pArray, s_boxes);
end;

constructor TBlowfish.Create(const key: string);
begin
  if (key.IsEmpty()) then raise EArgumentException.Create('[TBlowfish::create] The key cannot be empty.');
  pArray := __createPArray(key);
  __initialize(pArray, s_boxes);
end;

constructor TBlowfish.Create;
begin
  // this create cannot be called from outside
end;

class function TBlowfish.fromExisting(blowfish: TBlowfish): TBlowfish;
var
  I: Integer;
begin
  if (not Assigned(blowfish)) then raise EAccessViolation.Create('[TBlowfish::fromExisting()] You need to provide and existing instance of Blowfish.');
  result := TBlowfish.Create();
  result.pArray := Copy(blowfish.pArray, 0, P_ARRAY_SZ);
  SetLength(result.s_boxes, 4);
  for I := 0 to 3 do
  begin
    result.s_boxes[I] := Copy(blowfish.s_boxes[I], 0, S_BOX_SZ);
  end;
end;

function TBlowfish.plain(const cipher: string): string;
begin
  result := __plain(cipher, pArray, s_boxes);
end;

end.
