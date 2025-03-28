unit VSoft.ThreadpoolTimer.Windows;

interface

uses
  WinApi.Windows,
  VSoft.ThreadpoolTimer;

{$IF CompilerVersion >= 24.0} //XE3
{$LEGACYIFEND ON}
{$IFEND}

type
  _TP_CLEANUP_GROUP = record
  end;
  {$EXTERNALSYM _TP_CLEANUP_GROUP}
  TP_CLEANUP_GROUP = _TP_CLEANUP_GROUP;
  {$EXTERNALSYM TP_CLEANUP_GROUP}
  PTP_CLEANUP_GROUP = ^_TP_CLEANUP_GROUP;
  {$EXTERNALSYM PTP_CLEANUP_GROUP}
  TTPCleanupGroup = _TP_CLEANUP_GROUP;
  PTPCleanupGroup = ^TTPCleanupGroup;

  _TP_POOL = record
  end;
  {$EXTERNALSYM _TP_POOL}
  TP_POOL = _TP_POOL;
  {$EXTERNALSYM TP_POOL}
  TTPPool = _TP_POOL;
  PTPPool = ^TTPPool;

  _TP_TIMER = record
  end;
  {$EXTERNALSYM _TP_TIMER}
  TP_TIMER = _TP_TIMER;
  {$EXTERNALSYM TP_TIMER}
  PTP_TIMER = _TP_TIMER;
  {$EXTERNALSYM PTP_TIMER}
  TTPTimer = _TP_TIMER;
  PTPTimer = ^TTPTimer;

  TFNTPCleanupGroupCancelCallback = TFarProc;
  TFNPTPSimpleCallback = TFarProc;

  _TP_CALLBACK_PRIORITY = (
    TP_CALLBACK_PRIORITY_HIGH,
    TP_CALLBACK_PRIORITY_NORMAL,
    TP_CALLBACK_PRIORITY_LOW,
    TP_CALLBACK_PRIORITY_INVALID,
    TP_CALLBACK_PRIORITY_COUNT = TP_CALLBACK_PRIORITY_INVALID
  );
  {$EXTERNALSYM _TP_CALLBACK_PRIORITY}
  TP_CALLBACK_PRIORITY = _TP_CALLBACK_PRIORITY;
  {$EXTERNALSYM TP_CALLBACK_PRIORITY}
  TTPCallbackPriority = _TP_CALLBACK_PRIORITY;

  _TP_CALLBACK_ENVIRON_V3 = record
    Version: DWORD;
    Pool: PTPPool;
    CleanupGroup: PTPCleanupGroup;
    CleanupGroupCancelCallback: TFNTPCleanupGroupCancelCallback;
    RaceDll: Pointer;
    ActivationContext: Pointer;
    FinalizationCallback: TFNPTPSimpleCallback;
    Flags: DWORD;
    CallbackPriority: TTPCallbackPriority;
    Size: DWORD;
  end;
  {$EXTERNALSYM _TP_CALLBACK_ENVIRON_V3}
  TP_CALLBACK_ENVIRON_V3 = _TP_CALLBACK_ENVIRON_V3;
  {$EXTERNALSYM TP_CALLBACK_ENVIRON_V3}
  TP_CALLBACK_ENVIRON = TP_CALLBACK_ENVIRON_V3;
  {$EXTERNALSYM TP_CALLBACK_ENVIRON}
  PTP_CALLBACK_ENVIRON = ^TP_CALLBACK_ENVIRON_V3;
  {$EXTERNALSYM PTP_CALLBACK_ENVIRON}
  TTPCallbackEnviron = TP_CALLBACK_ENVIRON_V3;
  PTPCallbackEnviron = ^TTPCallbackEnviron;


  TFNTPTimerCallback = TFarProc;

  _TP_CALLBACK_INSTANCE = record
  end;
  {$EXTERNALSYM _TP_CALLBACK_INSTANCE}
  TP_CALLBACK_INSTANCE = _TP_CALLBACK_INSTANCE;
  {$EXTERNALSYM TP_CALLBACK_INSTANCE}
  PTP_CALLBACK_INSTANCE = ^_TP_CALLBACK_INSTANCE;
  {$EXTERNALSYM PTP_CALLBACK_INSTANCE}
  TTPCallbackInstance = _TP_CALLBACK_INSTANCE;
  PTPCallbackInstance = ^TTPCallbackInstance;


  function CreateThreadpoolTimer(pfnti: TFNTPTimerCallback; pv: Pointer; pcbe: PTPCallbackEnviron): PTPTimer; stdcall;
  {$EXTERNALSYM CreateThreadpoolTimer}
  procedure CloseThreadpoolTimer(pti: PTPTimer); stdcall;
  {$EXTERNALSYM CloseThreadpoolTimer}
  procedure SetThreadpoolTimer(pti: PTPTimer; pftDueTime: PFiletime; msPeriod, msWindowLength: DWORD); stdcall;
  {$EXTERNALSYM SetThreadpoolTimer}
  function SetThreadpoolTimerEx(pti: PTPTimer; pftDueTime: PFiletime; msPeriod, msWindowLength: DWORD): BOOL; stdcall;
  {$EXTERNALSYM SetThreadpoolTimerEx}
  procedure WaitForThreadpoolTimerCallbacks(pti: PTPTimer; fCancelPendingCallbacks: BOOL); stdcall;
  {$EXTERNALSYM WaitForThreadpoolTimerCallbacks}


type
  TWinTimerHandle = PTPTimer;

  TWindowsThreadpoolTimer = class(TInterfacedObject, IThreadPoolTimer)
  private
    FHandle : PTPTimer;
    FInterval : Cardinal;
    FCallBack : TThreadPoolTimerCallBack;
    FCallBackMethod : TThreadPoolTimerCallBackMethod;
    FCallBackProc : TThreadPoolTimerCallBackProc;
    FContext : UIntPtr;
    FIsRunning : boolean;
    FInCallback : boolean;
    FRunOnce : boolean;
  protected
    function GetInterval: Cardinal;
    function IsRunning: Boolean;
    procedure SetInterval(value: Cardinal);
    procedure Run;
    procedure RunOnce;
    procedure Stop;

    procedure DoStartTimer;
    procedure DoStopTimer;

    procedure DoTimerCallback;

  public
    constructor Create(interval : Cardinal; const callback : TThreadPoolTimerCallBack; const context : UIntPtr);overload;
    constructor Create(interval: Cardinal; const callback: TThreadPoolTimerCallBackMethod; const context: UIntPtr);overload;
    constructor Create(interval : Cardinal; const callback : TThreadPoolTimerCallBackProc; const context : UIntPtr); overload;
    destructor Destroy;override;
  end;

  TWindowsThreadpoolTimerFactory = class
  public
    class function CreateTimer(interval : Cardinal; const context : UIntPtr; const callback : TThreadPoolTimerCallBack) : IThreadPoolTimer;overload;
    class function CreateTimer(interval: Cardinal; const context : UIntPtr; const callback: TThreadPoolTimerCallBackMethod): IThreadPoolTimer;overload;
    class function CreateTimer(interval : Cardinal; const context : UIntPtr; const callback : TThreadPoolTimerCallBackProc) : IThreadPoolTimer; overload;
  end;



implementation

uses
  System.SysUtils;

function CreateThreadpoolTimer; external kernel32 name 'CreateThreadpoolTimer';
procedure CloseThreadpoolTimer; external kernel32 name 'CloseThreadpoolTimer';

procedure SetThreadpoolTimer; external kernel32 name 'SetThreadpoolTimer';
function SetThreadpoolTimerEx; external kernel32 name 'SetThreadpoolTimerEx';

procedure WaitForThreadpoolTimerCallbacks; external kernel32 name 'WaitForThreadpoolTimerCallbacks';


procedure TimerCallback(Instance : PTP_CALLBACK_INSTANCE; context : Pointer; timer  : PTP_TIMER);cdecl;
begin
  TWindowsThreadpoolTimer(context).DoTimerCallback;
end;


{ TWindowsThreadpoolTimerFactory }


class function TWindowsThreadpoolTimerFactory.CreateTimer(interval: Cardinal; const context : UIntPtr; const callback: TThreadPoolTimerCallBack): IThreadPoolTimer;
begin
  result := TWindowsThreadpoolTimer.Create(interval, callback, context);
end;

class function TWindowsThreadpoolTimerFactory.CreateTimer(interval: Cardinal; const context : UIntPtr; const callback: TThreadPoolTimerCallBackMethod): IThreadPoolTimer;
begin
  result := TWindowsThreadpoolTimer.Create(interval, callback, context);
end;

class function TWindowsThreadpoolTimerFactory.CreateTimer(interval: Cardinal; const context : UIntPtr; const callback: TThreadPoolTimerCallBackProc): IThreadPoolTimer;
begin
  result := TWindowsThreadpoolTimer.Create(interval, callback, context);
end;




{ TWindowsThreadpoolTimer }

constructor TWindowsThreadpoolTimer.Create(interval: Cardinal; const callback: TThreadPoolTimerCallBack; const context: UIntPtr);
begin
  FHandle := nil;
  FInterval := interval;
  FContext := context;
  FCallBack := callback;
  FCallBackMethod := nil;
  FCallBackProc := nil;
end;

constructor TWindowsThreadpoolTimer.Create(interval: Cardinal; const callback: TThreadPoolTimerCallBackMethod; const context: UIntPtr);
begin
  FHandle := nil;
  FInterval := interval;
  FContext := context;
  FCallBack := nil;
  FCallBackMethod := callback;
  FCallBackProc := nil;
end;

constructor TWindowsThreadpoolTimer.Create(interval: Cardinal; const callback: TThreadPoolTimerCallBackProc; const context: UIntPtr);
begin
  FHandle := nil;
  FInterval := interval;
  FContext := context;
  FCallBack := nil;
  FCallBackMethod := nil;
  FCallBackProc := callback;
end;

destructor TWindowsThreadpoolTimer.Destroy;
begin
  DoStopTimer;
  inherited;
end;

procedure TWindowsThreadpoolTimer.DoStartTimer;
var
  timerPeriod : FILETIME;
  delay   : int64;
  i : Cardinal;
begin

  //called to start or to change the interval;
  if FHandle = nil then
  begin
    FHandle := CreateThreadpoolTimer(@TimerCallback, Pointer(Self), nil);
    if FHandle = nil then
      RaiseLastOSError;
  end;
  //call setthrreadpooltimer
  delay := -(FInterval * 10 * 1000); //ms - negative number as per doco
  timerPeriod.dwLowDateTime   := delay and $FFFFFFFF;
  timerPeriod.dwHighDateTime  :=  (delay shr 32) and $FFFFFFFF;
  if FRunOnce then
    i := 0
  else
    i := FInterval;
  SetThreadpoolTimer(FHandle, @timerPeriod, i, 0);
  FIsRunning := true;
end;

procedure TWindowsThreadpoolTimer.DoStopTimer;
begin
  if FHandle <> nil then
  begin
    SetThreadpoolTimer(FHandle, nil, 0,0);
    if not FInCallback then
      WaitForThreadpoolTimerCallbacks(FHandle, true);  //Note calling this from a callback would deadlock.
    CloseThreadpoolTimer(FHandle);
    FHandle := nil;
    FIsRunning := false;
  end;

end;

procedure TWindowsThreadpoolTimer.DoTimerCallback;
begin
  FInCallBack := true;
  if Assigned(FCallBack) then
    FCallBack(FContext)
  else if Assigned(FCallBackMethod) then
    FCallBackMethod(FContext)
  else if Assigned(FCallBackProc) then
    FCallBackProc(FContext);
  if FRunOnce then
    DoStopTimer;
  FInCallBack := false;
end;

function TWindowsThreadpoolTimer.GetInterval: Cardinal;
begin
  result := FInterval;
end;


function TWindowsThreadpoolTimer.IsRunning: Boolean;
begin
  result := FIsRunning;
end;

procedure TWindowsThreadpoolTimer.SetInterval(value: Cardinal);
begin
  if FInterval <> value then
  begin
    FInterval := value;
    if FIsRunning then
      DoStartTimer;
  end;

end;

procedure TWindowsThreadpoolTimer.Run;
begin
  if FIsRunning then
    exit;
  FRunOnce := false;
  DoStartTimer;
end;

procedure TWindowsThreadpoolTimer.RunOnce;
begin
  if FIsRunning then
    exit;
  FRunOnce := true;
  DoStartTimer;
end;

procedure TWindowsThreadpoolTimer.Stop;
begin
  if not FIsRunning then
    exit;
  FRunOnce := false;
  DoStopTimer;
end;

end.

