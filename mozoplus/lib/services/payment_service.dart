import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_mozo_plus/screens/constants.dart';

class PaymentService {
  static Future<String> generateQRCode(double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-qr'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'currency': 'MXN',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['qr_data'];
      } else {
        throw Exception('Error generando código QR');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<bool> processPayment(String paymentMethod, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/process-payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'payment_method': paymentMethod,
          'amount': amount,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error procesando el pago: $e');
    }
  }
} 