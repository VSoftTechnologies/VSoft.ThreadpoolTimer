program Project1;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  VSoft.ThreadpoolTimer in '..\Source\VSoft.ThreadpoolTimer.pas',
  VSoft.ThreadpoolTimer.Windows in '..\Source\VSoft.ThreadpoolTimer.Windows.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
