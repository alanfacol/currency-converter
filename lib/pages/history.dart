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
  List<String> moneySymbol = ['USD', 'BRL', 'EUR', 'GBP', 'AUD', 'CAD', 'JPY'];
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
    DateTime dataAtual = DateTime.now();
    List<CurrencyData> currencies = [];
    try {
      for (int i = 0; i < 5; i++) {
        DateTime data = dataAtual.subtract(Duration(days: i));
        String dataFormatada = DateFormat('yyyy-MM-dd').format(data);

        CurrencyService currencyService = CurrencyService();
        currencies.add(await currencyService.fetchHistorialRates(
            symbols: moneySymbol, date: dataFormatada));
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

  void checkCurrencies() {}

  @override
  Widget build(BuildContext context) {
    String? currency1 = widget.currency1;
    String? currency2 = widget.currency2;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Histórico de cotação"),
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20.0, bottom: 20.00),
                child: Column(children: [
                  const Text(
                    'Últimos 5 dias das moedas selecionadas',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Text('$currency1 -> $currency2',
                      style:
                          const TextStyle(fontSize: 16.0, color: Colors.grey))
                ]),
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 125, 184, 86)),
                      )
                    : ListView.builder(
                        itemCount: rates?.length,
                        itemBuilder: (BuildContext context, int index) {
                          CurrencyData currencyData = rates!.elementAt(index);

                          int? timestamp =
                              int.tryParse(currencyData.timestamp.toString());
                          DateTime data = DateTime.fromMillisecondsSinceEpoch(
                              timestamp! * 1000);
                          String dataFormatada =
                              DateFormat('dd/MM/yyyy').format(data);

                          return ListTile(
                            title: Text(dataFormatada),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '1 $currency1 = ${((currencyData.rates[currency2] ?? 1.0) / (currencyData.rates[currency1] ?? 1.0)).toStringAsFixed(4)} $currency2'),
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
