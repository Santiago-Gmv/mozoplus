import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:app_mozo_plus/screens/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _codeController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    _shakeController.forward().then((_) => _shakeController.reverse());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.error_outline, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Error',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(message),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 4,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_codeController.text.isEmpty) {
      _showError('Por favor, ingrese un código');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('Intentando login con URL: $baseUrl'); // Debug
      final response = await http
          .post(
            Uri.parse('$baseUrl/verificar/${_codeController.text}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'code': _codeController.text}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('Respuesta completa del servidor: $data'); // Debug

        // Verificar la estructura completa de la respuesta
        if (data is Map<String, dynamic>) {
          print('Verificado: ${data['verificado']}');
          print('Tipo de verificado: ${data['verificado'].runtimeType}');

          // Convertir verificado a entero si es necesario
          final verificado = data['verificado'] is int
              ? data['verificado']
              : int.tryParse(data['verificado'].toString()) ?? 0;

          if (verificado == 1) {
            // Obtener y validar el nombre
            final nombreRaw = data['Nombre'];
            final nombre = nombreRaw?.toString();
            print('Nombre raw: $nombreRaw (${nombreRaw.runtimeType})');

            // Obtener y validar el ID - Intentar ambas claves 'ID' y 'id'
            var idRaw = data['ID']; // Primero intentar con mayúsculas
            if (idRaw == null) {
              idRaw = data['id']; // Si no existe, intentar con minúsculas
            }
            print('ID raw: $idRaw (${idRaw?.runtimeType})');

            int? id;
            if (idRaw != null) {
              if (idRaw is int) {
                id = idRaw;
              } else {
                id = int.tryParse(idRaw.toString());
              }
            }
            print('ID procesado: $id');

            if (nombre != null && nombre.isNotEmpty && id != null) {
              mozoName = nombre;
              mozoId = id;

              if (!mounted) return;

              print('Navegando a home con userId: $id, username: $nombre');
              Navigator.pushReplacementNamed(
                context,
                '/home',
                arguments: {
                  'userId': id,
                  'username': nombre,
                },
              );
            } else {
              print('Error de datos - nombre: $nombre, id: $id');
              _showError('Datos incompletos del servidor');
            }
          } else {
            _showError('Código incorrecto');
          }
        } else {
          print('Respuesta inválida: $data');
          _showError('Respuesta del servidor inválida');
        }
      } else {
        _showError('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showConfigDialog() {
    final TextEditingController ipController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título con icono y línea decorativa
                Container(
                  padding: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: kPrimaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.settings,
                            color: kPrimaryColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Configurar IP',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Texto descriptivo
                Text(
                  'Ingresa la dirección IP del servidor:',
                  style: TextStyle(
                    fontSize: 14,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                // Campo de texto mejorado
                TextField(
                  controller: ipController,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    hintText: 'Ejemplo: 192.168.1.100',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.computer,
                      color: kSecondaryTextColor,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: kBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: kPrimaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: kPrimaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: kPrimaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Botones con mejor estilo
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final newIp = ipController.text.trim();
                        if (await updateBaseUrl(newIp)) {
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('IP actualizada correctamente'),
                                ],
                              ),
                              backgroundColor: Colors.green[600],
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('IP inválida'),
                                ],
                              ),
                              backgroundColor: Colors.red[600],
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: kPrimaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _animation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo con animación de pulso
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'lib/img/Temp.png',
                          height: 200,
                          width: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Título con efecto de sombra
                    Text(
                      'MozoPlus',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                        color: kTextColor,
                        shadows: [
                          Shadow(
                            blurRadius: 15.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(3.0, 3.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Campo de código con animación de shake
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _codeController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Ingrese su código',
                            hintStyle: TextStyle(color: kSecondaryTextColor),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kBackgroundColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.lock_outline,
                                  color: kPrimaryColor),
                            ),
                            suffixIcon: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: kBackgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: kPrimaryColor,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: kPrimaryColor, width: 2),
                            ),
                          ),
                          style: TextStyle(color: kPrimaryColor, fontSize: 18),
                          obscureText: _obscureText,
                          onChanged: (value) {
                            if (value.length == 1) {
                              setState(() {
                                _obscureText = true;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Botón de ingreso con efecto de elevación
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login, size: 24),
                                  SizedBox(width: 12),
                                  Text(
                                    'INGRESAR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Enlace de olvidé mi código con efecto hover
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.help_outline,
                                            color: Colors.orange,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Text(
                                          '¿Olvidaste tu código?',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Por favor, contacta al administrador del restaurante para obtener un nuevo código.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          'Entendido',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        '¿Olvidaste tu código?',
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showConfigDialog,
        backgroundColor: kPrimaryColor,
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.settings, color: Colors.white),
        ),
      ),
    );
  }
}
