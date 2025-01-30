// class Product {
//   final String id;
//   final String name;
//   final String category;
//   final double price;
//   final String image;
//   final ProductDetails details;

//   Product({
//     required this.id,
//     required this.name,
//     required this.category,
//     required this.price,
//     required this.image,
//     required this.details,
//   });

//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['_id'],
//       name: json['name'],
//       category: json['category'],
//       price: json['price'].toDouble(),
//       image: json['image'],
//       details: ProductDetails.fromJson(json['details']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'name': name,
//       'category': category,
//       'price': price,
//       'image': image,
//       'details': details.toJson(),
//     };
//   }
// }

// class ProductDetails {
//   final int? pizzas;
//   final List<String>? wingsFlavors;
//   final List<String>? sides;
//   final List<String>? drinks;
//   final int? toppingsPerPizza;
//   final double? extraToppingPrice;
//   final List<String>? sizes;
//   final Map<String, double>? sizePrices;
//   final List<String>? flavors;

//   ProductDetails({
//     this.pizzas,
//     this.wingsFlavors,
//     this.sides,
//     this.drinks,
//     this.toppingsPerPizza,
//     this.extraToppingPrice,
//     this.sizes,
//     this.sizePrices,
//     this.flavors,
//   });

//   factory ProductDetails.fromJson(Map<String, dynamic> json) {
//     return ProductDetails(
//       pizzas: json['pizzas'],
//       wingsFlavors: json['wingsFlavors'] != null
//           ? List<String>.from(json['wingsFlavors'])
//           : null,
//       sides: json['sides'] != null ? List<String>.from(json['sides']) : null,
//       drinks: json['drinks'] != null ? List<String>.from(json['drinks']) : null,
//       toppingsPerPizza: json['toppingsPerPizza'],
//       extraToppingPrice: json['extraToppingPrice']?.toDouble(),
//       sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : null,
//       sizePrices: json['sizePrices'] != null
//           ? (json['sizePrices'] as Map<String, dynamic>).map(
//               (key, value) => MapEntry(key, value.toDouble()))
//           : null,
//       flavors: json['Flavors'] != null ? List<String>.from(json['Flavors']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'pizzas': pizzas,
//       'wingsFlavors': wingsFlavors,
//       'sides': sides,
//       'drinks': drinks,
//       'toppingsPerPizza': toppingsPerPizza,
//       'extraToppingPrice': extraToppingPrice,
//       'sizes': sizes,
//       'sizePrices': sizePrices,
//       'Flavors': flavors,
//     };
//   }
// }
