program Gustavo_Projeto;

uses
  Forms,
  Gustavo in 'Gustavo.pas' {CadastroCliente},
  ValidaCPF in 'ValidaCPF.pas',
  BuscarCepJson in 'BuscarCepJson.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TCadastroCliente, CadastroCliente);
  Application.Run;
end.
