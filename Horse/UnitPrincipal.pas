unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo;

type
  TFrmPrincipal = class(TForm)
    memo: TMemo;
    procedure FormShow(Sender: TObject);
  private
    procedure GetSSLPassword(var Password: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses IdSSLOpenSSL,
     Horse,
     Horse.Jhonson,
     Horse.Compression,
     Horse.CORS,
     Controller.Categoria,
     Controller.Usuario,
     Controller.Cidade,
     Controller.Banner,
     Controller.Cupom,
     Controller.Destaque,
     Controller.Estabelecimento,
     Controller.EstabelecimentoFavorito,
     Controller.Produto,
     Controller.UsuarioEndereco,
     Controller.Pedido,

     Controller.Usuario.Admin,
     Controller.ProdutoCategoria.Admin,
     Controller.Produto.Admin,
     Controller.Pedido.Admin,
     Controller.Estabelecimento.Admin;

procedure TFrmPrincipal.GetSSLPassword(Var Password: string);
begin
    Password := '123456...';
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
    THorse.Use(Compression()); // Deve vir antes do middleware JSON...
    THorse.Use(Jhonson());
    THorse.Use(CORS);

    // SSL...
    {
    THorse.IOHandleSSL.SSLVersions := [sslvSSLv3, sslvTLSv1_2];
    THorse.IOHandleSSL.CertFile := 'E:\DeliveryMais\Certificados\certificate.crt';
    THorse.IOHandleSSL.KeyFile := 'E:\DeliveryMais\Certificados\private.key';
    //THorse.IOHandleSSL.RootCertFile := '';
    //THorse.IOHandleSSL.OnGetPassword := GetSSLPassword;
    THorse.IOHandleSSL.Active := true;
    }


    // Registrar as rotas dos controllers...
    Controller.Categoria.RegistrarRotas;
    Controller.Usuario.RegistrarRotas;
    Controller.Cidade.RegistrarRotas;
    Controller.Banner.RegistrarRotas;
    Controller.Cupom.RegistrarRotas;
    Controller.Destaque.RegistrarRotas;
    Controller.Estabelecimento.RegistrarRotas;
    Controller.EstabelecimentoFavorito.RegistrarRotas;
    Controller.Produto.RegistrarRotas;
    Controller.UsuarioEndereco.RegistrarRotas;
    Controller.Pedido.RegistrarRotas;

    Controller.Usuario.Admin.RegistrarRotas;
    Controller.ProdutoCategoria.Admin.RegistrarRotas;
    Controller.Produto.Admin.RegistrarRotas;
    Controller.Pedido.Admin.RegistrarRotas;
    Controller.Estabelecimento.Admin.RegistrarRotas;


    THorse.Listen(8082);

    memo.Lines.Add('Servidor executando na porta: ' + THorse.Port.ToString);
end;

end.

