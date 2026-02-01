// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 3;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      currency: fields[0] as String,
      currencySymbol: fields[1] as String,
      hourlyWage: fields[2] as double,
      languageCode: fields[3] as String,
      hasCompletedOnboarding: fields[4] as bool,
      smallAmountThreshold: fields[5] as int,
      mediumAmountThreshold: fields[6] as int,
      smallAmountWaitHours: fields[7] as int,
      mediumAmountWaitDays: fields[8] as int,
      largeAmountWaitDays: fields[9] as int,
      useMinutesForSmallAmount: fields[10] == null ? false : fields[10] as bool,
      currentStreak: fields[11] == null ? 0 : fields[11] as int,
      longestStreak: fields[12] == null ? 0 : fields[12] as int,
      lastDecisionDate: fields[13] as DateTime?,
      monthlyBudget: fields[14] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.currency)
      ..writeByte(1)
      ..write(obj.currencySymbol)
      ..writeByte(2)
      ..write(obj.hourlyWage)
      ..writeByte(3)
      ..write(obj.languageCode)
      ..writeByte(4)
      ..write(obj.hasCompletedOnboarding)
      ..writeByte(5)
      ..write(obj.smallAmountThreshold)
      ..writeByte(6)
      ..write(obj.mediumAmountThreshold)
      ..writeByte(7)
      ..write(obj.smallAmountWaitHours)
      ..writeByte(8)
      ..write(obj.mediumAmountWaitDays)
      ..writeByte(9)
      ..write(obj.largeAmountWaitDays)
      ..writeByte(10)
      ..write(obj.useMinutesForSmallAmount)
      ..writeByte(11)
      ..write(obj.currentStreak)
      ..writeByte(12)
      ..write(obj.longestStreak)
      ..writeByte(13)
      ..write(obj.lastDecisionDate)
      ..writeByte(14)
      ..write(obj.monthlyBudget);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
