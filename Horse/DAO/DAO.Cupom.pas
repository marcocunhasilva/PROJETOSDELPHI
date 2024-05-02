unit DAO.Cupom;

interface

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.SysUtils,
     StrUtils,
     Dataset.Serialize,
     DAO.Connection;

type
    TCupom = class
    private
        FConn: TFDConnection;
        FID_CUPOM: integer;
        FCOD_CUPOM: string;
        FID_ESTABELECIMENTO: integer;
        FVL_PEDIDO: double;
        procedure Validate(operacao: string);

    public
        constructor Create;
        destructor Destroy; override;

        property ID_CUPOM: integer read FID_CUPOM write FID_CUPOM;
        property ID_ESTABELECIMENTO: integer read FID_ESTABELECIMENTO write FID_ESTABELECIMENTO;
        property COD_CUPOM: string read FCOD_CUPOM write FCOD_CUPOM;
        property VL_PEDIDO: double read FVL_PEDIDO write FVL_PEDIDO;

        function Validar: TJSONObject;
        function Listar: TJSONArray;
    end;

implementation

{ TCupom }

constructor TCupom.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TCupom.Destroy;
begin
    if Assigned(FConn) then
        FConn.Free;

    inherited;
end;

function TCupom.Validar: TJSONObject;
var
    qry: TFDQuery;
    json: TJSONObject;
begin
    Validate('Validar');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('SELECT C.*');
            SQL.Add('FROM TAB_CUPOM C');
            SQL.Add('JOIN TAB_ESTABELECIMENTO E ON (E.ID_CUPOM = C.ID_CUPOM)');
            SQL.Add('WHERE C.IND_ATIVO = ''S''');
            SQL.Add('AND C.VL_MIN_PEDIDO <= :VL_PEDIDO');
            SQL.Add('AND C.DT_VALIDADE >= :DT_VALIDADE');
            SQL.Add('AND C.COD_CUPOM = :COD_CUPOM');
            SQL.Add('AND E.ID_ESTABELECIMENTO = :ID_ESTABELECIMENTO');

            ParamByName('VL_PEDIDO').Value := VL_PEDIDO;
            ParamByName('DT_VALIDADE').Value := FormatDateTime('yyyy-mm-dd', date);
            ParamByName('COD_CUPOM').Value := COD_CUPOM;
            ParamByName('ID_ESTABELECIMENTO').Value := ID_ESTABELECIMENTO;

            Active := true;
        end;

        Result := qry.ToJSONObject;

    finally
        qry.Free;
    end;
end;

function TCupom.Listar(): TJSONArray;
var
    qry : TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('SELECT * FROM TAB_CUPOM');
            SQL.Add('WHERE IND_ATIVO = ''S'' AND DT_VALIDADE >= :DT_VALIDADE');
            ParamByName('DT_VALIDADE').Value := FormatDateTime('yyyy-mm-dd', now);
            Active := true;
        end;

        Result := qry.ToJSONArray();

    finally
        qry.DisposeOf;
    end;
end;


procedure TCupom.Validate(operacao: string);
begin
    if (COD_CUPOM.IsEmpty) and MatchStr(operacao, ['Validar']) then
        raise Exception.Create('Cupom não informado');
end;

end.
