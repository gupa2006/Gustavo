unit ValidaCPF;
 
interface


function CPFValido(CPF: string): boolean;

implementation
 uses SysUtils;

function CPFValido(CPF: string): boolean;
var  dig10, dig11: string;
    s, i, r, peso: integer;
begin
// length - retorna o tamanho da string (CPF � um n�mero formado por 11 d�gitos)
  if ((CPF = '00000000000') or (CPF = '11111111111') or
      (CPF = '22222222222') or (CPF = '33333333333') or
      (CPF = '44444444444') or (CPF = '55555555555') or
      (CPF = '66666666666') or (CPF = '77777777777') or
      (CPF = '88888888888') or (CPF = '99999999999') or
      (length(CPF) <> 11))
  then
  begin
    Result := False;
    exit;
  end;

  try
    s := 0;
    peso := 10;
    for i := 1 to 9 do
    begin
      s := s + (StrToInt(CPF[i]) * peso);
      peso := peso - 1;
    end;
    r := 11 - (s mod 11);
    if ((r = 10) or (r = 11)) then
      dig10 := '0'
    else
      str(r:1, dig10);

    s := 0;
    peso := 11;
    for i := 1 to 10 do
    begin
      s := s + (StrToInt(CPF[i]) * peso);
      peso := peso - 1;
    end;
    r := 11 - (s mod 11);
    if ((r = 10) or (r = 11)) then
      dig11 := '0'
    else
      str(r:1, dig11);

    if ((dig10 = CPF[10]) and (dig11 = CPF[11])) then
      Result := true
    else
      Result := False;
  except
    Result := False;
  end;
end;
 
end.
