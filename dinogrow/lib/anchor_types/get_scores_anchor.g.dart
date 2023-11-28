// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_scores_anchor.dart';

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$GetScoresAnchor {
  BigInt get deterministicId => throw UnimplementedError();
  int get score => throw UnimplementedError();
  Ed25519HDPublicKey get address => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BU64().write(writer, deterministicId);
    const BU32().write(writer, score);
    const BPublicKey().write(writer, address);

    return writer.toArray();
  }
}

class _GetScoresAnchor extends GetScoresAnchor {
  _GetScoresAnchor({
    required this.deterministicId,
    required this.score,
    required this.address,
  }) : super._();

  final BigInt deterministicId;
  final int score;
  final Ed25519HDPublicKey address;
}

class BGetScoresAnchor implements BType<GetScoresAnchor> {
  const BGetScoresAnchor();

  @override
  void write(BinaryWriter writer, GetScoresAnchor value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  GetScoresAnchor read(BinaryReader reader) {
    return GetScoresAnchor(
      deterministicId: const BU64().read(reader),
      score: const BU32().read(reader),
      address: const BPublicKey().read(reader),
    );
  }
}

GetScoresAnchor _$GetScoresAnchorFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BGetScoresAnchor().read(reader);
}
