import 'package:flutter/material.dart';
import 'package:flutter_bank_login_test/modules/auth/login.dart';
import 'package:flutter_bank_login_test/modules/extract/extract.dart';
import 'package:flutter_bank_login_test/theme/Theme.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(
      GetMaterialApp(
        getPages: [
        GetPage(name: "/", page: () => Login()),
        GetPage(name: "/extract", page: () => Extract()),
      ],
      theme: Themes.light,
      debugShowCheckedModeBanner: false,
    )
  );
}
