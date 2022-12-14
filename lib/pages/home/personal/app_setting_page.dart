import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_feed_app/themes/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:news_feed_app/utils/api_utils.dart';

class AppSettingPage extends StatefulWidget {
  const AppSettingPage({Key? key}) : super(key: key);

  @override
  State<AppSettingPage> createState() => _AppSettingPage();
}

class _AppSettingPage extends State<AppSettingPage> {
  late Future<Map<String, dynamic>> futureUserSettings;

  Future<Map<String, dynamic>> getUserSettings() async {
    final response = await http.get(ApiUtils.buildUri(path: "/settings/"),
        headers: {
          'authorization': await FirebaseAuth.instance.currentUser!.getIdToken()
        });
    if (response.statusCode == 200) {
      final userSettings = jsonDecode(response.body);
      return userSettings;
    } else {
      throw Exception(
          "Error when calling API to get user settings ${response.statusCode} ${response.body}");
    }
  }

  Future updateUserSettings({bool? enableNotification}) async {
    Map<String, dynamic> updateUserSettings = {};
    if (enableNotification != null) {
      updateUserSettings.update(
          'enableNotification', (value) => enableNotification,
          ifAbsent: () => enableNotification);
    }
    final response = await http.put(ApiUtils.buildUri(path: "/settings/"),
        body: json.encode(updateUserSettings),
        headers: {
          'authorization': await FirebaseAuth.instance.currentUser!.getIdToken()
        });
    if (response.statusCode == 200) {
    } else {
      throw Exception(
          "Error when calling API to update user settings ${response.statusCode} ${response.body}");
    }
  }

  @override
  void initState() {
    super.initState();
    futureUserSettings = getUserSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appMainBackground,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.setting)),
      body: Container(
          padding: const EdgeInsets.only(top: 14),
          child: ListView(
            children: <Widget>[
              FutureBuilder<Map<String, dynamic>>(
                  future: futureUserSettings,
                  builder: (context, snapshot) {
                    bool enableNotification = false;
                    if (snapshot.hasData) {
                      enableNotification = snapshot.data!["enableNotification"];
                    }
                    return SwitchListTile(
                      value: enableNotification,
                      title: const Text("Nh???n th??ng b??o ?????y"),
                      subtitle: const Text(
                          "Gi??p b???n lu??n c???p nh???t c??c b??i vi???t m???i nh???t"),
                      onChanged: (bool value) async {
                        await updateUserSettings(enableNotification: value);
                        setState(() {
                          futureUserSettings = getUserSettings();
                        });
                      },
                    );
                  })
            ],
          )),
    );
  }
}
