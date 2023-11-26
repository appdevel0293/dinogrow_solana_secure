import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart' as web3;

Future<String> loadAbi() async {
  final abi = await rootBundle.loadString('assets/abi.json');

  return abi; // Replace with your ABI file path
}
