import 'package:flutter/material.dart';
import 'package:flutter_bank_login_test/core/constants.dart';
import 'package:flutter_bank_login_test/core/utils/DateFormatter.dart';
import 'package:flutter_bank_login_test/data/models/Transaction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class Extract extends StatefulWidget {
  const Extract({Key? key}) : super(key: key);

  @override
  _ExtractState createState() => _ExtractState();
}

class _ExtractState extends State<Extract> {
  bool _loadingTransactions = true;
  int _page = 0;
  List<Transaction> _transactionList = [];
  ScrollController _scrollController = ScrollController();
  final box = GetStorage();

  _getData() {
    _getTransactions();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getTransactions();
      }
    });
  }

  Future<List<Transaction>> _getTransactions() async {
    try {
      setState(() {
        _page = _page + 1;
      });
      final response = await http.get(
        Uri.parse(Constant.api +
            Constant.apiExtract +
            "?dataInicial=" +
            DateFormatter.thirtyDaysAgoYYYYMMDDString() +
            "&dataFinal=" +
            DateFormatter.todayDateYYYYMMDDString() +
            "&pageSize=30&page=" +
            _page.toString() +
            ""),
        headers: {
          "Content-Type": "application/json",
          'Authorization': box.read("tokenNew")
        },
      );
      if (response.statusCode == 200) {
        List<Transaction> _temporaryList =
            Transaction.listTransactions(jsonDecode(response.body));
        setState(() {
          _transactionList = _transactionList + _temporaryList;
          if (_page == 1) {
            _loadingTransactions = false;
          }
          _loadingTransactions = false;
        });
        return _transactionList;
      } else {
        throw Exception('Não foi possível recuperar as transações.');
      }
    } catch (error) {
      throw Exception('Não foi possível recuperar as transações.');
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return _loadingTransactions
        ? Scaffold(
            body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text("Carregando suas transações..."),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "Em caso de demora tente novamente mais tarde.",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ],
            ),
          ))
        : Scaffold(
            body: ListView.separated(
              controller: _scrollController,
              itemCount: _transactionList.length + 2,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Container(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Transações",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Ver mais",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                  );
                }
                if (index == _transactionList.length + 1) {
                  return LinearProgressIndicator(
                    minHeight: 10,
                    color: Colors.blueAccent,
                    backgroundColor: Colors.blueAccent[500],
                  );
                }
                index -= 1;
                final _transaction = _transactionList[index];
                Color _color = _transaction.tipoLancamento == "C"
                    ? Colors.green
                    : Colors.red;
                return Container(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: _transaction.tipoLancamento == "C"
                              ? Icon(
                                  Icons.attach_money,
                                  color: _color,
                                  size: 32,
                                )
                              : Icon(
                                  Icons.money_off,
                                  color: _color,
                                  size: 32,
                                ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _transaction.descricaoOperacao,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                DateFormatter.dateToPtBr(
                                    _transaction.dataMovimento),
                                style: TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                            flex: 3,
                            child: Text(
                              _transaction.valorMovimento,
                              style: TextStyle(
                                  color: _color, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ))
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
          );
  }
}
