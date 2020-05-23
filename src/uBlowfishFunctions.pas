unit uBlowfishFunctions;

interface

uses uBlowfishHeader, System.SysUtils;

type
  T8BytesBlocks = TArray<FixedUInt>;

// High level functions
function __cipher(const plain: string; const pArray: TPArray; const sboxes: TSBOXGroup): string;
function __plain(const cipher: string; const pArray: TPArray; const sboxes: TSBOXGroup): string;
function __createPArray(const key: string): TPArray; // (1)
procedure __initialize(var pArray: TPArray; out sboxes: TSBOXGroup); // (2)

// Low level functions (commonly used by High level functions, so, don't worry trying to understand then)
function __hashThe(const key: string): TBytes;
function __get8BytesBlocksOf(const bytes: TBytes): T8BytesBlocks;
function __blowfishFn(const halve: FixedUInt; sboxes: TSBOXGroup): FixedUInt;
procedure __splitHalvesTo8Bytes(var dest: TBytes; const L_halve, R_halve: FixedUInt; var ByteIdx: Cardinal);
procedure __encrypt(var L_halve, R_halve: FixedUInt; pArray: TPArray; sboxes: TSBOXGroup);
procedure __decrypt(var L_halve, R_halve: FixedUInt; pArray: TPArray; sboxes: TSBOXGroup);

implementation

uses
  System.Hash, System.Math, System.NetEncoding;

function __cipher(const plain: string; const pArray: TPArray; const sboxes: TSBOXGroup): string;
var
  _8BytesBlocksOfPlain: T8BytesBlocks;
  blocksCount, _8BIdx, ByteIdx: Cardinal;
  cipherBytes: TBytes;
  L_halve,
  R_halve: FixedUInt;
  function outputWithBase64(): string;
  var
    base64: TBase64Encoding;
  begin
    base64 := TBase64Encoding.Create();
    result := base64.EncodeBytesToString(cipherBytes);
    base64.Free();
  end;
begin
  // 1. Get 4 bytes blocks from the plain
  _8BytesBlocksOfPlain := __get8BytesBlocksOf(TEncoding.UTF8.GetBytes(plain));
  blocksCount := Length(_8BytesBlocksOfPlain);
  _8BIdx := 0;
  ByteIdx := 0;
  SetLEngth(cipherBytes, blocksCount * 4); // 4x because blocksCount is 32 bits (4 bytes)!
  // 2. For every 8 bytes blocks, encrypt halves and join their bytes to cipherBytes
  while (_8BIdx < blocksCount) do
  begin
    L_halve := _8BytesBlocksOfPlain[_8BIdx];
    R_halve := _8BytesBlocksOfPlain[_8BIdx + 1];
    __encrypt(L_halve, R_halve, pArray, sboxes);
    __splitHalvesTo8Bytes(cipherBytes, L_halve, R_halve, ByteIdx);
    _8BIdx := _8BIdx + 2;
  end;
  // output in base64
  result := outputWithBase64();
end;

function __plain(const cipher: string; const pArray: TPArray; const sboxes: TSBOXGroup): string;
var
  base64: TBase64Encoding;
  _8BytesBlocksCipher: T8BytesBlocks;
  cipherBlocksCount, _8BIdx, ByteIdx: Cardinal;
  plainBytes: TBytes;
  L_halve, R_halve: FixedUInt;
begin
  // same as cipher(), but using _decrypt.
  base64 := TBase64Encoding.Create();
  _8BytesBlocksCipher := __get8BytesBlocksOf(base64.DecodeStringToBytes(cipher));
  cipherBlocksCount := Length(_8BytesBlocksCipher);
  _8BIdx := 0;
  ByteIdx := 0;
  SetLEngth(plainBytes, cipherBlocksCount * 4);
  while (_8BIdx < cipherBlocksCount) do
  begin
    L_halve := _8BytesBlocksCipher[_8BIdx];
    R_halve := _8BytesBlocksCipher[_8BIdx + 1];
    __decrypt(L_halve, R_halve, pArray, sboxes);
    __splitHalvesTo8Bytes(plainBytes, L_halve, R_halve, ByteIdx);
    _8BIdx := _8BIdx + 2;
  end;
  result := TEncoding.UTF8.GetString(plainBytes);
  base64.Free();
end;

function __hashThe(const key: string): TBytes;
var
  hash: THashSHA1;
begin
  hash.Create();
  hash.Reset();
  hash.Update(key);
  result := hash.HashAsBytes();
end;

function __get8BytesBlocksOf(const bytes: TBytes): T8BytesBlocks;
var
  I, J, Jf: Integer;
  tmp: FixedUInt;
  blocksCount: Cardinal;
begin
  Jf := 0;
  blocksCount := ceil(Length(bytes)/4);
  SetLength(result, blocksCount);
  for I := 0 to blocksCount-1 do
  begin
    for J := Jf to Jf + 3 do
    begin
      if (J >= Length(bytes)) then break;
      tmp := bytes[J];
      result[I] := result[I] + tmp shl (8 * (3 - (J mod 4)));
      inc(Jf);
    end;
  end;
end;

function __createPArray(const key: string): TPArray;
var
  pArrayIdx, keyBlocks_sz: integer;
  keyBlocks: T8BytesBlocks;
begin
  // Copy the original P_Array to modification.
  SetLength(result, P_ARRAY_SZ);
  keyBlocks := __get8BytesBlocksOf(TEncoding.UTF8.GetBytes(key)); // get the 4 bytes blocks of the key
  keyBlocks_sz := Length(keyBlocks);
  // for each 4bytes in P_array, xor it with each 4 bytes of key
  for pArrayIdx := 0 to Length(P_ARRAY)-1 do
  begin
    result[pArrayIdx] := P_ARRAY[pArrayIdx] xor keyBlocks[pArrayIdx mod keyBlocks_sz]; // repeat blocks of key, if needed
  end;
end;

procedure __initialize(var pArray: TPArray; out sboxes: TSBOXGroup);
var
  L_halve, R_halve: FixedUInt;
  I: Cardinal;
  procedure initializeSBoxes(sboxes: TSBOXGroup);
  var
    I, J: Cardinal;
  begin
    for I := 0 to 3 do
    begin
      J := 0;
      while (J < S_BOX_SZ) do
      begin
        __encrypt(L_halve, R_halve, pArray, sboxes);
        sboxes[I][J] := L_halve;
        sboxes[I][J + 1] := R_halve;
        J := J + 2;
      end;
    end;
  end;
begin
  I := 0;
  L_halve := 0;
  R_halve := 0;
  // create a copy of original S_BOXES for later modification
  SetLength(sboxes, 4);
  for I := 0 to 3 do
  begin
    sboxes[I] := Copy(S_BOXES[I], 0, S_BOX_SZ);
  end;
  // p_array initialization
  while (I < P_ARRAY_SZ) do
  begin
    __encrypt(L_halve, R_halve, pArray, sboxes);
    pArray[I] := L_halve;
    pArray[I + 1] := R_halve;
    I := I + 2;
  end;
  // the copy of S_BOXES initialization
  initializeSBoxes(sboxes);
end;

procedure __splitHalvesTo8Bytes(var dest: TBytes; const L_halve, R_halve: FixedUInt; var ByteIdx: Cardinal);
begin
  dest[ByteIdx + 0] := L_halve shr 24;
  dest[ByteIdx + 1] := L_halve shr 16 and $ff;
  dest[ByteIdx + 2] := L_halve shr 8 and $ff;
  dest[ByteIdx + 3] := L_halve and $ff;
  dest[ByteIdx + 4] := R_halve shr 24;
  dest[ByteIdx + 5] := R_halve shr 16 and $ff;
  dest[ByteIdx + 6] := R_halve shr 8 and $ff;
  dest[ByteIdx + 7] := R_halve and $ff;
  ByteIdx := ByteIdx + 8;
end;

procedure __encrypt(var L_halve, R_halve: FixedUInt; pArray: TPArray; sboxes: TSBOXGroup);
var
  I: Cardinal;
  procedure swap();
  var
    tmp: FixedUInt;
  begin
    tmp := L_halve;
    L_halve := R_halve;
    R_halve := tmp;
  end;
begin
  for I := 0 to 15 do
  begin
    L_halve := L_halve xor pArray[I];
    R_halve := __blowfishFn(L_halve, sboxes) xor R_halve;
    swap();
  end;
  swap();
  R_halve := R_halve xor pArray[16];
  L_halve := L_halve xor pArray[17];
end;

procedure __decrypt(var L_halve, R_halve: FixedUInt; pArray: TPArray; sboxes: TSBOXGroup);
var
  I: integer;
  procedure swap();
  var
    tmp: FixedUInt;
  begin
    tmp := L_halve;
    L_halve := R_halve;
    R_halve := tmp;
  end;
begin
  for I := 17 downto 2 do
  begin
    L_halve := L_halve xor pArray[I];
    R_halve := __blowfishFn(L_halve, sboxes) xor R_halve;
    swap();
  end;
  swap();
  R_halve := R_halve xor pArray[1];
  L_halve := L_halve xor pArray[0];
end;

function __blowfishFn(const halve: FixedUInt; sboxes: TSBOXGroup): FixedUInt;
begin
  result := ((sboxes[0][halve shr 24] + sboxes[1][halve shr 16 and $ff] mod $ffffffff) xor sboxes[2][halve shr 8 and $ff]) + sboxes[3][halve and $ff] mod $ffffffff;
end;

end.
