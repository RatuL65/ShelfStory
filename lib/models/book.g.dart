// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 0;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      id: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      genre: fields[3] as String,
      price: fields[4] as double?,
      datePurchased: fields[5] as DateTime,
      coverImagePath: fields[6] as String?,
      readingStatus: fields[7] as String,
      storyRating: fields[8] as double?,
      characterRating: fields[9] as double?,
      writingStyleRating: fields[10] as double?,
      emotionalImpactRating: fields[11] as double?,
      notes: fields[12] as String?,
      totalPages: fields[13] as int?,
      currentPage: fields[14] as int?,
      dateStarted: fields[15] as DateTime?,
      dateFinished: fields[16] as DateTime?,
      isbn: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.genre)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.datePurchased)
      ..writeByte(6)
      ..write(obj.coverImagePath)
      ..writeByte(7)
      ..write(obj.readingStatus)
      ..writeByte(8)
      ..write(obj.storyRating)
      ..writeByte(9)
      ..write(obj.characterRating)
      ..writeByte(10)
      ..write(obj.writingStyleRating)
      ..writeByte(11)
      ..write(obj.emotionalImpactRating)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.totalPages)
      ..writeByte(14)
      ..write(obj.currentPage)
      ..writeByte(15)
      ..write(obj.dateStarted)
      ..writeByte(16)
      ..write(obj.dateFinished)
      ..writeByte(17)
      ..write(obj.isbn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
