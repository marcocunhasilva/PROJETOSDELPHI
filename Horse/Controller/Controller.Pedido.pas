unit Controller.Pedido;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     DAO.Pedido,
     DAO.PedidoItem,
     DAO.PedidoItemDetalhe,
     System.SysUtils,
     Controller.Auth,
     Controller.Comum;

procedure RegistrarRotas;
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Adicionar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure AvaliarPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);


implementation

procedure RegistrarRotas;
begin
    // Versao Horse 2...
    //THorse.Get('/v1/pedidos', HorseJWT(Controller.Auth.SECRET, TMyClaims), Listar);
    //THorse.Post('/v1/pedidos', HorseJWT(Controller.Auth.SECRET, TMyClaims), Adicionar);
    //THorse.Patch('/v1/pedidos/avaliacao/:id_pedido', HorseJWT(Controller.Auth.SECRET, TMyClaims), AvaliarPedido);

    // Versao Horse 3...
    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/v1/pedidos', Listar);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Post('/v1/pedidos', Adicionar);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Patch('/v1/pedidos/avaliacao/:id_pedido', AvaliarPedido);


end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    ped: TPedido;
begin
    try
        try
            ped := TPedido.Create;
            ped.ID_USUARIO := Get_Usuario_Request(Req);

            Res.Send<TJSONArray>(ped.Listar(''));
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        ped.Free;
    end;

end;

procedure Adicionar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    ped: TPedido;
    item: TPedidoItem;
    detalhe: TPedidoItemDetalhe;

    body: TJSONValue;
    arrayItem, arrayDetalhe: TJSONArray;
    x, i: integer;
begin
    try
        try
            ped := TPedido.Create;
            ped.StartTransaction;

            body := Req.Body<TJSONObject>;

            // Pedido...
            with ped do
            begin
                ID_USUARIO := Get_Usuario_Request(Req);
                ID_ESTABELECIMENTO := body.GetValue<integer>('id_estabelecimento', 0);
                ID_CUPOM := body.GetValue<integer>('id_cupom', 0);
                VL_TAXA_ENTREGA := body.GetValue<double>('vl_taxa_entrega', 0);
                VL_DESCONTO := body.GetValue<double>('vl_desconto', 0);
                VL_TOTAL := body.GetValue<double>('vl_total', 0);
                STATUS := 'A';
                AVALIACAO := 0;
                ENDERECO := body.GetValue<string>('endereco', '');
                COMPLEMENTO := body.GetValue<string>('complemento', '');
                BAIRRO := body.GetValue<string>('bairro', '');
                CIDADE := body.GetValue<string>('cidade', '');
                UF := body.GetValue<string>('uf', '');
                CEP := body.GetValue<string>('cep', '');
                COD_CIDADE := body.GetValue<string>('cod_cidade', '');

                arrayItem := body.GetValue<TJSONArray>('itens');

                Inserir;
            end;


            // Itens do pedido....
            try
                item := TPedidoItem.Create(ped.GetConnection);

                for x := 0 to arrayItem.Size - 1 do
                begin
                    item.ID_PEDIDO := ped.ID_PEDIDO;
                    item.ID_PRODUTO := arrayItem.Get(x).GetValue<integer>('id_produto', 0);
                    item.DESCRICAO := arrayItem.Get(x).GetValue<string>('descricao', '');
                    item.QTD := arrayItem.Get(x).GetValue<integer>('qtd', 0);
                    item.VL_UNIT := arrayItem.Get(x).GetValue<double>('vl_unit', 0);
                    item.VL_TOTAL := arrayItem.Get(x).GetValue<double>('vl_total', 0);
                    item.Inserir;


                    // Detalhes dos itens...
                    arrayDetalhe := arrayItem.Get(x).GetValue<TJSONArray>('detalhes');

                    try
                        detalhe := TPedidoItemDetalhe.Create(ped.GetConnection);

                        for i := 0 to arrayDetalhe.Size - 1 do
                        begin
                            detalhe.ID_PEDIDO_ITEM := item.ID_PEDIDO_ITEM;
                            detalhe.NOME := arrayDetalhe.Get(i).GetValue<string>('nome', '');
                            detalhe.ID_ITEM := arrayDetalhe.Get(i).GetValue<integer>('id_item', 0);
                            detalhe.VL_ITEM := arrayDetalhe.Get(i).GetValue<double>('vl_item', 0);
                            detalhe.ORDEM := arrayDetalhe.Get(i).GetValue<integer>('ordem', 0);

                            detalhe.Inserir;
                        end;
                    finally
                        detalhe.Free;
                    end;

                end;
            finally
                item.Free;
            end;

            ped.CommitTransaction;

            Res.Send<TJSONObject>(CreateJsonObj('id_pedido', ped.ID_PEDIDO)).Status(THTTPStatus.Created);

        except on ex:exception do
            begin
                ped.RollbackTransaction;
                Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
            end;
        end;
    finally
        ped.Free;
    end;

end;

procedure AvaliarPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    ped: TPedido;
    body: TJSONValue;
begin
    try
        try
            ped := TPedido.Create;
            body := Req.Body<TJSONObject>;

            ped.ID_USUARIO := Get_Usuario_Request(Req);
            ped.AVALIACAO := body.GetValue<integer>('avaliacao', 0);

            try
                ped.ID_PEDIDO := Req.Params.Items['id_pedido'].ToInteger;
            except
                ped.ID_PEDIDO := 0;
            end;

            ped.AvaliarPedido;

            Res.Send<TJSONObject>(CreateJsonObj('id_pedido', ped.ID_PEDIDO));
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        ped.Free;
    end;

end;

end.
