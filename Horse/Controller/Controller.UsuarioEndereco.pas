unit Controller.UsuarioEndereco;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     DAO.UsuarioEndereco,
     System.SysUtils,
     Controller.Auth,
     Controller.Comum;

procedure RegistrarRotas;
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Adicionar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Editar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Excluir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EnderecoPadrao(Req: THorseRequest; Res: THorseResponse; Next: TProc);


implementation

procedure RegistrarRotas;
begin
    // Versao Horse 2...
    //THorse.Get('/v1/usuarios/enderecos/:id_endereco', HorseJWT(Controller.Auth.SECRET, TMyClaims), Listar);
    //THorse.Get('/v1/usuarios/enderecos', HorseJWT(Controller.Auth.SECRET, TMyClaims), Listar);
    //THorse.Post('/v1/usuarios/enderecos', HorseJWT(Controller.Auth.SECRET, TMyClaims), Adicionar);
    //THorse.Patch('/v1/usuarios/enderecos/:id_endereco', HorseJWT(Controller.Auth.SECRET, TMyClaims), Editar);
    //THorse.Delete('/v1/usuarios/enderecos/:id_endereco', HorseJWT(Controller.Auth.SECRET, TMyClaims), Excluir);
    //THorse.Patch('/v1/usuarios/enderecos/padrao/:id_endereco', HorseJWT(Controller.Auth.SECRET, TMyClaims), EnderecoPadrao);

    // Versao Horse 3...
    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/v1/usuarios/enderecos/:id_endereco', Listar);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/v1/usuarios/enderecos', Listar);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Post('/v1/usuarios/enderecos', Adicionar);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Patch('/v1/usuarios/enderecos/:id_endereco', Editar);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Delete('/v1/usuarios/enderecos/:id_endereco', Excluir);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Patch('/v1/usuarios/enderecos/padrao/:id_endereco', EnderecoPadrao);


end;


procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    endereco: TUsuarioEndereco;
begin
    try
        try
            endereco := TUsuarioEndereco.Create;
            endereco.ID_USUARIO := Get_Usuario_Request(Req);

            try
                endereco.ID_ENDERECO := Req.Params.Items['id_endereco'].ToInteger; // v1/usuarios/enderecos/1
            except
                endereco.ID_ENDERECO := 0;
            end;

            try
                endereco.COD_CIDADE := Req.Query['cod_cidade'];  // v1/usuarios/enderecos?cod_cidade=000000
            except
                endereco.COD_CIDADE := '';
            end;

            Res.Send<TJSONArray>(endereco.Listar);
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        endereco.Free;
    end;

end;

procedure Adicionar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    endereco: TUsuarioEndereco;
    body: TJSONValue;
begin
    try
        try
            endereco := TUsuarioEndereco.Create;
            body := Req.Body<TJSONObject>;

            with endereco do
            begin
                ID_USUARIO := Get_Usuario_Request(Req);
                ENDERECO := body.GetValue<string>('endereco', '');
                COMPLEMENTO := body.GetValue<string>('complemento', '');
                BAIRRO := body.GetValue<string>('bairro', '');
                CIDADE := body.GetValue<string>('cidade', '');
                UF := body.GetValue<string>('uf', '');
                CEP := body.GetValue<string>('cep', '');
                IND_PADRAO := body.GetValue<string>('ind_pdrao', '');
                COD_CIDADE := body.GetValue<string>('cod_cidade', '');

                Inserir;
            end;

            Res.Send<TJSONObject>(CreateJsonObj('id_endereco', endereco.ID_ENDERECO)).Status(THTTPStatus.Created);
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        endereco.Free;
    end;

end;

procedure Editar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    endereco: TUsuarioEndereco;
    body: TJSONValue;
begin
    try
        try
            endereco := TUsuarioEndereco.Create;
            body := Req.Body<TJSONObject>;

            with endereco do
            begin
                ID_USUARIO := Get_Usuario_Request(Req);
                ID_ENDERECO := Req.Params.Items['id_endereco'].ToInteger;
                ENDERECO := body.GetValue<string>('endereco', '');
                COMPLEMENTO := body.GetValue<string>('complemento', '');
                BAIRRO := body.GetValue<string>('bairro', '');
                CIDADE := body.GetValue<string>('cidade', '');
                UF := body.GetValue<string>('uf', '');
                CEP := body.GetValue<string>('cep', '');
                IND_PADRAO := body.GetValue<string>('ind_pdrao', '');
                COD_CIDADE := body.GetValue<string>('cod_cidade', '');

                Editar;
            end;

            Res.Send<TJSONObject>(CreateJsonObj('id_endereco', endereco.ID_ENDERECO));
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        endereco.Free;
    end;

end;

procedure Excluir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    endereco: TUsuarioEndereco;
begin
    try
        try
            endereco := TUsuarioEndereco.Create;
            endereco.ID_USUARIO := Get_Usuario_Request(Req);

            try
                endereco.ID_ENDERECO := Req.Params.Items['id_endereco'].ToInteger;
            except
                endereco.ID_ENDERECO := 0;
            end;

            endereco.Excluir;

            Res.Send<TJSONObject>(CreateJsonObj('id_endereco', endereco.ID_ENDERECO));
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        endereco.Free;
    end;

end;

procedure EnderecoPadrao(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    endereco: TUsuarioEndereco;
begin
    try
        try
            endereco := TUsuarioEndereco.Create;
            endereco.ID_USUARIO := Get_Usuario_Request(Req);

            try
                endereco.ID_ENDERECO := Req.Params.Items['id_endereco'].ToInteger;
            except
                endereco.ID_ENDERECO := 0;
            end;

            endereco.TornarPadrao;

            Res.Send<TJSONObject>(CreateJsonObj('id_endereco', endereco.ID_ENDERECO));
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        endereco.Free;
    end;

end;

end.
