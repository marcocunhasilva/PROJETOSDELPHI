unit DAO.Usuario.Admin;

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
    TUsuarioAdmin = class
    private
        FConn: TFDConnection;
        FBAIRRO: string;
        FEMAIL: string;
        FCOD_CIDADE: string;
        FUF: string;
        FCEP: string;
        FSENHA: string;
        FCOMPLEMENTO: string;
        FNOME: string;
        FCIDADE: string;
        FENDERECO: string;
        FID_USUARIO: integer;
        FID_CATEGORIA: integer;
        FESTABELECIMENTO: string;
        procedure Validate(operacao: string);

    public
        constructor Create;
        destructor Destroy; override;

        property ID_USUARIO: integer read FID_USUARIO write FID_USUARIO;
        property NOME: string read FNOME write FNOME;
        property EMAIL: string read FEMAIL write FEMAIL;
        property SENHA: string read FSENHA write FSENHA;
        property ENDERECO: string read FENDERECO write FENDERECO;
        property COMPLEMENTO: string read FCOMPLEMENTO write FCOMPLEMENTO;
        property BAIRRO: string read FBAIRRO write FBAIRRO;
        property CIDADE: string read FCIDADE write FCIDADE;
        property UF: string read FUF write FUF;
        property CEP: string read FCEP write FCEP;
        property COD_CIDADE: string read FCOD_CIDADE write FCOD_CIDADE;
        property ESTABELECIMENTO: string read FESTABELECIMENTO write FESTABELECIMENTO;
        property ID_CATEGORIA: integer read FID_CATEGORIA write FID_CATEGORIA;

        function Dashboard: TJSONObject;
        procedure Editar;
        procedure EditarSenha;
        procedure Inserir;
        function Listar: TJSONObject;
        function Login: TJsonObject;
    end;

implementation

constructor TUsuarioAdmin.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TUsuarioAdmin.Destroy;
begin
    if Assigned(FConn) then
        Fconn.Free;

    inherited;
end;

function TUsuarioAdmin.Login: TJsonObject;
var
    qry : TFDQuery;
begin
    Validate('Login');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('SELECT U.ID_USUARIO, U.NOME, U.EMAIL, U.DT_CADASTRO,');
            SQL.Add('       E.ENDERECO, E.COMPLEMENTO, E.BAIRRO, E.CIDADE, E.UF, E.CEP, E.COD_CIDADE');
            SQL.Add('FROM TAB_USUARIO U');
            SQL.Add('LEFT JOIN TAB_USUARIO_ENDERECO E ON (E.ID_USUARIO = U.ID_USUARIO AND E.IND_PADRAO = ''S'' )');
            SQL.Add('WHERE U.EMAIL = :EMAIL AND U.SENHA = :SENHA');

            ParamByName('EMAIL').Value := EMAIL;
            ParamByName('SENHA').Value := SENHA;

            Active := true;
        end;

        Result := qry.ToJSONObject;

    finally
        qry.DisposeOf;
    end;
end;

procedure TUsuarioAdmin.Inserir;
var
    qry : TFDQuery;
begin
    Validate('Inserir');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        try
            FConn.StartTransaction;

            with qry do
            begin
                Active := false;
                sql.Clear;
                SQL.Add('INSERT INTO TAB_USUARIO(NOME, EMAIL, SENHA, DT_CADASTRO)');
                SQL.Add('VALUES(:NOME, :EMAIL, :SENHA, current_timestamp)');
                SQL.Add('RETURNING ID_USUARIO');

                ParamByName('NOME').Value := NOME;
                ParamByName('EMAIL').Value := EMAIL;
                ParamByName('SENHA').Value := SENHA;

                Active := true;
                ID_USUARIO := FieldByName('ID_USUARIO').AsInteger;

                //------

                Active := false;
                sql.Clear;
                SQL.Add('INSERT INTO TAB_USUARIO_ENDERECO(ID_USUARIO, ENDERECO, COMPLEMENTO,');
                SQL.Add('BAIRRO, CIDADE, UF, CEP, IND_PADRAO, COD_CIDADE)');
                SQL.Add('VALUES(:ID_USUARIO, :ENDERECO, :COMPLEMENTO,');
                SQL.Add(':BAIRRO, :CIDADE, :UF, :CEP, :IND_PADRAO, :COD_CIDADE)');

                ParamByName('ID_USUARIO').Value := ID_USUARIO;
                ParamByName('ENDERECO').Value := ENDERECO;
                ParamByName('COMPLEMENTO').Value := COMPLEMENTO;
                ParamByName('BAIRRO').Value := BAIRRO;
                ParamByName('CIDADE').Value := CIDADE;
                ParamByName('UF').Value := UF;
                ParamByName('CEP').Value := CEP;
                ParamByName('IND_PADRAO').Value := 'S';
                ParamByName('COD_CIDADE').Value := COD_CIDADE;
                ExecSQL;

                //------

                Active := false;
                sql.Clear;
                SQL.Add('INSERT INTO TAB_ESTABELECIMENTO(NOME, ID_CATEGORIA, ENDERECO, COMPLEMENTO,');
                SQL.Add('BAIRRO, CIDADE, UF, CEP, COD_CIDADE, IND_ATIVO, ID_USUARIO, URL_FOTO, URL_LOGO)');
                SQL.Add('VALUES(:NOME, :ID_CATEGORIA, :ENDERECO, :COMPLEMENTO,');
                SQL.Add(':BAIRRO, :CIDADE, :UF, :CEP, :COD_CIDADE, :IND_ATIVO, :ID_USUARIO, :URL_FOTO, :URL_LOGO)');

                ParamByName('NOME').Value := ESTABELECIMENTO;
                ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
                ParamByName('ENDERECO').Value := ENDERECO;
                ParamByName('COMPLEMENTO').Value := COMPLEMENTO;
                ParamByName('BAIRRO').Value := BAIRRO;
                ParamByName('CIDADE').Value := CIDADE;
                ParamByName('UF').Value := UF;
                ParamByName('CEP').Value := CEP;
                ParamByName('COD_CIDADE').Value := COD_CIDADE;
                ParamByName('IND_ATIVO').Value := 'S';
                ParamByName('ID_USUARIO').Value := ID_USUARIO;
                ParamByName('URL_FOTO').Value := 'https://www.ifood.com.br/static/images/merchant/banner/DEFAULT.png';
                ParamByName('URL_LOGO').Value := 'https://cdn-icons-png.flaticon.com/128/1160/1160358.png';
                ExecSQL;
            end;

            FConn.Commit;

        except on ex:exception do
            begin
                FConn.Rollback;
                raise Exception.Create(ex.Message);
            end;
        end;

    finally
        qry.DisposeOf;
    end;

end;

procedure TUsuarioAdmin.Editar;
var
    qry : TFDQuery;
begin
    Validate('Editar');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            // Valida email...
            Active := false;
            sql.Clear;
            SQL.Add('SELECT ID_USUARIO FROM TAB_USUARIO');
            SQL.Add('WHERE EMAIL=:EMAIL');
            SQL.Add('AND ID_USUARIO <> :ID_USUARIO');
            ParamByName('EMAIL').Value := EMAIL;
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            Active := true;

            if RecordCount > 0 then
                raise Exception.Create('Esse e-mail já está em uso por outra conta');


            Active := false;
            sql.Clear;
            SQL.Add('UPDATE TAB_USUARIO SET NOME=:NOME, EMAIL=:EMAIL');
            SQL.Add('WHERE ID_USUARIO = :ID_USUARIO');

            ParamByName('NOME').Value := NOME;
            ParamByName('EMAIL').Value := EMAIL;
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ExecSQL;
        end;

    finally
        qry.DisposeOf;
    end;
end;

procedure TUsuarioAdmin.EditarSenha;
var
    qry : TFDQuery;
begin
    Validate('Senha');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE TAB_USUARIO SET SENHA=:SENHA');
            SQL.Add('WHERE ID_USUARIO = :ID_USUARIO');

            ParamByName('SENHA').Value := SENHA;
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ExecSQL;
        end;

    finally
        qry.DisposeOf;
    end;

end;

function TUsuarioAdmin.Listar: TJSONObject;
var
    qry : TFDQuery;
begin
    Validate('Listar');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('SELECT ID_USUARIO, NOME, EMAIL, DT_CADASTRO');
            SQL.Add('FROM TAB_USUARIO');
            SQL.Add('WHERE ID_USUARIO = :ID_USUARIO');

            ParamByName('ID_USUARIO').Value := ID_USUARIO;

            Active := true;
        end;

        Result := qry.ToJSONObject();

    finally
        qry.DisposeOf;
    end;
end;

function TUsuarioAdmin.Dashboard: TJSONObject;
var
    qry : TFDQuery;
    qtd_cliente: integer;
begin

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            // Qtd clientes novos do mes...
            Active := false;
            sql.Clear;
            SQL.Add('SELECT DISTINCT U.ID_USUARIO');
            SQL.Add('FROM TAB_USUARIO U');
            SQL.Add('JOIN TAB_PEDIDO P ON (P.ID_USUARIO = U.ID_USUARIO)');
            SQL.Add('JOIN TAB_ESTABELECIMENTO E ON (E.ID_ESTABELECIMENTO = P.ID_ESTABELECIMENTO)');
            SQL.Add('WHERE U.DT_CADASTRO >= :DT_CADASTRO');
            SQL.Add('AND E.ID_USUARIO = :ID_USUARIO');

            ParamByName('DT_CADASTRO').Value := FormatDateTime('yyyy-mm-01', now);
            ParamByName('ID_USUARIO').Value := ID_USUARIO;

            Active := true;

            qtd_cliente := RecordCount;



            Active := false;
            sql.Clear;
            SQL.Add('SELECT COUNT(*) AS QTD_PEDIDO_DIA, COALESCE(SUM(P.VL_TOTAL), 0) AS VL_TOTAL_DIA');
            SQL.Add('FROM TAB_PEDIDO P');
            SQL.Add('JOIN TAB_ESTABELECIMENTO E ON (E.ID_ESTABELECIMENTO = P.ID_ESTABELECIMENTO)');
            SQL.Add('WHERE E.ID_USUARIO = :ID_USUARIO');
            SQL.Add('AND P.DT_PEDIDO >= :DT_PEDIDO');

            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ParamByName('DT_PEDIDO').Value := FormatDateTime('yyyy-mm-dd', now);

            Active := true;
        end;

        Result := qry.ToJSONObject;

        Result.AddPair('qtd_cliente_novo', TJsonNumber.Create(qtd_cliente));

    finally
        qry.DisposeOf;
    end;
end;

procedure TUsuarioAdmin.Validate(operacao: string);
begin
    if (EMAIL.IsEmpty) and MatchStr(operacao, ['Login', 'Inserir', 'Editar']) then
        raise Exception.Create('E-mail não informado');

    if (SENHA.IsEmpty) and MatchStr(operacao, ['Login', 'Inserir', 'Senha']) then
        raise Exception.Create('Senha não informada');

    if (ID_USUARIO <= 0) and MatchStr(operacao, ['Editar', 'Listar', 'Senha']) then
        raise Exception.Create('Cód. usuário não informado');

    if (NOME.IsEmpty) and MatchStr(operacao, ['Inserir', 'Editar']) then
        raise Exception.Create('Nome não informado');

    if (NOME.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Estabelecimento não informado');

    if (ID_CATEGORIA <= 0) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Categoria não informada');

    if (ENDERECO.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Endereço não informado');

    if (BAIRRO.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Bairro não informado');

    if (CIDADE.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Cidade não informada');

    if (UF.IsEmpty) and MatchStr(operacao, ['Inserir'])  then
        raise Exception.Create('UF não informado');

    if (CEP.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('CEP não informado');

    if (COD_CIDADE.IsEmpty) and MatchStr(operacao, ['Inserir']) then
        raise Exception.Create('Cód. cidade não informado');

end;

end.
