unit Controller.Categoria;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     DAO.Categoria,
     System.SysUtils,
     Controller.Auth;

procedure RegistrarRotas;
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    // Versao Horse 2...
    //THorse.Get('/v1/categorias', HorseJWT(Controller.Auth.SECRET, TMyClaims), Listar);

    // Versao Horse 3 em diante...
    THorse.Get('/v1/categorias', Listar);
end;


procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    cat: TCategoria;
    cod_cidade: string;
begin
    try
        cod_cidade := Req.Query['cod_cidade']; // http://localhost:8082/v1/categorias?cod_cidade=0000000
    except
        cod_cidade := '';
    end;

    try
        try
            cat := TCategoria.Create;

            Res.Send<TJSONArray>(cat.Listar(cod_cidade));
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        cat.Free;
    end;

end;


end.
