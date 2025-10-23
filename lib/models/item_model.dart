enum ItemStatus { pending, complete, notAvailable }

enum ItemUnit {
  kg,
  gram,
  ltr,
  ml,
  meter,
  cm,
  feet,
  inch,
  pack,
  piece,
  bag,
  bottle,
  box,
  dozen,
  can,
  jar,
  other,
}

extension ItemUnitExtension on ItemUnit {
  String get symbol {
    switch (this) {
      case ItemUnit.kg:
        return 'kg';
      case ItemUnit.gram:
        return 'g';
      case ItemUnit.ltr:
        return 'L';
      case ItemUnit.ml:
        return 'ml';
      case ItemUnit.meter:
        return 'm';
      case ItemUnit.cm:
        return 'cm';
      case ItemUnit.feet:
        return 'ft';
      case ItemUnit.inch:
        return 'in';
      case ItemUnit.pack:
        return 'pack';
      case ItemUnit.piece:
        return 'pc';
      case ItemUnit.bag:
        return 'bag';
      case ItemUnit.bottle:
        return 'bottle';
      case ItemUnit.box:
        return 'box';
      case ItemUnit.dozen:
        return 'dozen';
      case ItemUnit.can:
        return 'can';
      case ItemUnit.jar:
        return 'jar';
      case ItemUnit.other:
        return '';
    }
  }

  bool get isWeightUnit => this == ItemUnit.kg || this == ItemUnit.gram;

  bool get isVolumeUnit => this == ItemUnit.ltr || this == ItemUnit.ml;

  bool get isLengthUnit =>
      this == ItemUnit.meter ||
      this == ItemUnit.cm ||
      this == ItemUnit.feet ||
      this == ItemUnit.inch;

  bool get isCountableUnit => !isWeightUnit && !isVolumeUnit && !isLengthUnit;
}

class ItemModel {
  int? id;
  int listId;
  String title;
  double price; // price per unit (e.g. ₹50/kg)
  double quantity;
  ItemUnit unit;
  ItemStatus status;
  DateTime createdAt;
  DateTime updatedAt;

  ItemModel({
    this.id,
    required this.listId,
    required this.title,
    this.price = 0.0,
    this.quantity = 1.0,
    this.unit = ItemUnit.piece,
    this.status = ItemStatus.pending,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // ✅ Accurate total price calculation
  double get totalPrice {
    // for countable units — simple multiplication
    if (unit.isCountableUnit) return price * quantity;

    double qty = quantity;

    // 🧮 handle weight
    if (unit == ItemUnit.gram) {
      qty = quantity / 1000;
    } else if (unit == ItemUnit.ml) {
      qty = quantity / 1000;
    } else if (unit == ItemUnit.cm) {
      qty = quantity / 100;
    } else if (unit == ItemUnit.inch) {
      qty = quantity / 39.37;
    } else if (unit == ItemUnit.feet) {
      qty = quantity / 3.281;
    }

    return price * qty;
  }

  // ✅ Map helpers
  Map<String, dynamic> toMap() => {
    'id': id,
    'listId': listId,
    'title': title,
    'price': price,
    'quantity': quantity,
    'unit': unit.index,
    'status': status.index,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ItemModel.fromMap(Map<String, dynamic> map) => ItemModel(
    id: map['id'],
    listId: map['listId'],
    title: map['title'],
    price: (map['price'] ?? 0).toDouble(),
    quantity: (map['quantity'] ?? 1).toDouble(),
    unit: ItemUnit.values[map['unit']],
    status: ItemStatus.values[map['status']],
    createdAt: DateTime.parse(map['createdAt']),
    updatedAt: DateTime.parse(map['updatedAt']),
  );

  // ✅ Copy
  ItemModel copyWith({
    String? title,
    double? price,
    double? quantity,
    ItemUnit? unit,
    ItemStatus? status,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      id: id,
      listId: listId,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ✅ Display helpers
  String get formattedQuantity => (quantity == quantity.truncateToDouble())
      ? '${quantity.toInt()} ${unit.symbol}'
      : '${quantity.toStringAsFixed(1)} ${unit.symbol}';

  String get formattedTotalPrice => '₹${totalPrice.toStringAsFixed(2)}';
}
