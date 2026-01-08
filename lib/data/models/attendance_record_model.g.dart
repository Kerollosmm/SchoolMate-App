// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceRecordModelAdapter extends TypeAdapter<AttendanceRecordModel> {
  @override
  final int typeId = 2;

  @override
  AttendanceRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceRecordModel(
      id: fields[0] as String,
      studentId: fields[1] as String,
      date: fields[2] as DateTime,
      statusString: fields[3] as String,
      markedByUserId: fields[4] as String,
      markedAt: fields[5] as DateTime,
      syncStatusString: fields[6] as String,
      conflictId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceRecordModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.statusString)
      ..writeByte(4)
      ..write(obj.markedByUserId)
      ..writeByte(5)
      ..write(obj.markedAt)
      ..writeByte(6)
      ..write(obj.syncStatusString)
      ..writeByte(7)
      ..write(obj.conflictId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
