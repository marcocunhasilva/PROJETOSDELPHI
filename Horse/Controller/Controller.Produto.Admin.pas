unit Controller.Produto.Admin;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     DAO.Produto.Admin,
     System.SysUtils,
     System.Classes,
     Controller.Comum,
     Controller.Auth;

procedure RegistrarRotas;
procedure Cardapio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure CardapioOpcional(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure CardapioOpcionalCadastro(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure DadosProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Inserir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Editar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Excluir(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('/admin/cardapios', Cardapio);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('/admin/cardapios/opcionais/:id_produto', CardapioOpcional);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Post('/admin/cardapios/opcionais/:id_produto', CardapioOpcionalCadastro);

    //----------------------

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('/admin/produtos/:id_produto', DadosProduto);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Post('/admin/produtos', Inserir);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Put('/admin/produtos/:id_produto', Editar);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Delete('/admin/produtos/:id_produto', Excluir);
end;


procedure Cardapio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    prod: TProdutoAdmin;
begin
    try
        try
            prod := TProdutoAdmin.Create;


            Res.Send<TJsonArray>(prod.Cardapio(Get_Usuario_Request(Req)));
        except
            Res.Send<TJsonArray>(TJsonArray.Create).Status(THTTPStatus.InternalServerError);
        end;
    finally
        prod.Free;
    end;
end;

procedure CardapioOpcional(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    prod: TProdutoAdmin;
begin
    try
        try
            prod := TProdutoAdmin.Create;

            try
                prod.id_produto := req.Params.Items['id_produto'].ToInteger;
            except
                prod.id_produto := 0;
            end;

            Res.Send<TJsonArray>(prod.CardapioOpcional());
        except
            Res.Send<TJsonArray>(TJsonArray.Create).Status(THTTPStatus.InternalServerError);
        end;
    finally
        prod.Free;
    end;
end;

procedure CardapioOpcionalCadastro(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    prod : TProdutoAdmin;
    body : TJsonArray;
begin
    try
        prod := TProdutoAdmin.Create;

        body := req.Body<TJsonArray>;

        try
            try
                prod.ID_PRODUTO := req.Params.Items['id_produto'].ToInteger;
            except
                prod.ID_PRODUTO := 0;
            end;


            // Grava os opcionais...
            prod.InserirOpcao(body);


            Res.Send<TJsonObject>(CreateJsonObj('retorno', 'OK')).Status(THTTPStatus.OK);

        except on ex:exception do
            Res.Send<TJsonObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;

    finally
        prod.free;
    end;
end;

procedure DadosProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    prod : TProdutoAdmin;
begin
    try
        try
            prod := TProdutoAdmin.Create;

            try
                prod.id_produto := req.Params.Items['id_produto'].ToInteger;
            except
                prod.id_produto := 0;
            end;

            Res.Send<TJsonArray>(prod.Listar);
        except
            Res.Send<TJsonArray>(TJsonArray.Create).Status(THTTPStatus.InternalServerError);
        end;
    finally
        prod.Free;
    end;
end;

procedure Inserir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    prod : TProdutoAdmin;
    body : TJsonValue;
begin
    try
        prod := TProdutoAdmin.Create;

        body := req.Body<TJSONObject>;

        try
            prod.ID_CATEGORIA := body.GetValue<integer>('id_categoria', 0);
            prod.NOME := body.GetValue<string>('nome', '');
            prod.DESCRICAO := body.GetValue<string>('descricao', '');
            prod.URL_FOTO := body.GetValue<string>('url_foto', '');
            prod.VL_PRODUTO := body.GetValue<double>('vl_produto', 0);
            prod.VL_PROMOCAO := body.GetValue<double>('vl_promocao', 0);
            prod.IND_ATIVO := body.GetValue<string>('ind_ativo', 'N');

            prod.Inserir(Get_Usuario_Request(Req));

            Res.Send<TJsonObject>(CreateJsonObj('id_produto', prod.ID_PRODUTO)).Status(THTTPStatus.Created);

        except on ex:exception do
                Res.Send<TJsonObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;

    finally
        prod.free;
    end;
end;

procedure Editar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    prod : TProdutoAdmin;
    body : TJsonValue;
begin
    try
        prod := TProdutoAdmin.Create;

        body := req.Body<TJSONObject>;

        try
            try
                prod.ID_PRODUTO := req.Params.Items['id_produto'].ToInteger;
            except
                prod.ID_PRODUTO := 0;
            end;

            prod.ID_CATEGORIA := body.GetValue<integer>('id_categoria', 0);
            prod.NOME := body.GetValue<string>('nome', '');
            prod.DESCRICAO := body.GetValue<string>('descricao', '');
            prod.URL_FOTO := body.GetValue<string>('url_foto', '');

            try
                prod.VL_PRODUTO := body.GetValue<double>('vl_produto', 0);
            except
                prod.VL_PRODUTO := 0;
            end;

            try
                prod.VL_PROMOCAO := body.GetValue<double>('vl_promocao', 0);
            except
                prod.VL_PROMOCAO := 0;
            end;

            prod.IND_ATIVO := body.GetValue<string>('ind_ativo', 'N');

            prod.Editar;

            Res.Send<TJsonObject>(CreateJsonObj('id_produto', prod.ID_PRODUTO)).Status(THTTPStatus.OK);

        except on ex:exception do
            Res.Send<TJsonObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;

    finally
        prod.free;
    end;
end;

procedure Excluir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    prod : TProdutoAdmin;
    body : TJsonValue;
begin
    try
        prod := TProdutoAdmin.Create;

        body := req.Body<TJSONObject>;

        try
            try
                prod.ID_PRODUTO := req.Params.Items['id_produto'].ToInteger;
            except
                prod.ID_PRODUTO := 0;
            end;

            prod.ExcluirProduto;

            Res.Send<TJsonObject>(CreateJsonObj('id_produto', prod.ID_PRODUTO)).Status(THTTPStatus.OK);

        except on ex:exception do
            Res.Send<TJsonObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;

    finally
        prod.free;
    end;
end;



end.
