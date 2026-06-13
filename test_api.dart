import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  var res = await http.get(Uri.parse('http://192.168.1.76:8080/api/potensi-lahan/filter-options'));
  var data = json.decode(res.body)['data'] as Map;
  print(data.keys);
  exit(0);
}
