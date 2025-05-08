class ProductFilters {
  String category;
  String gender;
  String color;
  List<String> sizes;
  List<String> materials;
  List<String> brands;
  double minPrice;
  double maxPrice;

  ProductFilters({
    this.category = '',
    this.gender = '',
    this.color = '',
    this.sizes = const [],
    this.materials = const [],
    this.brands = const [],
    this.minPrice = 0,
    this.maxPrice = 10000,
  });

  ProductFilters copyWith({
    String? category,
    String? gender,
    String? color,
    List<String>? sizes,
    List<String>? materials,
    List<String>? brands,
    double? minPrice,
    double? maxPrice,
  }) {
    return ProductFilters(
      category: category ?? this.category,
      gender: gender ?? this.gender,
      color: color ?? this.color,
      sizes: sizes ?? this.sizes,
      materials: materials ?? this.materials,
      brands: brands ?? this.brands,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    if (category.isNotEmpty) params['category'] = category;
    if (gender.isNotEmpty) params['gender'] = gender;
    if (color.isNotEmpty) params['color'] = color;
    if (sizes.isNotEmpty) params['size'] = sizes.join(',');
    if (materials.isNotEmpty) params['material'] = materials.join(',');
    if (brands.isNotEmpty) params['brand'] = brands.join(',');
    if (minPrice > 0) params['minPrice'] = minPrice.toString();
    if (maxPrice < 10000) params['maxPrice'] = maxPrice.toString();

    return params;
  }

  bool get hasFilters {
    return category.isNotEmpty ||
        gender.isNotEmpty ||
        color.isNotEmpty ||
        sizes.isNotEmpty ||
        materials.isNotEmpty ||
        brands.isNotEmpty ||
        minPrice > 0 ||
        maxPrice < 10000;
  }
}
