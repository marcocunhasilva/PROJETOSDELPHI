unit Controller.Destaque;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     DAO.Destaque,
     System.SysUtils,
     Controller.Comum,
     Controller.Auth;

procedure RegistrarRotas;
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    // Versao Horse 2...
    //THorse.Get('/v1/destaques', HorseJWT(Controller.Auth.SECRET, TMyClaims), Listar);

    // Versao Horse 3...
    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/v1/destaques', Listar);

end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    dest: TDestaque;
    cod_cidade: string;
begin
    try
        cod_cidade := Req.Query['cod_cidade'];
    except
        cod_cidade := '';
    end;

    try
        try
            dest := TDestaque.Create;
            Res.Send<TJSONArray>(dest.Listar(cod_cidade));

        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        dest.Free;
    end;

end;


end.
