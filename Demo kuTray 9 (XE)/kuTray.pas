unit kuTray;
{
версия 2022

Известные баги:
1) посворачивали приложение по разному, потом закрываем приложение, а иконка в трее не вырубается.
как обхожу проблему: в Form.Close делаем BarIcon_Hide и TrayIcon_Hide.
РЕШЕНО: введение глобальной _nidata

2) не работает ShowIconIn ни в kuForm.Create, ни в Application.Source - не убирается иконка из Bar
Обход проблемы: Form.Show + _FirstShow
Желаемое решение: вшить ShowIconIn в kuForm.Create чтоб работало

TkuForm является прямым потомком TForm:
1) TkuForm можно делать только для Application.MainForm
2) TkuForm осуществляет перехват нажатия на кнопки в заголовке формы: минимизировать, развернуть, закрыть
3) TkuForm имеет свойство CloseToTray - если оно True то при нажатии на кнопку [Х] в заголовке окна левой КМ приложение свернётся в трей. - переделать перехвать события с inherited OnCloseQuery
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
      fButtonInCaption: integer; //кнопка в заголовке окна над которой MouseDn

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
//  _RunMinimizedToTray: Boolean = False; //Запускать программу свёрнутую в трей
  _IconIn: TIconInType = inBar;           //Где будет отображаться иконка: itNone, itBar, itTray, itBarAndTray
  _PopupMenuTray: TPopupMenu;

  WM_TASKBARCREATED: Cardinal;
  _WindowActivHWND: HWND;
  _WindowActiv: Boolean = False; //Праметр запоминает активно ли окно нашей прораммы при событии трей-иконки MOVE
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
    Wnd := Application.MainForm.Handle;  //если поставить другоё Handle то не будет работать pmTray

    uID := 1;   //номер иконки, относящийся к данному окну, должны различаться по номерам
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







{$REGION ' TkuForm: поведение при клике по иконке в трее, и кликах по кнопкам в заголовке формы (свернуть, максимизировать, закрыть) '}





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

//перегружаем чоб восстановить трей-иконку при вылете explorer
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




//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH Вылет explorer
procedure TkuForm.WndProc(var msg: TMessage);
begin

if (msg.Msg = WM_TASKBARCREATED)
then ShowIconIn(_IconIn) //восстанавливаем трей-иконку при вылете explorer
else inherited WndProc(msg);

end;






{$REGION '   Minimize / Maximize / Close - ОБРАБОТКА нажатий на кнопки в заголовке окна  '}




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
//отжатие левой кнопкой мыши:
begin

if not _CanWorkWithTray
then
begin
  inherited;
  exit;
end;

case msg.wParam of


    HTMINBUTTON://перехват нажатия LMouse на кнопку [_]
    begin
        if fButtonInCaption <> 0 then exit;
        Application.Minimize;
    end;


    HTMAXBUTTON://перехват нажатия LMouse на кнопку [maх]
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


    HTCLOSE://перехват нажатия LMouse на кнопку [х]
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
//отжатие средней кнопкой мыши:
begin

if not _CanWorkWithTray
then
begin
  inherited;
  exit;
end;


case msg.wParam of


    HTMINBUTTON://по кнопке [_] - Сворачиваем программу в трей
    begin
        if fButtonInCaption <> 0 then exit;
        MinimizeToTray;
    end;


    HTMAXBUTTON://по кнопке [maх]
    begin
        if fButtonInCaption <> 1 then exit;
        Self.BorderStyle := bsNone;
        if Self.WindowState = wsMaximized then Self.WindowState := wsNormal;
        Self.WindowState := wsMaximized;
    end;


    HTCLOSE://по кнопке [х] - Закрываем программу
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
//отжатие правой кнопкой мыши:
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
//обработка этого события нужна для того, чтоб
//сделать правильное поведение при восстановлении при клике по иконке на панели задач

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
//События происходжящие с иконкой в системной трее: клики, наезды мышкой...
var
Point: TPoint;




    procedure SomeClick;
    begin

          if not IsWindowVisible(Self.Handle) //IsIconic(Application.Handle) //свёрнута ли форма
//
          then//свёрнуто:
          begin
              Application.ShowMainForm := True;
              Application.MainForm.Visible := True;
              Application.Restore;
              SetForegroundWindow(Application.Handle); //Вывести окно на передний план
              ShowIconIn(_IconIn);
          end

          else//НЕ свёрнуто:
          begin
//              ВНИМАНИЕ!!! Self.Handle <> Application.Handle
//              if GetWindow(Self.Handle, GW_HWNDFIRST) = Self.Handle ...
//              if GetForegroundWindow = Self.Handle ...
//              if GetActiveWindow = Self.Handle ...
//              if GetLastActivePopup(GetDesktopWindow) = Self.Handle ...

              //Гемморой в том, что после клика по трей-иконке активной становится панель задач,
              //следовательно надо найти предыдущее активное окно,
              //если было активно окно нашей программы => свернуть программу
              //если было активно окно НЕ нашей программы => вывести окно нашей программы на передний план

              //также можно определить последнее активное окно через: Z-последовательности, GetLastActivePopup

              if _WindowActiv = true

              then//окно активно => сворачиваем
              begin
//                ShowMessage('активно');

                MinimizeToTray;
                _WindowActiv := False;
              end

              else//окно пассивно => на передний план
              begin
//                ShowMessage('пассивно');
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
    //Запоминаем во внешнюю переменную активно ли окно нашей программы
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

//                                   GetActiveWindow //Активное окно моей программы
//                                   GetForegroundWindow //Вернёт Хэнл активного приложения
//                                     GetARENT
//                                       FindWindowEx(Application.Handle, Application.Handle, 'TForm', );
//ShowMessage(inttostr(_WindowActivHWND)+'==='+ inttostr( GetWindow(Handle,GW_HWNDPREV) ));
//          if _WindowActivHWND - явдяется окном нашей программы, то
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



