import 'package:dinogrow/Models/connectDataClass.dart';
import 'package:dinogrow/anchor_types/save_score_anchor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:solana/anchor.dart';
import 'package:solana/base58.dart';
import 'package:solana/dto.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import 'package:solana_buffer/buffer.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:http/http.dart';

Future<dynamic> saveScore(ConnectData connectData, BigInt score) async {
  dynamic result;
  await dotenv.load(fileName: ".env");
  if (connectData.selectedChain == Chain.polygon) {
    final address = dotenv.env['POLYGON_CONTRACT_ADDRESS'].toString();
    final seed = dotenv.env['EVM_KEY'].toString();
    Uint8List seedBytes = hexToBytes(seed);
    print(seedBytes);
    result = await _saveScoreEvm(connectData, address, score, seedBytes);
    return result;
  } else if (connectData.selectedChain == Chain.bsc) {
    final address = dotenv.env['BSC_CONTRACT_ADDRESS'].toString();
    final seed = dotenv.env['EVM_KEY'].toString();
    Uint8List seedBytes = hexToBytes(seed);

    result = await _saveScoreEvm(connectData, address, score, seedBytes);
    return result;
  } else if (connectData.selectedChain == Chain.solana) {
    final address = dotenv.env['SOLANA_PROGRAM_ADDRESS'].toString();
    result = await _saveScoreSolana(connectData, score, address);
    return result;
  }
  return result;
}

Future<dynamic> _saveScoreEvm(ConnectData connectData, String address,
    BigInt score, Uint8List key) async {
  final contractAddress = web3.EthereumAddress.fromHex(address);
  final abi = await rootBundle.loadString('assets/abi.json');
  final contract = web3.DeployedContract(
      web3.ContractAbi.fromJson(abi, 'userScores'), contractAddress);
  final function = contract.function("saveScore");
  final httpClient = Client();
  final ethClient = web3.Web3Client(connectData.rpc!, httpClient);

  try {
    final gasPrice = await ethClient.getGasPrice();
    final chainId = await ethClient.getChainId();
    final result = await ethClient.sendTransaction(
      connectData.credEvm!,
      web3.Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [score, connectData.credEvm!.address, key],
        from: connectData.credEvm!.address,
        gasPrice: web3.EtherAmount.inWei(
          gasPrice.getInWei,
        ),
      ),
      chainId: chainId.toInt(),
    );
    final res = {"result": result, "error": false};
    return res;
  } catch (e) {
    final result = e.toString();
    final res = {"result": result, "error": true};
    return res;
  }
}

Future<dynamic> _saveScoreSolana(
    ConnectData connectData, BigInt score, String address) async {
  final systemProgramId =
      Ed25519HDPublicKey.fromBase58(SystemProgram.programId);
  String wsUrl = connectData.rpc!.replaceFirst('https', 'wss');
  final client = SolanaClient(
    rpcUrl: Uri.parse(connectData.rpc!),
    websocketUrl: Uri.parse(wsUrl),
  );
  final programIdPublicKey = Ed25519HDPublicKey.fromBase58(address);
  String solanaKeyStr = dotenv.env['SOLANA_SK'].toString();
  solanaKeyStr = solanaKeyStr.replaceAll(RegExp(r'\[|\]'), '');
  List<String> valueStrings = solanaKeyStr.split(',');
  List<int> integerList =
      (valueStrings).map((value) => int.parse(value)).toList();
  integerList = integerList.sublist(0, 32);
  Uint8List solanaSk = Uint8List.fromList(integerList);

  final pair = await Ed25519HDKeyPair.random();

  final privateKey =
      await pair.extract().then((value) => value.bytes).then(base58encode);

  final securityKey =
      await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: solanaSk);

  print(securityKey.address);

  final profilePda = await Ed25519HDPublicKey.findProgramAddress(
    seeds: [
      Buffer.fromString("random"),
      connectData.credSolana!.publicKey.bytes,
    ],
    programId: programIdPublicKey,
  );

  final result = await client.rpcClient
      .getAccountInfo(
        profilePda.toBase58(),
        commitment: Commitment.confirmed,
        encoding: Encoding.jsonParsed,
      )
      .value;

  String method;
  result == null ? method = "savescore" : method = "savescore";

  final saveScore =
      SaveScoreAnchor(score: score, user: connectData.credSolana!.publicKey);
  final serializedParameters = ByteArray(saveScore.toBorsh().toList());
  final instruction = await AnchorInstruction.forMethod(
    programId: programIdPublicKey,
    method: method,
    arguments: serializedParameters,
    accounts: <AccountMeta>[
      AccountMeta.writeable(pubKey: profilePda, isSigner: false),
      AccountMeta.writeable(
          pubKey: connectData.credSolana!.publicKey, isSigner: true),
      AccountMeta.readonly(pubKey: systemProgramId, isSigner: false),
      AccountMeta.writeable(pubKey: securityKey.publicKey, isSigner: true),
    ],
    namespace: 'global',
  );

  try {
    final message = Message(instructions: [instruction]);
    final signature = await client.sendAndConfirmTransaction(
      message: message,
      signers: [connectData.credSolana!, securityKey],
      commitment: Commitment.confirmed,
    );
    final res = {"result": signature, "error": false};
    return res;
  } catch (e) {
    final res = {"result": e.toString(), "error": true};
    return res;
  }
}
