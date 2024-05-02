unit DAO.PedidoItem;

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
    TPedidoItem = class
    private
        FConn: TFDConnection;
        FID_PEDIDO_ITEM: integer;
        FVL_TOTAL: double;
        FID_PRODUTO: integer;
        FQTD: integer;
        FDESCRICAO: string;
        FID_PEDIDO: integer;
        FVL_UNIT: double;
        procedure Validate(operacao: string);
    public
        constructor Create(MyConn: TFDConnection);
        destructor Destroy; override;

        property ID_PEDIDO_ITEM: integer read FID_PEDIDO_ITEM write FID_PEDIDO_ITEM;
        property ID_PEDIDO: integer read FID_PEDIDO write FID_PEDIDO;
        property ID_PRODUTO: integer read FID_PRODUTO write FID_PRODUTO;
        property QTD: integer read FQTD write FQTD;
        property VL_UNIT: double read FVL_UNIT write FVL_UNIT;
        property VL_TOTAL: double read FVL_TOTAL write FVL_TOTAL;
        property DESCRICAO: string read FDESCRICAO write FDESCRICAO;

        procedure Inserir;
    end;

implementation

{ TPedidoItem }

constructor TPedidoItem.Create(MyConn: TFDConnection);
begin
    //FConn := TConnection.CreateConnection;
    FConn := MyConn;
end;

destructor TPedidoItem.Destroy;
begin
    //if Assigned(FConn) then
    //    FConn.Free;

    inherited;
end;

procedure TPedidoItem.Inserir;
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
            SQL.Add('INSERT INTO TAB_PEDIDO_ITEM(ID_PEDIDO,');
            SQL.Add('ID_PRODUTO, DESCRICAO, QTD, VL_UNIT, VL_TOTAL)');
            SQL.Add('VALUES(:ID_PEDIDO, :ID_PRODUTO, :DESCRICAO, :QTD, :VL_UNIT, :VL_TOTAL)');
            SQL.Add('RETURNING ID_PEDIDO_ITEM');

            ParamByName('ID_PEDIDO').Value := ID_PEDIDO;
            ParamByName('ID_PRODUTO').Value := ID_PRODUTO;
            ParamByName('DESCRICAO').Value := DESCRICAO;
            ParamByName('QTD').Value := QTD;
            ParamByName('VL_UNIT').Value := VL_UNIT;
            ParamByName('VL_TOTAL').Value := VL_TOTAL;

            Active := true;
            ID_PEDIDO_ITEM := FieldByName('ID_PEDIDO_ITEM').AsInteger;
        end;

    finally
        qry.Free;
    end;
end;

procedure TPedidoItem.Validate(operacao: string);
begin
    if (ID_PEDIDO <= 0) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Pedido não informado');

    if (ID_PRODUTO <= 0) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Cód. produto não informado');

    if (DESCRICAO.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Descrição não informada');

    if (QTD <= 0) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Qtde não informada');
end;


end.
