unit Controller.Cupom;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     DAO.Cupom,
     System.SysUtils,
     Controller.Comum,
     Controller.Auth;

procedure RegistrarRotas;
procedure ValidarCupom(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    // Versao Horse 2...
    //THorse.Get('/v1/cupons/validacao', HorseJWT(Controller.Auth.SECRET, TMyClaims), ValidarCupom);

    // Versao Horse 3...
    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/v1/cupons/validacao', ValidarCupom);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/v1/cupons', Listar);
end;


procedure ValidarCupom(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    cupom: TCupom;
    json: TJSONObject;
begin
    // v1/cupons/validacao?cod_cupom=000&valor=4500&id_estabelecimento=1

    try
        try
            cupom := TCupom.Create;

            try
                cupom.COD_CUPOM := Req.Query['cod_cupom'];
            except
                cupom.COD_CUPOM := '';
            end;

            try
                cupom.VL_PEDIDO := Req.Query['valor'].ToDouble / 100;
            except
                cupom.VL_PEDIDO := 0;
            end;

            try
                cupom.ID_ESTABELECIMENTO := Req.Query['id_estabelecimento'].ToInteger;
            except
                cupom.ID_ESTABELECIMENTO := 0;
            end;

            json := cupom.Validar;

            if json.Size > 0 then
                Res.Send<TJSONObject>(json)
            else
            begin
                json.DisposeOf;
                Res.Send<TJSONObject>(CreateJsonObj('erro', 'Cupom inválido'))
                   .Status(THTTPStatus.NotFound);
            end;

        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        cupom.Free;
    end;

end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    cupom : TCupom;
begin
    try
        try
            cupom := TCupom.Create;

            Res.Send<TJsonArray>(cupom.Listar);
        except
            Res.Send<TJsonArray>(TJsonArray.Create).Status(THTTPStatus.InternalServerError);
        end;
    finally
        cupom.Free;
    end;
end;


end.
