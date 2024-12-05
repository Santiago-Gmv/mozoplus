import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:app_mozo_plus/screens/constants.dart';
import 'package:app_mozo_plus/screens/edit_table_screen.dart';
import 'package:app_mozo_plus/widgets/qr_code_dialog.dart';

class SelectTableScreen extends StatefulWidget {
  final int userId;
  final String username;

  const SelectTableScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  _SelectTableScreenState createState() => _SelectTableScreenState();
}

class _SelectTableScreenState extends State<SelectTableScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<int> tables = [];
  Map<int, bool> tableStates = {};
  int? selectedTable;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isTableOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _loadTables();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTables() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/mesas'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          tables = [];
          tableStates.clear();
          for (var mesa in data) {
            int tableNumber = _parseTableNumber(mesa['Mesa']);
            bool isOpen = mesa['Disponible'] == false;
            tables.add(tableNumber);
            tableStates[tableNumber] = isOpen;
          }
          isLoading = false;
        });
        _controller.forward();
      } else {
        _handleError(errorCargaMesas);
      }
    } catch (e) {
      _handleError('$errorConexion: $e');
    }
  }

  int _parseTableNumber(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  void _handleError(String message) {
    print(message);
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _seleccionarMesa(BuildContext context, int numeroMesa) {
    setState(() {
      selectedTable = numeroMesa;
    });
    _navigateToMenu();
  }

  void _navigateToMenu() {
    Navigator.pushNamed(
      context,
      '/menu',
      arguments: {
        'selectedTable': selectedTable,
        'userId': widget.userId,
        'username': widget.username,
        'fromScreen': 'selectTable',
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

  void selectTable(int table) {
    setState(() {
      selectedTable = table;
    });
  }

  Future<void> _cerrarMesa() async {
    if (selectedTable != null) {
      if (!(tableStates[selectedTable] ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta mesa ya está cerrada'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final url = '$baseUrl/mesas/$selectedTable/cerrar';

      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.post(Uri.parse(url));

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          setState(() {
            tableStates[selectedTable!] = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$mesaCerradaExito $selectedTable'),
              backgroundColor: Colors.green,
            ),
          );
          _loadTables();
        } else {
          _handleError('$errorCerrarMesa: ${response.body}');
        }
      } catch (e) {
        _handleError('$errorConexion: $e');
      }
    }
  }

  Future<void> _abrirMesa() async {
    if (selectedTable != null) {
      if (tableStates[selectedTable] ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta mesa ya está abierta'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      try {
        setState(() {
          isTableOpen = true;
        });
        _navigateToMenu();
      } catch (e) {
        _handleError('$errorConexion: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una mesa primero'),
          backgroundColor: Colors.orange,
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

  void _mostrarQRMenu() {
    if (selectedTable != null) {
      showDialog(
        context: context,
        builder: (context) => QRCodeDialog(
          qrData: '$baseUrl/menu?mesa=$selectedTable',
          tableNumber: selectedTable!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTable = null;
        });
      },
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
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.table_restaurant,
                  color: kPrimaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'SELECCIONAR MESA',
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
                        color: Colors.black.withOpacity(0.1),
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
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: kPrimaryGradient,
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor)))
              : tables.isEmpty
                  ? Center(
                      child: Text(
                        textoNoMesas,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kTextColor,
                        ),
                      ),
                    )
                  : FadeTransition(
                      opacity: _animation,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: tables.length,
                        itemBuilder: (context, index) {
                          return TableCard(
                            tableNumber: tables[index],
                            isSelected: tables[index] == selectedTable,
                            isOpen: tableStates[tables[index]] ?? false,
                            onSelect: selectTable,
                          );
                        },
                      ),
                    ),
        ),
        floatingActionButton: selectedTable != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Comanda enviada a la cocina'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    backgroundColor: kPrimaryColor,
                    heroTag: 'comandaMesa',
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.print, size: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: _mostrarQRMenu,
                    backgroundColor: kPrimaryColor,
                    heroTag: 'qrMenu',
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.qr_code, size: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: _cerrarMesa,
                    backgroundColor: Colors.red,
                    heroTag: 'cerrarMesa',
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close, size: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: () {
                      if (selectedTable != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTableScreen(
                              selectedTable: selectedTable!,
                              userId: widget.userId,
                              username: widget.username,
                              apiUrl: '$baseUrl/mesas/$selectedTable',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, selecciona una mesa primero'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    backgroundColor: Colors.orange,
                    heroTag: 'editarMesa',
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.edit, size: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: _abrirMesa,
                    backgroundColor: kPrimaryColor,
                    heroTag: 'confirmarMesa',
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check, size: 24),
                    ),
                  ),
                ],
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class TableCard extends StatefulWidget {
  final int tableNumber;
  final bool isSelected;
  final bool isOpen;
  final Function(int) onSelect;

  const TableCard({
    super.key,
    required this.tableNumber,
    required this.isSelected,
    required this.isOpen,
    required this.onSelect,
  });

  @override
  _TableCardState createState() => _TableCardState();
}

class _TableCardState extends State<TableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () => widget.onSelect(widget.tableNumber),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: widget.isSelected
                ? kPrimaryLightColor
                : widget.isOpen
                    ? kBackgroundColor
                    : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? kPrimaryColor.withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                spreadRadius: widget.isSelected ? 3 : 1,
                blurRadius: widget.isSelected ? 10 : 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_bar,
                size: 60,
                color: widget.isOpen
                    ? Colors.red.shade700
                    : widget.isSelected
                        ? kPrimaryColor
                        : kTextColor,
              ),
              const SizedBox(height: 12),
              Text(
                "$textoMesa ${widget.tableNumber}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isOpen
                      ? Colors.red.shade700
                      : widget.isSelected
                          ? kPrimaryColor
                          : kTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isOpen
                    ? textoOcupada
                    : widget.isSelected
                        ? textoSeleccionada
                        : textoDisponible,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isOpen
                      ? Colors.red.shade600
                      : widget.isSelected
                          ? kPrimaryLightColor
                          : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
