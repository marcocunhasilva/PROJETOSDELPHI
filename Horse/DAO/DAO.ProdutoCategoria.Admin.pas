unit DAO.ProdutoCategoria.Admin;

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
    TProdutoCategoriaAdmin = class
    private
        FConn : TFDConnection;
        FIND_ATIVO: string;
        FCATEGORIA: string;
        FID_CATEGORIA: integer;
        FID_ESTABELECIMENTO: integer;
        procedure Validate(operacao: string);
    public
        constructor Create;
        destructor Destroy; override;

        property ID_CATEGORIA: integer read FID_CATEGORIA write FID_CATEGORIA;
        property CATEGORIA: string read FCATEGORIA write FCATEGORIA;
        property ID_ESTABELECIMENTO: integer read FID_ESTABELECIMENTO write FID_ESTABELECIMENTO;
        property IND_ATIVO: string read FIND_ATIVO write FIND_ATIVO;

        function Listar(id_usuario: integer): TJSONArray;
        procedure Inserir(id_usuario: integer);
        procedure Editar;
        procedure Excluir;
end;

implementation


constructor TProdutoCategoriaAdmin.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TProdutoCategoriaAdmin.Destroy;
begin
    if Assigned(FConn) then
        Fconn.Free;

    inherited;
end;

function TProdutoCategoriaAdmin.Listar(id_usuario: integer): TJSONArray;
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
            SQL.Add('SELECT C.ID_CATEGORIA, C.CATEGORIA, C.IND_ATIVO');
            SQL.Add('FROM TAB_PRODUTO_CATEGORIA C');
            SQL.Add('JOIN TAB_ESTABELECIMENTO E ON (E.ID_ESTABELECIMENTO = C.ID_ESTABELECIMENTO)');
            SQL.Add('WHERE E.ID_USUARIO = :ID_USUARIO ');

            if IND_ATIVO <> '' then
            begin
                SQL.Add('AND C.IND_ATIVO = :IND_ATIVO ');
                ParamByName('IND_ATIVO').Value := IND_ATIVO;
            end;

            if ID_CATEGORIA > 0 then
            begin
                SQL.Add('AND C.ID_CATEGORIA = :ID_CATEGORIA');
                ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
            end;

            SQL.Add('ORDER BY C.CATEGORIA');

            ParamByName('ID_USUARIO').Value := id_usuario;

            Active := true;
        end;

        result := qry.ToJSONArray();

    finally
        qry.DisposeOf;
    end;
end;

procedure TProdutoCategoriaAdmin.Inserir(id_usuario: integer);
var
    qry : TFDQuery;
begin
    Validate('Inserir');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            // Descobre o estabelecimento...
            Active := false;
            sql.Clear;
            SQL.Add('SELECT ID_ESTABELECIMENTO FROM TAB_ESTABELECIMENTO WHERE ID_USUARIO = :ID_USUARIO');
            ParamByName('ID_USUARIO').Value := ID_USUARIO;
            Active := true;

            ID_ESTABELECIMENTO := FieldByName('ID_ESTABELECIMENTO').AsInteger;


            Active := false;
            sql.Clear;
            SQL.Add('INSERT INTO TAB_PRODUTO_CATEGORIA(ID_ESTABELECIMENTO, CATEGORIA, IND_ATIVO)');
            SQL.Add('VALUES(:ID_ESTABELECIMENTO, :CATEGORIA, :IND_ATIVO)');
            SQL.Add('RETURNING ID_CATEGORIA');
            ParamByName('ID_ESTABELECIMENTO').Value := ID_ESTABELECIMENTO;
            ParamByName('CATEGORIA').Value := CATEGORIA;
            ParamByName('IND_ATIVO').Value := IND_ATIVO;
            Active := true;

            ID_CATEGORIA := FieldByName('ID_CATEGORIA').AsInteger;
        end;

    finally
        qry.DisposeOf;
    end;
end;

procedure TProdutoCategoriaAdmin.Editar;
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
            SQL.Add('UPDATE TAB_PRODUTO_CATEGORIA SET CATEGORIA = :CATEGORIA, IND_ATIVO = :IND_ATIVO');
            SQL.Add('WHERE ID_CATEGORIA = :ID_CATEGORIA');
            ParamByName('CATEGORIA').Value := CATEGORIA;
            ParamByName('IND_ATIVO').Value := IND_ATIVO;
            ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
            ExecSQL;
        end;

    finally
        qry.DisposeOf;
    end;
end;

procedure TProdutoCategoriaAdmin.Excluir;
var
    qry : TFDQuery;
begin
    Validate('Excluir');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        with qry do
        begin
            // Verifica se existe produto cadastrado...
            Active := false;
            sql.Clear;
            SQL.Add('SELECT ID_PRODUTO FROM TAB_PRODUTO WHERE ID_CATEGORIA = :ID_CATEGORIA');
            ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
            Active := true;

            if RecordCount > 0 then
                raise Exception.Create('A categoria não pode ser excluída porque possui produtos cadastrados.');



            Active := false;
            sql.Clear;
            SQL.Add('DELETE FROM TAB_PRODUTO_CATEGORIA WHERE ID_CATEGORIA = :ID_CATEGORIA');
            ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
            ExecSQL;
        end;

    finally
        qry.DisposeOf;
    end;
end;

procedure TProdutoCategoriaAdmin.Validate(operacao: string);
begin
    if (ID_CATEGORIA <= 0) and MatchStr(operacao, ['Editar', 'Excluir']) then
        raise Exception.Create('Categoria não informada');

    if (CATEGORIA.IsEmpty) and MatchStr(operacao, ['Inserir', 'Editar']) then
        raise Exception.Create('Descrição da categoria não informada');
end;

end.
