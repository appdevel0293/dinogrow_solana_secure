// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"inputs":[{"internalType":"uint256","name":"score","type":"uint256"},{"internalType":"uint256","name":"timestamp","type":"uint256"}],"name":"saveScore","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"scores","outputs":[{"internalType":"uint256","name":"score","type":"uint256"},{"internalType":"uint256","name":"timestamp","type":"uint256"}],"stateMutability":"view","type":"function"}]',
  'Chuo',
);

class Chuo extends _i1.GeneratedContract {
  Chuo({
    required _i1.EthereumAddress address,
    required _i1.Web3Client client,
    int? chainId,
  }) : super(
          _i1.DeployedContract(
            _contractAbi,
            address,
          ),
          client,
          chainId,
        );

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> saveScore(
    BigInt score,
    BigInt timestamp, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, 'b038a192'));
    final params = [
      score,
      timestamp,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<Scores> scores(
    _i1.EthereumAddress $param2, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, '76dd110f'));
    final params = [$param2];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return Scores(response);
  }
}

class Scores {
  Scores(List<dynamic> response)
      : score = (response[0] as BigInt),
        timestamp = (response[1] as BigInt);

  final BigInt score;

  final BigInt timestamp;
}
