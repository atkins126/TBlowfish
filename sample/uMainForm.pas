unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, uBlowfish;

type
  TForm2 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Output: TMemo;
    Label1: TLabel;
    edtKey: TEdit;
    Label4: TLabel;
    Label3: TLabel;
    edtInput: TEdit;
    GridPanel1: TGridPanel;
    btnCipher: TButton;
    btnPlain: TButton;
    procedure btnCipherClick(Sender: TObject);
    procedure btnPlainClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    blowfish: TBlowfish; // the blowfish instance
    lastUsedKey: string; // to track changes on key
    function keyChanged(): boolean;
    function checkKey(): boolean;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.btnCipherClick(Sender: TObject);
begin
  if (not checkKey()) then exit();
  Output.Lines.Text := blowfish.cipher(edtInput.Text);
end;

procedure TForm2.btnPlainClick(Sender: TObject);
begin
  if (not checkKey()) then exit();
  Output.Lines.Text := blowfish.plain(edtInput.Text);
end;

function TForm2.checkKey: boolean;
begin
  result := true;
  if (keyChanged()) then
  begin
    blowfish.Free();
    blowfish := TBlowfish.Create(edtKey.Text);
  end;
  if (lastUsedKey.IsEmpty()) then
  begin
    ShowMessage('You need to provide an key!');
    result := false;
  end;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  blowfish.Free();
end;

function TForm2.keyChanged: boolean;
begin
  result := edtKey.Text <> lastUsedKey;
  if (result) then lastUsedKey := edtKey.Text;
end;

end.
