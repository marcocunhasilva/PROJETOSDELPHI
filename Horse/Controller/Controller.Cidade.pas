unit Controller.Cidade;

interface

uses Horse,
     System.JSON,
     DAO.Cidade,
     System.SysUtils;

procedure RegistrarRotas;
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
    THorse.Get('/v1/cidades', Listar);
end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    cid: TCidade;
begin
    try
        try
            cid := TCidade.Create;

            Res.Send<TJSONArray>(cid.Listar);
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        cid.Free;
    end;

end;


end.
