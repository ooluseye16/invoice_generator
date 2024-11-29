// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_field.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceFormFieldAdapter extends TypeAdapter<InvoiceFormField> {
  @override
  final int typeId = 1;

  @override
  InvoiceFormField read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceFormField(
      name: fields[0] as String,
      type: fields[1] as FormFieldType,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceFormField obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceFormFieldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FormFieldTypeAdapter extends TypeAdapter<FormFieldType> {
  @override
  final int typeId = 2;

  @override
  FormFieldType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FormFieldType.text;
      case 1:
        return FormFieldType.number;
      case 2:
        return FormFieldType.phone;
      case 3:
        return FormFieldType.date;
      case 4:
        return FormFieldType.email;
      case 5:
        return FormFieldType.listOfGoods;
      case 6:
        return FormFieldType.price;
      default:
        return FormFieldType.text;
    }
  }

  @override
  void write(BinaryWriter writer, FormFieldType obj) {
    switch (obj) {
      case FormFieldType.text:
        writer.writeByte(0);
        break;
      case FormFieldType.number:
        writer.writeByte(1);
        break;
      case FormFieldType.phone:
        writer.writeByte(2);
        break;
      case FormFieldType.date:
        writer.writeByte(3);
        break;
      case FormFieldType.email:
        writer.writeByte(4);
        break;
      case FormFieldType.listOfGoods:
        writer.writeByte(5);
        break;
      case FormFieldType.price:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormFieldTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
