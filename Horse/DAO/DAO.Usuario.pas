unit DAO.Usuario;

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
    TUsuario = class
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


        function Login: TJSONObject;
        procedure Inserir;
        procedure Editar;
        function Listar: TJSONArray;
    end;

implementation

{ TUsuario }

constructor TUsuario.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TUsuario.Destroy;
begin
    if Assigned(FConn) then
        FConn.Free;

    inherited;
end;

function TUsuario.Listar: TJSONArray;
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
            SQL.Add('SELECT ID_USUARIO, NOME, EMAIL, DT_CADASTRO');
            SQL.Add('FROM TAB_USUARIO');
            SQL.Add('WHERE ID_USUARIO = :ID_USUARIO');

            ParamByName('ID_USUARIO').Value := ID_USUARIO;

            Active := true;
        end;

        Result := qry.ToJSONArray();

    finally
        qry.Free;
    end;
end;

function TUsuario.Login: TJSONObject;
var
    qry: TFDQuery;
begin
    Validate('Login');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('SELECT U.ID_USUARIO, U.NOME, U.EMAIL, U.DT_CADASTRO,');
            SQL.Add('       E.ENDERECO, E.COMPLEMENTO, E.BAIRRO, E.CIDADE, E.UF, E.CEP, E.COD_CIDADE');
            SQL.Add('FROM TAB_USUARIO U');
            SQL.Add('LEFT JOIN TAB_USUARIO_ENDERECO E ON (E.ID_USUARIO = U.ID_USUARIO AND E.IND_PADRAO = ''S'')');
            SQL.Add('WHERE U.EMAIL = :EMAIL AND U.SENHA = :SENHA ');
            ParamByName('EMAIL').Value := EMAIL;
            ParamByName('SENHA').Value := SENHA;

            Active := true;
        end;

        Result := qry.ToJSONObject();

    finally
        qry.Free;
    end;
end;

procedure TUsuario.Inserir;
var
    qry: TFDQuery;
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


                //-----

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
            end;

            FConn.Commit;

        except on ex:exception do
            begin
                FConn.Rollback;
                raise Exception.Create(ex.Message);
            end;
        end;

    finally
        qry.Free;
    end;
end;

procedure TUsuario.Editar;
var
    qry: TFDQuery;
begin
    Validate('Editar');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE TAB_USUARIO SET NOME=:NOME, EMAIL=:EMAIL');
            SQL.Add('WHERE ID_USUARIO=:ID_USUARIO');

            ParamByName('NOME').Value := NOME;
            ParamByName('EMAIL').Value := EMAIL;
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ExecSQL;
        end;

    finally
        qry.Free;
    end;
end;

procedure TUsuario.Validate(operacao: string);
begin
    if (ID_USUARIO <= 0) and MatchStr(operacao, ['Listar', 'Editar']) then
        raise Exception.Create('Usuário não informado');

    if (EMAIL.IsEmpty) and MatchStr(operacao, ['Login', 'Inserir', 'Editar']) then
        raise Exception.Create('E-mail não informado');

    if (SENHA.IsEmpty) and MatchStr(operacao, ['Login', 'Inserir']) then
        raise Exception.Create('Senha não informada');

    if (NOME.IsEmpty) and MatchStr(operacao, ['Inserir', 'Editar']) then
        raise Exception.Create('Nome não informado');

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
