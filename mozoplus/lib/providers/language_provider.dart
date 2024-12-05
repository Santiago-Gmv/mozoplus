import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'es'; // Idioma por defecto

  String get currentLanguage => _currentLanguage;

  Locale get currentLocale => Locale(_currentLanguage);

  void changeLanguage(String languageCode) {
    _currentLanguage = languageCode;
    notifyListeners();
  }

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  // Diccionario de traducciones
  final Map<String, Map<String, String>> _translations = {
    'es': {
      'appTitle': 'MozoPlus',
      'enterCode': 'Ingrese su código',
      'login': 'Ingresar',
      'forgotCode': '¿Olvidaste tu código?',
      'forgotCodeTitle': 'Código Olvidado',
      'forgotCodeMessage': 'Por favor contacta a tu supervisor para obtener un nuevo código.',
      'understood': 'Entendido',
      'selectTable': 'Seleccionar Mesa',
      'table': 'Mesa',
      'occupied': 'Ocupada',
      'available': 'Disponible',
      'selected': 'Seleccionada',
      'close': 'Cerrar',
      'confirm': 'Confirmar',
      'edit': 'Editar',
      'tableOptions': 'Opciones',
      'logout': 'Cerrar Sesión',
      'cancel': 'Cancelar',
      'logoutConfirmation': '¿Estás seguro que deseas cerrar sesión?',
      'errorLoadingTables': 'Error al cargar las mesas',
      'errorConnection': 'Error de conexión',
      'noTables': 'No hay mesas disponibles',
      'tableClosedSuccess': 'Mesa cerrada exitosamente:',
      'errorClosingTable': 'Error al cerrar la mesa',
      'tableAlreadyClosed': 'La mesa ya está cerrada',
      'tableAlreadyOpen': 'La mesa ya está abierta',
      'pleaseSelectTable': 'Por favor seleccione una mesa',
      'payment': 'Pago',
      'billSummary': 'Resumen de Cuenta',
      'card': 'Tarjeta',
      'cash': 'Efectivo',
    },
    'en': {
      'appTitle': 'WaiterPlus',
      'enterCode': 'Enter your code',
      'login': 'Login',
      'forgotCode': 'Forgot your code?',
      'forgotCodeTitle': 'Forgot Code',
      'forgotCodeMessage': 'Please contact your supervisor to get a new code.',
      'understood': 'Understood',
      'selectTable': 'Select Table',
      'table': 'Table',
      'occupied': 'Occupied',
      'available': 'Available',
      'selected': 'Selected',
      'close': 'Close',
      'confirm': 'Confirm',
      'edit': 'Edit',
      'tableOptions': 'Options',
      'logout': 'Logout',
      'cancel': 'Cancel',
      'logoutConfirmation': 'Are you sure you want to logout?',
      'errorLoadingTables': 'Error loading tables',
      'errorConnection': 'Connection error',
      'noTables': 'No tables available',
      'tableClosedSuccess': 'Table closed successfully:',
      'errorClosingTable': 'Error closing table',
      'tableAlreadyClosed': 'Table is already closed',
      'tableAlreadyOpen': 'Table is already open',
      'pleaseSelectTable': 'Please select a table',
      'payment': 'Payment',
      'billSummary': 'Bill Summary',
      'card': 'Card',
      'cash': 'Cash',
    },
  };
} 