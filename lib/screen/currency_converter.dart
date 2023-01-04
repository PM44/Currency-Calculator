import 'package:currency_converter/block/currency_bloc.dart';
import 'package:currency_converter/core/consts/app_text_styles.dart';
import 'package:currency_converter/data/model/currency.dart';
import 'package:currency_converter/data/repositories/currency_repository.dart';
import 'package:currency_converter/screen/search_currency.dart';
import 'package:currency_converter/screen/widget/currency_tile.dart';
import 'package:currency_converter/screen/widget/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({Key? key}) : super(key: key);

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final _currencyBloc = CurrencyBloc(currencyRepository: CurrencyRepository());
  final _baseTextEditingController = TextEditingController();
  final _toTextEditingController = TextEditingController();
  List<String> operations = <String>[];
  List<TextEditingController> editController = <TextEditingController>[];
  List<Currency> selectedCurrency = <Currency>[];
  List<Currency> allCurrency = <Currency>[];
  Currency? outputCurrency;

  @override
  void initState() {
    editController.add(TextEditingController());
    operations.add("=");
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _currencyBloc.close();
    _baseTextEditingController.dispose();
    _toTextEditingController.dispose();
  }

  List<Widget> getTextFields() {
    List<Widget> widgets = <Widget>[];
    for (int i = 0; i < editController.length; i++) {
      widgets.add(CurrencyTextField(
        index: i,
        editingController: editController[i],
        callbak: (Currency currency, int index) {
          selectedCurrency.insert(index, currency);
        },
        itemRemoveCallback: (int index) {
          if (index != 0) {
            setState(() {
              selectedCurrency.removeAt(index);
              editController.removeAt(index);
              operations.removeAt(index);
            });
          }
        },
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _currencyBloc..add(const GetAllCurrency()),
        child: SafeArea(
          child: BlocBuilder<CurrencyBloc, CurrencyState>(
            bloc: _currencyBloc,
            builder: (context, state) {
              if (state is CurrencyInitialState) {
                BlocProvider.of<CurrencyBloc>(context)
                    .add(const GetAllCurrency());
              }
              if (state is CurrencyLoadingState) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (state is CurrencyFetchedState) {
                allCurrency.clear();
                allCurrency = state.allCurrency;
                if (selectedCurrency.isEmpty) {
                  selectedCurrency.add(state.allCurrency.first);
                }
                outputCurrency ??= state.allCurrency.first;
                return calculatorScreen();
              }
              if (state is CurrencyLoadedState) {
                return calculatorScreen();
              } else if (state is CurrencyFailedState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                ));
                return calculatorScreen();
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  void _showModalBottomSheet(bool isBaseCurrency) {
    showModalBottomSheet(
        clipBehavior: Clip.hardEdge,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        context: context,
        builder: (context) => BlocProvider.value(
              value: _currencyBloc,
              child: SearchCurrencyBottomSheet(
                isBaseCurrency: isBaseCurrency,
                allCurrency: _currencyBloc.currency,
                callbak: (Currency currency) {
                  setState(() {
                    outputCurrency = currency;
                  });
                },
              ),
            ));
  }

  Widget calculatorScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (editController.isNotEmpty)
            Column(
              children: getTextFields(),
            ),
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      editController.add(TextEditingController());
                      selectedCurrency.add(allCurrency.first);
                      operations.add('+');
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      editController.add(TextEditingController());
                      selectedCurrency.add(allCurrency.first);
                      operations.add('-');
                    });
                  },
                  icon: const Icon(
                    Icons.horizontal_rule,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      editController.add(TextEditingController());
                      selectedCurrency.add(allCurrency.first);
                      operations.add('*');
                    });
                  },
                  icon: const Icon(
                    Icons.clear,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      editController.add(TextEditingController());
                      selectedCurrency.add(allCurrency.first);
                      operations.add('/');
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                  ),
                )
              ],
            ),
          ),
          Row(
            children: [
              const SizedBox(
                width: 16,
              ),
              Text(
                "Output in",
                style: AppTextStyles.titleWhiteMedium
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 16,
              ),
              GestureDetector(
                  onTap: () {
                    _showModalBottomSheet(true);
                  },
                  child: CurrencyTile(
                      currency: outputCurrency != null
                          ? outputCurrency!
                          : allCurrency.isNotEmpty
                              ? allCurrency.first
                              : const Currency(
                                  currencyName: 'United Arab Emirates Dirham',
                                  currencyCode: 'AED'),
                      isHint: true)),
              const SizedBox(
                width: 100,
              ),
              TextButton(
                  onPressed: () {
                    int totalOutputCurrency = 0;
                    for (int i = 0; i < editController.length; i++) {
                      _currencyBloc.add(
                        ConvertCurrenciesEvent(
                            amount:
                                double.parse(editController.elementAt(i).text),
                            baseCurrency:
                                selectedCurrency.elementAt(i).currencyCode,
                            expression: operations.elementAt(i),
                            toCurrency: outputCurrency?.currencyCode ?? ''),
                      );

                      int convertedValue = 0;
                      totalOutputCurrency =
                          totalOutputCurrency + convertedValue;
                    }
                  },
                  child: Text(
                    "Calculate",
                    style: AppTextStyles.titleWhiteMedium.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ))
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Total Amount",
                style: AppTextStyles.titleWhiteMedium.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              Text(
                _currencyBloc.totalAmount.toString(),
                style: AppTextStyles.titleWhiteMedium.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          )
        ],
      ),
    );
  }
}
