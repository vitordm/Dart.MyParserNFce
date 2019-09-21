import 'package:MyParserNFce/models/nfce_comercio.dart';
import 'package:MyParserNFce/models/nfce_item.dart';

class NFce {
  String numero;
  String serie;
  DateTime dataNfce;
  String chaveAcesso;
  String protocoloAutorizacao;
  bool consumidorIdentificado;
  String documentoConsumidor;
  double valorTotal;
  double valorDesconto;
  String formaPagamento;
  double valorPago;

  NFceComercio comercio;
  List<NFceItem> itens = List<NFceItem>();

  NFce(
      {this.numero,
      this.serie,
      this.dataNfce,
      this.chaveAcesso,
      this.protocoloAutorizacao,
      this.consumidorIdentificado,
      this.documentoConsumidor,
      this.valorTotal,
      this.valorDesconto,
      this.formaPagamento,
      this.valorPago});

  Map<String, dynamic> toMap() => {
        'numero': this.numero,
        'serie': this.serie,
        'dataNfce': this.dataNfce,
        'chaveAcesso': this.chaveAcesso,
        'protocoloAutorizacao': this.protocoloAutorizacao,
        'consumidorIdentificado': this.consumidorIdentificado,
        'documentoConsumidor': this.documentoConsumidor,
        'valorTotal': this.valorTotal,
        'valorDesconto': this.valorDesconto,
        'formaPagamento': this.formaPagamento,
        'valorPago': this.valorPago,
        'comercio': comercio.toMap(),
        'itens': itens.map((i) => i.toMap()).toList()
      };
}
