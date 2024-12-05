import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'constants.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentOptionsScreen extends StatefulWidget {
  final int selectedTable;
  final int userId;
  final String username;
  final Map<String, dynamic> order;

  const PaymentOptionsScreen({
    super.key,
    required this.selectedTable,
    required this.userId,
    required this.username,
    required this.order,
  });

  @override
  _PaymentOptionsScreenState createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  String _selectedPaymentMethod = 'cash';
  bool _splitBill = false;
  int _numberOfPeople = 1;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.translate('paymentOptions'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: kPrimaryGradient,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen de la mesa
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.all(size.width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${languageProvider.translate('table')} ${widget.selectedTable}',
                          style: TextStyle(
                            fontSize: size.width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                          ),
                        ),
                        Text(
                          '${languageProvider.translate('waiter')}: ${widget.username}',
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            color: kTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Opciones de pago
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.all(size.width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageProvider.translate('paymentMethod'),
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                          ),
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryLightColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.money, color: kPrimaryColor),
                          ),
                          title: Text(
                            languageProvider.translate('cash'),
                            style: TextStyle(
                              color: kTextColor,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                          trailing: Radio<String>(
                            value: 'cash',
                            groupValue: _selectedPaymentMethod,
                            activeColor: kPrimaryColor,
                            onChanged: (value) {
                              setState(() => _selectedPaymentMethod = value!);
                            },
                          ),
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryLightColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.credit_card, color: kPrimaryColor),
                          ),
                          title: Text(
                            languageProvider.translate('card'),
                            style: TextStyle(
                              color: kTextColor,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                          trailing: Radio<String>(
                            value: 'card',
                            groupValue: _selectedPaymentMethod,
                            activeColor: kPrimaryColor,
                            onChanged: (value) {
                              setState(() => _selectedPaymentMethod = value!);
                            },
                          ),
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryLightColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.credit_card, color: kPrimaryColor),
                          ),
                          title: Text(
                            'Tarjeta de Débito',
                            style: TextStyle(
                              color: kTextColor,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                          trailing: Radio<String>(
                            value: 'debit',
                            groupValue: _selectedPaymentMethod,
                            activeColor: kPrimaryColor,
                            onChanged: (value) {
                              setState(() => _selectedPaymentMethod = value!);
                            },
                          ),
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryLightColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.swap_horiz, color: kPrimaryColor),
                          ),
                          title: Text(
                            'Transferencia',
                            style: TextStyle(
                              color: kTextColor,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                          trailing: Radio<String>(
                            value: 'transfer',
                            groupValue: _selectedPaymentMethod,
                            activeColor: kPrimaryColor,
                            onChanged: (value) {
                              setState(() => _selectedPaymentMethod = value!);
                            },
                          ),
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryLightColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.qr_code, color: kPrimaryColor),
                          ),
                          title: Text(
                            'QR',
                            style: TextStyle(
                              color: kTextColor,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                          trailing: Radio<String>(
                            value: 'qr',
                            groupValue: _selectedPaymentMethod,
                            activeColor: kPrimaryColor,
                            onChanged: (value) {
                              setState(() => _selectedPaymentMethod = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Dividir cuenta
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.all(size.width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              languageProvider.translate('splitBill'),
                              style: TextStyle(
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.bold,
                                color: kTextColor,
                              ),
                            ),
                            Switch(
                              value: _splitBill,
                              onChanged: (value) {
                                setState(() => _splitBill = value);
                              },
                            ),
                          ],
                        ),
                        if (_splitBill) ...[
                          SizedBox(height: size.height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                languageProvider.translate('numberOfPeople'),
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  color: kTextColor,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove,
                                      color: kPrimaryColor,
                                    ),
                                    onPressed: () {
                                      if (_numberOfPeople > 1) {
                                        setState(() => _numberOfPeople--);
                                      }
                                    },
                                  ),
                                  Text(
                                    '$_numberOfPeople',
                                    style: TextStyle(
                                      fontSize: size.width * 0.04,
                                      color: kTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: kPrimaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() => _numberOfPeople++);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.print),
                      label: Text(languageProvider.translate('print')),
                      onPressed: () {
                        // Implementar impresión
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code),
                      label: Text(languageProvider.translate('generateQR')),
                      onPressed: () {
                        _showQRDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.04),

                // Botón de procesar pago
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Implementar procesamiento de pago
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      languageProvider.translate('processPayment'),
                      style: TextStyle(fontSize: size.width * 0.05),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQRDialog(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data:
                      'Mesa: ${widget.selectedTable}, Total: ${widget.order['total']}',
                  version: QrVersions.auto,
                  size: size.width * 0.6,
                ),
                SizedBox(height: size.height * 0.02),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(languageProvider.translate('close')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
