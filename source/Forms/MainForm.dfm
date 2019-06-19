object MainFormClass: TMainFormClass
  Left = 0
  Top = 0
  Caption = 'Web Updater'
  ClientHeight = 411
  ClientWidth = 515
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 32
    Width = 23
    Height = 13
    Caption = 'URL:'
  end
  object lblAppGUID: TLabel
    Left = 18
    Top = 59
    Width = 55
    Height = 13
    Caption = 'App GUID::'
  end
  object edtURL: TEdit
    Left = 79
    Top = 29
    Width = 418
    Height = 21
    TabOrder = 0
    Text = 'https://alexhomepc.dlinkddns.com:20000/appupdate'
  end
  object btnCallUpdate: TButton
    Left = 400
    Top = 366
    Width = 97
    Height = 33
    Caption = 'Call Updater'
    TabOrder = 1
    OnClick = btnCallUpdateClick
  end
  object edtAppGUID: TEdit
    Left = 79
    Top = 56
    Width = 234
    Height = 21
    TabOrder = 2
    Text = 'C3230577-4412-4DF2-BA44-4FED1C2744C4'
  end
  object memo: TMemo
    Left = 18
    Top = 83
    Width = 479
    Height = 271
    TabOrder = 3
  end
end
