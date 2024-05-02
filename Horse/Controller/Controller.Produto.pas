unit Controller.Produto;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     DAO.Produto,
     System.SysUtils,
     Controller.Auth;

procedure RegistrarRotas;
procedure Cardapio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarOpcao(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure DadosProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    // Horse Versao 2...
    //THorse.Get('/v1/cardapios/:id_estabelecimento', HorseJWT(Controller.Auth.SECRET, TMyClaims), Cardapio);
    //THorse.Get('/v1/cardapios/opcoes/:id_produto', HorseJWT(Controller.Auth.SECRET, TMyClaims), ListarOpcao);
    //THorse.Get('/v1/produtos/:id_produto', HorseJWT(Controller.Auth.SECRET, TMyClaims), DadosProduto);

    // Horse Versao 3...
    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/v1/cardapios/:id_estabelecimento', Cardapio);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/v1/cardapios/opcoes/:id_produto', ListarOpcao);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/v1/produtos/:id_produto', DadosProduto);
end;
procedure Cardapio(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    prod: TProduto;
begin
    try
        try
            prod := TProduto.Create;

            try
                prod.ID_ESTABELECIMENTO := Req.Params.Items['id_estabelecimento'].ToInteger;
            except
                prod.ID_ESTABELECIMENTO := 0;
            end;

            Res.Send<TJSONArray>(prod.Cardapio);
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        prod.Free;
    end;

end;

procedure ListarOpcao(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    prod: TProduto;
begin
    try
        try
            prod := TProduto.Create;

            try
                prod.ID_PRODUTO := Req.Params.Items['id_produto'].ToInteger;
            except
                prod.ID_PRODUTO := 0;
            end;

            Res.Send<TJSONArray>(prod.ListarOpcao);
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        prod.Free;
    end;

end;

procedure DadosProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    prod: TProduto;
begin
    try
        try
            prod := TProduto.Create;

            try
                prod.ID_PRODUTO := Req.Params.Items['id_produto'].ToInteger;
            except
                prod.ID_PRODUTO := 0;
            end;

            Res.Send<TJSONArray>(prod.Listar);
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        prod.Free;
    end;

end;

end.
