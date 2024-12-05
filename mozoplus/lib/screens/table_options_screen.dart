import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'package:flutter/services.dart';

class TableOptionsScreen extends StatefulWidget {
  final int selectedTable;
  final int userId;
  final String username;
  final Map<String, dynamic> tableData;

  const TableOptionsScreen({
    super.key,
    required this.selectedTable,
    required this.userId,
    required this.username,
    required this.tableData,
  });

  @override
  State<TableOptionsScreen> createState() => _TableOptionsScreenState();
}

class _TableOptionsScreenState extends State<TableOptionsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildOptionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          icon: Icon(icon, size: 28),
          label: Text(
            label,
            style: const TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTableOpen = widget.tableData['isOpen'] ?? false;
    final double total = widget.tableData['total'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
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
                Icons.more_horiz,
                color: Colors.purple,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${languageProvider.translate('tableOptions')} ${widget.selectedTable}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple, Colors.deepPurple],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScaleTransition(
                scale: _animation,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade100,
                          Colors.purple.shade50,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.table_restaurant,
                              size: 32,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${languageProvider.translate('table')} ${widget.selectedTable}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              isTableOpen ? Icons.lock_open : Icons.lock,
                              size: 24,
                              color: isTableOpen ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${languageProvider.translate('status')}: ${isTableOpen ? languageProvider.translate('open') : languageProvider.translate('closed')}',
                              style: TextStyle(
                                fontSize: 20,
                                color: isTableOpen ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              size: 24,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${languageProvider.translate('total')}: \$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildOptionButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/edit_table',
                            arguments: {
                              'selectedTable': widget.selectedTable,
                              'userId': widget.userId,
                              'username': widget.username,
                            },
                          );
                        },
                        icon: Icons.edit,
                        label: languageProvider.translate('editTable'),
                        color: Colors.teal.shade700,
                      ),
                      _buildOptionButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/payment',
                            arguments: {
                              'selectedTable': widget.selectedTable,
                              'userId': widget.userId,
                              'username': widget.username,
                            },
                          );
                        },
                        icon: Icons.payment,
                        label: languageProvider.translate('payment'),
                        color: Colors.teal.shade700,
                      ),
                      _buildOptionButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/table_history',
                            arguments: {
                              'selectedTable': widget.selectedTable,
                              'userId': widget.userId,
                              'username': widget.username,
                            },
                          );
                        },
                        icon: Icons.history,
                        label: languageProvider.translate('viewHistory'),
                        color: Colors.teal.shade700,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}