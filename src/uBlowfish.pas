unit uBlowfish;

interface

uses uBlowfishHeader, System.SysUtils;

type
  T32bitsBlocks = TArray<FixedUInt>;

// High level functions
function __cipher(const plain: string; const pArray: TPArray; const sbox0, sbox1, sbox2, sbox3: TSBOX): string;
function __plain(const cipher: string; const pArray: TPArray; const sbox0, sbox1, sbox2, sbox3: TSBOX): string;
function __createPArray(const key: string): TPArray;
procedure __initialize(var pArray: TPArray; out sbox0, sbox1, sbox2, sbox3: TSBOX);

// Low level functions (commonly used by High level functions, so, don't worry trying to understand then)
function __hashThe(const key: string): TBytes;
function __getBitsBlocksOf(const bytes: TBytes): T32bitsBlocks;
function __blowfishFn(const halve: FixedUInt; sbox0, sbox1, sbox2, sbox3: TSBOX): FixedUInt;
procedure __encrypt(var L_halve, R_halve: FixedUInt; pArray: TPArray; sbox0, sbox1, sbox2, sbox3: TSBOX);
procedure __decrypt(var L_halve, R_halve: FixedUInt; pArray: TPArray; sbox0, sbox1, sbox2, sbox3: TSBOX);

implementation

uses
  System.Hash, System.Math, System.NetEncoding;

function __cipher(const plain: string; const pArray: TPArray; const sbox0, sbox1, sbox2, sbox3: TSBOX): string;
var
  _32bitsBlocksOfData: T32bitsBlocks;
  blocksCount, I, J: Integer;
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
  _32bitsBlocksOfData := __getBitsBlocksOf(TEncoding.UTF8.GetBytes(plain));
  blocksCount := Length(_32bitsBlocksOfData);
  I := 0;
  J := 0;
  SetLEngth(cipherBytes, blocksCount * 4);
  while (I < blocksCount) do
  begin
    L_halve := _32bitsBlocksOfData[I];
    R_halve := _32bitsBlocksOfData[I + 1];
    __encrypt(L_halve, R_halve, pArray, sbox0, sbox1, sbox2, sbox3);
    cipherBytes[J + 0] := L_halve shr 24;
    cipherBytes[J + 1] := L_halve shr 16 and $ff;
    cipherBytes[J + 2] := L_halve shr 8 and $ff;
    cipherBytes[J + 3] := L_halve and $ff;
    cipherBytes[J + 4] := R_halve shr 24;
    cipherBytes[J + 5] := R_halve shr 16 and $ff;
    cipherBytes[J + 6] := R_halve shr 8 and $ff;
    cipherBytes[J + 7] := R_halve and $ff;
    I := I + 2;
    J := J + 8;
  end;
  result := outputWithBase64();
end;

function __plain(const cipher: string; const pArray: TPArray; const sbox0, sbox1, sbox2, sbox3: TSBOX): string;
var
  base64: TBase64Encoding;
  cipherBitsBlocks: T32bitsBlocks;
  blocksCount, I, J: integer;
  plainBytes: TBytes;
  L_halve, R_halve: FixedUInt;
begin
  base64 := TBase64Encoding.Create();
  cipherBitsBlocks := __getBitsBlocksOf(base64.DecodeStringToBytes(cipher));
  blocksCount := Length(cipherBitsBlocks);
  I := 0;
  J := 0;
  SetLEngth(plainBytes, blocksCount * 4);
  while (I < blocksCount) do
  begin
    L_halve := cipherBitsBlocks[I];
    R_halve := cipherBitsBlocks[I + 1];
    __decrypt(L_halve, R_halve, pArray, sbox0, sbox1, sbox2, sbox3);
    plainBytes[J + 0] := L_halve shr 24;
    plainBytes[J + 1] := L_halve shr 16 and $ff;
    plainBytes[J + 2] := L_halve shr 8 and $ff;
    plainBytes[J + 3] := L_halve and $ff;
    plainBytes[J + 4] := R_halve shr 24;
    plainBytes[J + 5] := R_halve shr 16 and $ff;
    plainBytes[J + 6] := R_halve shr 8 and $ff;
    plainBytes[J + 7] := R_halve and $ff;
    I := I + 2;
    J := J + 8;
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

function __getBitsBlocksOf(const bytes: TBytes): T32bitsBlocks;
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
      tmp := bytes[J];
      result[I] := result[I] + tmp shl (8 * (3 - (J mod 4)));
    end;
    Jf := J;
  end;
end;

function __createPArray(const key: string): TPArray;
var
  I, keyBlocks_sz: integer;
  keyBlocks: T32bitsBlocks;
begin
  SetLength(result, P_ARRAY_SZ);
  keyBlocks := __getBitsBlocksOf(TEncoding.UTF8.GetBytes(key));
  keyBlocks_sz := Length(keyBlocks);
  for I := 0 to Length(P_ARRAY)-1 do
  begin
    result[I] := P_ARRAY[I] xor keyBlocks[I mod keyBlocks_sz];
  end;
end;

procedure __initialize(var pArray: TPArray; out sbox0, sbox1, sbox2, sbox3: TSBOX);
var
  L_halve, R_halve: FixedUInt;
  I: Integer;
  procedure produceCopiesOfSBoxs();
  begin
    sbox0 := Copy(S_BOX0, 0, S_BOX_SZ);
    sbox1 := Copy(S_BOX1, 0, S_BOX_SZ);
    sbox2 := Copy(S_BOX2, 0, S_BOX_SZ);
    sbox3 := Copy(S_BOX3, 0, S_BOX_SZ);
  end;
  procedure initializeSBox(sbox: TSBOX);
  var
    I: integer;
  begin
    I := 0;
    while (I < S_BOX_SZ) do
    begin
      __encrypt(L_halve, R_halve, pArray, sbox0, sbox1, sbox2, sbox3);
      sbox[I] := L_halve;
      sbox[I + 1] := R_halve;
      I := I + 2;
    end;
  end;
begin
  I := 0;
  L_halve := 0;
  R_halve := 0;
  produceCopiesOfSBoxs();
  while (I < P_ARRAY_SZ) do
  begin
    __encrypt(L_halve, R_halve, pArray, sbox0, sbox1, sbox2, sbox3);
    pArray[I] := L_halve;
    pArray[I + 1] := R_halve;
    I := I + 2;
  end;
  initializeSBox(sbox0);
  initializeSBox(sbox1);
  initializeSBox(sbox2);
  initializeSBox(sbox3);
end;

procedure __encrypt(var L_halve, R_halve: FixedUInt; pArray: TPArray; sbox0, sbox1, sbox2, sbox3: TSBOX);
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
  for I := 0 to 15 do
  begin
    L_halve := L_halve xor pArray[I];
    R_halve := __blowfishFn(L_halve, sbox0, sbox1, sbox2, sbox3) xor R_halve;
    swap();
  end;
  swap();
  R_halve := R_halve xor pArray[16];
  L_halve := L_halve xor pArray[17];
end;

procedure __decrypt(var L_halve, R_halve: FixedUInt; pArray: TPArray; sbox0, sbox1, sbox2, sbox3: TSBOX);
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
    R_halve := __blowfishFn(L_halve, sbox0, sbox1, sbox2, sbox3) xor R_halve;
    swap();
  end;
  swap();
  R_halve := R_halve xor pArray[1];
  L_halve := L_halve xor pArray[0];
end;

function __blowfishFn(const halve: FixedUInt; sbox0, sbox1, sbox2, sbox3: TSBOX): FixedUInt;
begin
  result := ((sbox0[halve shr 24] + sbox1[halve shr 16 and $ff] mod $ffffffff) xor sbox2[halve shr 8 and $ff]) + sbox3[halve and $ff] mod $ffffffff;
end;

end.
