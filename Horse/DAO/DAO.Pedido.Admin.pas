unit DAO.Pedido.Admin;

interface

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.SysUtils,
     System.StrUtils,
     DataSet.Serialize,
     DAO.Connection;

type
    TPedidoAdmin = class
    private
        FCONN : TFDConnection;
        FCOD_CIDADE: string;
        FID_PEDIDO: integer;
        FSTATUS: string;
        FID_USUARIO: integer;
        FSTATUS_NOT_IN: string;
        procedure Validate(operacao: string);
    public
        constructor Create;
        destructor Destroy; override;

        property ID_PEDIDO: integer read FID_PEDIDO write FID_PEDIDO;
        property ID_USUARIO: integer read FID_USUARIO write FID_USUARIO;

        property STATUS: string read FSTATUS write FSTATUS;
        property STATUS_NOT_IN: string read FSTATUS_NOT_IN write FSTATUS_NOT_IN;

        function Listar(): TJSONArray;
        procedure StatusPedido;
        function ListarUltPedidos(): TJSONArray;
end;

implementation

uses
  System.Variants;

constructor TPedidoAdmin.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TPedidoAdmin.Destroy;
begin
    if Assigned(FConn) then
        Fconn.Free;

    inherited;
end;

function TPedidoAdmin.Listar(): TJSONArray;
var
    qryPed, qryItem, qryDetalhe : TFDQuery;
    i, d: integer;
    arrayItem, arrayDetalhe: TJsonArray;
begin
    Validate('Listar');

    try
        qryPed := TFDQuery.Create(nil);
        qryPed.Connection := FConn;

        qryItem := TFDQuery.Create(nil);
        qryItem.Connection := FConn;

        qryDetalhe := TFDQuery.Create(nil);
        qryDetalhe.Connection := FConn;

        // Monta lista dos pedidos (sem itens)
        qryPed.Active := false;
        qryPed.sql.Clear;
        qryPed.SQL.Add('SELECT P.ID_PEDIDO, P.DT_PEDIDO, P.STATUS, U.NOME, P.ENDERECO, P.COMPLEMENTO, P.BAIRRO, P.VL_TOTAL');
        qryPed.SQL.Add('FROM TAB_PEDIDO P');
        qryPed.SQL.Add('JOIN TAB_USUARIO U ON (U.ID_USUARIO = P.ID_USUARIO)');
        qryPed.SQL.Add('JOIN TAB_ESTABELECIMENTO E ON (P.ID_ESTABELECIMENTO = E.ID_ESTABELECIMENTO)');
        qryPed.SQL.Add('WHERE E.ID_USUARIO = :ID_USUARIO');

        qryPed.ParamByName('ID_USUARIO').Value := ID_USUARIO;

        if STATUS <> '' then
        begin
            qryPed.SQL.Add('AND P.STATUS = :STATUS');
            qryPed.ParamByName('STATUS').Value := STATUS;
        end;

        if STATUS_NOT_IN <> '' then
        begin
            qryPed.SQL.Add('AND P.STATUS <> :STATUS_NOT_IN');
            qryPed.ParamByName('STATUS_NOT_IN').Value := STATUS_NOT_IN;
        end;

        qryPed.SQL.Add('ORDER BY P.ID_PEDIDO DESC');
        qryPed.Active := true;

        Result := qryPed.ToJSONArray();


        // Insere os itens dos pedidos
        for i := 0 to Result.Size - 1 do
        begin
            qryItem.Active := false;
            qryItem.sql.Clear;
            qryItem.SQL.Add('SELECT I.ID_PEDIDO_ITEM, I.DESCRICAO, P.URL_FOTO, I.QTD, I.VL_UNIT');
            qryItem.SQL.Add('FROM TAB_PEDIDO_ITEM I');
            qryItem.SQL.Add('JOIN TAB_PRODUTO P ON (P.ID_PRODUTO = I.ID_PRODUTO)');
            qryItem.SQL.Add('WHERE I.ID_PEDIDO = :ID_PEDIDO');
            qryItem.ParamByName('ID_PEDIDO').Value := Result[i].GetValue<integer>('id_pedido', 0);
            qryItem.Active := true;

            arrayItem := qryItem.ToJSONArray;

            // Insere os detalhes de cada item
            for d := 0 to arrayItem.Size - 1 do
            begin
                qryDetalhe.Active := false;
                qryDetalhe.sql.Clear;
                qryDetalhe.SQL.Add('SELECT D.ID_PEDIDO_DETALHE, D.NOME');
                qryDetalhe.SQL.Add('FROM TAB_PEDIDO_ITEM_DETALHE D');
                qryDetalhe.SQL.Add('WHERE D.ID_PEDIDO_ITEM = :ID_PEDIDO_ITEM');
                qryDetalhe.ParamByName('ID_PEDIDO_ITEM').Value := arrayItem[d].GetValue<integer>('id_pedido_item', 0);
                qryDetalhe.Active := true;

                arrayDetalhe := qryDetalhe.ToJSONArray;

                TJsonObject(arrayItem[d]).AddPair('detalhes', arrayDetalhe);
            end;

            TJsonObject(Result[i]).AddPair('itens', arrayItem);
        end;


    finally
        qryPed.DisposeOf;
        qryItem.DisposeOf;
        qryDetalhe.DisposeOf;
    end;
end;

function TPedidoAdmin.ListarUltPedidos(): TJSONArray;
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
            SQL.Add('SELECT FIRST 20 P.ID_PEDIDO, U.NOME, P.STATUS, P.ID_ESTABELECIMENTO, E.NOME AS ESTABELECIMENTO, P.BAIRRO, P.VL_TOTAL');
            SQL.Add('FROM TAB_PEDIDO P');
            SQL.Add('JOIN TAB_USUARIO U ON (U.ID_USUARIO = P.ID_USUARIO)');
            SQL.Add('JOIN TAB_ESTABELECIMENTO E ON (E.ID_ESTABELECIMENTO = P.ID_ESTABELECIMENTO)');
            SQL.Add('WHERE E.ID_USUARIO = :ID_USUARIO');

            SQL.Add('ORDER BY P.ID_PEDIDO DESC');

            ParamByName('ID_USUARIO').Value := id_usuario;

            Active := true;
        end;

        result := qry.ToJSONArray();

    finally
        qry.DisposeOf;
    end;
end;

procedure TPedidoAdmin.StatusPedido;
var
    qry : TFDQuery;
begin
    Validate('StatusPedido');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE TAB_PEDIDO SET STATUS = :STATUS');
            SQL.Add('WHERE ID_PEDIDO = :ID_PEDIDO');
            ParamByName('STATUS').Value := STATUS;
            ParamByName('ID_PEDIDO').Value := ID_PEDIDO;
            ExecSQL;
        end;

    finally
        qry.DisposeOf;
    end;
end;


procedure TPedidoAdmin.Validate(operacao: string);
begin
    if (ID_USUARIO <= 0) and MatchStr(operacao, ['Listar']) then
        raise Exception.Create('Cód. usuário não informado');

    if (STATUS.IsEmpty) and MatchStr(operacao, ['StatusPedido']) then
        raise Exception.Create('Status não informado');

    if (ID_PEDIDO <= 0) and MatchStr(operacao, ['StatusPedido']) then
        raise Exception.Create('Id. pedido não informado');

end;

end.
