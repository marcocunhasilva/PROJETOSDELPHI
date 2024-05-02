unit Controller.EstabelecimentoFavorito;

interface

uses Horse,
     Horse.JWT,
     System.JSON,
     DAO.UsuarioFavorito,
     System.SysUtils,
     Controller.Auth,
     Controller.Comum;

procedure RegistrarRotas;
procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Adicionar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Excluir(Req: THorseRequest; Res: THorseResponse; Next: TProc);


implementation

procedure RegistrarRotas;
begin
    // Versao Horse 2...
    //THorse.Get('/v1/estabelecimentos/favoritos', HorseJWT(Controller.Auth.SECRET, TMyClaims), Listar);
    //THorse.Post('/v1/estabelecimentos/favoritos', HorseJWT(Controller.Auth.SECRET, TMyClaims), Adicionar);
    //THorse.Delete('/v1/estabelecimentos/favoritos/:id_favorito', HorseJWT(Controller.Auth.SECRET, TMyClaims), Excluir);

    // Versao Horse 3...
    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Get('/v1/estabelecimentos/favoritos', Listar);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Post('/v1/estabelecimentos/favoritos', Adicionar);

    THorse.AddCallback(HorseJWT(Controller.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
          .Delete('/v1/estabelecimentos/favoritos/:id_favorito', Excluir);

end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    fav: TUsuarioFavorito;
begin
    try
        try
            fav := TUsuarioFavorito.Create;
            fav.ID_USUARIO := Get_Usuario_Request(Req);
            Res.Send<TJSONArray>(fav.Listar);
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        fav.Free;
    end;

end;

procedure Adicionar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    fav: TUsuarioFavorito;
    body: TJSONValue;
begin
    try
        try
            fav := TUsuarioFavorito.Create;
            fav.ID_USUARIO := Get_Usuario_Request(Req);

            body := Req.Body<TJSONObject>;

            fav.ID_ESTABELECIMENTO := body.GetValue<integer>('id_estabelecimento', 0);
            fav.Inserir;

            Res.Send<TJSONObject>(CreateJsonObj('id_favorito', fav.ID_FAVORITO)).Status(THTTPStatus.Created);
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        fav.Free;
    end;

end;

procedure Excluir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    fav: TUsuarioFavorito;
begin
    try
        try
            fav := TUsuarioFavorito.Create;
            fav.ID_USUARIO := Get_Usuario_Request(Req);

            try
                fav.ID_FAVORITO := Req.Params.Items['id_favorito'].ToInteger;
            except
                fav.ID_FAVORITO := 0;
            end;

            fav.Excluir;

            Res.Send<TJSONObject>(CreateJsonObj('id_favorito', fav.ID_FAVORITO));
        except on ex:exception do
            Res.Send(ex.Message).Status(THTTPStatus.InternalServerError);
        end;
    finally
        fav.Free;
    end;

end;


end.
