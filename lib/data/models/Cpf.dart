class Cpf {
  final String key;
  final List<String> values;

  Cpf({required this.key, required this.values});

  static List<Cpf> listCpf (json) {
    List<Cpf> cpfAuthList = [];
    for (var keysData in json['data']['keys']) {
      cpfAuthList.add(Cpf(key: keysData['key'], values: List<String>.from(keysData['values'])));
    }
    return cpfAuthList;
  }
}