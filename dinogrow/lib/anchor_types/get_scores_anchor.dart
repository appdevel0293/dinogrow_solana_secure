import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:solana/solana.dart';

part 'get_scores_anchor.g.dart';

@BorshSerializable()
class GetScoresAnchor with _$GetScoresAnchor {
  factory GetScoresAnchor({
    @BU64() required BigInt deterministicId,
    @BU32() required int score,
    @BPublicKey() required Ed25519HDPublicKey address,
  }) = _GetScoresAnchor;

  const GetScoresAnchor._();

  factory GetScoresAnchor.fromBorsh(Uint8List data) =>
      _$GetScoresAnchorFromBorsh(data);
}
