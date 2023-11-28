import 'package:dinogrow/Models/connectDataClass.dart';
import 'package:dinogrow/Models/score.dart';
import 'package:dinogrow/anchor_types/get_scores_anchor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:http/http.dart';

Future<List<Score>> getScores(ConnectData connectData) async {
  List<Score> result = [];
  await dotenv.load(fileName: ".env");
  if (connectData.selectedChain == Chain.polygon) {
    final address = dotenv.env['POLYGON_CONTRACT_ADDRESS'].toString();
    final contractAddress = web3.EthereumAddress.fromHex(address);
    result = await _getScoresEvm(
        connectData.rpc!, contractAddress, connectData.credEvm!);
  } else if (connectData.selectedChain == Chain.bsc) {
    final address = dotenv.env['BSC_CONTRACT_ADDRESS'].toString();
    final contractAddress = web3.EthereumAddress.fromHex(address);
    result = await _getScoresEvm(
        connectData.rpc!, contractAddress, connectData.credEvm!);
  } else if (connectData.selectedChain == Chain.solana) {
    result = await _getScoresSolana(connectData.rpc!);
  }
  return result;
}

Future<List<Score>> _getScoresEvm(String rpc,
    web3.EthereumAddress contractAddress, web3.Credentials credentials) async {
  final abi = await rootBundle.loadString('assets/abi.json');
  final contract = web3.DeployedContract(
      web3.ContractAbi.fromJson(abi, 'userScores'), contractAddress);
  final function = contract.function("getScores");
  final httpClient = Client();
  final ethClient = web3.Web3Client(rpc, httpClient);
  final result =
      await ethClient.call(contract: contract, function: function, params: []);

  if (result.isNotEmpty) {
    List<dynamic> addresses = result[0].map((item) => item.toString()).toList();
    List<dynamic> scores = result[1].map((item) => item.toString()).toList();
    List<Score> scoreList = List.generate(addresses.length, (index) {
      return Score(
          score: scores[index].toString(),
          address: addresses[index].toString());
    });
    return scoreList;
  } else {
    return [];
  }
}

Future<List<Score>> _getScoresSolana(String rpc) async {
  List<Score> scoreList = [];
  String wsUrl = rpc.replaceFirst('https', 'wss');
  final client = SolanaClient(
    rpcUrl: Uri.parse(rpc!),
    websocketUrl: Uri.parse(wsUrl),
  );
  await dotenv.load(fileName: ".env");
  final address = dotenv.env['SOLANA_PROGRAM_ADDRESS'].toString();
  final accounts = await client.rpcClient.getProgramAccounts(
    address,
    encoding: Encoding.base64,
  );
  for (var account in accounts) {
    try {
      final bytes = account.account.data as BinaryAccountData;
      final decodedData = GetScoresAnchor.fromBorsh(bytes.data as Uint8List);
      Score item = Score(address: '', score: '');
      item.address = decodedData.address.toString();
      item.score = decodedData.score.toString();
      scoreList.add(item);
    } catch (e) {
      print(e);
    }
  }
  return scoreList;
}
