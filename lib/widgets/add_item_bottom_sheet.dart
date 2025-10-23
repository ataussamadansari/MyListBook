import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_model.dart';
import '../providers/lists_provider.dart';

class AddItemBottomSheet extends StatelessWidget {
  final ItemModel? item;

  const AddItemBottomSheet({super.key, this.item});

  static void show(BuildContext context, {ItemModel? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemBottomSheet(item: item),
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
      child: _AddItemForm(item: item),
    );
  }
}

class _AddItemForm extends StatefulWidget {
  final ItemModel? item;

  const _AddItemForm({this.item});

  @override
  State<_AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<_AddItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _quantityController = TextEditingController();

  ItemUnit _selectedUnit = ItemUnit.piece;
  double _quantity = 1.0;

  List<Map<String, dynamic>> _getUnitCategories() {
    return [
      {
        'title': 'Weight',
        'units': ItemUnit.values.where((unit) => unit.isWeightUnit).toList(),
      },
      {
        'title': 'Volume',
        'units': ItemUnit.values.where((unit) => unit.isVolumeUnit).toList(),
      },
      {
        'title': 'Length',
        'units': ItemUnit.values.where((unit) => unit.isLengthUnit).toList(),
      },
      {
        'title': 'Countable',
        'units': ItemUnit.values.where((unit) => unit.isCountableUnit).toList(),
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _titleController.text = widget.item!.title;
      _quantityController.text = widget.item!.quantity.toStringAsFixed(2);
      _selectedUnit = widget.item!.unit;
      _quantity = widget.item!.quantity;
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ListsProvider>(context, listen: false);
      final currentList = provider.currentList;

      if (currentList != null) {
        final item = ItemModel(
          id: widget.item?.id,
          listId: currentList.id!,
          title: _titleController.text.trim(),
          price: widget.item?.price ?? 0.0,
          quantity: _quantity,
          unit: _selectedUnit,
          status: widget.item?.status ?? ItemStatus.pending,
        );

        if (widget.item == null) {
          provider.addItemToCurrentList(item);
        } else {
          provider.updateItem(item);
        }
        Navigator.pop(context);
      }
    }
  }

  void _updateQuantity(String value) {
    setState(() {
      _quantity = double.tryParse(value) ?? 1.0;
    });
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
              Text(
                widget.item == null ? 'Add Item' : 'Edit Item',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                // Use Column instead of Row for better responsiveness
                Column(
                  children: [
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: _updateQuantity,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ItemUnit>(
                      value: _selectedUnit,
                      isExpanded: true, // FIX: Added isExpanded
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _getUnitCategories().expand((category) {
                        final List<DropdownMenuItem<ItemUnit>> categoryItems = [
                          // Category header (disabled)
                          DropdownMenuItem<ItemUnit>(
                            enabled: false,
                            child: Text(
                              category['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          // Units in this category
                          ...(category['units'] as List<ItemUnit>).map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  unit.name, // Show only name, not symbol to save space
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }),
                        ];
                        return categoryItems;
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedUnit = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.item == null ? 'Add Item' : 'Update Item',
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
