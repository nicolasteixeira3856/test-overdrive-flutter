class Account {
  final String codigo;

  Account({required this.codigo});

  static List<Account> listAccounts (json) {
    List<Account> listAccount = [];
    for (var keysData in json['data']) {
      listAccount.add(Account(codigo: keysData['codigo']));
    }
    return listAccount;
  }
}