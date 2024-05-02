unit Controller.ProdutoCategoria.Admin;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     Controller.Comum,
     DAO.ProdutoCategoria.Admin,
     System.SysUtils,
     System.Classes,
     Controller.Auth;

procedure RegistrarRotas;
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Inserir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Editar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Excluir(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('/admin/produtos/categorias/:id_categoria', Listar);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('/admin/produtos/categorias', Listar);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Post('/admin/produtos/categorias', Inserir);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Put('/admin/produtos/categorias/:id_categoria', Editar);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Delete('/admin/produtos/categorias/:id_categoria', Excluir);
end;


procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    cat: TProdutoCategoriaAdmin;
begin
    try
        try
            cat := TProdutoCategoriaAdmin.Create;

            try
                cat.id_categoria := req.Params.Items['id_categoria'].ToInteger;
            except
                cat.id_categoria := 0;
            end;

            try
                cat.ind_ativo := req.Query['ind_ativo'];
            except
                cat.ind_ativo := '';
            end;

            Res.Send<TJsonArray>(cat.Listar(Get_Usuario_Request(Req)));
        except
            Res.Send<TJsonArray>(TJsonArray.Create).Status(THTTPStatus.InternalServerError);
        end;
    finally
        cat.Free;
    end;
end;

procedure Inserir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    cat : TProdutoCategoriaAdmin;
    body : TJsonValue;
begin
    try
        cat := TProdutoCategoriaAdmin.Create;

        body := req.Body<TJSONObject>;

        try
            cat.CATEGORIA := body.GetValue<string>('categoria', '');
            cat.IND_ATIVO := body.GetValue<string>('ind_ativo', 'N');

            cat.Inserir(Get_Usuario_Request(Req));

            Res.Send<TJsonObject>(CreateJsonObj('id_categoria', cat.ID_CATEGORIA)).Status(THTTPStatus.Created);

        except on ex:exception do
                Res.Send<TJsonObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;

    finally
        cat.free;
    end;
end;

procedure Editar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    cat : TProdutoCategoriaAdmin;
    body : TJsonValue;
begin
    try
        cat := TProdutoCategoriaAdmin.Create;

        body := req.Body<TJSONObject>;

        try
            cat.CATEGORIA := body.GetValue<string>('categoria', '');
            cat.IND_ATIVO := body.GetValue<string>('ind_ativo', 'N');

            try
                cat.id_categoria := req.Params.Items['id_categoria'].ToInteger;
            except
                cat.id_categoria := 0;
            end;

            cat.Editar;

            Res.Send<TJsonObject>(CreateJsonObj('id_categoria', cat.ID_CATEGORIA)).Status(THTTPStatus.Created);

        except on ex:exception do
                Res.Send<TJsonObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;

    finally
        cat.free;
    end;
end;

procedure Excluir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    cat : TProdutoCategoriaAdmin;
    body : TJsonValue;
begin
    try
        cat := TProdutoCategoriaAdmin.Create;

        body := req.Body<TJSONObject>;

        try
            try
                cat.id_categoria := req.Params.Items['id_categoria'].ToInteger;
            except
                cat.id_categoria := 0;
            end;

            cat.Excluir;

            Res.Send<TJsonObject>(CreateJsonObj('id_categoria', cat.ID_CATEGORIA)).Status(THTTPStatus.Created);

        except on ex:exception do
                Res.Send<TJsonObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;

    finally
        cat.free;
    end;
end;


end.
