unit Controller.Banner;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     DAO.Banner,
     System.SysUtils,
     Controller.Auth;

procedure RegistrarRotas;
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    // Versao Horse 2...
    //THorse.Get('/v1/banners', HorseJWT(Controller.Auth.SECRET, TMyClaims), Listar);

    // Versao Horse 3...
    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/v1/banners', Listar);
end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    banner: TBanner;
    cod_cidade: string;
begin
    try
        cod_cidade := Req.Query.Items['cod_cidade'];  // v1/banners?cod_cidade=000000
    except
        cod_cidade := '';
    end;

    try
        try
            banner := TBanner.Create;

            Res.Send<TJSONArray>(banner.Listar(cod_cidade));
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        banner.Free;
    end;

end;


end.
