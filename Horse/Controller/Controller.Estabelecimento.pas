unit Controller.Estabelecimento;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     DAO.Estabelecimento,
     System.SysUtils,
     Controller.Comum,
     Controller.Auth;

procedure RegistrarRotas;
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarId(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    // Versao Horse 2...
    //THorse.Get('/v1/estabelecimentos', HorseJWT(Controller.Auth.SECRET, TMyClaims), Listar);
    //THorse.Get('/v1/estabelecimentos/:id_estabelecimento', HorseJWT(Controller.Auth.SECRET, TMyClaims), ListarId);

    // Versao Horse 3...
    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/v1/estabelecimentos', Listar);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/v1/estabelecimentos/:id_estabelecimento', ListarId);


end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    estab: TEstabelecimento;
    pagina: integer;
begin
    try
        try
            estab := TEstabelecimento.Create;
            estab.ID_USUARIO := Get_Usuario_Request(Req);

            try
                estab.ID_CATEGORIA := Req.Query['id_categoria'].ToInteger;
            except
                estab.ID_CATEGORIA := 0;
            end;

            try
                estab.ID_BANNER := Req.Query['id_banner'].ToInteger;
            except
                estab.ID_BANNER := 0;
            end;

            try
                estab.NOME := Req.Query['nome'];
            except
                estab.NOME := '';
            end;

            try
                estab.COD_CIDADE := Req.Query['cod_cidade'];
            except
                estab.COD_CIDADE := '';
            end;

            try
                pagina := Req.Query['pagina'].ToInteger;
            except
                pagina := 0;
            end;

            Res.Send<TJSONArray>(estab.Listar(pagina));

        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        estab.Free;
    end;

end;

procedure ListarId(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    estab: TEstabelecimento;
    jsonArray: TJSONArray;
begin
    // .../v1/estabelecimentos/123

    try
        try
            estab := TEstabelecimento.Create;
            estab.ID_USUARIO := Get_Usuario_Request(Req);
            estab.ID_ESTABELECIMENTO := Req.Params.Items['id_estabelecimento'].ToInteger;

            jsonArray := estab.Listar(0);

            if jsonArray.Size > 0 then
                Res.Send<TJSONArray>(jsonArray)
            else
                Res.Send<TJSONArray>(jsonArray).Status(THTTPStatus.NotFound);

        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        estab.Free;
    end;

end;


end.
