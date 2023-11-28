import 'package:dinogrow/Models/connectDataClass.dart';
import 'package:dinogrow/Models/displayDataClass.dart';
import 'package:dinogrow/Models/score.dart';
import 'package:dinogrow/services/connect_data.dart';
import 'package:dinogrow/services/get_display_data.dart';
import 'package:dinogrow/services/get_scores.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  List<Score> items = [];
  bool loading = true;
  ConnectData connectData = ConnectData();
  DisplayData displayData = DisplayData();
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).go("/home");
        },
        backgroundColor: Colors.black.withOpacity(0.8),
        child: const Icon(
          Icons.arrow_back,
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: displayData.chainLogo,
                  ),
                  const Text("Top Scores",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: const Color.fromRGBO(241, 189, 57, 1),
                            width: 6),
                      ),
                      child: loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: getRanking,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  items.sort((a, b) => double.parse(b.score)
                                      .compareTo(double.parse(a.score)));

                                  final item = items[index];

                                  return ListTile(
                                    leading: Text('${index + 1}.',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    title: Text(
                                        '${item.address.substring(0, 5)}...${item.address.substring(item.address.toString().length - 5, item.address.length)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    trailing: Text(item.score,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                  );
                                },
                              ),
                            ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Future<void> getData() async {
    connectData = await getconnectdata();
    displayData = await getDisplayData(connectData);
    getRanking();
  }

  Future<void> getRanking() async {
    List<Score> items2save = [];

    setState(() {
      loading = true;
    });

    items2save = await getScores(connectData);

    setState(() {
      items = items2save;
    });

    setState(() {
      loading = false;
    });
  }
}
