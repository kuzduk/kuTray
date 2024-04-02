unit Main;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, Dialogs, StdCtrls, Menus,
  IniFiles, ExtCtrls, ShellApi, XPMan,

  kuTray;


type
  TForm1 = class(TkuForm)
    btnMail: TButton;
    chWorkWithTray: TCheckBox;
    PanelTray: TPanel;
    lab_OnRestoreIcon: TLabel;
    chRunMinimizedToTray: TCheckBox;
    Panel_Minimize: TPanel;
    Label1: TLabel;
    ch_MinimizeToTrayR: TCheckBox;
    CheckBox2: TCheckBox;
    ch_MinimizeToBarL: TCheckBox;
    Panel1: TPanel;
    Label10: TLabel;
    ch_CloseToTrayR: TCheckBox;
    CheckBox1: TCheckBox;
    chCloseToTray: TCheckBox;
    cbIconOnRestore: TComboBox;
    Panel3: TPanel;
    Label2: TLabel;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    chCloseTotrayByEsc: TCheckBox;
    btnMinimizeToTray: TButton;
    pmTray: TPopupMenu;
    pm_top1: TMenuItem;
    pm_ShowForm2: TMenuItem;
    pm_FullScreen: TMenuItem;
    pm_MinimizeToTray: TMenuItem;
    N1: TMenuItem;
    pm_Close: TMenuItem;

    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure cbIconOnRestoreChange(Sender: TObject);
    procedure chWorkWithTrayClick(Sender: TObject);
    procedure chCloseToTrayClick(Sender: TObject);
    procedure btnMailClick(Sender: TObject);
    procedure btnMinimizeToTrayClick(Sender: TObject);

    procedure pm_CloseClick(Sender: TObject);
    procedure pm_MinimizeToTrayClick(Sender: TObject);
    procedure pm_FullScreenClick(Sender: TObject);
    procedure pm_ShowForm2Click(Sender: TObject);
    procedure pm_top1Click(Sender: TObject);



  end;

var
  Form1: TForm1;


implementation

{$R *.DFM}

uses Unit2;





{$REGION '   Form1   '}



//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH Show
procedure TForm1.FormShow(Sender: TObject);
begin

if not _FirstShow then exit;

_FirstShow := False;

ShowIconIn(_IconIn);

end;



//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH Destroy
procedure TForm1.FormDestroy(Sender: TObject);
var ini : TIniFile;

begin

ini := TiniFile.Create( ExtractFilePath(Application.ExeName) + 'settings.ini' );

try
  ini.Writebool     ( 'Settings', 'RunMinimizedToTray', chRunMinimizedToTray.Checked  );
  ini.Writebool     ( 'Settings', 'CloseTotray',        chCloseToTray.Checked         );
  ini.WriteInteger  ( 'Settings', 'IconIn',             IconInToInt                   );
  ini.Writebool     ( 'Settings', 'WorkWithTray',       _WorkWithTray              );

finally
  ini.Free;
end;

end;




{$ENDREGION}






{$REGION ' Tray sets '}


//------------------------------------------------------------------------------ OnRestore Icon
procedure TForm1.cbIconOnRestoreChange(Sender: TObject);
begin

_IconIn := IntToIconIn(Form1.cbIconOnRestore.ItemIndex);
ShowIconIn(_IconIn);
SetForegroundWindow(Self.Handle);

end;



//------------------------------------------------------------------------------ btnMinimizeToTray
procedure TForm1.btnMinimizeToTrayClick(Sender: TObject);
begin
MinimizeToTray;
end;



//------------------------------------------------------------------------------ Close To Tray
procedure TForm1.chWorkWithTrayClick(Sender: TObject);
begin

SetWorkWithTray(chWorkWithTray.Checked);
PanelTray.Visible := chWorkWithTray.Checked;
if chWorkWithTray.Checked
then cbIconOnRestoreChange(Sender);

end;



//------------------------------------------------------------------------------
procedure TForm1.chCloseToTrayClick(Sender: TObject);
begin

Form1.CloseToTray := chCloseToTray.Checked;

end;



//------------------------------------------------------------------------------ Сайт
procedure TForm1.btnMailClick(Sender: TObject);
begin
ShellExecute(Form1.Handle, nil, 'http://kuzduk.ru/delphi/kulibrary', nil, nil, SW_SHOWNORMAL);
end;



{$ENDREGION}







{$REGION '   pm   '}



//------------------------------------------------------------------------------ Close
procedure TForm1.pm_CloseClick(Sender: TObject);
begin
Form1.Close;
end;


//------------------------------------------------------------------------------ Full Screen
procedure TForm1.pm_FullScreenClick(Sender: TObject);
begin

case Self.BorderStyle
of

  bsNone:
      Self.BorderStyle := bsSizeable;


  bsSizeable:
      begin
        Self.BorderStyle := bsNone;

        case Self.WindowState
        of
          wsNormal: Self.WindowState := wsMaximized;

          wsMaximized:
          begin
             Self.WindowState := wsNormal;
             Self.WindowState := wsMaximized;
          end;
        end;
      end;

end;


end;


//------------------------------------------------------------------------------ Esc
procedure TForm1.pm_MinimizeToTrayClick(Sender: TObject);
begin

if not chCloseTotrayByEsc.Checked then exit;

MinimizeToTray;

end;


//------------------------------------------------------------------------------ Form 2
procedure TForm1.pm_ShowForm2Click(Sender: TObject);
begin
Form2.Show;
//Form2.Caption := inttostr(Form2.Handle);
end;


//------------------------------------------------------------------------------ Handle
procedure TForm1.pm_top1Click(Sender: TObject);
begin

ShowMessage('Application.Handle = '+inttostr(Application.Handle)+#13#10+
            'Application.MainFormHandle = '+ inttostr(Application.MainFormHandle)+#13#10+
            'GetActiveWindow = '+ inttostr(GetActiveWindow)+#13#10+
            'GetForegroundWindow = '+inttostr(GetForegroundWindow)
            );

end;


{$ENDREGION}










end.
