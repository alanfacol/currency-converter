import 'dart:ui';

import 'package:currency_converter/http/request.dart';
import 'package:currency_converter/model/currency.model.dart';
import 'package:currency_converter/pages/history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> moneySymbol = ['USD', 'BRL', 'EUR', 'GBP', 'AUD', 'CAD', 'JPY'];
  String? selectedCurrency1 = 'USD';
  String? selectedCurrency2 = 'BRL';
  Map<String, String> currencies = {};
  CurrencyData? rates;

  TextEditingController firstTextFieldController = TextEditingController();
  TextEditingController secondTextFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCurrencies();
    loadRates();
    firstTextFieldController.addListener(updateSecondTextField);
  }

  @override
  void dispose() {
    firstTextFieldController.removeListener(updateSecondTextField);
    firstTextFieldController.dispose();
    secondTextFieldController.dispose();
    super.dispose();
  }

  void updateSecondTextField() {
    if (firstTextFieldController.text.isEmpty) {
      setState(() {
        secondTextFieldController.text = '';
      });
    } else {
      double value = double.tryParse(firstTextFieldController.text) ?? 0.0;
      double toDollar = value / (rates?.rates[selectedCurrency1] ?? 1.0);
      double newValue = toDollar * (rates?.rates[selectedCurrency2] ?? 1.0);
      setState(() {
        secondTextFieldController.text = newValue.toStringAsFixed(2);
      });
    }
  }

  void loadCurrencies() async {
    try {
      CurrencyService currencyService = CurrencyService();
      Map<String, String> loadedCurrencies =
          await currencyService.fetchCurrencies(allowedTypes: moneySymbol);
      setState(() {
        currencies = loadedCurrencies;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void loadRates() async {
    try {
      CurrencyService currencyService = CurrencyService();
      CurrencyData loadedCurrencies =
          await currencyService.fetchRates(symbols: moneySymbol);
      setState(() {
        rates = loadedCurrencies;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  String formatTimestamp() {
    try {
      int? timestamp = int.tryParse(rates?.timestamp.toString() ?? '');
      DateTime data = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
      return DateFormat('dd/MM/yyyy').format(data);
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
          color: const Color.fromARGB(100, 218, 218, 218),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
                child: SingleChildScrollView(
                    child: Column(children: [
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: const Column(children: [
                  Text(
                    'Faça suas conversões em tempo real',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Text('Veja a cotação de cada moeda nesse exato momento',
                      style: TextStyle(fontSize: 14.0, color: Colors.grey))
                ]),
              ),
              Container(
                padding: const EdgeInsets.all(40.0),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: const Color.fromARGB(197, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1), // Cor da sombra
                        spreadRadius: 0.1,
                        blurRadius: 10,
                        offset: const Offset(10, 10),
                      ),
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Converter"),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                              value: selectedCurrency1,
                              isExpanded: true,
                              isDense: false,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedCurrency1 = newValue;
                                });
                                updateSecondTextField();
                              },
                              items: currencies.entries
                                  .map<DropdownMenuItem<String>>(
                                      (MapEntry<String, String> value) {
                                return DropdownMenuItem<String>(
                                  value: value.key,
                                  child: Text('${value.value} (${value.key})',
                                      style: const TextStyle(fontSize: 14.0)),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 15.0),
                                  border: InputBorder.none),
                              icon: const Icon(
                                  Icons.arrow_drop_down_circle_outlined)),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: TextField(
                            controller: firstTextFieldController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Digite o valor',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                            onChanged: (value) {
                              updateSecondTextField();
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(children: [
                      Expanded(
                          child: Column(children: [
                        TextButton(
                          onPressed: () {
                            String? temp = selectedCurrency1;
                            setState(() {
                              selectedCurrency1 = selectedCurrency2;
                              selectedCurrency2 = temp;
                              updateSecondTextField();
                            });
                          },
                          child: const Icon(Icons.currency_exchange),
                        )
                      ]))
                    ]),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                              value: selectedCurrency2,
                              isExpanded: true,
                              isDense: false,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedCurrency2 = newValue;
                                });
                                updateSecondTextField();
                              },
                              items: currencies.entries
                                  .map<DropdownMenuItem<String>>(
                                      (MapEntry<String, String> value) {
                                return DropdownMenuItem<String>(
                                  value: value.key,
                                  child: Text('${value.value} (${value.key})',
                                      style: const TextStyle(fontSize: 14.0)),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 15.0),
                                  border: InputBorder.none),
                              icon: const Icon(
                                  Icons.arrow_drop_down_circle_outlined)),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: TextField(
                            controller: secondTextFieldController,
                            keyboardType: TextInputType.number,
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: 'Resultado',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Indicador de conversão (${formatTimestamp()})",
                        style: const TextStyle(
                            fontSize: 14.0, color: Colors.grey)),
                    Row(
                      children: [
                        Text(
                            "1 $selectedCurrency1 = ${((rates?.rates[selectedCurrency2] ?? 1.0) / (rates?.rates[selectedCurrency1] ?? 1.0)).toStringAsFixed(3)} $selectedCurrency2",
                            style: const TextStyle(fontSize: 16.0))
                      ],
                    )
                  ],
                ),
              )
            ])))
          ])),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => History(
                    currency1: selectedCurrency1,
                    currency2: selectedCurrency2)),
          );
        },
        child: const Icon(Icons.history),
      ),
    );
  }
}
