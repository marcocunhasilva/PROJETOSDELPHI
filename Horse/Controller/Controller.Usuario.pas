unit Controller.Usuario;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     DAO.Usuario,
     System.SysUtils,
     Controller.Auth,
     Controller.Comum;

procedure RegistrarRotas;
procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure CadastrarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    THorse.Post('v1/usuarios/login', Login);
    THorse.Post('v1/usuarios/registro', CadastrarUsuario);

    // Versao Horse 2...
    //THorse.Get('v1/usuarios/:id_usuario', HorseJWT(Controller.Auth.SECRET, TMyClaims), ListarId);
    //THorse.Patch('v1/usuarios', HorseJWT(Controller.Auth.SECRET, TMyClaims), EditarUsuario);

    // Versao Horse 3...
    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('v1/usuarios/:id_usuario', ListarId);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Patch('v1/usuarios', EditarUsuario);

end;


procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    usuario: TUsuario;
    body: TJSONValue;
    json: TJSONObject;
begin
    try
        try
            usuario := TUsuario.Create;

            body := Req.Body<TJSONObject>;

            usuario.EMAIL := body.GetValue<string>('email', '');
            usuario.SENHA := body.GetValue<string>('senha', '');

            json := usuario.Login;

            if json.Size = 0 then
                Res.Send<TJSONObject>(CreateJsonObj('erro', 'E-mail ou senha inválida'))
                   .Status(THTTPStatus.Unauthorized)
            else
            begin
                usuario.ID_USUARIO := json.GetValue<integer>('id_usuario', 0);

                // Gerar token JWT com o id_usuario dentro dele...
                json.AddPair('token', Criar_Token(usuario.ID_USUARIO));

                Res.Send<TJSONObject>(json).Status(THTTPStatus.OK);
            end;

        except on ex:exception do
            Res.Send<TJSONObject>(CreateJsonObj('erro', ex.Message))
               .Status(THTTPStatus.InternalServerError);
        end;
    finally
        usuario.Free;
    end;
end;

procedure CadastrarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    usuario: TUsuario;
    body: TJSONValue;
    json: TJSONObject;
begin
    try
        try
            usuario := TUsuario.Create;

            body := Req.Body<TJSONObject>;

            usuario.NOME := body.GetValue<string>('nome', '');
            usuario.EMAIL := body.GetValue<string>('email', '');
            usuario.SENHA := body.GetValue<string>('senha', '');
            usuario.ENDERECO := body.GetValue<string>('endereco', '');
            usuario.COMPLEMENTO := body.GetValue<string>('complemento', '');
            usuario.BAIRRO := body.GetValue<string>('bairro', '');
            usuario.CIDADE := body.GetValue<string>('cidade', '');
            usuario.UF := body.GetValue<string>('uf', '');
            usuario.CEP := body.GetValue<string>('cep', '');
            usuario.COD_CIDADE := body.GetValue<string>('cod_cidade', '');

            usuario.Inserir;

            // Gerar token JWT com o id_usuario dentro dele...
            json := TJSONObject.Create;
            json.AddPair('id_usuario', TJSONNumber.Create(usuario.ID_USUARIO));
            json.AddPair('token', Criar_Token(usuario.ID_USUARIO));

            Res.Send<TJSONObject>(json).Status(THTTPStatus.Created);

        except on ex:exception do
            Res.Send<TJSONObject>(CreateJsonObj('erro', ex.Message))
               .Status(THTTPStatus.InternalServerError);
        end;
    finally
        usuario.Free;
    end;
end;

procedure EditarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    usuario: TUsuario;
    body: TJSONValue;
begin
    try
        try
            usuario := TUsuario.Create;
            usuario.ID_USUARIO := Get_Usuario_Request(Req);

            body := Req.Body<TJSONObject>;
            usuario.NOME := body.GetValue<string>('nome', '');
            usuario.EMAIL := body.GetValue<string>('email', '');

            usuario.Editar;

            Res.Send<TJSONObject>(CreateJsonObj('id_usuario', usuario.ID_USUARIO))
               .Status(THTTPStatus.OK);

        except on ex:exception do
            Res.Send<TJSONObject>(CreateJsonObj('erro', ex.Message))
               .Status(THTTPStatus.InternalServerError);
        end;

    finally
        usuario.free;
    end;
end;

procedure ListarId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    usuario: TUsuario;
begin
    try
        try
            usuario := TUsuario.Create;
            usuario.ID_USUARIO := Req.Params.Items['id_usuario'].ToInteger; // ...v1/usuarios/123

            if Get_Usuario_Request(Req) <> usuario.ID_USUARIO then
                raise Exception.Create('Operação não permitida (obter informações de outro usuário)');

            Res.Send<TJSONArray>(usuario.Listar);

        except on ex:exception do
            Res.Send<TJSONObject>(CreateJsonObj('erro', ex.Message))
               .Status(THTTPStatus.InternalServerError);
        end;

    finally
        usuario.Free;
    end;
end;




end.
