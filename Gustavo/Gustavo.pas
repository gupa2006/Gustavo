unit Gustavo;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, Mask, StdCtrls, ExtCtrls,ValidaCPF, BuscarCepJson,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  IdSMTP,IdMessage,idText,IdSSLOpenSSL,IdIOHandler, IdExplicitTLSClientServerBase,
  IdSSL, IdResourceStringsOpenSSL,
  IniFiles,
  IdMessageClient,
  IdSMTPBase,
  IdIOHandlerSocket,
  IdIOHandlerStack,
  IdAttachmentFile,
   WinInet;

type
  TCadastroCliente = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    edtNome: TEdit;
    edtID: TMaskEdit;
    edtCPF: TMaskEdit;
    edtTel: TMaskEdit;
    edtEmail: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    GroupBox1: TGroupBox;
    edtCEP: TMaskEdit;
    Label6: TLabel;
    edtLogradouro: TEdit;
    edtNumero: TEdit;
    edtBairro: TEdit;
    edtComplemento: TEdit;
    edtCidade: TEdit;
    edtEstado: TEdit;
    edtPais: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    btnEmail: TButton;
    edtSeuEmail: TEdit;
    edtSenha: TEdit;
    Label14: TLabel;
    Label15: TLabel;
    procedure edtCPFExit(Sender: TObject);
    procedure edtCEPExit(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
  private
    function EnviaMail(Email, Conta, Senha, Autentica, Smtp, Auth_SSL, Nom_exibe, Porta_smtp, Corpo, Destinatario, Assunto, Anexo : String) : String;
  public
    { Public declarations }
  end;

var
  CadastroCliente: TCadastroCliente;

implementation
    uses SysUtils;
{$R *.dfm}

procedure TCadastroCliente.btnEmailClick(Sender: TObject);
var
  caminho:string;
  Arquivo: TStringList;
begin
  caminho := ExtractFilePath(Application.ExeName)+'Arquivo.xml';
  Arquivo := TStringList.Create;
  try
    Arquivo.Add('<xmlCadastro>');
    Arquivo.Add('<nome>+edtNome.Text+</nome>');
    Arquivo.Add('<cpf>+edtCPF.Text+</cpf>');
    Arquivo.Add('<identidade>+edtID.Text+</identidade>');
    Arquivo.Add('<telefone>+edtTel.Text+</telefone>');
    Arquivo.Add('<email>+edtEmail.Text+</email>');
    Arquivo.Add('<endereco>');
    Arquivo.Add('<cep>+edtCEP.Text+</cep>');
    Arquivo.Add('<logradouro>+edtLogradouro.Text+</logradouro>');
    Arquivo.Add('<numero>+edtNumero.Text+</numero>');
    Arquivo.Add('<complemento>+edtComplemento.Text+</complemento>');
    Arquivo.Add('<bairro>+edtBairro.Text+</bairro>');
    Arquivo.Add('<cidade>+edtCidade.Text+</cidade>');
    Arquivo.Add('<uf>+edtEstado.Text+</uf>');
    Arquivo.Add('<pais>+edtPais.Text+</pais>');
    Arquivo.Add('</endereco>');
    Arquivo.Add('</xmlCadastro>');
    Arquivo.SaveToFile(caminho);
    EnviaMail(edtSeuEmail.Text,
             edtSeuEmail.Text,
             edtSenha.Text,
             'N',//Autentica
             'Smtp.gmail.com',
             'S',//Auth_SSL
             'Nom_exibe',
             '25',// Porta_smtp, padrao 25, ssl 465
             'Arquivo xml do cadastro', // Corpo do email
             edtEmail.Text,
             'Cadastro',
             caminho );
  finally
    Arquivo.Free;
    DeleteFile(caminho+'Arquivo.xml');
  end;
end;

procedure TCadastroCliente.edtCEPExit(Sender: TObject);
Var
  Logradouro, Bairro, Cidade, Estado, Pais: String;
begin
  BuscarCEP(edtCEP.Text, Logradouro, Bairro, Cidade, Estado, Pais);

  edtLogradouro.Text := Logradouro;
  edtBairro.Text := Bairro;
  edtCidade.Text := Cidade;
  edtEstado.Text := Estado;
  edtPais.Text := Pais;
end;

procedure TCadastroCliente.edtCPFExit(Sender: TObject);
begin
  if not CPFValido(edtCPF.Text) then
  begin
    edtCPF.text := '';
    ShowMessage('CPF inv�lido!');
  end;
end;

function TCadastroCliente.EnviaMail(Email, Conta, Senha, Autentica, Smtp,
  Auth_SSL, Nom_exibe, Porta_smtp, Corpo, Destinatario, Assunto,
  Anexo: String): String;
var
Mensagem: TIdMessage;
cnxSMTP: TIdSMTP;
AuthSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
Result := '';
try

Mensagem := TIdMessage.Create(nil);
cnxSMTP  := TIdSMTP.Create(nil);



Mensagem.From.Name := Nom_exibe; // Nome do Remetente
Mensagem.From.Address := Email; // E-mail do Remetente = email valido...
Mensagem.Recipients.EMailAddresses := Destinatario;  // destinatario
Mensagem.Priority := mpHighest;
Mensagem.Subject := Assunto; // Assunto do E-mail

cnxSMTP.Host := Smtp;  // smtp terra}
cnxSMTP.Username := Conta;
cnxSMTP.Password := Senha;
if Autentica = 'S' then
cnxSMTP.AuthType := satDefault;
if Autentica = 'N' then
cnxSMTP.AuthType := satNone;


if Auth_SSL = 'S' then
 begin
  AuthSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  cnxSMTP.IOHandler := AuthSSL;
  cnxSMTP.UseTLS := utUseImplicitTLS;
  AuthSSL.DefaultPort := StrToInt(Porta_smtp);
  AuthSSL.SSLOptions.Method := sslvSSLv3;
  AuthSSL.SSLOptions.Mode := sslmClient;
 end;

cnxSMTP.Port := StrToInt(Porta_smtp);


if trim(Anexo) <> '' then
 begin
  TIdAttachmentFile.Create(Mensagem.MessageParts, TFileName(Anexo));
 end;

Mensagem.Body.Clear;
Mensagem.Body.Add(Corpo);
cnxSMTP.UseEhlo := true;
cnxSMTP.UseVerp := false;


cnxSMTP.ReadTimeout := 10000;
cnxSMTP.Connect;
sleep(1000);
cnxSMTP.Authenticate;
sleep(1000);
Try
if cnxSMTP.Connected then
 cnxSMTP.Send(Mensagem)
 else
  begin
   Result := 'Mensagem n�o pode ser enviada.';
   exit;
  end;
except
  cnxSMTP.Disconnect;
  cnxSMTP.Host := Smtp;   // smtp
  cnxSMTP.AuthType := satNone;
  cnxSMTP.Connect;
  try
    cnxSMTP.Send(Mensagem);
  except
   begin
    Result := 'N�o pode enviar o email para ' + Destinatario +  '. Verifique as configura��es da conta!';
   end;
  end;
  cnxSMTP.Disconnect;
end;
cnxSMTP.Disconnect;


finally
FreeAndNil(Mensagem);
FreeAndNil(cnxSMTP);
if Auth_SSL = 'S' then
 FreeAndNil(AuthSSL);
end;

if Result = '' then
 Result := 'E-Mail enviado para ' + Destinatario;

end;

end.
