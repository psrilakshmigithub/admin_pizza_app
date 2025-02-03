class Order {
  final String? id;
  final String userId;
  final String deliveryType;
  final String? scheduleTime;
  final String? instructions;
  final double totalPrice;
  final double tip;
  final String? paymentIntentId;
  final String status;
  final DateTime? createdAt;
  final String? reason;
  final bool isOrderConfirmed;
  final String paymentStatus;
  final List<OrderItem> items;

  Order({
    this.id,
    required this.userId,
    required this.deliveryType,
    this.scheduleTime,
    this.instructions,
    required this.totalPrice,
    this.tip = 0.0,
    this.paymentIntentId,
    required this.status,
    this.createdAt,
    this.reason = '',
    this.isOrderConfirmed = false,
    this.paymentStatus = 'not paid',
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      userId: json['userId'],
      deliveryType: json['deliveryType'],
      scheduleTime: json['scheduleTime'],
      instructions: json['instructions'],
      totalPrice: json['totalPrice'].toDouble(),
      tip: json['tip'] != null ? json['tip'].toDouble() : 0.0,
      paymentIntentId: json['paymentIntentId'],
      status: json['status'],
      reason: json['reason'],
      isOrderConfirmed:json['isOrderConfirmed'],
      paymentStatus: json['paymentStatus'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'deliveryType': deliveryType,
      'scheduleTime': scheduleTime,
      'instructions': instructions,
      'totalPrice': totalPrice,
      'tip': tip,
      'paymentIntentId': paymentIntentId,
      'status': status,
      'reason': reason,
      'isOrderConfirmed': isOrderConfirmed,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final Product productId; // Parse as a Product object
  final String? size;
  final String? wingsFlavor;
  final List<String>? sides;
  final List<Drink>? drinks;
  final dynamic toppings; // Array or Mixed type
  final int quantity;
  final double priceByQuantity;
  final double tip;
  final double totalPrice;

  OrderItem({
    required this.productId,
    this.size,
    this.wingsFlavor,
    this.sides,
    this.drinks,
    this.toppings,
    required this.quantity,
    required this.priceByQuantity,
    required this.totalPrice,
    this.tip = 0.0,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: Product.fromJson(json['productId']), // Parse nested Product
      size: json['size'],
      wingsFlavor: json['wingsFlavor'],
      sides: json['sides'] != null ? List<String>.from(json['sides']) : null,
      drinks: json['drinks'] != null
          ? (json['drinks'] as List).map((drink) => Drink.fromJson(drink)).toList()
          : null,
      toppings: json['toppings'],
      quantity: json['quantity'],
      priceByQuantity: json['priceByQuantity'].toDouble(),
      totalPrice: json['totalPrice'].toDouble(),
      tip: json['tip'] != null ? json['tip'].toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId.toJson(), // Convert Product to JSON
      'size': size,
      'wingsFlavor': wingsFlavor,
      'sides': sides,
      'drinks': drinks?.map((drink) => drink.toJson()).toList(),
      'toppings': toppings,
      'quantity': quantity,
      'priceByQuantity': priceByQuantity,
      'totalPrice': totalPrice,
      'tip': tip,
    };
  }
}

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String image;
  final ProductDetails details;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.details,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      category: json['category'],
      price: json['price'].toDouble(),
      image: json['image'],
      details: ProductDetails.fromJson(json['details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'category': category,
      'price': price,
      'image': image,
      'details': details.toJson(),
    };
  }
}

class ProductDetails {
  final List<String>? wingsFlavors;
  final List<String>? sizes;
  final List<String>? sides;
  final List<String>? drinks;
  final List<String>? flavors;

  ProductDetails({
    this.wingsFlavors,
    this.sizes,
    this.sides,
    this.drinks,
    this.flavors,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      wingsFlavors: json['wingsFlavors'] != null ? List<String>.from(json['wingsFlavors']) : null,
      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : null,
      sides: json['sides'] != null ? List<String>.from(json['sides']) : null,
      drinks: json['drinks'] != null ? List<String>.from(json['drinks']) : null,
      flavors: json['Flavors'] != null ? List<String>.from(json['Flavors']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wingsFlavors': wingsFlavors,
      'sizes': sizes,
      'sides': sides,
      'drinks': drinks,
      'Flavors': flavors,
    };
  }
}

class Drink {
  final String name;
  final int quantity;
  final String? id;

  Drink({
    required this.name,
    required this.quantity,
    this.id,
  });

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      name: json['name'],
      quantity: json['quantity'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      '_id': id,
    };
  }
}
