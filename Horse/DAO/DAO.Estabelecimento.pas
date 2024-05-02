unit DAO.Estabelecimento;

interface

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.SysUtils,
     Dataset.Serialize,
     DAO.Connection;

type
    TEstabelecimento = class
    private
        FConn: TFDConnection;
        FID_USUARIO: integer;
        FCOD_CIDADE: string;
        FID_CATEGORIA: integer;
        FID_ESTABELECIMENTO: integer;
        FNOME: string;
        FID_BANNER: integer;
    public
        constructor Create;
        destructor Destroy; override;

        property ID_USUARIO: integer read FID_USUARIO write FID_USUARIO;
        property ID_ESTABELECIMENTO: integer read FID_ESTABELECIMENTO write FID_ESTABELECIMENTO;
        property ID_CATEGORIA: integer read FID_CATEGORIA write FID_CATEGORIA;
        property ID_BANNER: integer read FID_BANNER write FID_BANNER;
        property NOME: string read FNOME write FNOME;
        property COD_CIDADE: string read FCOD_CIDADE write FCOD_CIDADE;

        function Listar(pagina: integer): TJSONArray;
    end;

implementation

{ TEstabelecimento }

constructor TEstabelecimento.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TEstabelecimento.Destroy;
begin
    if Assigned(FConn) then
        FConn.Free;

    inherited;
end;

function TEstabelecimento.Listar(pagina: integer): TJSONArray;
var
    qry: TFDQuery;
    qtd_reg_pagina, skip: integer;
begin
    qtd_reg_pagina := 10;
    skip := (pagina * qtd_reg_pagina) - qtd_reg_pagina;

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            SQL.Clear;

            if pagina > 0 then
            begin
                SQL.Add('SELECT FIRST :FIRST SKIP :SKIP');
                ParamByName('FIRST').Value := qtd_reg_pagina;
                ParamByName('SKIP').Value := skip;
            end
            else
                SQL.Add('SELECT ');

            SQL.Add('   E.ID_ESTABELECIMENTO, E.NOME, E.URL_FOTO, E.URL_LOGO, COALESCE(E.AVALIACAO, 0) AS AVALIACAO, E.ID_CATEGORIA,');
            SQL.Add('   COALESCE(E.ID_CUPOM, 0) AS ID_CUPOM, E.VL_MIN_PEDIDO, E.VL_TAXA_ENTREGA, E.ENDERECO, ');
            SQL.Add('   COALESCE(E.COMPLEMENTO, '''') AS COMPLEMENTO,');
            SQL.Add('   E.BAIRRO, E.CIDADE, E.UF, E.CEP, E.COD_CIDADE, E.IND_ATIVO, COALESCE(E.QTD_AVALIACAO, 0) AS QTD_AVALIACAO, ');
            SQL.Add('   COALESCE(F.ID_FAVORITO, 0) AS ID_FAVORITO, COALESCE(U.DESCRICAO, '''') AS TEXTO_CUPOM, C.CATEGORIA');

            SQL.Add('FROM TAB_ESTABELECIMENTO E');
            SQL.Add('JOIN TAB_CATEGORIA C ON (C.ID_CATEGORIA = E.ID_CATEGORIA)');
            SQL.Add('LEFT JOIN TAB_USUARIO_FAVORITO F ON (F.ID_ESTABELECIMENTO = E.ID_ESTABELECIMENTO');
            SQL.Add('                                    AND F.ID_USUARIO = :ID_USUARIO)');
            SQL.Add('LEFT JOIN TAB_CUPOM U ON (U.ID_CUPOM = E.ID_CUPOM AND U.IND_ATIVO = ''S'' ');
            SQL.Add('                                    AND U.DT_VALIDADE >= current_timestamp)');

            if ID_BANNER > 0 then
                SQL.Add('JOIN TAB_BANNER_ESTABELECIMENTO B ON (B.ID_ESTABELECIMENTO = E.ID_ESTABELECIMENTO)');

            SQL.Add('WHERE E.IND_ATIVO = ''S'' ');

            ParamByName('ID_USUARIO').Value := ID_USUARIO;

            if ID_ESTABELECIMENTO > 0 then
            begin
                SQL.Add('AND E.ID_ESTABELECIMENTO = :ID_ESTABELECIMENTO');
                ParamByName('ID_ESTABELECIMENTO').Value := ID_ESTABELECIMENTO;
            end;

            if ID_CATEGORIA > 0 then
            begin
                SQL.Add('AND E.ID_CATEGORIA = :ID_CATEGORIA');
                ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
            end;

            if NOME <> '' then
            begin
                SQL.Add('AND E.NOME LIKE :NOME');
                ParamByName('NOME').Value := '%' + NOME + '%';
            end;

            if COD_CIDADE <> '' then
            begin
                SQL.Add('AND E.COD_CIDADE = :COD_CIDADE');
                ParamByName('COD_CIDADE').Value := COD_CIDADE;
            end;

            if ID_BANNER > 0 then
            begin
                SQL.Add('AND B.ID_BANNER = :ID_BANNER');
                ParamByName('ID_BANNER').Value := ID_BANNER;
            end;

            SQL.Add('ORDER BY E.NOME');

            Active := true;
        end;

        Result := qry.ToJSONArray();

    finally
        qry.Free;
    end;
end;

end.
