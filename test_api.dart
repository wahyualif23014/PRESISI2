import 'dart:convert';
import 'dart:io';
import 'package:KETAHANANPANGAN/core/config/api_config.dart';
import 'package:http/http.dart' as http;

void main() async {
  var res = await http.get(Uri.parse('${ApiConfig.apiBaseUrl}/potensi-lahan/filter-options'));
  var data = json.decode(res.body)['data'] as Map;
  print(data.keys);
  exit(0);
}
