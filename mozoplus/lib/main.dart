import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/select_table_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/preview_order_screen.dart';
import 'screens/order_summary_screen.dart';
import 'screens/edit_order_screen.dart';
import 'screens/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSavedIp(); // Cargar la IP guardada
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicación para Meseros',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          print('Argumentos recibidos en /home: $args'); // Debug
          
          if (args == null) {
            print('No hay argumentos'); // Debug
            return const LoginScreen();
          }
          
          if (args is! Map<String, dynamic>) {
            print('Argumentos no son un Map'); // Debug
            return const LoginScreen();
          }
          
          final userId = args['userId'];
          final username = args['username'];
          
          print('userId: $userId (${userId.runtimeType})'); // Debug
          print('username: $username (${username.runtimeType})'); // Debug
          
          if (userId == null || username == null || username.toString().isEmpty) {
            print('Datos de usuario inválidos'); // Debug
            return const LoginScreen();
          }
          
          // Asegurarse de que userId sea un int
          final userIdInt = userId is int ? userId : int.tryParse(userId.toString());
          if (userIdInt == null) {
            print('userId no es un número válido'); // Debug
            return const LoginScreen();
          }
          
          return SelectTableScreen(
            userId: userIdInt,
            username: username.toString(),
          );
        },
        '/menu': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null) {
            return const LoginScreen(); // Return to login if no arguments
          }
          return MenuScreen(
            apiUrl: '$baseUrl/menu',
            selectedTable: args['selectedTable'] as int,
            userId: args['userId'] as int,
            username: args['username'] as String,
            fromScreen: args['fromScreen'] as String,
            existingOrders: args['existingOrders'] as List<Map<String, dynamic>>?,
          );
        },
        '/previewOrder': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null) {
            return const LoginScreen(); // Return to login if no arguments
          }
          return PreviewOrderScreen(
            order: args['pedido'],
            selectedTable: args['selectedTable'],
            userId: args['userId'],
            username: args['username'],
          );
        },
        '/editOrder': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null) {
            return const LoginScreen(); // Return to login if no arguments
          }
          return EditOrderScreen(
            order: args['order'],
            selectedTable: args['selectedTable'],
            userId: args['userId'],
            username: args['username'],
          );
        },
        '/orderSummary': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null) {
            return const LoginScreen(); // Return to login if no arguments
          }
          return OrderSummaryScreen(
            order: args['order'],
            selectedTable: args['selectedTable'],
            userId: args['userId'],
            username: args['username'],
            numberOfAdults: args['numberOfAdults'],
            numberOfChildren: args['numberOfChildren'],
            extra: args['extra'],
          );
        },
      },
    );
  }
}
