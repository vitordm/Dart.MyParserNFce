class NFceComercio {
  String razaoSocial;
  String cnpj;
  String ie;
  String endereco;

  NFceComercio({this.razaoSocial, this.cnpj, this.ie, this.endereco});

  factory NFceComercio.fromMap(Map<String, dynamic> map) => NFceComercio(
      razaoSocial: map['razao_social'],
      cnpj: map['razao_social'],
      ie: map['ie'],
      endereco: map['endereco']);

  Map<String, dynamic> toMap() => {
        'razao_social': razaoSocial,
        'cnpj': cnpj,
        'ie': ie,
        'endereco': endereco
      };
}
//library MyParserNFce.Models;
