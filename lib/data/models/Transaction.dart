import 'package:flutter_bank_login_test/core/utils/CurrencyFormatter.dart';

class Transaction {
  final String tipoLancamento;
  final String descricaoOperacao;
  final String dataMovimento;
  final String valorMovimento;

  Transaction({
    required this.tipoLancamento,
    required this.descricaoOperacao,
    required this.dataMovimento,
    required this.valorMovimento
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      tipoLancamento: json['data']['tipoLancamento'],
      descricaoOperacao: json['data']['descricaoOperacao'],
      dataMovimento: json['data']['dataMovimento'],
      valorMovimento: json['data']['valorMovimento'],
    );
  }

  static List<Transaction> listTransactions (json) {
    List<Transaction> transactionsList = [];
    for (var transactionData in json['data']) {
      String valorMovimento = CurrencyFormatter.doubleToBrazilianRealString(transactionData['valorMovimento']);
      transactionsList.add(Transaction(
          tipoLancamento: transactionData['tipoLancamento'],
          descricaoOperacao: transactionData['descricaoOperacao'],
          dataMovimento: transactionData['dataMovimento'],
          valorMovimento: valorMovimento
      ));
    }
    return transactionsList;
  }
}