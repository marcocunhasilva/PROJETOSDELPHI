unit DAO.Estabelecimento.Admin;

interface

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.SysUtils,
     DataSet.Serialize,
     DAO.Connection,
     System.StrUtils;

type
    TEstabelecimentoAdmin = class
    private
        FConn : TFDConnection;
        FCOD_CIDADE: string;
        FID_CATEGORIA: integer;
        FID_ESTABELECIMENTO: integer;
        FNOME: string;
        FID_USUARIO: integer;
        FID_BANNER: integer;
        FBAIRRO: string;
        FURL_FOTO: string;
        FUF: string;
        FCEP: string;
        FCOMPLEMENTO: string;
        FCIDADE: string;
        FENDERECO: string;
        FID_CUPOM: integer;
        FVL_TAXA_ENTREGA: double;
        FVL_MIN_PEDIDO: double;
        FURL_LOGO: string;
        FIND_ATIVO: string;

        procedure Validate(operacao: string);
    public
        constructor Create;
        destructor Destroy; override;

        property ID_USUARIO: integer read FID_USUARIO write FID_USUARIO;
        property ID_ESTABELECIMENTO: integer read FID_ESTABELECIMENTO write FID_ESTABELECIMENTO;
        property ID_CATEGORIA: integer read FID_CATEGORIA write FID_CATEGORIA;
        property ID_BANNER: integer read FID_BANNER write FID_BANNER;
        property ID_CUPOM: integer read FID_CUPOM write FID_CUPOM;
        property NOME: string read FNOME write FNOME;
        property URL_FOTO: string read FURL_FOTO write FURL_FOTO;
        property URL_LOGO: string read FURL_LOGO write FURL_LOGO;
        property COD_CIDADE: string read FCOD_CIDADE write FCOD_CIDADE;

        property ENDERECO: string read FENDERECO write FENDERECO;
        property COMPLEMENTO: string read FCOMPLEMENTO write FCOMPLEMENTO;
        property BAIRRO: string read FBAIRRO write FBAIRRO;
        property CIDADE: string read FCIDADE write FCIDADE;
        property UF: string read FUF write FUF;
        property CEP: string read FCEP write FCEP;

        property VL_MIN_PEDIDO: double read FVL_MIN_PEDIDO write FVL_MIN_PEDIDO;
        property VL_TAXA_ENTREGA: double read FVL_TAXA_ENTREGA write FVL_TAXA_ENTREGA;
        property IND_ATIVO: string read FIND_ATIVO write FIND_ATIVO;

        function Listar: TJsonObject;
        procedure Editar;
end;

implementation


constructor TEstabelecimentoAdmin.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TEstabelecimentoAdmin.Destroy;
begin
    if Assigned(FConn) then
        Fconn.Free;

    inherited;
end;

function TEstabelecimentoAdmin.Listar: TJsonObject;
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


            SQL.Add('SELECT E.ID_ESTABELECIMENTO, E.NOME, E.URL_FOTO, E.URL_LOGO, COALESCE(E.AVALIACAO, 0) AS AVALIACAO, E.ID_CATEGORIA,');
            SQL.Add('   COALESCE(E.ID_CUPOM, 0) AS ID_CUPOM, E.VL_MIN_PEDIDO, E.VL_TAXA_ENTREGA, E.ENDERECO, COALESCE(E.COMPLEMENTO, '''') AS COMPLEMENTO,');
            SQL.Add('   E.BAIRRO, E.CIDADE, E.UF, E.CEP, E.COD_CIDADE, E.IND_ATIVO, C.CATEGORIA');
            SQL.Add('FROM TAB_ESTABELECIMENTO E');
            SQL.Add('JOIN TAB_CATEGORIA C ON (C.ID_CATEGORIA = E.ID_CATEGORIA)');
            SQL.Add('WHERE E.ID_USUARIO = :ID_USUARIO');

            ParamByName('ID_USUARIO').Value := ID_USUARIO;

            Active := true;
        end;

        result := qry.ToJSONObject;

    finally
        qry.DisposeOf;
    end;
end;

procedure TEstabelecimentoAdmin.Editar;
var
    qry : TFDQuery;
begin
    Validate('Editar');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE TAB_ESTABELECIMENTO SET NOME=:NOME, ID_CUPOM=:ID_CUPOM, VL_MIN_PEDIDO=:VL_MIN_PEDIDO, VL_TAXA_ENTREGA=:VL_TAXA_ENTREGA,');
            SQL.Add('ENDERECO=:ENDERECO, COMPLEMENTO=:COMPLEMENTO, BAIRRO=:BAIRRO, CIDADE=:CIDADE, UF=:UF, CEP=:CEP, COD_CIDADE=:COD_CIDADE,');
            SQL.Add('ID_CATEGORIA=:ID_CATEGORIA, URL_FOTO=:URL_FOTO, URL_LOGO=:URL_LOGO, IND_ATIVO=:IND_ATIVO ');
            SQL.Add('WHERE ID_USUARIO = :ID_USUARIO');
            SQL.Add('RETURNING ID_ESTABELECIMENTO');

            ParamByName('NOME').Value := NOME;
            ParamByName('ID_CUPOM').Value := ID_CUPOM;
            ParamByName('VL_MIN_PEDIDO').Value := VL_MIN_PEDIDO;
            ParamByName('VL_TAXA_ENTREGA').Value := VL_TAXA_ENTREGA;
            ParamByName('ENDERECO').Value := ENDERECO;
            ParamByName('COMPLEMENTO').Value := COMPLEMENTO;
            ParamByName('BAIRRO').Value := BAIRRO;
            ParamByName('CIDADE').Value := CIDADE;
            ParamByName('UF').Value := UF;
            ParamByName('CEP').Value := CEP;
            ParamByName('COD_CIDADE').Value := COD_CIDADE;
            ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
            ParamByName('URL_FOTO').Value := URL_FOTO;
            ParamByName('URL_LOGO').Value := URL_LOGO;
            ParamByName('IND_ATIVO').Value := IND_ATIVO;
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            Active := true;

            ID_ESTABELECIMENTO := FieldByName('ID_ESTABELECIMENTO').AsInteger;
        end;

    finally
        qry.DisposeOf;
    end;

end;

procedure TEstabelecimentoAdmin.Validate(operacao: string);
begin
    if (ID_USUARIO <= 0) and MatchStr(operacao, ['Editar']) then
        raise Exception.Create('Cód. usuário não informado');

    if (NOME.IsEmpty) and MatchStr(operacao, ['Editar']) then
        raise Exception.Create('Estabelecimento não informado');

    if (ID_CATEGORIA <= 0) and MatchStr(operacao, ['Editar']) then
        raise Exception.Create('Categoria não informada');

    if (ENDERECO.IsEmpty) and MatchStr(operacao, ['Editar']) then
        raise Exception.Create('Endereço não informado');

    if (BAIRRO.IsEmpty) and MatchStr(operacao, ['Editar']) then
        raise Exception.Create('Bairro não informado');

    if (CIDADE.IsEmpty) and MatchStr(operacao, ['Editar']) then
        raise Exception.Create('Cidade não informada');

    if (UF.IsEmpty) and MatchStr(operacao, ['Editar'])  then
        raise Exception.Create('UF não informado');

    if (CEP.IsEmpty) and MatchStr(operacao, ['Editar']) then
        raise Exception.Create('CEP não informado');

    if (COD_CIDADE.IsEmpty) and MatchStr(operacao, ['Editar']) then
        raise Exception.Create('Cód. cidade não informado');

    if (URL_FOTO.IsEmpty) and MatchStr(operacao, ['Editar']) then
        raise Exception.Create('URL da foto não informada');

    if (URL_LOGO.IsEmpty) and MatchStr(operacao, ['Editar']) then
        raise Exception.Create('URL do logotipo não informada');
end;


end.
