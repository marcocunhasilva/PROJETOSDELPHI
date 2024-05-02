unit DAO.Cidade;

interface

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.SysUtils,
     Dataset.Serialize,
     DAO.Connection;

type
    TCidade = class
    private
        FConn: TFDConnection;
    public
        constructor Create;
        destructor Destroy; override;

        function Listar(): TJSONArray;
    end;

implementation

{ TCidade }

constructor TCidade.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TCidade.Destroy;
begin
    if Assigned(FConn) then
        FConn.Free;

    inherited;
end;

function TCidade.Listar(): TJSONArray;
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
            SQL.Add('SELECT *');
            SQL.Add('FROM TAB_CIDADE');
            SQL.Add('ORDER BY CIDADE');

            Active := true;
        end;

        Result := qry.ToJSONArray();

    finally
        qry.Free;
    end;
end;

end.
