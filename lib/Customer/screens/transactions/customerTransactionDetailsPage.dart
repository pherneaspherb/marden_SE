import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderType;
  static const _purpleColor = Color(0xFF4B007D);

  const TransactionDetailsPage({
    super.key,
    required this.orderData,
    required this.orderType,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = orderData['totalAmount'] ?? 0;
    final dateTime = orderData['timestamp']?.toDate();
    final formattedDate = dateTime != null
        ? DateFormat('dd MMM yyyy  hh:mm a').format(dateTime)
        : 'N/A';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              decoration: const BoxDecoration(
                color: _purpleColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Thank you for being\nwith us.',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOTAL PAID
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL PAID:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '₱${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _purpleColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      thickness: 1,
                      height: 30,
                      indent: 24,
                      endIndent: 24,
                      color: _purpleColor,
                    ),

                    // Breakdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                        },
                        children: [
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Breakdown',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: Text('Service'),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Text(
                                  orderType,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (orderData['additionalService'] != null)
                            TableRow(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text('Extras'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Text(
                                    '${orderData['additionalService']}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          if (orderData['weight'] != null)
                            TableRow(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text('Weight'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Text(
                                    '${orderData['weight']}kg',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  'Total',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Text(
                                  '₱${totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: _purpleColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Order Details
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Order Details',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Download Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: download logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _purpleColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Download Receipt',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}