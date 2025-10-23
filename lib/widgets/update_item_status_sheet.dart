import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_model.dart';
import '../providers/lists_provider.dart';

class UpdateItemStatusSheet extends StatelessWidget {
  final ItemModel item;

  const UpdateItemStatusSheet({super.key, required this.item});

  static void show(BuildContext context, {required ItemModel item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateItemStatusSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: _UpdateStatusForm(item: item),
    );
  }
}

class _UpdateStatusForm extends StatefulWidget {
  final ItemModel item;

  const _UpdateStatusForm({required this.item});

  @override
  State<_UpdateStatusForm> createState() => _UpdateStatusFormState();
}

class _UpdateStatusFormState extends State<_UpdateStatusForm> {
  final _priceController = TextEditingController();
  ItemStatus _selectedStatus = ItemStatus.pending;

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.item.price > 0
        ? widget.item.price.toStringAsFixed(2)
        : '';
    _selectedStatus = widget.item.status;
  }

  void _submit() {
    final provider = Provider.of<ListsProvider>(context, listen: false);

    double price = double.tryParse(_priceController.text) ?? 0.0;

    // If status is complete, price must be provided
    if (_selectedStatus == ItemStatus.complete && price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter price for completed items')),
      );
      return;
    }

    // If status is not available, set price to 0
    if (_selectedStatus == ItemStatus.notAvailable) {
      price = 0.0;
    }

    final updatedItem = widget.item.copyWith(
      price: price,
      status: _selectedStatus,
    );

    provider.updateItem(updatedItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              const Text(
                'Update Item Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Item Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.item.formattedQuantity,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Status Selection
              const Text(
                'Select Status:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatusOption(
                    ItemStatus.pending,
                    'Pending',
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusOption(
                    ItemStatus.complete,
                    'Complete',
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusOption(
                    ItemStatus.notAvailable,
                    'Not Available',
                    Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Price Input (only show for complete status)
              if (_selectedStatus == ItemStatus.complete)
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price Paid *',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getStatusColor(_selectedStatus),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Update Status',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(ItemStatus status, String label, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatus = status;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _selectedStatus == status ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _selectedStatus == status ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _getStatusIcon(status),
                color: _selectedStatus == status ? Colors.white : color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: _selectedStatus == status ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(ItemStatus status) {
    switch (status) {
      case ItemStatus.pending:
        return Icons.pending_actions;
      case ItemStatus.complete:
        return Icons.check_circle;
      case ItemStatus.notAvailable:
        return Icons.cancel;
    }
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

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}
