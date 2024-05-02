unit DAO.Produto;

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
    TProduto = class
    private
        FConn: TFDConnection;
        FID_PRODUTO: integer;
        FID_ESTABELECIMENTO: integer;
        procedure Validate(operacao: string);
    public
        constructor Create;
        destructor Destroy; override;

        property ID_PRODUTO: integer read FID_PRODUTO write FID_PRODUTO;
        property ID_ESTABELECIMENTO: integer read FID_ESTABELECIMENTO write FID_ESTABELECIMENTO;

        function Listar: TJSONArray;
        function Cardapio: TJSONArray;
        function ListarOpcao: TJSONArray;
    end;

implementation

{ TProduto }

constructor TProduto.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TProduto.Destroy;
begin
    if Assigned(FConn) then
        FConn.Free;

    inherited;
end;

function TProduto.Listar: TJSONArray;
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
            SQL.Add('FROM TAB_PRODUTO');
            SQL.Add('WHERE ID_PRODUTO > 0');

            if ID_PRODUTO > 0 then
            begin
                SQL.Add('AND ID_PRODUTO = :ID_PRODUTO');
                ParamByName('ID_PRODUTO').Value := ID_PRODUTO;
            end;

            SQL.Add('ORDER BY NOME');
            Active := true;
        end;

        Result := qry.ToJSONArray();

    finally
        qry.Free;
    end;
end;

function TProduto.ListarOpcao: TJSONArray;
var
    qry: TFDQuery;
begin
    Validate('ListarOpcao');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('SELECT O.*, I.ID_ITEM, I.NOME AS NOME_ITEM, ');
            SQL.Add('       COALESCE(I.DESCRICAO, '''') AS DESCRICAO_ITEM, COALESCE(I.VL_ITEM, 0) AS VL_ITEM');
            SQL.Add('FROM TAB_PRODUTO_OPCAO O');
            SQL.Add('JOIN TAB_PRODUTO_OPCAO_ITEM I ON (I.ID_OPCAO = O.ID_OPCAO)');
            SQL.Add('WHERE O.IND_ATIVO = ''S'' ');
            SQL.Add('AND O.ID_PRODUTO = :ID_PRODUTO');
            SQL.Add('ORDER BY O.ORDEM, I.ORDEM, I.NOME');
            ParamByName('ID_PRODUTO').Value := ID_PRODUTO;

            Active := true;
        end;

        Result := qry.ToJSONArray();

    finally
        qry.Free;
    end;
end;

function TProduto.Cardapio: TJSONArray;
var
    qry: TFDQuery;
begin
    Validate('Cardapio');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('SELECT P.*, C.CATEGORIA');
            SQL.Add('FROM TAB_PRODUTO P');
            SQL.Add('JOIN TAB_PRODUTO_CATEGORIA C ON (C.ID_CATEGORIA = P.ID_CATEGORIA)');
            SQL.Add('WHERE C.IND_ATIVO = ''S'' ');
            SQL.Add('AND P.IND_ATIVO = ''S'' ');
            SQL.Add('AND P.ID_ESTABELECIMENTO = :ID_ESTABELECIMENTO');
            SQL.Add('ORDER BY C.ORDEM, P.NOME');

            ParamByName('ID_ESTABELECIMENTO').Value := ID_ESTABELECIMENTO;

            Active := true;
        end;

        Result := qry.ToJSONArray();

    finally
        qry.Free;
    end;
end;

procedure TProduto.Validate(operacao: string);
begin
    if (ID_ESTABELECIMENTO <= 0) and MatchStr(operacao, ['Cardapio']) then
        raise Exception.Create('Estabelecimento não informado');

    if (ID_PRODUTO <= 0) and MatchStr(operacao, ['ListarOpcao']) then
        raise Exception.Create('Produto não informado');
end;

end.
