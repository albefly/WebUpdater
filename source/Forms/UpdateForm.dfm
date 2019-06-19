object UpdateFormClass: TUpdateFormClass
  Left = 0
  Top = 0
  Caption = 'New / Old version available'
  ClientHeight = 447
  ClientWidth = 444
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object lblNewVersion: TLabel
    Left = 24
    Top = 24
    Width = 108
    Height = 13
    Caption = 'New version available:'
  end
  object lblOldVersion: TLabel
    Left = 24
    Top = 184
    Width = 103
    Height = 13
    Caption = 'Old version available:'
  end
  object mmoNewVersion: TMemo
    Left = 56
    Top = 43
    Width = 337
    Height = 113
    TabOrder = 0
  end
  object mmoOldVersion: TMemo
    Left = 56
    Top = 203
    Width = 337
    Height = 113
    TabOrder = 1
  end
  object btnUpgrade: TButton
    Left = 288
    Top = 384
    Width = 105
    Height = 33
    Caption = 'Upgrade'
    TabOrder = 2
    OnClick = btnUpgradeClick
  end
  object btnDowngrade: TButton
    Left = 160
    Top = 384
    Width = 105
    Height = 33
    Caption = 'Downgrade'
    TabOrder = 3
    OnClick = btnDowngradeClick
  end
  object prgDownload: TProgressBar
    Left = 56
    Top = 344
    Width = 337
    Height = 17
    TabOrder = 4
    Visible = False
  end
end
