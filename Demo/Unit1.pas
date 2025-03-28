unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  VSoft.ThreadpoolTimer, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FTimer : IThreadPoolTimer;
    FTimer2 : IThreadPoolTimer;
  public
    { Public declarations }
    procedure Callback(context : UIntPtr);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  FTimer.RunOnce;
  FTimer2.Run;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  FTimer.Stop;
  FTimer2.Stop;
end;

procedure TForm1.Callback(context: UIntPtr);
begin
  TThread.Queue(nil, procedure
  begin
    Edit1.Text := IntToStr(GetTickCount);
  end);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FTimer := TThreadPoolTimerFactory.CreateTimer(1000,0,
  procedure (context : UIntPtr)
  begin
    Memo1.Lines.Add(IntToStr(GetTickCount));
  end);
  FTimer2 := TThreadPoolTimerFactory.CreateTimer(10, 0, Self.Callback);
end;

end.
