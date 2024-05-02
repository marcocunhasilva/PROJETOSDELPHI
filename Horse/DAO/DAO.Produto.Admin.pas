unit DAO.Produto.Admin;

interface

uses FireDAC.Comp.Client,
     FireDAC.DApt,
     Data.DB,
     System.JSON,
     System.SysUtils,
     DataSet.Serialize,
     DAO.Connection;

type
    TProdutoAdmin = class
    private
        FConn : TFDConnection;
        FID_PRODUTO: integer;
        FID_ESTABELECIMENTO: integer;
        FVL_PROMOCAO: double;
        FDESCRICAO: string;
        FIND_ATIVO: string;
        FID_CATEGORIA: integer;
        FVL_PRODUTO: double;
        FNOME: string;
        FURL_FOTO: string;
        procedure Validate(operacao: string);
    public
        constructor Create;
        destructor Destroy; override;

        property ID_PRODUTO: integer read FID_PRODUTO write FID_PRODUTO;
        property ID_ESTABELECIMENTO : integer read FID_ESTABELECIMENTO write FID_ESTABELECIMENTO;
        property ID_CATEGORIA: integer read FID_CATEGORIA write FID_CATEGORIA;
        property NOME: string read FNOME write FNOME;
        property DESCRICAO: string read FDESCRICAO write FDESCRICAO;
        property URL_FOTO: string read FURL_FOTO write FURL_FOTO;
        property VL_PRODUTO: double read FVL_PRODUTO write FVL_PRODUTO;
        property VL_PROMOCAO: double read FVL_PROMOCAO write FVL_PROMOCAO;
        property IND_ATIVO: string read FIND_ATIVO write FIND_ATIVO;

        function Cardapio(id_usuario: integer): TJSONArray;
        function CardapioOpcional: TJSONArray;
        function Listar: TJSONArray;
        procedure Inserir(id_usuario: integer);
        procedure Editar;
        procedure ExcluirProduto;
        procedure ExcluirOpcionais;
        procedure InserirOpcao(arrayOp: TJsonArray);
end;

implementation

uses
  System.StrUtils;


constructor TProdutoAdmin.Create;
begin
    FConn := TConnection.CreateConnection;
end;

destructor TProdutoAdmin.Destroy;
begin
  if Assigned(FConn) then
        Fconn.Free;

  inherited;
end;

function TProdutoAdmin.Cardapio(id_usuario: integer): TJSONArray;
var
    qry : TFDQuery;
    i: integer;
    arrayProd: TJsonArray;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        // Listagem somente das categorias...

        qry.Active := false;
        qry.sql.Clear;
        qry.SQL.Add('SELECT C.ID_CATEGORIA, C.CATEGORIA, C.IND_ATIVO');
        qry.SQL.Add('FROM TAB_PRODUTO_CATEGORIA C');
        qry.SQL.Add('JOIN TAB_ESTABELECIMENTO E ON (E.ID_ESTABELECIMENTO = C.ID_ESTABELECIMENTO)');
        qry.SQL.Add('WHERE E.ID_USUARIO = :ID_USUARIO ');

        qry.ParamByName('ID_USUARIO').Value := id_usuario;

        qry.Active := true;

        Result := qry.ToJSONArray();


        // Busca produtos de cada categoria...
        for i := 0 to Result.Size - 1 do
        begin
            qry.Active := false;
            qry.sql.Clear;
            qry.SQL.Add('SELECT P.ID_PRODUTO, P.NOME, P.VL_PRODUTO, P.VL_PROMOCAO, P.URL_FOTO, P.IND_ATIVO');
            qry.SQL.Add('FROM TAB_PRODUTO P');
            qry.SQL.Add('JOIN TAB_ESTABELECIMENTO E ON (E.ID_ESTABELECIMENTO = P.ID_ESTABELECIMENTO)');
            qry.SQL.Add('WHERE E.ID_USUARIO = :ID_USUARIO ');
            qry.SQL.Add('AND P.ID_CATEGORIA = :ID_CATEGORIA ');

            qry.ParamByName('ID_USUARIO').Value := id_usuario;
            qry.ParamByName('ID_CATEGORIA').Value := Result[i].GetValue<integer>('id_categoria', 0);

            qry.Active := true;

            arrayProd := qry.ToJSONArray;

            TJsonObject(Result[i]).AddPair('produtos', arrayProd);
        end;

    finally
        qry.DisposeOf;
    end;
end;

function TProdutoAdmin.CardapioOpcional: TJSONArray;
var
    qry : TFDQuery;
    i: integer;
    arrayItem: TJsonArray;
begin
    Validate('CardapioOpcional');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;


        // Listagem somente dos "grupos" (Escolha seu pão)
        qry.Active := false;
        qry.sql.Clear;
        qry.SQL.Add('SELECT O.ID_OPCAO, O.DESCRICAO, O.IND_OBRIGATORIO, O.QTD_MAX_ESCOLHA, O.IND_ATIVO');
        qry.SQL.Add('FROM TAB_PRODUTO_OPCAO O');
        qry.SQL.Add('WHERE O.ID_PRODUTO = :ID_PRODUTO ');

        qry.ParamByName('ID_PRODUTO').Value := ID_PRODUTO;

        qry.Active := true;

        Result := qry.ToJSONArray();


        // Busca os subitens opcionais de cada "grupo" (Escolha seu pão -> Pão Baguete, Pão de Dog...)
        for i := 0 to Result.Size - 1 do
        begin
            qry.Active := false;
            qry.sql.Clear;
            qry.SQL.Add('SELECT I.ID_ITEM, I.NOME, I.VL_ITEM');
            qry.SQL.Add('FROM TAB_PRODUTO_OPCAO_ITEM I');
            qry.SQL.Add('WHERE I.ID_OPCAO = :ID_OPCAO');

            qry.ParamByName('ID_OPCAO').Value := Result[i].GetValue<integer>('id_opcao', 0);

            qry.Active := true;

            arrayItem := qry.ToJSONArray;

            TJsonObject(Result[i]).AddPair('itens', arrayItem);
        end;

    finally
        qry.DisposeOf;
    end;
end;

function TProdutoAdmin.Listar: TJSONArray;
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
            SQL.Add('SELECT P.*');
            SQL.Add('FROM TAB_PRODUTO P');
            SQL.Add('WHERE P.ID_PRODUTO > 0');

            if ID_PRODUTO > 0 then
            begin
                SQL.Add('AND P.ID_PRODUTO = :ID_PRODUTO');
                ParamByName('ID_PRODUTO').Value := ID_PRODUTO;
            end;

            SQL.Add('ORDER BY P.NOME');

            Active := true;
        end;

        result := qry.ToJSONArray();
    finally
        qry.DisposeOf;
    end;
end;

procedure TProdutoAdmin.Inserir(id_usuario: integer);
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
            SQL.Add('INSERT INTO TAB_PRODUTO(ID_ESTABELECIMENTO, ID_CATEGORIA, NOME, DESCRICAO, URL_FOTO, VL_PRODUTO, VL_PROMOCAO, IND_ATIVO)');
            SQL.Add('VALUES(:ID_ESTABELECIMENTO, :ID_CATEGORIA, :NOME, :DESCRICAO, :URL_FOTO, :VL_PRODUTO, :VL_PROMOCAO, :IND_ATIVO)');
            SQL.Add('RETURNING ID_PRODUTO');
            ParamByName('ID_ESTABELECIMENTO').Value := ID_ESTABELECIMENTO;
            ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
            ParamByName('NOME').Value := NOME;
            ParamByName('DESCRICAO').Value := DESCRICAO;
            ParamByName('URL_FOTO').Value := URL_FOTO;
            ParamByName('VL_PRODUTO').Value := VL_PRODUTO;
            ParamByName('VL_PROMOCAO').Value := VL_PROMOCAO;
            ParamByName('IND_ATIVO').Value := IND_ATIVO;
            Active := true;

            ID_PRODUTO := FieldByName('ID_PRODUTO').AsInteger;
        end;

    finally
        qry.DisposeOf;
    end;
end;

procedure TProdutoAdmin.InserirOpcao(arrayOp: TJsonArray);
var
    qry : TFDQuery;
    id_opcao, i, x: integer;
    arrayItem: TJsonArray;
begin
    Validate('InserirOpcao');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        try
            FConn.StartTransaction;

            // Remove os opcionais...
            ExcluirOpcionais;


            for i := 0 to arrayOp.Size - 1 do
            begin
                if arrayOp[i].GetValue<string>('descricao').IsEmpty then
                        raise Exception.Create('Informe a descrição de todos os grupos');

                qry.Active := false;
                qry.sql.Clear;
                qry.SQL.Add('INSERT INTO TAB_PRODUTO_OPCAO(ID_PRODUTO, DESCRICAO, IND_OBRIGATORIO, QTD_MAX_ESCOLHA, IND_ATIVO, ORDEM)');
                qry.SQL.Add('VALUES(:ID_PRODUTO, :DESCRICAO, :IND_OBRIGATORIO, :QTD_MAX_ESCOLHA, :IND_ATIVO, :ORDEM)');
                qry.SQL.Add('RETURNING ID_OPCAO');

                qry.ParamByName('ID_PRODUTO').Value := ID_PRODUTO;
                qry.ParamByName('DESCRICAO').Value := arrayOp[i].GetValue<string>('descricao');
                qry.ParamByName('IND_OBRIGATORIO').Value := arrayOp[i].GetValue<string>('ind_obrigatorio');
                qry.ParamByName('QTD_MAX_ESCOLHA').Value := arrayOp[i].GetValue<integer>('qtd_max_escolha');
                qry.ParamByName('IND_ATIVO').Value := arrayOp[i].GetValue<string>('ind_ativo');
                qry.ParamByName('ORDEM').Value := i + 1;
                qry.Active := true;

                id_opcao := qry.FieldByName('ID_OPCAO').AsInteger;


                // Loop nos itens...
                arrayItem := arrayOp[i].GetValue<TJsonArray>('itens');

                for x := 0 to arrayItem.Size - 1 do
                begin
                    if arrayItem[x].GetValue<string>('nome').IsEmpty then
                        raise Exception.Create('Informe a descrição de todos os opcionais');

                    qry.Active := false;
                    qry.sql.Clear;
                    qry.SQL.Add('INSERT INTO TAB_PRODUTO_OPCAO_ITEM(ID_OPCAO, NOME, DESCRICAO, VL_ITEM, ORDEM)');
                    qry.SQL.Add('VALUES(:ID_OPCAO, :NOME, :DESCRICAO, :VL_ITEM, :ORDEM)');

                    qry.ParamByName('ID_OPCAO').Value := id_opcao;
                    qry.ParamByName('NOME').Value := arrayItem[x].GetValue<string>('nome');
                    qry.ParamByName('DESCRICAO').Value := arrayItem[x].GetValue<string>('nome');
                    qry.ParamByName('VL_ITEM').Value := arrayItem[x].GetValue<double>('vl_item');
                    qry.ParamByName('ORDEM').Value := x + 1;
                    qry.ExecSQL;
                end;
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

procedure TProdutoAdmin.Editar;
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
            SQL.Add('UPDATE TAB_PRODUTO SET ID_CATEGORIA = :ID_CATEGORIA, NOME=:NOME, DESCRICAO=:DESCRICAO, URL_FOTO=:URL_FOTO, ');
            SQL.Add('VL_PRODUTO=:VL_PRODUTO, VL_PROMOCAO=:VL_PROMOCAO, IND_ATIVO=:IND_ATIVO');
            SQL.Add('WHERE ID_PRODUTO = :ID_PRODUTO');

            ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
            ParamByName('NOME').Value := NOME;
            ParamByName('DESCRICAO').Value := DESCRICAO;
            ParamByName('URL_FOTO').Value := URL_FOTO;
            ParamByName('VL_PRODUTO').Value := VL_PRODUTO;
            ParamByName('VL_PROMOCAO').Value := VL_PROMOCAO;
            ParamByName('IND_ATIVO').Value := IND_ATIVO;
            ParamByName('ID_PRODUTO').Value := ID_PRODUTO;
            ExecSQL;
        end;

    finally
        qry.DisposeOf;
    end;
end;

procedure TProdutoAdmin.ExcluirProduto;
var
    qry, qryOpcao : TFDQuery;
begin
    Validate('ExcluirProduto');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        qryOpcao := TFDQuery.Create(nil);
        qryOpcao.Connection := FConn;

        try
            FConn.StartTransaction;

            // Busca subitens opcionais do produto (X-Salada -> Escolha o pao -> Pão de Dog)
            qryOpcao.Active := false;
            qryOpcao.sql.Clear;
            qryOpcao.SQL.Add('SELECT ID_OPCAO FROM TAB_PRODUTO_OPCAO WHERE ID_PRODUTO = :ID_PRODUTO');
            qryOpcao.ParamByName('ID_PRODUTO').Value := ID_PRODUTO;
            qryOpcao.Active := true;

            while NOT qryOpcao.eof do
            begin
                qry.Active := false;
                qry.sql.Clear;
                qry.SQL.Add('DELETE FROM TAB_PRODUTO_OPCAO_ITEM WHERE ID_OPCAO = :ID_OPCAO');
                qry.ParamByName('ID_OPCAO').Value := qryOpcao.FieldByName('ID_OPCAO').AsInteger;
                qry.ExecSQL;

                qryOpcao.Next;
            end;

            // Exclui opcionais do produto (X-Salada -> Escolha o pao)
            qry.Active := false;
            qry.sql.Clear;
            qry.SQL.Add('DELETE FROM TAB_PRODUTO_OPCAO WHERE ID_PRODUTO = :ID_PRODUTO');
            qry.ParamByName('ID_PRODUTO').Value := ID_PRODUTO;
            qry.ExecSQL;


            // Exclui o produto (X-Salada)
            qry.Active := false;
            qry.sql.Clear;
            qry.SQL.Add('DELETE FROM TAB_PRODUTO WHERE ID_PRODUTO = :ID_PRODUTO');
            qry.ParamByName('ID_PRODUTO').Value := ID_PRODUTO;
            qry.ExecSQL;


            FConn.Commit;

        except on ex:exception do
            begin
                FConn.Rollback;
                raise Exception.Create(ex.Message);
            end;
        end;

    finally
        qry.DisposeOf;
        qryOpcao.DisposeOf;
    end;
end;

procedure TProdutoAdmin.ExcluirOpcionais;
var
    qry, qryOpcao : TFDQuery;
begin
    Validate('ExcluirOpcionais');

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := FConn;

        qryOpcao := TFDQuery.Create(nil);
        qryOpcao.Connection := FConn;

        try
            FConn.StartTransaction;

            // Busca subitens opcionais do produto (X-Salada -> Escolha o pao -> Pão de Dog)
            qryOpcao.Active := false;
            qryOpcao.sql.Clear;
            qryOpcao.SQL.Add('SELECT ID_OPCAO FROM TAB_PRODUTO_OPCAO WHERE ID_PRODUTO = :ID_PRODUTO');
            qryOpcao.ParamByName('ID_PRODUTO').Value := ID_PRODUTO;
            qryOpcao.Active := true;

            while NOT qryOpcao.eof do
            begin
                qry.Active := false;
                qry.sql.Clear;
                qry.SQL.Add('DELETE FROM TAB_PRODUTO_OPCAO_ITEM WHERE ID_OPCAO = :ID_OPCAO');
                qry.ParamByName('ID_OPCAO').Value := qryOpcao.FieldByName('ID_OPCAO').AsInteger;
                qry.ExecSQL;

                qryOpcao.Next;
            end;

            // Exclui opcionais do produto (X-Salada -> Escolha o pao)
            qry.Active := false;
            qry.sql.Clear;
            qry.SQL.Add('DELETE FROM TAB_PRODUTO_OPCAO WHERE ID_PRODUTO = :ID_PRODUTO');
            qry.ParamByName('ID_PRODUTO').Value := ID_PRODUTO;
            qry.ExecSQL;

            FConn.Commit;

        except on ex:exception do
            begin
                FConn.Rollback;
                raise Exception.Create(ex.Message);
            end;
        end;

    finally
        qry.DisposeOf;
        qryOpcao.DisposeOf;
    end;
end;

procedure TProdutoAdmin.Validate(operacao: string);
begin
    if (ID_PRODUTO <= 0) and MatchStr(operacao, ['Editar', 'ExcluirProduto', 'ExcluirOpcionais', 'CardapioOpcional', 'InserirOpcao']) then
        raise Exception.Create('Cód. produto não informado');

    if (URL_FOTO.IsEmpty) and MatchStr(operacao, ['Inserir', 'Editar']) then
        raise Exception.Create('URL da foto não informada');

    if (NOME.IsEmpty) and MatchStr(operacao, ['Inserir', 'Editar']) then
        raise Exception.Create('Nome do produto não informado');

    if (DESCRICAO.IsEmpty) and MatchStr(operacao, ['Inserir', 'Editar']) then
        raise Exception.Create('Descrição do produto não informada');

    if (ID_CATEGORIA <= 0) and MatchStr(operacao, ['Inserir', 'Editar']) then
        raise Exception.Create('Categoria do produto não informada');
end;

end.
