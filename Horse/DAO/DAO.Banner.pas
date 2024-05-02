unit DAO.Banner;

interface

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.SysUtils,
     Dataset.Serialize,
     DAO.Connection;

type
    TBanner = class
    private
        FConn: TFDConnection;
    public
        constructor Create;
        destructor Destroy; override;

        function Listar(cod_cidade: string): TJSONArray;
    end;

implementation

{ TBanner }

constructor TBanner.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TBanner.Destroy;
begin
    if Assigned(FConn) then
        FConn.Free;

    inherited;
end;

function TBanner.Listar(cod_cidade: string): TJSONArray;
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
            SQL.Add('FROM TAB_BANNER');
            SQL.Add('WHERE COD_CIDADE = :COD_CIDADE');
            SQL.Add('ORDER BY ORDEM');

            ParamByName('COD_CIDADE').Value := cod_cidade;

            Active := true;
        end;

        Result := qry.ToJSONArray();

    finally
        qry.Free;
    end;
end;

end.
