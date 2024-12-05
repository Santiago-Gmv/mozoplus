import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:app_mozo_plus/screens/constants.dart';
import '../widgets/qr_payment_dialog.dart';

class OrderSummaryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> order;
  final int selectedTable;
  final int userId;
  final String username;
  final int numberOfAdults;
  final int numberOfChildren;
  final String extra;

  const OrderSummaryScreen({
    super.key,
    required this.order,
    required this.selectedTable,
    required this.userId,
    required this.username,
    required this.numberOfAdults,
    required this.numberOfChildren,
    required this.extra,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String selectedPaymentMethod = 'QR';
  bool splitBill = false;
  int numberOfPeople = 2;

  Future<void> _enviarComanda(BuildContext context) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/mesas/${widget.selectedTable}/${widget.username}/abrir'));

      if (response.statusCode == 200) {
        await _actualizarCategoria(
            'productos', widget.order.map((item) => item['name']).toList());

        await _actualizarCategoria('cantidad_comensales', widget.numberOfAdults);

        await _actualizarCategoria('comensales_infantiles', widget.numberOfChildren);

        await _actualizarCategoria('Extra', widget.extra);

        print("numberOfChildren: ${widget.numberOfChildren}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comanda enviada a la cocina'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false,
            arguments: {
              'userId': widget.userId,
              'username': widget.username,
            });
      }
    } catch (e) {
      print('Excepción capturada: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar la comanda: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _actualizarCategoria(String categoria, dynamic valor) async {
    final url = Uri.parse('$baseUrl/mesas/${widget.selectedTable}');
    final respuesta = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"categoria": categoria, "valor": valor}),
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
          'Error al actualizar $categoria: ${respuesta.reasonPhrase}');
    }
  }

  void _mostrarDialogoMesaNoDisponible(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mesa no disponible'),
          content: const Text(
              'La mesa seleccionada ya no está disponible. Por favor, seleccione otra mesa.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Volver a selección de mesa'),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false,
                    arguments: {
                      'userId': widget.userId,
                      'username': widget.username,
                    });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final url = '$baseUrl/salir/${widget.username}';
    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarQRCode(BuildContext context, double total) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return QRPaymentDialog(
          total: total,
        );
      },
    );
  }

  void _mostrarDialogoConfirmacionLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text('Cerrar Sesión'),
            ],
          ),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.order.fold(0, (sum, item) {
      double precio = (item['price'] is int)
          ? (item['price'] as int).toDouble()
          : (item['price'] as double?) ?? 0.0;
      return sum + precio;
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: kPrimaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Resumen de la Orden',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: kTextColor,
              ),
            ),
          ],
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: kTextColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: kTextColor,
                size: 20,
              ),
              onPressed: () => _mostrarDialogoConfirmacionLogout(context),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: kPrimaryGradient,
        ),
        child: Column(
          children: [
            // Información de la mesa
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.table_bar, color: kPrimaryColor, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Mesa ${widget.selectedTable}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person, color: kPrimaryColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Mesero: ${widget.username}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: kTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.group, color: kPrimaryColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${widget.numberOfAdults} Adultos',
                        style: const TextStyle(
                          fontSize: 16,
                          color: kTextColor,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.child_care, color: kPrimaryColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${widget.numberOfChildren} Niños',
                        style: const TextStyle(
                          fontSize: 16,
                          color: kTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Detalles del pedido
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kPrimaryLightColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.receipt_long, color: kPrimaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Detalles del Pedido',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.order.length,
                          itemBuilder: (context, index) {
                            final item = widget.order[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: kPrimaryLightColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.restaurant_menu,
                                      color: kPrimaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: kTextColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Text(
                                      '1',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '\$${item['price'].toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.black12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Método de pago
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kPrimaryLightColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.payment, color: kPrimaryColor),
                              SizedBox(width: 8),
                              Text(
                                'Método de Pago',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: DropdownButtonFormField<String>(
                            value: selectedPaymentMethod,
                            isExpanded: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'Efectivo',
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 40),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: kPrimaryLightColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.money, color: kPrimaryColor, size: 24),
                                      ),
                                      const Text('Efectivo'),
                                    ],
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Tarjeta de Crédito',
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 40),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: kPrimaryLightColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.credit_card, color: kPrimaryColor, size: 24),
                                      ),
                                      const Text('Tarjeta de Crédito'),
                                    ],
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Tarjeta de Débito',
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 40),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: kPrimaryLightColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.credit_card, color: kPrimaryColor, size: 24),
                                      ),
                                      const Text('Tarjeta de Débito'),
                                    ],
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Transferencia',
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 40),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: kPrimaryLightColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.swap_horiz, color: kPrimaryColor, size: 24),
                                      ),
                                      const Text('Transferencia'),
                                    ],
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'QR',
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 40),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: kPrimaryLightColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.qr_code, color: kPrimaryColor, size: 24),
                                      ),
                                      const Text('QR'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedPaymentMethod = value!;
                                if (value == 'QR') {
                                  _mostrarQRCode(context, total);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dividir cuenta
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kPrimaryLightColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.people, color: kPrimaryColor),
                                  SizedBox(width: 8),
                                  Text(
                                    'Dividir Cuenta',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: kTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: splitBill,
                                activeColor: kPrimaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    splitBill = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        if (splitBill)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                TextFormField(
                                  initialValue: numberOfPeople.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Número de personas',
                                    prefixIcon: const Icon(Icons.group_add),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: kBackgroundColor,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      numberOfPeople = int.tryParse(value) ?? numberOfPeople;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: kPrimaryLightColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.calculate, color: kPrimaryColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Total por persona: \$${(total / numberOfPeople).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: kTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Botón Enviar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    _enviarComanda(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.send),
                      const SizedBox(width: 8),
                      const Text(
                        'Enviar Orden',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
