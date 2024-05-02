program Servidor;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitPrincipal in 'UnitPrincipal.pas' {FrmPrincipal},
  DAO.Connection in 'DAO\DAO.Connection.pas',
  DAO.Banner in 'DAO\DAO.Banner.pas',
  DAO.Categoria in 'DAO\DAO.Categoria.pas',
  DAO.Cidade in 'DAO\DAO.Cidade.pas',
  DAO.Cupom in 'DAO\DAO.Cupom.pas',
  DAO.Destaque in 'DAO\DAO.Destaque.pas',
  DAO.Estabelecimento in 'DAO\DAO.Estabelecimento.pas',
  DAO.Pedido in 'DAO\DAO.Pedido.pas',
  DAO.PedidoItem in 'DAO\DAO.PedidoItem.pas',
  DAO.PedidoItemDetalhe in 'DAO\DAO.PedidoItemDetalhe.pas',
  DAO.Produto in 'DAO\DAO.Produto.pas',
  DAO.Usuario in 'DAO\DAO.Usuario.pas',
  DAO.UsuarioEndereco in 'DAO\DAO.UsuarioEndereco.pas',
  DAO.UsuarioFavorito in 'DAO\DAO.UsuarioFavorito.pas',
  Controller.Categoria in 'Controller\Controller.Categoria.pas',
  Controller.Auth in 'Controller\Controller.Auth.pas',
  Controller.Usuario in 'Controller\Controller.Usuario.pas',
  Controller.Comum in 'Controller\Controller.Comum.pas',
  Controller.Cidade in 'Controller\Controller.Cidade.pas',
  Controller.Banner in 'Controller\Controller.Banner.pas',
  Controller.Cupom in 'Controller\Controller.Cupom.pas',
  Controller.Destaque in 'Controller\Controller.Destaque.pas',
  Controller.Estabelecimento in 'Controller\Controller.Estabelecimento.pas',
  Controller.EstabelecimentoFavorito in 'Controller\Controller.EstabelecimentoFavorito.pas',
  Controller.Produto in 'Controller\Controller.Produto.pas',
  Controller.UsuarioEndereco in 'Controller\Controller.UsuarioEndereco.pas',
  Controller.Pedido in 'Controller\Controller.Pedido.pas',
  Controller.Usuario.Admin in 'Controller\Controller.Usuario.Admin.pas',
  DAO.Usuario.Admin in 'DAO\DAO.Usuario.Admin.pas',
  Controller.ProdutoCategoria.Admin in 'Controller\Controller.ProdutoCategoria.Admin.pas',
  DAO.ProdutoCategoria.Admin in 'DAO\DAO.ProdutoCategoria.Admin.pas',
  Controller.Produto.Admin in 'Controller\Controller.Produto.Admin.pas',
  DAO.Produto.Admin in 'DAO\DAO.Produto.Admin.pas',
  Controller.Pedido.Admin in 'Controller\Controller.Pedido.Admin.pas',
  DAO.Pedido.Admin in 'DAO\DAO.Pedido.Admin.pas',
  Controller.Estabelecimento.Admin in 'Controller\Controller.Estabelecimento.Admin.pas',
  DAO.Estabelecimento.Admin in 'DAO\DAO.Estabelecimento.Admin.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
