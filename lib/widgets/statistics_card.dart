import 'package:flutter/material.dart';

class StatisticsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatisticsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'List Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildStatRow('Total Items', stats['totalItems'].toString()),
          _buildStatRow('Completed Items', stats['completedItems'].toString()),
          _buildStatRow(
            'Completion Rate',
            '${stats['totalItems'] > 0 ? ((stats['completedItems'] / stats['totalItems']) * 100).toStringAsFixed(1) : 0}%',
          ),
          const Divider(),
          _buildStatRow(
            'Total Cost',
            '\$${stats['totalCost'].toStringAsFixed(2)}',
          ),
          _buildStatRow(
            'Completed Cost',
            '\$${stats['completedCost'].toStringAsFixed(2)}',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
