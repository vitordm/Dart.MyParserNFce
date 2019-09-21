import 'package:MyParserNFce/models/nfce.dart';
import 'package:MyParserNFce/models/nfce_comercio.dart';
import 'package:MyParserNFce/models/nfce_item.dart';

import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';

//remover isso
import 'package:html/parser_console.dart';

class MyParserNFceFactory {
  final String urlSefaz;

  MyParserNFceFactory(this.urlSefaz);

  Future<NFce> make() async {
    useConsole();

    NFce nfce;

    try {
      var parameter = RegExp(r"\?p.*$").stringMatch(urlSefaz);
      final url =
          'https://www.sefaz.rs.gov.br/ASP/AAE_ROOT/NFE/SAT-WEB-NFE-NFC_QRCODE_1.asp' +
              parameter;

      var client = Client();
      Response response = await client.get(url);

      if (response.statusCode != 200) return null;

      var document = parse(response.body);

      var tableRespostaWs = document.getElementById("respostaWS");
      var tablesDados = tableRespostaWs.querySelectorAll("tr > td > table");

      if (tablesDados.isEmpty) return null;

      final comercio = _extractComercioFromTableDados(tablesDados);
      nfce = _extractNFceFromTableDados(tablesDados);

      nfce.comercio = comercio;
      nfce.itens = _extracItensFromTableDados(tablesDados);
    } catch (e) {
      print(e);
    }

    return nfce;
  }

  String _clearSpaces(String str) {
    var regexLimpaEspacos =
        RegExp(r"\r?\n", caseSensitive: false, multiLine: true);
    str = str.replaceAll(regexLimpaEspacos, '');
    regexLimpaEspacos = RegExp(r"(  *)", caseSensitive: false, multiLine: true);
    str = str.replaceAll(regexLimpaEspacos, ' ');
    return str.trim();
  }

  double _convertToDoubleOrDefault(String str, double defautValue) {
    if (str.toLowerCase() != "nan") {
      return double.parse(str.replaceAll('.', '').replaceAll(',', '.').trim());
    }

    return defautValue;
  }

  NFceComercio _extractComercioFromTableDados(List<Element> tablesDados) {
    //Comercio
    var tableComercio = tablesDados[3];
    var tdsComercio = tableComercio.querySelectorAll("tr > td");
    var mapComercio = Map<String, dynamic>();
    mapComercio['razao_social'] = tdsComercio[1].text.trim();
    var cnpjIe = _clearSpaces(tdsComercio[2].text.trim());

    var regexCnpj =
        RegExp(r"CNPJ\:.{19}", caseSensitive: false, multiLine: true);
    var cnpj = regexCnpj.stringMatch(cnpjIe);
    cnpj = cnpj
        .replaceAll(
            RegExp(r"CNPJ\:", caseSensitive: false, multiLine: true), '')
        .trim();
    mapComercio['cnpj'] = cnpj;
    var ie = (RegExp(r"Inscr.*", caseSensitive: false, multiLine: true))
        .stringMatch(cnpjIe);
    ie = ie.replaceAll(RegExp(r"Ins.*\:"), '').trim();
    mapComercio['ie'] = ie;
    tableComercio = tablesDados[4];
    var comercioEndereco = tableComercio.querySelector("tr > td");
    mapComercio['endereco'] = _clearSpaces(comercioEndereco.text);

    return NFceComercio.fromMap(mapComercio);
  }

  NFce _extractNFceFromTableDados(List<Element> tablesDados) {
    var tableDadosNf = tablesDados[6];
    var tdsDadosNf = tableDadosNf.querySelectorAll('tr > td');
    var dadosPrincipais = _clearSpaces(tdsDadosNf[0].text);

    var numeroSerie =
        RegExp(r"NF.* Data", caseSensitive: false, multiLine: false)
            .stringMatch(dadosPrincipais);

    var splitDados = numeroSerie.split(' ');
    var numero = splitDados[2].trim();
    var serie = splitDados[4].trim();
    var strDataNf = RegExp(r"\d\d\/.*$", caseSensitive: false, multiLine: false)
        .stringMatch(dadosPrincipais)
        .trim();

    var dataNf = DateFormat('dd/MM/yyyy HH:mm:ss').parse(strDataNf);

    var chaveAcesso = tdsDadosNf[3].text.trim();

    var protocoloAutorizacao =
        tdsDadosNf[4].text.trim().replaceFirst(RegExp(r"^.*\:"), '').trim();

    var tdsConsumidor = tablesDados[7].querySelectorAll("tr > td");
    var consumidorDados = tdsConsumidor[1].text.trim();
    consumidorDados = _clearSpaces(consumidorDados);
    consumidorDados = consumidorDados
        .replaceFirst(
            RegExp(r"^(CPF|CNPJ)\:", caseSensitive: false, multiLine: false),
            '')
        .trim();

    var consumidorIdentificado = true;
    var documentosSemPontos =
        consumidorDados.replaceAll(RegExp(r"(\.|\-)"), '').trim();
    if (RegExp(r"\D", caseSensitive: false).hasMatch(documentosSemPontos)) {
      consumidorIdentificado = false;
      consumidorDados = '';
    }

    var tableValoresNF = tablesDados[9];
    var tdsValoresNF = tableValoresNF.querySelectorAll('tr > td');

    var valorTotal = tdsValoresNF[1].text.trim();
    var valorDesconto = tdsValoresNF[3].text.trim();
    var formaPagamento = tdsValoresNF[6].text.trim();
    var valorPago = tdsValoresNF[7].text.trim();

    var valorTotalDouble = double.parse(
        valorTotal.replaceAll('.', '').replaceAll(',', '.').trim());

    double valorDescontoDouble = 0;
    if (valorDesconto.toLowerCase() != "nan") {
      valorDescontoDouble = double.parse(
          valorDesconto.replaceAll('.', '').replaceAll(',', '.').trim());
    }

    double valorPagoDouble;
    if (valorPago.toLowerCase() != 'nan') {
      valorPagoDouble = double.parse(
          valorPago.replaceAll('.', '').replaceAll(',', '.').trim());
    }

    return NFce(
        numero: numero,
        serie: serie,
        dataNfce: dataNf,
        chaveAcesso: chaveAcesso,
        protocoloAutorizacao: protocoloAutorizacao,
        consumidorIdentificado: consumidorIdentificado,
        documentoConsumidor: consumidorDados,
        valorTotal: valorTotalDouble,
        formaPagamento: formaPagamento,
        valorDesconto: valorDescontoDouble,
        valorPago: valorPagoDouble);
  }

  List<NFceItem> _extracItensFromTableDados(List<Element> tablesDados) {
    final itens = List<NFceItem>();
    var tableItens = tablesDados[8];
    var trsItens = tableItens.querySelectorAll('tr');
    for (var i = 1; i < trsItens.length; i++) {
      var trItem = trsItens[i];
      var tdsDadosItens = trItem.querySelectorAll('td');

      var codigo = tdsDadosItens[0].text.trim();
      var descricao = tdsDadosItens[1].text.trim();
      var qtde = tdsDadosItens[2].text.trim();
      var un = tdsDadosItens[3].text.trim();
      var valorUnitario = tdsDadosItens[4].text.trim();
      var valorTotal = tdsDadosItens[5].text.trim();

      var item = NFceItem(
          codigo: codigo,
          descricao: descricao,
          qtde: _convertToDoubleOrDefault(qtde, 0),
          un: un,
          valorUnitario: _convertToDoubleOrDefault(valorUnitario, 0),
          valorTotal: _convertToDoubleOrDefault(valorTotal, 0));
      itens.add(item);
    }

    return itens;
  }
}

Future initiate() async {
  await MyParserNFceFactory('')
      .make();
}
