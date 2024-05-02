unit Controller.Pedido.Admin;

interface

uses Horse,
     Horse.Jhonson,
     Horse.JWT,
     System.JSON,
     DAO.Pedido.Admin,
     System.SysUtils,
     Controller.Auth,
     Controller.Comum,
     Rest.Json;

procedure RegistrarRotas;
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure StatusPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarPedidosDashboard(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('/admin/pedidos', Listar);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Put('/admin/pedidos/status/:id_pedido', StatusPedido);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('admin/pedidos/dashboard', ListarPedidosDashboard);
end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    ped: TPedidoAdmin;
begin
    try
        try
            ped := TPedidoAdmin.Create;

            ped.id_usuario := Get_Usuario_Request(Req);

            try
                ped.STATUS := req.Query['status'];
            except
                ped.STATUS := '';
            end;

            try
                ped.STATUS_NOT_IN := req.Query['status_not_in'];
            except
                ped.STATUS_NOT_IN := '';
            end;

            Res.Send<TJsonArray>(ped.Listar).Status(THTTPStatus.OK);
        except
            Res.Send<TJsonArray>(TJsonArray.Create).Status(THTTPStatus.InternalServerError);
        end;
    finally
        ped.Free;
    end;
end;

procedure StatusPedido(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    ped : TPedidoAdmin;
    body: TJsonValue;
begin
    try
        ped := TPedidoAdmin.Create;

        try
            ped.id_usuario := Get_Usuario_Request(Req);

            body := req.Body<TJSONObject>;
            ped.status := body.GetValue<string>('status', '');

            try
                ped.id_pedido := req.Params.Items['id_pedido'].ToInteger;
            except
                ped.id_pedido := 0;
            end;

            ped.StatusPedido;

            Res.Send<TJSONObject>(CreateJsonObj('id_pedido', ped.id_pedido)).Status(THTTPStatus.OK);
        except on ex:exception do
            Res.Send<TJSONObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.BadRequest);
        end;

    finally
        ped.Free;
    end;
end;

procedure ListarPedidosDashboard(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    pedido: TPedidoAdmin;
begin
    try
        try
            pedido := TPedidoAdmin.Create;

            pedido.ID_USUARIO := Get_Usuario_Request(Req);

            Res.Send<TJsonArray>(pedido.ListarUltPedidos);

        except on ex:exception do
            Res.Send<TJSONObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;
    finally
        pedido.Free;
    end;
end;

end.
