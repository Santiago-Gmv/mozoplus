import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class PaymentScreen extends StatefulWidget {
  final int tableNumber;
  final int userId;
  final String username;

  const PaymentScreen({
    super.key,
    required this.tableNumber,
    required this.userId,
    required this.username,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: 'paymentIcon',
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.payment,
                  color: Colors.green,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${languageProvider.translate("payment")} ${languageProvider.translate("table")} ${widget.tableNumber}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade400,
              Colors.teal.shade700,
            ],
          ),
        ),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildBillSummaryCard(languageProvider),
                const SizedBox(height: 20),
                _buildPaymentOptions(languageProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillSummaryCard(LanguageProvider languageProvider) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.green.shade50],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.green.shade300, Colors.teal.shade700],
              ).createShader(bounds),
              child: const Icon(
                Icons.receipt_long,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              languageProvider.translate('billSummary'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(thickness: 2),
            // Aquí irían los detalles de la cuenta con animaciones
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions(LanguageProvider languageProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildPaymentOption(
            context,
            Icons.credit_card,
            languageProvider.translate('card'),
            Colors.blue,
            languageProvider,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPaymentOption(
            context,
            Icons.money,
            languageProvider.translate('cash'),
            Colors.green,
            languageProvider,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
    LanguageProvider languageProvider,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          _controller.reverse().then((_) => _controller.forward());
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, color.withOpacity(0.1)],
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 