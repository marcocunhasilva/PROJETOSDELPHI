unit Controller.Estabelecimento.Admin;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     DAO.Estabelecimento.Admin,
     System.SysUtils,
     Controller.Auth,
     Controller.Comum;

procedure RegistrarRotas;
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Editar(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('/admin/estabelecimentos', Listar);

    THorse
        .AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Put('/admin/estabelecimentos', Editar);
end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    estab : TEstabelecimentoAdmin;
begin
    try
        try
            estab := TEstabelecimentoAdmin.Create;

            estab.id_usuario := Get_Usuario_Request(Req);

            Res.Send<TJsonObject>(estab.Listar).Status(THTTPStatus.OK);

        except on ex:exception do
            Res.Send<TJsonObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;
    finally
        estab.Free;
    end;
end;

procedure Editar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    estab : TEstabelecimentoAdmin;
    body : TJsonValue;
begin
    try
        try
            estab := TEstabelecimentoAdmin.Create;

            body := req.Body<TJSONObject>;

            estab.id_usuario := Get_Usuario_Request(Req);
            estab.nome := body.GetValue<string>('nome', '');
            estab.id_cupom := body.GetValue<integer>('id_cupom', 0);
            estab.vl_min_pedido := body.GetValue<double>('vl_min_pedido', 0);
            estab.vl_taxa_entrega := body.GetValue<double>('vl_taxa_entrega', 0);

            estab.endereco := body.GetValue<string>('endereco', '');
            estab.complemento := body.GetValue<string>('complemento', '');
            estab.bairro := body.GetValue<string>('bairro', '');
            estab.cidade := body.GetValue<string>('cidade', '');
            estab.cod_cidade := body.GetValue<string>('cod_cidade', '');
            estab.uf := body.GetValue<string>('uf', '');
            estab.cep := body.GetValue<string>('cep', '');
            estab.id_categoria := body.GetValue<integer>('id_categoria', 0);

            estab.url_foto := body.GetValue<string>('url_foto', '');
            estab.url_logo := body.GetValue<string>('url_logo', '');
            estab.ind_ativo := body.GetValue<string>('ind_ativo', 'N');

            estab.Editar;

            Res.Send<TJsonObject>(CreateJsonObj('id_estabelecimento', estab.ID_ESTABELECIMENTO)).Status(THTTPStatus.OK);

        except on ex:exception do
            Res.Send<TJsonObject>(CreateJsonObj('erro', ex.Message)).Status(THTTPStatus.InternalServerError);
        end;

    finally
        estab.Free;
    end;
end;


end.
