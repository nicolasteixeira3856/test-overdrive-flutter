import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bank_login_test/core/constants.dart';
import 'package:flutter_bank_login_test/data/models/Account.dart';
import 'package:flutter_bank_login_test/data/models/Cpf.dart';
import 'package:flutter_bank_login_test/data/models/User.dart';
import 'package:flutter_bank_login_test/theme/Theme.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _cpfController = TextEditingController();
  TextEditingController _passwordController = TextEditingController(text: '');
  bool _isCpfValid = false;
  String _keyboard1 = "0 ou 1";
  String _keyboard2 = "2 ou 3";
  String _keyboard3 = "4 ou 5";
  String _keyboard4 = "6 ou 7";
  String _keyboard5 = "8 ou 9";
  String _keyboard1TrueValue = "A";
  String _keyboard2TrueValue = "B";
  String _keyboard3TrueValue = "C";
  String _keyboard4TrueValue = "D";
  String _keyboard5TrueValue = "E";
  late List<Cpf> _cpfAuthList;
  late List<Account> _accountList;
  final box = GetStorage();

  _build() async {
    await _cpfAuth();
    await _buildKeyboard();
  }

  Future<List<Cpf>> _cpfAuth() async {
    try {
      _openLoadingDialog();
      String _cpf = _cpfController.text;
      _cpf = _cpf.replaceAll(".", "");
      _cpf = _cpf.replaceAll("-", "");

      String body = json.encode({
        'data': {'cpf': _cpf}
      });

      final response = await http.post(
        Uri.parse(Constant.api + Constant.apiCpf),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        _cpfAuthList = Cpf.listCpf(jsonDecode(response.body));
        Get.back();
        return _cpfAuthList;
      } else {
        _error();
        throw Exception('Não foi possível criar uma listagem de cpfAuth.');
      }
    } catch (error) {
      _error();
      throw Exception('Não foi possível criar uma listagem de cpfAuth.');
    }
  }

  Future<User> _loginButtonPressed() async {
    try {
      _openLoggingIn();
      String _cpf = _cpfController.text;
      _cpf = _cpf.replaceAll(".", "");
      _cpf = _cpf.replaceAll("-", "");

      String body = json.encode({
        'data': {'cpf': _cpf, 'senha': _passwordController.text}
      });

      final response = await http.post(
        Uri.parse(Constant.api + Constant.apiUser),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        User loginAuth = User.fromJson(jsonDecode(response.body));
        box.write("cpf", _cpf);
        box.write("token", loginAuth.token);
        box.write("refreshToken", loginAuth.refreshToken);
        _recuperarContas();
        return loginAuth;
      } else {
        throw Exception('Não foi possível recuperar os dados.');
      }
    } catch (error) {
      Get.back();
      _error();
      throw Exception('Não foi possível recuperar os dados.');
    }
  }

  Future<List<Account>> _recuperarContas() async {
    try {
      final response = await http.get(
        Uri.parse(Constant.api +
            Constant.apiAccounts +
            "?usuario=" +
            box.read("cpf")),
        headers: {
          "Content-Type": "application/json",
          'Authorization': box.read("token")
        },
      );

      if (response.statusCode == 200) {
        _accountList = Account.listAccounts(jsonDecode(response.body));
        box.write("account", _accountList[0].codigo);
        _authCompany();
        return _accountList;
      } else {
        throw Exception('Não foi possível criar uma listagem de contas.');
      }
    } catch (error) {
      Get.back();
      _error();
      throw Exception('Não foi possível criar uma listagem de contas.');
    }
  }

  Future<User> _authCompany() async {
    try {
      String body = json.encode({
        'refreshToken': box.read("refreshToken"),
        'codigoConta': box.read("account")
      });

      final response = await http.post(
        Uri.parse(Constant.api + Constant.apiAuthCompany),
        headers: {
          "Content-Type": "application/json",
          'Authorization': box.read("token")
        },
        body: body,
      );

      if (response.statusCode == 200) {
        User loginAuth = User.fromJson(jsonDecode(response.body));
        print(loginAuth.toString());
        box.write("tokenNew", loginAuth.token);
        box.write("refreshTokenNew", loginAuth.refreshToken);
        Get.back();
        Get.offAllNamed('/extract');
        return loginAuth;
      } else {
        throw Exception('Não foi possível recuperar os dados.');
      }
    } catch (error) {
      Get.back();
      _error();
      throw Exception('Não foi possível recuperar os dados.');
    }
  }

  _buildKeyboard() {
    setState(() {
      //Controls numbers displayed for the user
      _keyboard1 = _cpfAuthList[0].values[0] + " ou " + _cpfAuthList[0].values[1];
      _keyboard2 = _cpfAuthList[1].values[0] + " ou " + _cpfAuthList[1].values[1];
      _keyboard3 = _cpfAuthList[2].values[0] + " ou " + _cpfAuthList[2].values[1];
      _keyboard4 = _cpfAuthList[3].values[0] + " ou " + _cpfAuthList[3].values[1];
      _keyboard5 = _cpfAuthList[4].values[0] + " ou " + _cpfAuthList[4].values[1];
      //Controls the true meaning behind the numbers
      _keyboard1TrueValue = _cpfAuthList[0].key;
      _keyboard2TrueValue = _cpfAuthList[1].key;
      _keyboard3TrueValue = _cpfAuthList[2].key;
      _keyboard4TrueValue = _cpfAuthList[3].key;
      _keyboard5TrueValue = _cpfAuthList[4].key;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  _openLoadingDialog() {
    Get.defaultDialog(
      title: "",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(
            height: 20,
          ),
          Text("Carregando")
        ],
      ),
    );
  }

  _openLoggingIn() {
    Get.defaultDialog(
      barrierDismissible: false,
      title: "",
      content: WillPopScope(
        onWillPop: () => Future.value(false),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Text("Acessando sua conta...")
          ],
        ),
      ),
    );
  }

  _error() {
    Get.defaultDialog(
      title: "Ops!",
      confirm: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cpfController = TextEditingController();
                _passwordController = TextEditingController(text: '');
                _isCpfValid = false;
                _keyboard1 = "0 ou 1";
                _keyboard2 = "2 ou 3";
                _keyboard3 = "4 ou 5";
                _keyboard4 = "6 ou 7";
                _keyboard5 = "8 ou 9";
                _keyboard1TrueValue = "A";
                _keyboard2TrueValue = "B";
                _keyboard3TrueValue = "C";
                _keyboard4TrueValue = "D";
                _keyboard5TrueValue = "E";
              });
              Get.back();
            },
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text("Ocorreu um erro, tente novamente!")],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 128,
                ),
              ),
              Center(
                  child: Text(
                "A sua conta digital",
                style: TextStyle(fontSize: 18, color: Themes.light.accentColor),
              )),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CpfInputFormatter()
                  ],
                  onChanged: (cpf) {
                    _isCpfValid = UtilBrasilFields.isCPFValido(cpf);
                    if (_isCpfValid) {
                      _build();
                      FocusScope.of(context).unfocus();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "CPF",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  controller: _passwordController,
                  readOnly: true,
                  obscureText: true,
                  decoration: InputDecoration(hintText: "Senha"),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: ElevatedButton(
                            child: Text(_keyboard1),
                            onPressed: () {
                              setState(() {
                                _passwordController.text =
                                    _passwordController.text +
                                        _keyboard1TrueValue;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: ElevatedButton(
                            child: Text(_keyboard2),
                            onPressed: () {
                              setState(() {
                                _passwordController.text =
                                    _passwordController.text +
                                        _keyboard2TrueValue;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: ElevatedButton(
                            child: Text(_keyboard3),
                            onPressed: () {
                              setState(() {
                                _passwordController.text =
                                    _passwordController.text +
                                        _keyboard3TrueValue;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: ElevatedButton(
                            child: Text(_keyboard4),
                            onPressed: () {
                              setState(() {
                                _passwordController.text =
                                    _passwordController.text +
                                        _keyboard4TrueValue;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: ElevatedButton(
                            child: Text(_keyboard5),
                            onPressed: () {
                              setState(() {
                                _passwordController.text =
                                    _passwordController.text +
                                        _keyboard5TrueValue;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: ElevatedButton.icon(
                            label: Text("Limpar"),
                            icon: Icon(Icons.backspace),
                            onPressed: () {
                              setState(() {
                                _passwordController.text = "";
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                    onPressed: (_isCpfValid && _passwordController.text.length > 7) ? () {_loginButtonPressed();} : null,
                    child: Text("Entrar")),
              )
            ],
          ),
        ),
      ),
    );
  }
}
