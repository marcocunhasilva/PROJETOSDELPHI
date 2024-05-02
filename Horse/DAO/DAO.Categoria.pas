unit DAO.Categoria;

interface

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.SysUtils,
     Dataset.Serialize,
     DAO.Connection;

type
    TCategoria = class
    private
        FConn: TFDConnection;
    public
        constructor Create;
        destructor Destroy; override;

        function Listar(cod_cidade: string): TJSONArray;
    end;

implementation

{ TCategoria }

constructor TCategoria.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TCategoria.Destroy;
begin
    if Assigned(FConn) then
        FConn.Free;

    inherited;
end;

function TCategoria.Listar(cod_cidade: string): TJSONArray;
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
            SQL.Add('SELECT C.*');
            SQL.Add('FROM TAB_CATEGORIA C');
            SQL.Add('JOIN TAB_CATEGORIA_CIDADE CC ON (CC.ID_CATEGORIA = C.ID_CATEGORIA)');
            SQL.Add('WHERE CC.COD_CIDADE = :COD_CIDADE');
            SQL.Add('ORDER BY C.ORDEM');

            ParamByName('COD_CIDADE').Value := cod_cidade;

            Active := true;
        end;

        Result := qry.ToJSONArray();

    finally
        qry.Free;
    end;
end;

end.
