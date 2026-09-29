class CategoryModel {
  final String categoryId;
  final String categoryName;
  final String status;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'status': status,
    };
  }
}