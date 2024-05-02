unit DAO.UsuarioFavorito;

interface

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.SysUtils,
     System.StrUtils,
     Dataset.Serialize,
     DAO.Connection;

type
    TUsuarioFavorito = class
    private
        FConn: TFDConnection;
        FID_FAVORITO: integer;
        FID_ESTABELECIMENTO: integer;
        FID_USUARIO: integer;

        procedure Validate(operacao: string);
    public
        constructor Create;
        destructor Destroy; override;

        property ID_FAVORITO: integer read FID_FAVORITO write FID_FAVORITO;
        property ID_USUARIO: integer read FID_USUARIO write FID_USUARIO;
        property ID_ESTABELECIMENTO: integer read FID_ESTABELECIMENTO write FID_ESTABELECIMENTO;

        function Listar: TJSONArray;
        procedure Inserir;
        procedure Excluir;
    end;

implementation

{ TUsuarioFavorito }

constructor TUsuarioFavorito.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TUsuarioFavorito.Destroy;
begin
    if Assigned(FConn) then
        FConn.Free;

    inherited;
end;

function TUsuarioFavorito.Listar: TJSONArray;
var
    qry: TFDQuery;
begin
    Validate('Listar');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('SELECT F.ID_FAVORITO, E.ID_ESTABELECIMENTO, E.NOME, E.URL_LOGO, E.AVALIACAO,');
            SQL.Add('       C.CATEGORIA, E.ENDERECO, E.COMPLEMENTO, E.BAIRRO, E.CIDADE, E.UF, E.COD_CIDADE');
            SQL.Add('FROM TAB_USUARIO_FAVORITO F');
            SQL.Add('JOIN TAB_ESTABELECIMENTO E ON (E.ID_ESTABELECIMENTO = F.ID_ESTABELECIMENTO)');
            SQL.Add('JOIN TAB_CATEGORIA C ON (C.ID_CATEGORIA = E.ID_CATEGORIA)');
            SQL.Add('WHERE F.ID_USUARIO = :ID_USUARIO');
            SQL.Add('ORDER BY E.NOME');

            ParamByName('ID_USUARIO').Value := ID_USUARIO;

            Active := true;
        end;

        Result := qry.ToJSONArray();

    finally
        qry.Free;
    end;
end;

procedure TUsuarioFavorito.Inserir;
var
    qry: TFDQuery;
begin
    Validate('Inserir');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('INSERT INTO TAB_USUARIO_FAVORITO(ID_USUARIO, ID_ESTABELECIMENTO)');
            SQL.Add('VALUES(:ID_USUARIO, :ID_ESTABELECIMENTO)');
            SQL.Add('RETURNING ID_FAVORITO');

            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ParamByName('ID_ESTABELECIMENTO').Value := ID_ESTABELECIMENTO;
            Active := true;

            ID_FAVORITO := FieldByName('ID_FAVORITO').AsInteger;
        end;

    finally
        qry.Free;
    end;
end;

procedure TUsuarioFavorito.Excluir;
var
    qry: TFDQuery;
begin
    Validate('Excluir');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('DELETE FROM TAB_USUARIO_FAVORITO');
            SQL.Add('WHERE ID_FAVORITO = :ID_FAVORITO AND ID_USUARIO=:ID_USUARIO');
            ParamByName('ID_FAVORITO').Value := ID_FAVORITO;
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ExecSQL;
        end;

    finally
        qry.Free;
    end;
end;

procedure TUsuarioFavorito.Validate(operacao: string);
begin
    if (ID_USUARIO <= 0) and MatchStr(operacao, ['Listar', 'Inserir', 'Excluir']) then
        raise Exception.Create('Usuário não informado');

    if (ID_ESTABELECIMENTO <= 0) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Estabelecimento não informado');

    if (ID_FAVORITO <= 0) and MatchStr(operacao, ['Excluir']) then
        raise Exception.Create('Id. favorito não informada');

end;

end.
