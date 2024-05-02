unit DAO.PedidoItemDetalhe;

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
    TPedidoItemDetalhe = class
    private
        FConn: TFDConnection;
        FVL_ITEM: double;
        FID_PEDIDO_ITEM: integer;
        FID_PEDIDO_DETALHE: integer;
        FID_ITEM: integer;
        FNOME: string;
        FORDEM: integer;
        procedure Validate(operacao: string);
    public
        constructor Create(MyConn: TFDConnection);
        destructor Destroy; override;

        property ID_PEDIDO_DETALHE: integer read FID_PEDIDO_DETALHE write FID_PEDIDO_DETALHE;
        property ID_PEDIDO_ITEM: integer read FID_PEDIDO_ITEM write FID_PEDIDO_ITEM;
        property ID_ITEM: integer read FID_ITEM write FID_ITEM;
        property ORDEM: integer read FORDEM write FORDEM;
        property VL_ITEM: double read FVL_ITEM write FVL_ITEM;
        property NOME: string read FNOME write FNOME;

        procedure Inserir;
    end;

implementation

{ TPedidoItemDetalhe }

constructor TPedidoItemDetalhe.Create(MyConn: TFDConnection);
begin
    //FConn := TConnection.CreateConnection;
    FConn := MyConn;
end;

destructor TPedidoItemDetalhe.Destroy;
begin
    //if Assigned(FConn) then
    //    FConn.Free;

    inherited;
end;

procedure TPedidoItemDetalhe.Inserir;
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
            SQL.Add('INSERT INTO TAB_PEDIDO_ITEM_DETALHE(ID_PEDIDO_ITEM,');
            SQL.Add('NOME, ID_ITEM, VL_ITEM, ORDEM)');
            SQL.Add('VALUES(:ID_PEDIDO_ITEM, :NOME, :ID_ITEM, :VL_ITEM, :ORDEM)');
            SQL.Add('RETURNING ID_PEDIDO_DETALHE');

            ParamByName('ID_PEDIDO_ITEM').Value := ID_PEDIDO_ITEM;
            ParamByName('NOME').Value := NOME;
            ParamByName('ID_ITEM').Value := ID_ITEM;
            ParamByName('VL_ITEM').Value := VL_ITEM;
            ParamByName('ORDEM').Value := ORDEM;

            Active := true;
            ID_PEDIDO_DETALHE := FieldByName('ID_PEDIDO_DETALHE').AsInteger;
        end;

    finally
        qry.Free;
    end;
end;

procedure TPedidoItemDetalhe.Validate(operacao: string);
begin
    if (ID_PEDIDO_ITEM <= 0) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Id. pedido item não informado');

    if (ID_ITEM <= 0) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Id. item não informado');

    if (NOME.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Nome não informado');

    if (ORDEM <= 0) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Ordem não informada');
end;


end.
