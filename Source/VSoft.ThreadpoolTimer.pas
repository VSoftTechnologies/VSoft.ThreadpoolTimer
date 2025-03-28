unit VSoft.ThreadpoolTimer;

interface


type
  IThreadPoolTimer = interface;
  TThreadPoolTimerCallBack = procedure(context : UIntPtr);
  TThreadPoolTimerCallBackMethod = procedure(context : UIntPtr) of object;
  TThreadPoolTimerCallBackProc = reference to procedure(context : UIntPtr);
  

  IThreadPoolTimer = interface
  ['{C8A7E189-C9EF-480C-A082-980992449B4C}']
    function GetInterval : Cardinal;
    procedure SetInterval(value : Cardinal); 
    procedure Stop;
    procedure Run;
    procedure RunOnce;
    function IsRunning : boolean;
    
  end;

  TThreadPoolTimerFactory = record
    class function CreateTimer(interval : Cardinal; const context : UIntPtr; const callback : TThreadPoolTimerCallBack) : IThreadPoolTimer; overload;static; 
    class function CreateTimer(interval : Cardinal; const context : UIntPtr; const callback : TThreadPoolTimerCallBackMethod) : IThreadPoolTimer; overload;static;
    class function CreateTimer(interval : Cardinal; const context : UIntPtr; const callback : TThreadPoolTimerCallBackProc) : IThreadPoolTimer; overload;static;
  end;

implementation


{$IFDEF MSWINDOWS}
uses
  VSoft.ThreadpoolTimer.Windows;
{$ELSE}
  Platform not supported;
{$ENDIF}


{ TThreadPoolTimerFactory }

class function TThreadPoolTimerFactory.CreateTimer(interval: Cardinal; const context : UIntPtr; const callback: TThreadPoolTimerCallBack): IThreadPoolTimer;
begin
  {$IFDEF MSWINDOWS}
  result := TWindowsThreadpoolTimerFactory.CreateTimer(interval, context, callback);
  {$ELSE}
    Platform not implemented
  {$ENDIF}
end;

class function TThreadPoolTimerFactory.CreateTimer(interval: Cardinal; const context : UIntPtr; const callback: TThreadPoolTimerCallBackMethod): IThreadPoolTimer;
begin
  {$IFDEF MSWINDOWS}
  result := TWindowsThreadpoolTimerFactory.CreateTimer(interval, context, callback);
  {$ELSE}
    Platform not implemented
  {$ENDIF}

end;

class function TThreadPoolTimerFactory.CreateTimer(interval: Cardinal; const context : UIntPtr;const callback: TThreadPoolTimerCallBackProc): IThreadPoolTimer;
begin
  {$IFDEF MSWINDOWS}
  result := TWindowsThreadpoolTimerFactory.CreateTimer(interval, context, callback);
  {$ELSE}
    Platform not implemented
  {$ENDIF}
end;

end.
