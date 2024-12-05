import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Paleta de colores principal
const kPrimaryColor = Color(0xFF2196F3);  // Azul principal
const kPrimaryLightColor = Color(0xFF64B5F6);  // Azul claro
const kPrimaryDarkColor = Color(0xFF1976D2);  // Azul oscuro
const kAccentColor = Color(0xFF42A5F5);  // Azul acento
const kBackgroundColor = Color(0xFFE3F2FD);  // Azul muy claro para fondos
const kTextColor = Color(0xFF1565C0);  // Azul oscuro para textos
const kSecondaryTextColor = Color(0xFF90CAF9);  // Azul claro para textos secundarios

// Gradientes
const kPrimaryGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF2196F3),  // Azul principal
    Color(0xFF1976D2),  // Azul oscuro
  ],
);

String baseUrl = 'http://192.168.0.101:8000';

// Función para verificar conexión a internet
Future<bool> hasInternetConnection() async {
  return await InternetConnectionChecker().hasConnection;
}

// Función para validar formato de IP
bool isValidIp(String ip) {
  final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
  if (!ipRegex.hasMatch(ip)) return false;
  
  final parts = ip.split('.');
  return parts.every((part) {
    final value = int.tryParse(part);
    return value != null && value >= 0 && value <= 255;
  });
}

// Función para actualizar la IP del servidor
Future<bool> updateBaseUrl(String ip) async {
  if (!isValidIp(ip)) {
    return false;
  }
  
  try {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = 'http://$ip:8000';
    await prefs.setString('server_ip', ip);
    return true;
  } catch (e) {
    print('Error al guardar IP: $e');
    return false;
  }
}

// Función para cargar la IP del servidor guardada
Future<void> loadSavedIp() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('server_ip');
    if (savedIp != null && isValidIp(savedIp)) {
      baseUrl = 'http://$savedIp:8000';
      print('IP cargada: $baseUrl'); // Para depuración
    }
  } catch (e) {
    print('Error al cargar IP: $e');
  }
}

// Variables globales
String? mozoName;
int? mozoId;
int? selectedTable;
Map<int, bool> tableStates = {};
bool isTableOpen = false;

// Mensajes de error
const String errorCargaMesas = 'Error al cargar las mesas';
const String errorConexion = 'Error de conexión';
const String errorCerrarMesa = 'Error al cerrar la mesa';
const String errorCerrarSesion = 'Error al cerrar sesión';
const String errorProcesandoPago = 'Error procesando el pago';
const String errorGenerandoQR = 'Error generando código QR';

// Mensajes de éxito
const String mesaCerradaExito = 'Mesa cerrada exitosamente';
const String sesionCerradaExito = 'Sesión cerrada exitosamente';
const String pagoExitoso = 'Pago procesado exitosamente';

// Textos de la interfaz
const String tituloSeleccionarMesa = 'Seleccionar Mesa';
const String textoNoMesas = 'No se encontraron mesas';
const String textoMesa = 'Mesa';
const String textoSeleccionada = 'Seleccionada';
const String textoDisponible = 'Disponible';
const String textoOcupada = 'Ocupada';
