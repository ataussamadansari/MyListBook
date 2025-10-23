import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_model.dart';
import '../providers/lists_provider.dart';
import '../widgets/add_item_bottom_sheet.dart';
import '../widgets/statistics_card.dart';
import '../widgets/update_item_status_sheet.dart';

class ListItemsScreen extends StatefulWidget {
  const ListItemsScreen({super.key});

  @override
  State<ListItemsScreen> createState() => _ListItemsScreenState();
}

class _ListItemsScreenState extends State<ListItemsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ListsProvider>(context);
    final currentList = provider.currentList;

    if (currentList == null) {
      return const Scaffold(body: Center(child: Text('No list selected')));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        scrolledUnderElevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentList.title),
            Text(
              currentList.description,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showStatistics(context, provider),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummarySection(provider),
          Expanded(child: _buildItemsList(provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddItemBottomSheet.show(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummarySection(ListsProvider provider) {
    final totalItems = provider.currentListItems.length;
    final totalCost = provider.currentListItems
        .where((item) => item.status == ItemStatus.complete && item.price > 0)
        .fold(0.0, (sum, item) => sum + item.totalPrice);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.green.shade100, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            icon: Icons.shopping_bag_outlined,
            value: totalItems.toString(),
            label: 'Total Items',
            color: Colors.blue,
          ),
          _buildSummaryItem(
            icon: Icons.attach_money,
            value: '\$${totalCost.toStringAsFixed(2)}',
            label: 'Total Cost',
            color: Colors.green,
          ),
          _buildSummaryItem(
            icon: Icons.check_circle,
            value: provider.currentListItems
                .where((item) => item.status == ItemStatus.complete)
                .length
                .toString(),
            label: 'Completed',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildItemsList(ListsProvider provider) {
    final items = provider.currentListItems;

    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No items in this list',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Tap + to add your first item',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return const SizedBox(height: 85);
        }

        final item = items[index];
        return _buildItemCard(context, provider, item);
      },
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    ListsProvider provider,
    ItemModel item,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildStatusIndicator(item, provider),
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.status == ItemStatus.complete
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.formattedQuantity),
            if (item.status == ItemStatus.complete && item.price > 0)
              Text(
                'Price: \$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (item.status == ItemStatus.complete && item.price > 0)
              Text(
                '\$${item.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            if (item.status == ItemStatus.notAvailable)
              Text(
                'Not Available',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        onTap: () => _handleItemTap(context, provider, item),
        onLongPress: () => _showDeleteItemDialog(context, provider, item),
      ),
    );
  }

  Widget _buildStatusIndicator(ItemModel item, ListsProvider provider) {
    return GestureDetector(
      onTap: () => _handleStatusTap(provider, item),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: _getStatusColor(item.status),
          shape: BoxShape.circle,
        ),
        child: item.status == ItemStatus.complete
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : item.status == ItemStatus.notAvailable
            ? const Icon(Icons.close, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  void _handleItemTap(
    BuildContext context,
    ListsProvider provider,
    ItemModel item,
  ) {
    // If item is pending, show status update sheet
    if (item.status == ItemStatus.pending) {
      UpdateItemStatusSheet.show(context, item: item);
    }
    // If item is complete or not available, just show edit sheet for basic info
    else {
      AddItemBottomSheet.show(context, item: item);
    }
  }

  void _handleStatusTap(ListsProvider provider, ItemModel item) {
    // Toggle between pending and not available
    ItemStatus newStatus;
    if (item.status == ItemStatus.pending) {
      newStatus = ItemStatus.notAvailable;
    } else if (item.status == ItemStatus.notAvailable) {
      newStatus = ItemStatus.pending;
    } else {
      // If complete, go back to pending
      newStatus = ItemStatus.pending;
    }

    provider.updateItem(
      item.copyWith(
        status: newStatus,
        // Reset price if going to pending/not available from complete
        price: newStatus != ItemStatus.complete ? 0.0 : item.price,
      ),
    );
  }

  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.pending:
        return Colors.orange;
      case ItemStatus.complete:
        return Colors.green;
      case ItemStatus.notAvailable:
        return Colors.red;
    }
  }

  void _showDeleteItemDialog(
    BuildContext context,
    ListsProvider provider,
    ItemModel item,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            isDefaultAction: true,
            onPressed: () {
              provider.deleteItem(item.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showStatistics(BuildContext context, ListsProvider provider) async {
    final stats = await provider.getCurrentListStats();
    showDialog(
      context: context,
      builder: (context) => Dialog(child: StatisticsCard(stats: stats)),
    );
  }
}
