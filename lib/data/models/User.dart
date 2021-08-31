class User {
  final String token;
  final String parceiro;
  final String urlLogoParceiro;
  final String usuario;
  final String nome;
  final String refreshToken;

  User({
    required this.token,
    required this.parceiro,
    required this.urlLogoParceiro,
    required this.usuario,
    required this.nome,
    required this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['data']['token'],
      parceiro: json['data']['parceiro'],
      urlLogoParceiro: json['data']['urlLogoParceiro'],
      usuario: json['data']['usuario'],
      nome: json['data']['nome'],
      refreshToken: json['data']['refreshToken'],
    );
  }
}