// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductCategoryAdapter extends TypeAdapter<ProductCategory> {
  @override
  final int typeId = 5;

  @override
  ProductCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProductCategory.electronics;
      case 1:
        return ProductCategory.clothing;
      case 2:
        return ProductCategory.food;
      case 3:
        return ProductCategory.entertainment;
      case 4:
        return ProductCategory.home;
      case 5:
        return ProductCategory.health;
      case 6:
        return ProductCategory.sports;
      case 7:
        return ProductCategory.travel;
      case 8:
        return ProductCategory.books;
      case 9:
        return ProductCategory.other;
      default:
        return ProductCategory.electronics;
    }
  }

  @override
  void write(BinaryWriter writer, ProductCategory obj) {
    switch (obj) {
      case ProductCategory.electronics:
        writer.writeByte(0);
        break;
      case ProductCategory.clothing:
        writer.writeByte(1);
        break;
      case ProductCategory.food:
        writer.writeByte(2);
        break;
      case ProductCategory.entertainment:
        writer.writeByte(3);
        break;
      case ProductCategory.home:
        writer.writeByte(4);
        break;
      case ProductCategory.health:
        writer.writeByte(5);
        break;
      case ProductCategory.sports:
        writer.writeByte(6);
        break;
      case ProductCategory.travel:
        writer.writeByte(7);
        break;
      case ProductCategory.books:
        writer.writeByte(8);
        break;
      case ProductCategory.other:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
