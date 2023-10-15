import 'dart:convert';

import 'package:flutter/services.dart';

class ServiceAccount {
  var type;
  var json;
  var privateKeyId;
  var privateKey;
  var clientEmail;
  var clientId;
  var projectId;
  var authUri;
  var tokenUri;


  ServiceAccount(this.json, this.type, this.privateKeyId, this.privateKey, this.clientEmail, this.clientId, this.projectId, this.authUri, this.tokenUri);

  static Future<ServiceAccount> getServiceAccount() async {
    String jsonString = await rootBundle.loadString("keystore/service-account.json");
    final jsonResponse = jsonDecode(jsonString);
    return ServiceAccount(jsonResponse,
        jsonResponse["type"],
        jsonResponse["private_key_id"],
        jsonResponse["private_key"],
        jsonResponse["client_email"],
        jsonResponse["client_id"],
        jsonResponse["project_id"],
        jsonResponse["auth_uri"],
        jsonResponse["token_uri"]);
  }
}