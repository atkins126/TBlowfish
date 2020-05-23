object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Blowfish class usage example'
  ClientHeight = 290
  ClientWidth = 870
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 870
    Height = 57
    Align = alTop
    Caption = 'Panel1'
    Padding.Left = 10
    Padding.Top = 15
    Padding.Right = 10
    Padding.Bottom = 10
    ShowCaption = False
    TabOrder = 0
    ExplicitLeft = 24
    object Label4: TLabel
      AlignWithMargins = True
      Left = 454
      Top = 19
      Width = 22
      Height = 24
      Align = alLeft
      Caption = 'Key:'
      Layout = tlCenter
      ExplicitHeight = 13
    end
    object Label3: TLabel
      AlignWithMargins = True
      Left = 14
      Top = 19
      Width = 30
      Height = 24
      Align = alLeft
      Caption = 'Input:'
      Layout = tlCenter
      ExplicitHeight = 13
    end
    object edtKey: TEdit
      AlignWithMargins = True
      Left = 482
      Top = 19
      Width = 229
      Height = 24
      Align = alLeft
      TabOrder = 1
      ExplicitTop = 27
    end
    object edtInput: TEdit
      AlignWithMargins = True
      Left = 50
      Top = 19
      Width = 398
      Height = 24
      Align = alLeft
      TabOrder = 0
      ExplicitLeft = 51
      ExplicitTop = 24
      ExplicitHeight = 19
    end
    object GridPanel1: TGridPanel
      AlignWithMargins = True
      Left = 717
      Top = 19
      Width = 139
      Height = 24
      Align = alClient
      Caption = 'GridPanel1'
      ColumnCollection = <
        item
          Value = 50.000000000000000000
        end
        item
          Value = 50.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = btnCipher
          Row = 0
        end
        item
          Column = 1
          Control = btnPlain
          Row = 0
        end>
      RowCollection = <
        item
          Value = 100.000000000000000000
        end>
      TabOrder = 2
      ExplicitLeft = 744
      ExplicitTop = 10
      ExplicitWidth = 185
      ExplicitHeight = 41
      DesignSize = (
        139
        24)
      object btnCipher: TButton
        Left = 1
        Top = 1
        Width = 68
        Height = 22
        Anchors = []
        Caption = 'Cipher!'
        TabOrder = 0
        OnClick = btnCipherClick
        ExplicitLeft = 0
        ExplicitTop = 0
      end
      object btnPlain: TButton
        Left = 69
        Top = 1
        Width = 69
        Height = 22
        Anchors = []
        Caption = 'To plain!'
        TabOrder = 1
        OnClick = btnPlainClick
        ExplicitTop = 10
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 57
    Width = 870
    Height = 233
    Align = alClient
    Caption = 'Panel1'
    Padding.Left = 5
    Padding.Top = 5
    Padding.Right = 5
    Padding.Bottom = 5
    TabOrder = 1
    ExplicitLeft = 144
    ExplicitTop = 152
    ExplicitWidth = 185
    ExplicitHeight = 41
    object Label1: TLabel
      Left = 6
      Top = 189
      Width = 858
      Height = 38
      Align = alBottom
      Caption = 
        'TBlowfish: implemented by Daniel Prado (github.com/dfeprado). I'#39 +
        'm thanks to Bruce Schneier (www.schneier.com), the creator of Bl' +
        'owfish algorithm.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      WordWrap = True
      ExplicitTop = 208
      ExplicitWidth = 855
    end
    object Output: TMemo
      Left = 6
      Top = 6
      Width = 858
      Height = 183
      Align = alClient
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
      ExplicitHeight = 208
    end
  end
end
