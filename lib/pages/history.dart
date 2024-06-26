import 'package:currency_converter/http/request.dart';
import 'package:currency_converter/model/currency.model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  final String? currency1;
  final String? currency2;

  // ignore: use_super_parameters
  const History({
    super.key,
    required this.currency1,
    required this.currency2,
  });

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<CurrencyData>? rates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistoricalRates();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadHistoricalRates() async {
    DateTime now = DateTime.now();
    List<CurrencyData> currencies = [];
    try {
      for (int i = 0; i <= 5; i++) {
        DateTime date = now.subtract(Duration(days: i));
        String formattedDate = DateFormat('yyyy-MM-dd').format(date);

        CurrencyService currencyService = CurrencyService();
        currencies.add(await currencyService.fetchHistorialRates(
            codes: [widget.currency1!, widget.currency2!],
            date: formattedDate));
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
    setState(() {
      rates?.addAll(currencies);
      isLoading = false;
    });
  }

  double getPercentage(List<CurrencyData> currencies, int index,
      String currency1, String currency2) {
    if (index < currencies.length - 1) {
      double percent = (((currencies[index].rates[currency2] ?? 1.0) /
              (currencies[index].rates[currency1] ?? 1.0)) /
          ((currencies[index + 1].rates[currency2] ?? 1.0) /
              (currencies[index + 1].rates[currency1] ?? 1.0)));
      return (percent - 1) * 100;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? currency1 = widget.currency1;
    String? currency2 = widget.currency2;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(
            "Histórico de cotação",
            textAlign: TextAlign.center,
          ),
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20.0, bottom: 20.00),
                child: Column(children: [
                  const Text(
                    'Últimos 5 dias',
                    style: TextStyle(fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                  Text('$currency1 -> $currency2',
                      style:
                          const TextStyle(fontSize: 16.0, color: Colors.grey))
                ]),
              ),
              Expanded(
                child: isLoading
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            CircularProgressIndicator(
                                color: Color.fromARGB(255, 125, 184, 86)),
                            SizedBox(height: 10.0),
                            Text(
                              "Carregando dados",
                            ),
                          ])
                    : ListView.builder(
                        itemCount: rates!.length - 1,
                        itemBuilder: (BuildContext context, int index) {
                          CurrencyData currencyData = rates!.elementAt(index);
                          double percentage = getPercentage(
                              rates!, index, currency1!, currency2!);

                          int? timestamp =
                              int.tryParse(currencyData.timestamp.toString());
                          DateTime data = DateTime.fromMillisecondsSinceEpoch(
                              timestamp! * 1000);
                          String dataFormatada =
                              DateFormat('dd/MM/yyyy').format(data);

                          return ListTile(
                            title: Text(dataFormatada),
                            subtitle: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '1 $currency1 = ${((currencyData.rates[currency2] ?? 1.0) / (currencyData.rates[currency1] ?? 1.0)).toStringAsFixed(4)} $currency2'),
                                const SizedBox(width: 5.0),
                                percentage > 0
                                    ? const Icon(
                                        Icons.arrow_upward,
                                        size: 20,
                                        color: Colors.green,
                                      )
                                    : percentage == 0
                                        ? const Icon(
                                            Icons.linear_scale,
                                            size: 20,
                                          )
                                        : const Icon(
                                            Icons.arrow_downward,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                const SizedBox(width: 5.0),
                                Text('${percentage.toStringAsFixed(3)}%')
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ));
  }
}
