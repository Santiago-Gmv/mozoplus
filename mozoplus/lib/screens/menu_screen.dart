import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:app_mozo_plus/screens/constants.dart';
import 'package:app_mozo_plus/screens/edit_order_screen.dart';

class MenuScreen extends StatefulWidget {
  final String apiUrl;
  final int selectedTable;
  final int userId;
  final String username;
  final String fromScreen;
  final List<Map<String, dynamic>>? existingOrders;

  const MenuScreen({
    super.key,
    required this.apiUrl,
    required this.selectedTable,
    required this.userId,
    required this.username,
    required this.fromScreen,
    this.existingOrders,
  });

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  Map<String, List<dynamic>> menu = {
    "bebidas": [],
    "entradas": [],
    "platos_principales": [],
    "postres": []
  };
  List<Map<String, dynamic>> pedido = [];
  bool isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (widget.existingOrders != null) {
      pedido = List<Map<String, dynamic>>.from(widget.existingOrders!);
    }
    _cargarMenuDesdeAPI();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _cargarMenuDesdeAPI() async {
    try {
      final response = await http.get(Uri.parse(widget.apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          menu = Map<String, List<dynamic>>.from(data['menu']);
          isLoading = false;
        });
        _controller.forward();
      } else {
        print('Error en la respuesta de la API: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error al cargar el menú desde la API: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> categorias = menu.keys.toList();

    return DefaultTabController(
      length: categorias.length,
      child: Scaffold(
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
                      color: kPrimaryColor.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: kPrimaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'MENÚ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: kTextColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          backgroundColor: kPrimaryColor,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: kPrimaryColor,
                size: 24,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                onPressed: () => _mostrarDialogoConfirmacionLogout(context),
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: kPrimaryColor,
            labelColor: kPrimaryColor,
            unselectedLabelColor: kPrimaryLightColor,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            tabs: categorias.map((categoria) {
              IconData icon;
              switch (categoria) {
                case "bebidas":
                  icon = Icons.water_drop;
                  break;
                case "entradas":
                  icon = Icons.breakfast_dining;
                  break;
                case "platos_principales":
                  icon = Icons.dining;
                  break;
                case "postres":
                  icon = Icons.cookie;
                  break;
                default:
                  icon = Icons.restaurant_menu;
              }
              return Tab(
                icon: Icon(icon, size: 18),
                text: categoria.toUpperCase().replaceAll('_', ' '),
              );
            }).toList(),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: kPrimaryGradient,
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  ),
                )
              : FadeTransition(
                  opacity: _animation,
                  child: TabBarView(
                    children: categorias.map((categoria) {
                      return _construirListaMenu(menu[categoria]);
                    }).toList(),
                  ),
                ),
        ),
        floatingActionButton: pedido.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () {
                  if (widget.fromScreen == 'selectTable') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditOrderScreen(
                          order: pedido,
                          selectedTable: widget.selectedTable,
                          userId: widget.userId,
                          username: widget.username,
                        ),
                      ),
                    );
                  } else {
                    Navigator.pop(context, pedido);
                  }
                },
                backgroundColor: kPrimaryColor,
                icon: const Icon(Icons.restaurant_menu),
                label: Text(
                  '${pedido.fold<int>(0, (sum, item) => sum + (item['quantity'] as int? ?? 1))} items',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _construirListaMenu(List<dynamic>? items) {
    if (items == null || items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_meals, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay elementos disponibles',
              style: TextStyle(
                fontSize: 18,
                color: kTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        bool isInCart = pedido.any((element) => element['name'] == item['name']);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(15),
            color: kBackgroundColor,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                setState(() {
                  int existingIndex = pedido.indexWhere(
                    (element) => element['name'] == item['name']
                  );

                  if (existingIndex != -1) {
                    pedido[existingIndex] = {
                      ...pedido[existingIndex],
                      'quantity': (pedido[existingIndex]['quantity'] ?? 1) + 1,
                    };
                  } else {
                    pedido.add({
                      ...item,
                      'quantity': 1,
                    });
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: kPrimaryLightColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        size: 30,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kTextColor,
                            ),
                          ),
                          Text(
                            '\$${item['price'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isInCart)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kPrimaryLightColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.check,
                          color: kPrimaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
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
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
