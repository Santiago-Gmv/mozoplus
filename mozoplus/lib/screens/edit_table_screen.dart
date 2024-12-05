import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:app_mozo_plus/screens/constants.dart';

class EditTableScreen extends StatefulWidget {
  final int selectedTable;
  final int userId;
  final String username;
  final String apiUrl;

  const EditTableScreen({
    super.key,
    required this.selectedTable,
    required this.userId,
    required this.username,
    required this.apiUrl,
  });

  @override
  _EditTableScreenState createState() => _EditTableScreenState();
}

class _EditTableScreenState extends State<EditTableScreen> {
  List<Map<String, dynamic>> pedidos = [];
  int adultos = 0;
  int ninos = 0;
  String extra = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDetallesMesa();
  }

  Future<void> _cargarDetallesMesa() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/mesas/${widget.selectedTable}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"categoria": "obtener_datos", "valor": "true"}),
      );

      if (response.statusCode == 200) {
        final detallesMesa = jsonDecode(response.body);

        setState(() {
          // Actualizamos el estado con los datos recibidos
          if (detallesMesa.containsKey('productos') &&
              detallesMesa['productos'] is List) {
            final Map<String, int> contadorProductos = {};
            for (var producto in detallesMesa['productos']) {
              if (contadorProductos.containsKey(producto)) {
                contadorProductos[producto] = contadorProductos[producto]! + 1;
              } else {
                contadorProductos[producto] = 1;
              }
            }

            pedidos = contadorProductos.entries
                .map((entry) => {'name': entry.key, 'quantity': entry.value})
                .toList();
          } else {
            pedidos = [];
          }
          adultos = detallesMesa['cantidad_comensales'] ?? 0;
          ninos = detallesMesa['comensales_infantiles'] ?? 0;
          extra = detallesMesa['Extra'] ?? '';
          _isLoading = false;
        });
      } else {
        print('Error al cargar detalles: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar detalles: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _actualizarDetallesMesa() async {
    setState(() => _isLoading = true);

    try {
      await _actualizarCategoria("cantidad_comensales", adultos);
      await _actualizarCategoria("comensales_infantiles", ninos);
      await _actualizarCategoria("Extra", extra);
      List<String> newPedidos = [];
      for (var pedido in pedidos) {
        for (var i = 0; i < pedido['quantity']; i++) {
          newPedidos.add(pedido['name']);
        }
      }
      await _actualizarCategoria("productos", newPedidos);

      _mostrarMensaje('Detalles actualizados correctamente');
      Navigator.pop(context);
    } catch (e) {
      _mostrarError('Error al actualizar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _actualizarCategoria(String categoria, dynamic valor) async {
    final url = Uri.parse(widget.apiUrl);
    try {
      final respuesta = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "mesa": widget.selectedTable,
          "categoria": categoria,
          "valor": valor,
          "userId": widget.userId,
          "username": widget.username,
        }),
      );

      if (respuesta.statusCode != 200) {
        print('Respuesta del servidor: ${respuesta.body}');
        throw Exception(
            'Error al actualizar $categoria: ${respuesta.statusCode} - ${respuesta.reasonPhrase}');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      rethrow;
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      backgroundColor: const Color(0xFF00BCD4), // Cyan 500
    ));
  }

  void _mostrarError(String error) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_note,
                color: Color(0xFF00838F), // Cyan 800
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'MESA ${widget.selectedTable}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00BCD4), // Cyan 500
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00BCD4), // Cyan 500
              Color(0xFF0097A7), // Cyan 700
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00ACC1)), // Cyan 600
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildGuestsCard(),
                    const SizedBox(height: 16),
                    _buildOrdersCard(),
                    const SizedBox(height: 16),
                    _buildNotesCard(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildGuestsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4DD0E1).withOpacity(0.2), // Cyan 300
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB2EBF2), // Cyan 100
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.people,
                    color: const Color(0xFF00838F), // Cyan 800
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Comensales',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00838F), // Cyan 800
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildGuestCounter(
                    'Adultos',
                    adultos,
                    Icons.person,
                    (value) => setState(() => adultos = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGuestCounter(
                    'Niños',
                    ninos,
                    Icons.child_care,
                    (value) => setState(() => ninos = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFB2EBF2), // Cyan 100
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group,
                    color: const Color(0xFF00838F), // Cyan 800
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total: ${adultos + ninos}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00838F), // Cyan 800
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCounter(
      String label, int value, IconData icon, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB2EBF2), // Cyan 100
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00838F)), // Cyan 800
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF00838F), // Cyan 800
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCounterButton(
                Icons.remove,
                () => onChanged(value > 0 ? value - 1 : 0),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00838F), // Cyan 800
                  ),
                ),
              ),
              _buildCounterButton(
                Icons.add,
                () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFB2EBF2), // Cyan 100
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF00838F), // Cyan 800
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB2EBF2), // Cyan 100
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.restaurant_menu,
                        color: const Color(0xFF00838F), // Cyan 800
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pedidos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00838F), // Cyan 800
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB2EBF2), // Cyan 100
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: const Color(0xFF00838F), // Cyan 800
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pedidos.length} items',
                        style: TextStyle(
                          color: const Color(0xFF00838F), // Cyan 800
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (pedidos.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay pedidos aún',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pedidos.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final pedido = pedidos[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB2EBF2), // Cyan 100
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        color: const Color(0xFF00838F), // Cyan 800
                      ),
                    ),
                    title: Text(
                      pedido['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB2EBF2), // Cyan 100
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'x${pedido['quantity']}',
                            style: TextStyle(
                              color: const Color(0xFF00838F), // Cyan 800
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red.shade400,
                          onPressed: () {
                            setState(() {
                              pedidos.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/menu',
                    arguments: {
                      'selectedTable': widget.selectedTable,
                      'userId': widget.userId,
                      'username': widget.username,
                      'fromScreen': 'editTable',
                      'existingOrders': pedidos,
                    },
                  );

                  if (result != null) {
                    setState(() {
                      pedidos = List<Map<String, dynamic>>.from(result as List);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB2EBF2), // Cyan 100
                  foregroundColor: const Color(0xFF00838F), // Cyan 800
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Agregar Pedido',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB2EBF2), // Cyan 100
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.note_add,
                    color: const Color(0xFF00838F), // Cyan 800
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Notas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00838F), // Cyan 800
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: extra),
              onChanged: (value) => extra = value,
              maxLines: 4,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Agregar notas o comentarios...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade700,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: const Color(0xFF4DD0E1)), // Cyan 300
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: const Color(0xFF4DD0E1)), // Cyan 300
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: const Color(0xFF00ACC1), width: 2), // Cyan 600
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _actualizarDetallesMesa,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00ACC1), // Cyan 600
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.save, size: 24),
          SizedBox(width: 8),
          Text(
            'Guardar Cambios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
