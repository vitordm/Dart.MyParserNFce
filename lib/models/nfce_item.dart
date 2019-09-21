class NFceItem {
  String codigo;
  String descricao;
  double qtde;
  String un;
  double valorUnitario;
  double valorTotal;

  NFceItem(
      {this.codigo,
      this.descricao,
      this.qtde,
      this.un,
      this.valorUnitario,
      this.valorTotal});

  Map<String, dynamic> toMap() => {
        'codigo': this.codigo,
        'descricao': this.descricao,
        'qtde': this.qtde,
        'un': this.un,
        'valorUnitario': this.valorUnitario,
        'valorTotal': this.valorTotal,
      };
}
