program kuTrayDEMO;

uses
  Forms,
  kuFiles,
  IniFiles,
  SysUtils,
  Windows,
  kuModul,
  kuTray, //������ ������ � ����� ����� uses ����� ������� ��� ����� � Source �� ��� ��������� �������������� ���������� �� ����� ������ ���� (� ������� �� ��������� ������ � ����)
  Main in 'Main.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2};

{$R *.RES}

var
  i: integer;
  s: string;
  ini: TIniFile;

begin
Application.Initialize;
Application.Title := 'kuTrayDEMO';
Application.CreateForm(TForm1, Form1);
Application.CreateForm(TForm2, Form2);



{$REGION '  settings.ini   '}


s := Path_setini;

if FileExists(s)

then
begin

  ini := TiniFile.Create(s);

  try
      //WorkWithTray
      _CanWorkWithTray := ini.ReadBool( 'Settings', 'WorkWithTray', True );
      Form1.chWorkWithTray.Checked := _CanWorkWithTray;


      //Close to tray
      Form1.CloseToTray := ini.ReadBool('Settings', 'CloseTotray', Form1.chCloseToTray.Checked);
      Form1.chCloseToTray.Checked := Form1.CloseToTray;


      //Icon in
      i := ini.ReadInteger( 'Settings', 'IconIn', 2 );
      Form1.cbIconOnRestore.ItemIndex := i;
      _IconIn := IntToIconIn(i);
      //����� � Form1.OnShow ����� ShowIconIn


      //Run minimized to tray
      Form1.chRunMinimizedToTray.Checked := ini.ReadBool('Settings', 'RunMinimizedToTray', Form1.chRunMinimizedToTray.Checked);
      if Form1.chRunMinimizedToTray.Checked and _CanWorkWithTray then MinimizeToTray;

  finally
      ini.Free;
  end;

end

else
begin
    //Icon in
    _IconIn := IntToIconIn(Form1.cbIconOnRestore.ItemIndex);

    //Close to tray
    Form1.CloseToTray := Form1.chCloseToTray.Checked;
end;



_PopupMenuTray := Form1.pmTray;



{$ENDREGION}



//������ ����������� Form1.Show � ������� ��������� ShowIconIn


Application.Run;
end.
