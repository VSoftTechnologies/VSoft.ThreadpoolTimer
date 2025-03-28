# VSoft.ThreadPoolTimer
A simple threadpool based timer for Delphi XE2-12.x  - currently only implemented for Win32/Win64

````delphi
 FTimer := TThreadPoolTimerFactory.CreateTimer(1000,0,
  procedure (context : UIntPtr)
  begin
    Memo1.Lines.Add(IntToStr(GetTickCount));
  end);
````
The callback function can be a procedure, method or anonymous method. 

Call the Run or RunOnce methods to star the timer. 
