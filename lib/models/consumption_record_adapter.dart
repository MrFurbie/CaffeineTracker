import 'package:hive/hive.dart';
import 'consumption_record.dart';

class ConsumptionRecordAdapter extends TypeAdapter<ConsumptionRecord> {
  @override
  final int typeId = 0;

  @override
  ConsumptionRecord read(BinaryReader reader) {
    return ConsumptionRecord(
      id: reader.readString(),
      drinkId: reader.readString(),
      servingSizeId: reader.readString(),
      timestamp: DateTime.parse(reader.readString()),
      caffeineAmount: reader.readInt(),
      notes: reader.readBool() ? reader.readString() : null,
    );
  }

  @override
  void write(BinaryWriter writer, ConsumptionRecord obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.drinkId);
    writer.writeString(obj.servingSizeId);
    writer.writeString(obj.timestamp.toIso8601String());
    writer.writeInt(obj.caffeineAmount);
    writer.writeBool(obj.notes != null);
    if (obj.notes != null) {
      writer.writeString(obj.notes!);
    }
  }
}