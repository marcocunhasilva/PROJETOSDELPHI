unit Controller.Usuario.Admin;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     DAO.Usuario.Admin,
     System.SysUtils,
     Controller.Auth,
     Controller.Comum;

procedure RegistrarRotas;
procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure CadastrarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarSenha(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Dashboard(Req: THorseRequest; Res: THorseResponse; Next: TProc);


implementation

procedure RegistrarRotas;
begin
    THorse.Post('admin/usuarios/login', Login);
    THorse.Post('admin/usuarios/registro', CadastrarUsuario);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Put('admin/usuarios', EditarUsuario);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Put('admin/usuarios/senha', EditarSenha);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('admin/usuarios/dashboard', Dashboard);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('admin/usuarios', Listar);

end;



procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    usuario : TUsuarioAdmin;
    body : TJsonValue;
    json : TJSONObject;
begin
    try
        try
            usuario := TUsuarioAdmin.Create;

            body := req.Body<TJSONObject>;
            usuario.email := body.GetValue<string>('email', '');
            usuario.senha := body.GetValue<string>('senha', '');

            json := usuario.Login;

            if json.Size = 0 then
            begin
                Res.Send<TJsonObject>(CreateJsonObj('erro', 'E-mail ou senha inválida'))
                   .Status(THTTPStatus.Unauthorized);
                json.DisposeOf;
            end
            else
            begin
                usuario.ID_USUARIO := json.GetValue<integer>('id_usuario', 0);

                // Gerar token para o usuario...
                json.AddPair('token', Criar_Token(usuario.ID_USUARIO));

                Res.Send<TJsonObject>(json).Status(THTTPStatus.OK);
            end;

        except on ex:exception do
            Res.Send<TJsonObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;

    finally
        usuario.Free;
    end;
end;

procedure CadastrarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    usuario : TUsuarioAdmin;
    body : TJsonValue;
    json : TJSONObject;
begin
    try
        try
            usuario := TUsuarioAdmin.Create;

            //sleep(3000);

            body := req.Body<TJSONObject>;
            usuario.nome := body.GetValue<string>('nome', '');
            usuario.email := body.GetValue<string>('email', '');
            usuario.senha := body.GetValue<string>('senha', '');

            usuario.estabelecimento := body.GetValue<string>('estabelecimento', '');
            usuario.endereco := body.GetValue<string>('endereco', '');
            usuario.complemento := body.GetValue<string>('complemento', '');
            usuario.bairro := body.GetValue<string>('bairro', '');
            usuario.cidade := body.GetValue<string>('cidade', '');
            usuario.uf := body.GetValue<string>('uf', '');
            usuario.cep := body.GetValue<string>('cep', '');
            usuario.cod_cidade := body.GetValue<string>('cod_cidade', '');
            usuario.id_categoria := body.GetValue<integer>('id_categoria', 0);

            usuario.Inserir;

            // Monta json de retorno com token...
            json := TJSONObject.Create;
            json.AddPair('id_usuario', TJSONNumber.Create(usuario.ID_USUARIO));
            json.AddPair('token', Criar_Token(usuario.ID_USUARIO));

            Res.Send<TJsonObject>(json).Status(THTTPStatus.Created);

        except on ex:exception do
            Res.Send<TJsonObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;

    finally
        usuario.Free;
    end;
end;

procedure EditarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    usuario : TUsuarioAdmin;
    body : TJsonValue;
begin
    try
        try
            usuario := TUsuarioAdmin.Create;
            usuario.id_usuario := Get_Usuario_Request(Req);

            body := Req.Body<TJSONObject>;
            usuario.nome := body.GetValue<string>('nome', '');
            usuario.email := body.GetValue<string>('email', '');

            usuario.Editar;

            Res.Send<TJsonObject>(CreateJsonObj('id_usuario', usuario.ID_USUARIO)).Status(THTTPStatus.OK);

        except on ex:exception do
            Res.Send<TJsonObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;

    finally
        usuario.Free;
    end;
end;

procedure EditarSenha(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    usuario : TUsuarioAdmin;
    body : TJsonValue;
    senha2: string;
begin
    try
        try
            usuario := TUsuarioAdmin.Create;
            usuario.id_usuario := Get_Usuario_Request(Req);

            body := Req.Body<TJSONObject>;
            usuario.senha := body.GetValue<string>('senha', '');
            senha2 := body.GetValue<string>('senha2', '');

            if usuario.senha <> senha2 then
                raise Exception.Create('As senhas não conferem. Digite novamente');

            usuario.EditarSenha;

            Res.Send<TJsonObject>(CreateJsonObj('id_usuario', usuario.ID_USUARIO)).Status(THTTPStatus.OK);

        except on ex:exception do
            Res.Send<TJsonObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;

    finally
        usuario.Free;
    end;
end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    usuario: TUsuarioAdmin;
begin
    try
        try
            usuario := TUsuarioAdmin.Create;
            usuario.id_usuario := Get_Usuario_Request(Req);

            Res.Send<TJsonObject>(usuario.Listar);

        except on ex:exception do
            Res.Send<TJSONObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;
    finally
        usuario.Free;
    end;
end;

procedure Dashboard(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    usuario: TUsuarioAdmin;
begin
    try
        try
            usuario := TUsuarioAdmin.Create;
            usuario.id_usuario := Get_Usuario_Request(Req);

            Res.Send<TJsonObject>(usuario.Dashboard);

        except on ex:exception do
            Res.Send<TJSONObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;
    finally
        usuario.Free;
    end;
end;




end.
