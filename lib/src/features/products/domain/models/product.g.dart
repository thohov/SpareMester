// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as double,
      url: fields[3] as String?,
      imageUrl: fields[4] as String?,
      desireScore: fields[5] as int,
      createdAt: fields[6] as DateTime,
      timerEndDate: fields[7] as DateTime,
      status: fields[8] as ProductStatus,
      decision: fields[9] as PurchaseDecision?,
      decisionDate: fields[10] as DateTime?,
      category: fields[11] == null
          ? ProductCategory.other
          : fields[11] as ProductCategory,
      extendedCooldownDays: fields[12] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.desireScore)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.timerEndDate)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.decision)
      ..writeByte(10)
      ..write(obj.decisionDate)
      ..writeByte(11)
      ..write(obj.category)
      ..writeByte(12)
      ..write(obj.extendedCooldownDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductStatusAdapter extends TypeAdapter<ProductStatus> {
  @override
  final int typeId = 1;

  @override
  ProductStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProductStatus.waiting;
      case 1:
        return ProductStatus.completed;
      case 2:
        return ProductStatus.archived;
      default:
        return ProductStatus.waiting;
    }
  }

  @override
  void write(BinaryWriter writer, ProductStatus obj) {
    switch (obj) {
      case ProductStatus.waiting:
        writer.writeByte(0);
        break;
      case ProductStatus.completed:
        writer.writeByte(1);
        break;
      case ProductStatus.archived:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PurchaseDecisionAdapter extends TypeAdapter<PurchaseDecision> {
  @override
  final int typeId = 2;

  @override
  PurchaseDecision read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PurchaseDecision.impulseBuy;
      case 1:
        return PurchaseDecision.plannedPurchase;
      case 2:
        return PurchaseDecision.avoided;
      default:
        return PurchaseDecision.impulseBuy;
    }
  }

  @override
  void write(BinaryWriter writer, PurchaseDecision obj) {
    switch (obj) {
      case PurchaseDecision.impulseBuy:
        writer.writeByte(0);
        break;
      case PurchaseDecision.plannedPurchase:
        writer.writeByte(1);
        break;
      case PurchaseDecision.avoided:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseDecisionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
