unit kuTray;
{
������ 2022

��������� ����:
1) ������������� ���������� �� �������, ����� ��������� ����������, � ������ � ���� �� ����������.
��� ������ ��������: � Form.Close ������ BarIcon_Hide � TrayIcon_Hide.
������: �������� ���������� _nidata

2) �� �������� ShowIconIn �� � kuForm.Create, �� � Application.Source - �� ��������� ������ �� Bar
����� ��������: Form.Show + _FirstShow
�������� �������: ����� ShowIconIn � kuForm.Create ���� ��������

TkuForm �������� ������ �������� TForm:
1) TkuForm ����� ������ ������ ��� Application.MainForm
2) TkuForm ������������ �������� ������� �� ������ � ��������� �����: ��������������, ����������, �������
3) TkuForm ����� �������� CloseToTray - ���� ��� True �� ��� ������� �� ������ [�] � ��������� ���� ����� �� ���������� �������� � ����. - ���������� ��������� ������� � inherited OnCloseQuery
}

interface


uses Windows, Messages, SysUtils, Forms, Dialogs, ActiveX, ShellApi, Controls,
     Classes, Menus, Types, Graphics, StdCtrls, GraphUtil;


const
  WM_MYICONNOTIFY = WM_USER + 123;


type
  TIconInType = (inNone, inBar, inTray, inBarAndTray);

  TkuForm = class(TForm)

    private
      fCloseToTray: Boolean;
      fButtonInCaption: integer; //������ � ��������� ���� ��� ������� MouseDn

    protected
      procedure SetCloseToTray(Value: Boolean);

    public
      constructor Create(AOwner: TComponent); override;
      procedure  Loaded; override;
      destructor Destroy; override;

      procedure WndProc(var msg: TMessage); override;

      procedure xxxApplicationRestore(Sender: TObject);
      procedure xxxApplicationMinimize(Sender: TObject);

      procedure TrayEvents(var msg: TMessage); message WM_MYICONNOTIFY;

      procedure MouseDnL(var msg: TMessage); message WM_NCLBUTTONDOWN;
      procedure MouseDnM(var msg: TMessage); message WM_NCMBUTTONDOWN;
      procedure MouseDnR(var msg: TMessage); message WM_NCRBUTTONDOWN;

      procedure MouseUpL(var msg: TMessage); message WM_NCLBUTTONUP;
      procedure MouseUpM(var msg: TMessage); message WM_NCMBUTTONUP;
      procedure MouseUpR(var msg: TMessage); message WM_NCRBUTTONUP;

      property CloseToTray: Boolean read fCloseToTray write SetCloseToTray default false;
  end;


var
  _CanWorkWithTray: Boolean = True;
  _FirstShow: Boolean = True;
//  _RunMinimizedToTray: Boolean = False; //��������� ��������� �������� � ����
  _IconIn: TIconInType = inBar;           //��� ����� ������������ ������: itNone, itBar, itTray, itBarAndTray
  _PopupMenuTray: TPopupMenu;

  WM_TASKBARCREATED: Cardinal;
  _WindowActivHWND: HWND;
  _WindowActiv: Boolean = False; //������� ���������� ������� �� ���� ����� �������� ��� ������� ����-������ MOVE
  _nidata : TNotifyIconData;


procedure BarIcon_Show;
procedure BarIcon_Hide;

procedure TrayIcon_Show;
procedure TrayIcon_Hide;

procedure MinimizeToTray;

procedure ShowIconIn(IconIn: TIconInType);

function IconInToInt: integer;
function IntToIconIn(IntIconIn: integer): TIconInType;

procedure SetWorkWithTray(Value: Boolean);


implementation



{$REGION ' Bar and Tray icons '}




//------------------------------------------------------------------------------ BarIcon Show
procedure BarIcon_Show;
begin
ShowWindow(Application.Handle, SW_SHOW);
//Application.MainFormOnTaskBar := True;
end;


//------------------------------------------------------------------------------ BarIcon Hide
procedure BarIcon_Hide;
begin
ShowWindow(Application.Handle, SW_HIDE);
//Application.MainFormOnTaskBar := False;
end;





//------------------------------------------------------------------------------ TrayIcon Show
procedure TrayIcon_Show;
begin

with _nidata
do
begin
    cbSize := System.SizeOf(TNotifyIconData);
//
//    if Application.MainForm = nil
//    then
//    Wnd := Application.Handle
    ;
//    else
    Wnd := Application.MainForm.Handle;  //���� ��������� ����� Handle �� �� ����� �������� pmTray

    uID := 1;   //����� ������, ����������� � ������� ����, ������ ����������� �� �������
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    uCallBackMessage := WM_MYICONNOTIFY;
    hIcon := Application.Icon.Handle;
    StrPCopy(szTip, Application.Title);
end;

Shell_NotifyIcon(NIM_ADD, @_nidata);



// From Vob Join
//    tnid: TNotifyIconData;
//    HMainIcon: HICON;
//  HMainIcon:= LoadIcon(MainInstance, 'MAINICON');
//
//  Shell_NotifyIcon(NIM_DELETE, @tnid);
//
//  tnid.cbSize              := sizeof(TNotifyIconData);
//  tnid.Wnd                 := handle;
//  tnid.uID                 := 123;
//  tnid.uFlags              := NIF_MESSAGE or NIF_ICON or NIF_TIP;
//  tnid.uCallbackMessage    := WM_NOTIFYICON;
//  tnid.hIcon               := HMainIcon;
//  tnid.szTip               := 'Join VOB Files Tool';
//
//  Shell_NotifyIcon(NIM_ADD, @tnid);
//  AppForm.Hide;

end;


//------------------------------------------------------------------------------ TrayIcon Hide
procedure TrayIcon_Hide;
begin

//with _nidata
//do
//begin
//   cbSize := System.SizeOf(TNotifyIconData);
//
//   if Application.MainForm = nil
//   then
//   Wnd := Application.Handle
////   ;
//   else Wnd := Application.MainForm.Handle;
//
//   uID := 1;
//end;

Shell_NotifyIcon(NIM_DELETE, @_nidata);

end;






//------------------------------------------------------------------------------ Minimize To Tray
procedure MinimizeToTray;
begin

if Application.MainForm <> nil then Application.ShowMainForm := False;
Application.Minimize;
ShowIconIn(inTray);

end;

                   

//------------------------------------------------------------------------------ Show IconIn
procedure ShowIconIn(IconIn: TIconInType);
begin

case IconIn of

  inNone:
  begin
    TrayIcon_Hide;
    BarIcon_Hide;
  end;


  inBar:
  begin
    TrayIcon_Hide;
    BarIcon_Show;
  end;


  inTray:
  begin
    TrayIcon_Show;
    BarIcon_Hide;
  end;


  inBarAndtray:
  begin
    TrayIcon_Show;
    BarIcon_Show;
  end;

end;

end;
                  


//------------------------------------------------------------------------------ IconIn to Int
function IconInToInt: integer;
begin

  case _IconIn
  of
    inNone:       Result := 0;
    inBar:        Result := 1;
    inTray:       Result := 2;
    inBarAndTray: Result := 3;
  end;

end;

                     

//------------------------------------------------------------------------------ Int to IconIn
function IntToIconIn(IntIconIn: integer): TIconInType;
begin

  case IntIconIn
  of
    0: Result := inNone;
    1: Result := inBar;
    2: Result := inTray;
    3: Result := inBarAndTray;
    else Result := inBar;
  end

end;




{$ENDREGION}







{$REGION ' TkuForm: ��������� ��� ����� �� ������ � ����, � ������ �� ������� � ��������� ����� (��������, ���������������, �������) '}





{$REGION '   kuForm   '}



//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH Create
constructor TkuForm.Create(AOwner: TComponent);
begin

inherited;

//ShowIconIn(_IconIn);

end;




//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH Loaded
procedure TkuForm.Loaded;
begin

inherited;

//ShowMessage('Form1.Loaded');

//����������� ��� ������������ ����-������ ��� ������ explorer
//Self.IconIn := itBar;
WM_TASKBARCREATED := RegisterWindowMessage('TaskbarCreated');
//ShowIconIn(_IconIn);

//if Self = TFormKU(Application.MainForm) then
//
//
//if _RunMinimized
//
//    then
//    begin
//        Application.ShowMainForm := False;
//        ShowNeedIcon(2, Self);
//    end
//
//    else ShowNeedIcon(_IconIn, Self);


end;




//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH Destroy
destructor TkuForm.Destroy;
begin

inherited;

TrayIcon_Hide;

end;




//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH ����� explorer
procedure TkuForm.WndProc(var msg: TMessage);
begin

if (msg.Msg = WM_TASKBARCREATED)
then ShowIconIn(_IconIn) //��������������� ����-������ ��� ������ explorer
else inherited WndProc(msg);

end;






{$REGION '   Minimize / Maximize / Close - ��������� ������� �� ������ � ��������� ����  '}




//============================================================================== Mouse Dn L
procedure TkuForm.MouseDnL(var msg: TMessage);
begin

if not _CanWorkWithTray
then
begin
  inherited;
  exit;
end;



case  msg.wParam
of

  HTMINBUTTON: fButtonInCaption := 0;

  HTMAXBUTTON: fButtonInCaption := 1;

  HTCLOSE:     fButtonInCaption := 2;

  else inherited;

end;


end;


//============================================================================== Mouse Dn M
procedure TkuForm.MouseDnM(var msg: TMessage);
begin

if not _CanWorkWithTray
then
begin
  inherited;
  exit;
end;

MouseDnL(msg);

end;


//============================================================================== Mouse Dn R
procedure TkuForm.MouseDnR(var msg: TMessage);
begin

if not _CanWorkWithTray
then
begin
  inherited;
  exit;
end;

MouseDnL(msg);

end;







//============================================================================== Mouse Up L
procedure TkuForm.MouseUpL(var msg: TMessage);
//������� ����� ������� ����:
begin

if not _CanWorkWithTray
then
begin
  inherited;
  exit;
end;

case msg.wParam of


    HTMINBUTTON://�������� ������� LMouse �� ������ [_]
    begin
        if fButtonInCaption <> 0 then exit;
        Application.Minimize;
    end;


    HTMAXBUTTON://�������� ������� LMouse �� ������ [ma�]
    begin
        if Self.WindowState = wsNormal
        then
        begin
            Self.WindowState := wsMaximized;
            exit;
        end;

        if Self.WindowState = wsMaximized
        then
        begin
            Self.WindowState := wsNormal;
            exit;
        end;
    end;


    HTCLOSE://�������� ������� LMouse �� ������ [�]
    begin
          if Self.CloseToTray

          then
          begin
              Application.Minimize;
              ShowIconIn(inTray);
          end

          else Self.Close;
    end;

end;

end;


//============================================================================== Mouse Up M
procedure TkuForm.MouseUpM(var msg: TMessage);
//������� ������� ������� ����:
begin

if not _CanWorkWithTray
then
begin
  inherited;
  exit;
end;


case msg.wParam of


    HTMINBUTTON://�� ������ [_] - ����������� ��������� � ����
    begin
        if fButtonInCaption <> 0 then exit;
        MinimizeToTray;
    end;


    HTMAXBUTTON://�� ������ [ma�]
    begin
        if fButtonInCaption <> 1 then exit;
        Self.BorderStyle := bsNone;
        if Self.WindowState = wsMaximized then Self.WindowState := wsNormal;
        Self.WindowState := wsMaximized;
    end;


    HTCLOSE://�� ������ [�] - ��������� ���������
    begin
        if fButtonInCaption <> 2 then exit;
        ShowIconIn(inNone);
        Self.Close;
        exit;
    end;

end;


end;


//============================================================================== Mouse Up R
procedure TkuForm.MouseUpR(var msg: TMessage);
//������� ������ ������� ����:
begin

if not _CanWorkWithTray
then
begin
  inherited;
  exit;
end;


case msg.wParam
of

    HTMINBUTTON:
    begin
      if fButtonInCaption <> 0 then exit;
      MinimizeToTray;
    end;


    HTMAXBUTTON:
    begin
      if fButtonInCaption <> 1 then exit;
    end;


    HTCLOSE:
    begin
      if fButtonInCaption <> 2 then exit;
      MinimizeToTray;
    end;

end;

end;





//------------------------------------------------------------------------------ Close To Tray
procedure TkuForm.SetCloseToTray(Value: Boolean);
begin

Self.fCloseToTray := Value;

end;




{$ENDREGION}





//------------------------------------------------------------------------------ 
procedure SetWorkWithTray(Value: Boolean);
begin

_CanWorkWithTray := Value;

if not Value
then 
ShowIconIn(inBar); 

end;






{$ENDREGION}







{$REGION '   Application   '}


//------------------------------------------------------------------------------  Restore
procedure TkuForm.xxxApplicationRestore(Sender: TObject);
begin
//��������� ����� ������� ����� ��� ����, ����
//������� ���������� ��������� ��� �������������� ��� ����� �� ������ �� ������ �����

//ShowMessage('sssssssss');

if not _CanWorkWithTray then exit;

ShowIconIn(_IconIn);

end;



//------------------------------------------------------------------------------  Minimize
procedure TkuForm.xxxApplicationMinimize(Sender: TObject);
begin

//...

end;




{$ENDREGION}






//============================================================================== Tray ico Events
procedure TkuForm.TrayEvents(var msg: TMessage);
//������� ������������� � ������� � ��������� ����: �����, ������ ������...
var
Point: TPoint;




    procedure SomeClick;
    begin

          if not IsWindowVisible(Self.Handle) //IsIconic(Application.Handle) //������� �� �����
//
          then//�������:
          begin
              Application.ShowMainForm := True;
              Application.MainForm.Visible := True;
              Application.Restore;
              SetForegroundWindow(Application.Handle); //������� ���� �� �������� ����
              ShowIconIn(_IconIn);
          end

          else//�� �������:
          begin
//              ��������!!! Self.Handle <> Application.Handle
//              if GetWindow(Self.Handle, GW_HWNDFIRST) = Self.Handle ...
//              if GetForegroundWindow = Self.Handle ...
//              if GetActiveWindow = Self.Handle ...
//              if GetLastActivePopup(GetDesktopWindow) = Self.Handle ...

              //�������� � ���, ��� ����� ����� �� ����-������ �������� ���������� ������ �����,
              //������������� ���� ����� ���������� �������� ����,
              //���� ���� ������� ���� ����� ��������� => �������� ���������
              //���� ���� ������� ���� �� ����� ��������� => ������� ���� ����� ��������� �� �������� ����

              //����� ����� ���������� ��������� �������� ���� �����: Z-������������������, GetLastActivePopup

              if _WindowActiv = true

              then//���� ������� => �����������
              begin
//                ShowMessage('�������');

                MinimizeToTray;
                _WindowActiv := False;
              end

              else//���� �������� => �� �������� ����
              begin
//                ShowMessage('��������');
                SetForegroundWindow(Application.Handle);
                _WindowActiv := True;
              end;
          end;
    end;



begin

if not _CanWorkWithTray then exit;

case msg.LParam
of

//  WM_MOUSEWHEEL: ShowMessage('wheel');


  WM_MOUSEMOVE:
  begin
    //���������� �� ������� ���������� ������� �� ���� ����� ���������
    if (Application.Handle = GetForegroundWindow) or (Self.Handle = GetForegroundWindow)
    then _WindowActiv := True
    else _WindowActiv := False;
    _WindowActivHWND :=  GetForegroundWindow;
  end;



  WM_RBUTTONDOWN://Tray Popup Menu
  begin
    if _PopupMenuTray <> nil
    then
    begin
//          ShowMessage(_pmTray.Owner.Name);
//          Application.ProcessMessages;
//          _pmTray.AutoPopup := True;
//          _pmTray.PopupComponent := Owner;
//                                 application.fi

//                                   GetActiveWindow //�������� ���� ���� ���������
//                                   GetForegroundWindow //����� ���� ��������� ����������
//                                     GetARENT
//                                       FindWindowEx(Application.Handle, Application.Handle, 'TForm', );
//ShowMessage(inttostr(_WindowActivHWND)+'==='+ inttostr( GetWindow(Handle,GW_HWNDPREV) ));
//          if _WindowActivHWND - �������� ����� ����� ���������, ��
//          then
//          begin
//            ShowMessage(inttostr(GetForegroundWindow)+'==='+ inttostr(GetActiveWindow) );
////            SetForegroundWindow(Application.MainForm.Handle);
//          end;

          SetForegroundWindow(Application.MainForm.Handle);
          GetCursorPos(Point);
          _PopupMenuTray.Popup(Point.X, Point.Y);
          PostMessage(Application.Handle, WM_NULL, 0, 0);
    end;
  end;



  WM_LBUTTONDOWN:
  begin
      SomeClick
  end;



  WM_MBUTTONDOWN:
  begin
      SomeClick;
  end;



  WM_LBUTTONDBLCLK:
  begin
//    SomeClick
  end;


end;

end;







initialization
Application.OnRestore  := TkuForm(Application.MainForm).xxxApplicationRestore;
Application.OnMinimize := TkuForm(Application.MainForm).xxxApplicationMinimize;
//Application.OnActivate

{$ENDREGION}





end.



