unit DAO.UsuarioEndereco;

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
    TUsuarioEndereco = class
    private
        FConn: TFDConnection;
        FID_ENDERECO: integer;
        FBAIRRO: string;
        FCOD_CIDADE: string;
        FUF: string;
        FCEP: string;
        FCOMPLEMENTO: string;
        FIND_PADRAO: string;
        FCIDADE: string;
        FENDERECO: string;
        FID_USUARIO: integer;

        procedure Validate(operacao: string);
    public
        constructor Create;
        destructor Destroy; override;

        property ID_ENDERECO: integer read FID_ENDERECO write FID_ENDERECO;
        property ID_USUARIO: integer read FID_USUARIO write FID_USUARIO;
        property ENDERECO: string read FENDERECO write FENDERECO;
        property COMPLEMENTO: string read FCOMPLEMENTO write FCOMPLEMENTO;
        property BAIRRO: string read FBAIRRO write FBAIRRO;
        property CIDADE: string read FCIDADE write FCIDADE;
        property UF: string read FUF write FUF;
        property CEP: string read FCEP write FCEP;
        property IND_PADRAO: string read FIND_PADRAO write FIND_PADRAO;
        property COD_CIDADE: string read FCOD_CIDADE write FCOD_CIDADE;

        function Listar: TJSONArray;
        procedure Inserir;
        procedure Editar;
        procedure Excluir;
        procedure TornarPadrao;
    end;

implementation

{ TUsuarioEndereco }

constructor TUsuarioEndereco.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TUsuarioEndereco.Destroy;
begin
    if Assigned(FConn) then
        FConn.Free;

    inherited;
end;

function TUsuarioEndereco.Listar: TJSONArray;
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
            SQL.Add('SELECT *');
            SQL.Add('FROM TAB_USUARIO_ENDERECO');
            SQL.Add('WHERE ID_USUARIO = :ID_USUARIO');

            ParamByName('ID_USUARIO').Value := ID_USUARIO;

            if ID_ENDERECO > 0 then
            begin
                SQL.Add('AND ID_ENDERECO = :ID_ENDERECO');
                ParamByName('ID_ENDERECO').Value := ID_ENDERECO;
            end;

            if COD_CIDADE <> '' then
            begin
                SQL.Add('AND COD_CIDADE = :COD_CIDADE');
                ParamByName('COD_CIDADE').Value := COD_CIDADE;
            end;

            SQL.Add('ORDER BY ID_ENDERECO DESC');

            Active := true;
        end;

        Result := qry.ToJSONArray();

    finally
        qry.Free;
    end;
end;

procedure TUsuarioEndereco.Inserir;
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
            SQL.Add('INSERT INTO TAB_USUARIO_ENDERECO(ID_USUARIO, ENDERECO, COMPLEMENTO,');
            SQL.Add('BAIRRO, CIDADE, UF, CEP, IND_PADRAO, COD_CIDADE)');
            SQL.Add('VALUES(:ID_USUARIO, :ENDERECO, :COMPLEMENTO,');
            SQL.Add(':BAIRRO, :CIDADE, :UF, :CEP, :IND_PADRAO, :COD_CIDADE)');
            SQL.Add('RETURNING ID_ENDERECO');

            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ParamByName('ENDERECO').Value := ENDERECO;
            ParamByName('COMPLEMENTO').Value := COMPLEMENTO;
            ParamByName('BAIRRO').Value := BAIRRO;
            ParamByName('CIDADE').Value := CIDADE;
            ParamByName('UF').Value := UF;
            ParamByName('CEP').Value := CEP;
            ParamByName('IND_PADRAO').Value := IND_PADRAO;
            ParamByName('COD_CIDADE').Value := COD_CIDADE;
            Active := true;

            ID_ENDERECO := FieldByName('ID_ENDERECO').AsInteger;
        end;

    finally
        qry.Free;
    end;
end;

procedure TUsuarioEndereco.Editar;
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
            SQL.Add('UPDATE TAB_USUARIO_ENDERECO SET ENDERECO=:ENDERECO, COMPLEMENTO=:COMPLEMENTO,');
            SQL.Add('BAIRRO=:BAIRRO, CIDADE=:CIDADE, UF=:UF, CEP=:CEP, COD_CIDADE=:COD_CIDADE');
            SQL.Add('WHERE ID_ENDERECO = :ID_ENDERECO AND ID_USUARIO=:ID_USUARIO');

            ParamByName('ENDERECO').Value := ENDERECO;
            ParamByName('COMPLEMENTO').Value := COMPLEMENTO;
            ParamByName('BAIRRO').Value := BAIRRO;
            ParamByName('CIDADE').Value := CIDADE;
            ParamByName('UF').Value := UF;
            ParamByName('CEP').Value := CEP;
            ParamByName('COD_CIDADE').Value := COD_CIDADE;
            ParamByName('ID_ENDERECO').Value := ID_ENDERECO;
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ExecSQL;
        end;

    finally
        qry.Free;
    end;
end;

procedure TUsuarioEndereco.Excluir;
var
    qry: TFDQuery;
begin
    Validate('Excluir');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('DELETE FROM TAB_USUARIO_ENDERECO');
            SQL.Add('WHERE ID_ENDERECO = :ID_ENDERECO AND ID_USUARIO=:ID_USUARIO');
            ParamByName('ID_ENDERECO').Value := ID_ENDERECO;
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ExecSQL;
        end;

    finally
        qry.Free;
    end;
end;

procedure TUsuarioEndereco.TornarPadrao;
var
    qry: TFDQuery;
begin
    Validate('TornarPadrao');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE TAB_USUARIO_ENDERECO SET IND_PADRAO = ''N''');
            SQL.Add('WHERE ID_USUARIO=:ID_USUARIO');
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ExecSQL;

            Active := false;
            sql.Clear;
            SQL.Add('UPDATE TAB_USUARIO_ENDERECO SET IND_PADRAO = ''S''');
            SQL.Add('WHERE ID_ENDERECO=:ID_ENDERECO AND ID_USUARIO=:ID_USUARIO');
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            ParamByName('ID_ENDERECO').Value := ID_ENDERECO;
            ExecSQL;
        end;

    finally
        qry.Free;
    end;
end;

procedure TUsuarioEndereco.Validate(operacao: string);
begin
    if (ID_USUARIO <= 0) and MatchStr(operacao, ['Listar', 'Editar', 'Excluir', 'TornarPadrao']) then
        raise Exception.Create('Usuário não informado');

    if (ENDERECO.IsEmpty) and MatchStr(operacao, ['Inserir', 'Editar']) then
        raise Exception.Create('Endereço não informado');

    if (BAIRRO.IsEmpty) and MatchStr(operacao, ['Inserir', 'Editar']) then
        raise Exception.Create('Bairro não informado');

    if (CIDADE.IsEmpty) and MatchStr(operacao, ['Inserir', 'Editar']) then
        raise Exception.Create('Cidade não informada');

    if (UF.IsEmpty) and MatchStr(operacao, ['Inserir', 'Editar'])  then
        raise Exception.Create('UF não informado');

    if (CEP.IsEmpty) and MatchStr(operacao, ['Inserir', 'Editar']) then
        raise Exception.Create('CEP não informado');

    if (COD_CIDADE.IsEmpty) and MatchStr(operacao, ['Inserir', 'Editar']) then
        raise Exception.Create('Cód. cidade não informado');

    if (ID_ENDERECO <= 0) and MatchStr(operacao, ['Editar', 'Excluir', 'TornarPadrao']) then
        raise Exception.Create('Id. endereço não informado');
end;

end.
