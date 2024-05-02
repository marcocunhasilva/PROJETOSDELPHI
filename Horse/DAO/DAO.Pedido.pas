unit DAO.Pedido;

interface

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.StrUtils,
     System.SysUtils,
     System.Variants,
     Dataset.Serialize,
     DAO.Connection;

type
    TPedido = class
    private
        FConn: TFDConnection;
        FID_USUARIO: integer;
        FID_PEDIDO: integer;
        FAVALIACAO: integer;
        FID_ESTABELECIMENTO: integer;
        FVL_TOTAL: double;
        FBAIRRO: string;
        FCOD_CIDADE: string;
        FUF: string;
        FID_CUPOM: integer;
        FCEP: string;
        FSTATUS: string;
        FVL_TAXA_ENTREGA: double;
        FCOMPLEMENTO: string;
        FVL_DESCONTO: double;
        FCIDADE: string;
        FENDERECO: string;
        procedure Validate(operacao: string);
    public
        constructor Create;
        destructor Destroy; override;

        property ID_PEDIDO: integer read FID_PEDIDO write FID_PEDIDO;
        property ID_USUARIO: integer read FID_USUARIO write FID_USUARIO;
        property ID_ESTABELECIMENTO: integer read FID_ESTABELECIMENTO write FID_ESTABELECIMENTO;
        property ID_CUPOM: integer read FID_CUPOM write FID_CUPOM;
        property AVALIACAO: integer read FAVALIACAO write FAVALIACAO;

        property VL_TAXA_ENTREGA: double read FVL_TAXA_ENTREGA write FVL_TAXA_ENTREGA;
        property VL_DESCONTO: double read FVL_DESCONTO write FVL_DESCONTO;
        property VL_TOTAL: double read FVL_TOTAL write FVL_TOTAL;

        property ENDERECO: string read FENDERECO write FENDERECO;
        property COMPLEMENTO: string read FCOMPLEMENTO write FCOMPLEMENTO;
        property BAIRRO: string read FBAIRRO write FBAIRRO;
        property CIDADE: string read FCIDADE write FCIDADE;
        property UF: string read FUF write FUF;
        property CEP: string read FCEP write FCEP;
        property COD_CIDADE: string read FCOD_CIDADE write FCOD_CIDADE;
        property STATUS: string read FSTATUS write FSTATUS;


        function Listar(cod_cidade: string): TJSONArray;
        function GetConnection: TFDConnection;
        procedure AvaliarPedido;
        procedure Inserir;
        procedure StartTransaction;
        procedure RollbackTransaction;
        procedure CommitTransaction;
    end;

implementation

{ TPedido }

constructor TPedido.Create;
begin
    FConn := TConnection.CreateConnection;
end;

procedure TPedido.StartTransaction;
begin
    FConn.StartTransaction;
end;

procedure TPedido.CommitTransaction;
begin
    FConn.Commit;
end;

procedure TPedido.RollbackTransaction;
begin
    FConn.Rollback;
end;

function TPedido.GetConnection: TFDConnection;
begin
    Result := FConn;
end;

destructor TPedido.Destroy;
begin
    if Assigned(FConn) then
        FConn.Free;

    inherited;
end;

function TPedido.Listar(cod_cidade: string): TJSONArray;
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
            SQL.Add('SELECT P.ID_PEDIDO, P.ID_ESTABELECIMENTO, E.NOME, COUNT(*) AS QTD_ITEM, P.VL_TOTAL,');
            SQL.Add('       P.DT_PEDIDO, E.URL_LOGO, COALESCE(P.AVALIACAO, 0) AS AVALIACAO, P.STATUS');
            SQL.Add('FROM TAB_PEDIDO P');
            SQL.Add('JOIN TAB_ESTABELECIMENTO E ON (P.ID_ESTABELECIMENTO = E.ID_ESTABELECIMENTO)');
            SQL.Add('JOIN TAB_PEDIDO_ITEM I ON (P.ID_PEDIDO = I.ID_PEDIDO)');
            SQL.Add('WHERE P.ID_USUARIO = :ID_USUARIO');
            SQL.Add('GROUP BY P.ID_PEDIDO, P.ID_ESTABELECIMENTO, E.NOME, P.VL_TOTAL,');
            SQL.Add('       P.DT_PEDIDO, E.URL_LOGO, P.AVALIACAO, P.STATUS');
            SQL.Add('ORDER BY P.ID_PEDIDO DESC');

            ParamByName('ID_USUARIO').Value := ID_USUARIO;

            Active := true;
        end;

        Result := qry.ToJSONArray();

    finally
        qry.Free;
    end;
end;

procedure TPedido.AvaliarPedido;
var
    qry: TFDQuery;
begin
    Validate('AvaliarPedido');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('UPDATE TAB_PEDIDO SET AVALIACAO = :AVALIACAO');
            SQL.Add('WHERE ID_PEDIDO = :ID_PEDIDO');
            SQL.Add('RETURNING ID_ESTABELECIMENTO');
            ParamByName('AVALIACAO').Value := AVALIACAO;
            ParamByName('ID_PEDIDO').Value := ID_PEDIDO;
            Active := true;

            ID_ESTABELECIMENTO := FieldByName('ID_ESTABELECIMENTO').AsInteger;


            // Atualizar estatisticas do estab...
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE TAB_ESTABELECIMENTO ');
            SQL.Add('SET QTD_AVALIACAO = (');
            SQL.Add('           SELECT COUNT(*) FROM TAB_PEDIDO P');
            SQL.Add('           WHERE P.AVALIACAO > 0');
            SQL.Add('           AND   P.ID_ESTABELECIMENTO = :ID_ESTABELECIMENTO');
            SQL.Add('           ),');

            SQL.Add('AVALIACAO = (');
            SQL.Add('           SELECT AVG(AVALIACAO) FROM TAB_PEDIDO P');
            SQL.Add('           WHERE P.AVALIACAO > 0');
            SQL.Add('           AND   P.ID_ESTABELECIMENTO = :ID_ESTABELECIMENTO');
            SQL.Add('           )');

            SQL.Add('WHERE ID_ESTABELECIMENTO = :ID_ESTABELECIMENTO');
            ParamByName('ID_ESTABELECIMENTO').Value := ID_ESTABELECIMENTO;
            ExecSQL;
        end;

    finally
        qry.Free;
    end;
end;

procedure TPedido.Inserir;
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
            SQL.Add('INSERT INTO TAB_PEDIDO(ID_USUARIO, ID_ESTABELECIMENTO, ID_CUPOM, VL_TAXA_ENTREGA,');
            SQL.Add('VL_DESCONTO, VL_TOTAL, DT_PEDIDO, STATUS, AVALIACAO, ENDERECO, COMPLEMENTO,');
            SQL.Add('BAIRRO, CIDADE, UF, CEP, COD_CIDADE)');
            SQL.Add('VALUES(:ID_USUARIO, :ID_ESTABELECIMENTO, :ID_CUPOM, :VL_TAXA_ENTREGA,');
            SQL.Add(':VL_DESCONTO, :VL_TOTAL, current_timestamp, :STATUS, :AVALIACAO, :ENDERECO, :COMPLEMENTO,');
            SQL.Add(':BAIRRO, :CIDADE, :UF, :CEP, :COD_CIDADE)');
            SQL.Add('RETURNING ID_PEDIDO');

            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ParamByName('ID_ESTABELECIMENTO').Value := ID_ESTABELECIMENTO;

            if ID_CUPOM > 0 then
                ParamByName('ID_CUPOM').Value := ID_CUPOM
            else
            begin
                ParamByName('ID_CUPOM').DataType := ftInteger;
                ParamByName('ID_CUPOM').Value := Unassigned;
            end;


            ParamByName('VL_TAXA_ENTREGA').Value := VL_TAXA_ENTREGA;
            ParamByName('VL_DESCONTO').Value := VL_DESCONTO;
            ParamByName('VL_TOTAL').Value := VL_TOTAL;
            ParamByName('STATUS').Value := STATUS;  // A (Aguardando), P (Em produção), E (Saiu para entrega), F (Finalizado)
            ParamByName('AVALIACAO').Value := AVALIACAO;

            ParamByName('ENDERECO').Value := ENDERECO;
            ParamByName('COMPLEMENTO').Value := COMPLEMENTO;
            ParamByName('BAIRRO').Value := BAIRRO;
            ParamByName('CIDADE').Value := CIDADE;
            ParamByName('UF').Value := UF;
            ParamByName('CEP').Value := CEP;
            ParamByName('COD_CIDADE').Value := COD_CIDADE;
            Active := true;

            ID_PEDIDO := FieldByName('ID_PEDIDO').AsInteger;
        end;

    finally
        qry.Free;
    end;
end;

procedure TPedido.Validate(operacao: string);
begin
    if (ID_USUARIO <= 0) and MatchStr(operacao, ['Listar', 'Inserir']) then
        raise Exception.Create('Cód. usuário não informado');

    if (ID_ESTABELECIMENTO <= 0) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Cód. estabelecimento não informado');

    if (STATUS.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Status não informado');

    if (ENDERECO.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Endereço não informado');

    if (BAIRRO.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Bairro não informado');

    if (CIDADE.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Cidade não informada');

    if (UF.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('UF não informado');

    if (CEP.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('CEP não informado');

    if (COD_CIDADE.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Cód. cidade não informado');

    if (ID_PEDIDO <= 0) and MatchStr(operacao, ['AvaliarPedido']) then
        raise Exception.Create('Id. pedido não informado');

    if (AVALIACAO <= 0) and MatchStr(operacao, ['AvaliarPedido']) then
        raise Exception.Create('Avaliação não informada');
end;

end.
