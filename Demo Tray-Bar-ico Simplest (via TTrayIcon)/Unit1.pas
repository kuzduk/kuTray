unit Unit1;

interface

uses
  Windows, Variants, Forms, StdCtrls, Controls, Classes, ExtCtrls;

type
  TForm1 = class(TForm)
    TrayIcon1: TTrayIcon;
    cb_IconOnRestore: TComboBox;
    procedure cb_IconOnRestoreChange(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}



procedure TForm1.cb_IconOnRestoreChange(Sender: TObject);
begin


case cb_IconOnRestore.ItemIndex of

  0://None
  begin
    TrayIcon1.Visible := False;
    ShowWindow(Application.Handle, SW_HIDE);
  end;


  1://Bar
  begin
    TrayIcon1.Visible := False;
    ShowWindow(Application.Handle, SW_SHOW);
  end;


  2://Tray
  begin
    TrayIcon1.Visible := True;
    ShowWindow(Application.Handle, SW_HIDE);
  end;


  3://Bar & Tray
  begin
    TrayIcon1.Visible := True;
    ShowWindow(Application.Handle, SW_SHOW);
  end;

end;


end;






procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
Application.Restore;
end;

end.
