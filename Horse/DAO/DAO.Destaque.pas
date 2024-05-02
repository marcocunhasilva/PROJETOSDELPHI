unit DAO.Destaque;

interface

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.SysUtils,
     Dataset.Serialize,
     DAO.Connection;

type
    TDestaque = class
    private
        FConn: TFDConnection;
    public
        constructor Create;
        destructor Destroy; override;

        function Listar(cod_cidade: string): TJSONArray;
    end;

implementation

{ TDestaque }

constructor TDestaque.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TDestaque.Destroy;
begin
    if Assigned(FConn) then
        FConn.Free;

    inherited;
end;

function TDestaque.Listar(cod_cidade: string): TJSONArray;
var
    qry: TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('SELECT D.DESCRICAO, E.ID_ESTABELECIMENTO, E.NOME, E.URL_LOGO, E.AVALIACAO, C.CATEGORIA');
            SQL.Add('FROM TAB_DESTAQUE D ');
            SQL.Add('JOIN TAB_DESTAQUE_ESTABELECIMENTO DE ON (DE.ID_DESTAQUE = D.ID_DESTAQUE)');
            SQL.Add('JOIN TAB_ESTABELECIMENTO E ON (E.ID_ESTABELECIMENTO = DE.ID_ESTABELECIMENTO)');
            SQL.Add('JOIN TAB_CATEGORIA C ON (C.ID_CATEGORIA = E.ID_CATEGORIA)');
            SQL.Add('WHERE D.IND_ATIVO = :IND_ATIVO');
            SQL.Add('AND E.COD_CIDADE = :COD_CIDADE');
            SQL.Add('ORDER BY D.ORDEM');

            ParamByName('IND_ATIVO').Value := 'S';
            ParamByName('COD_CIDADE').Value := cod_cidade;

            Active := true;
        end;

        Result := qry.ToJSONArray();

    finally
        qry.Free;
    end;
end;

end.
