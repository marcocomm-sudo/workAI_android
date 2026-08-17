import 'dart:convert';
import 'package:http/http.dart' as http;

class CirpackApiService {
  final String baseUrl;

  CirpackApiService({this.baseUrl = 'http://10.0.2.2:8000'});

  Future<Map<String, dynamic>> checkHealth() async {
    final response = await http.get(Uri.parse('$baseUrl/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Impossibile connettersi al server Cirpack');
    }
  }

  Future<Map<String, dynamic>> runAudit(String accountId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/audit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'account_id': accountId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Errore durante l\'audit: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getCdrStats(
      String userId, String dateFrom, String dateTo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/cdr/stats'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'date_from': dateFrom,
        'date_to': dateTo,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Errore durante il recupero dei CDR: ${response.body}');
    }
  }
}
