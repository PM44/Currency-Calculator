import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:currency_converter/block/currency_bloc.dart';
import 'package:currency_converter/core/connection_Status.dart';
import 'package:currency_converter/core/consts/app_text_styles.dart';
import 'package:currency_converter/data/model/currency.dart';
import 'package:currency_converter/data/repositories/currency_repository.dart';
import 'package:currency_converter/screen/search_currency.dart';
import 'package:currency_converter/screen/widget/currency_tile.dart';
import 'package:currency_converter/screen/widget/text_field.dart';
import 'package:flutter/cupertino.dart';
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
  Map _source = {ConnectivityResult.none: false};
  final MyConnectivity _connectivity = MyConnectivity.instance;

  bool isOffline = false;

  @override
  void initState() {
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
    });
    editController.add(TextEditingController());
    operations.add("=");
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _connectivity.disposeStream();
    _currencyBloc.close();
    _baseTextEditingController.dispose();
    _toTextEditingController.dispose();
  }

  List<Widget> getTextFields() {
    List<Widget> widgets = <Widget>[];
    if (allCurrency.isNotEmpty) {
      for (int i = 0; i < editController.length; i++) {
        widgets.add(CurrencyTextField(
          index: i,
          editingController: editController[i],
          allCurrency: allCurrency,
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
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_source.keys.toList()[0]) {
      case ConnectivityResult.mobile:
        isOffline = true;
        break;
      case ConnectivityResult.wifi:
        isOffline = true;
        break;
      case ConnectivityResult.none:
      default:
        isOffline = false;
    }
    return Scaffold(
      body: BlocProvider(
        create: (context) => _currencyBloc..add(const GetAllCurrency()),
        child: SafeArea(
          child: BlocConsumer<CurrencyBloc, CurrencyState>(
            listener: (context, state) {

            },
            builder: (context, state) {
              print(state);
              if (state is CurrencyLoadingState) {
                return Stack(
                  children:[ const Center(
                    child: CircularProgressIndicator(),
                  ),
                    if(state.isScreenShown!)
                    calculatorScreen(state, null)
                  ]
                );
              }
              if (state is CurrencyFetchedState) {
                allCurrency = _currencyBloc.currency;
                if (selectedCurrency.isEmpty) {
                  selectedCurrency.add(state.allCurrency.first);
                }
                outputCurrency ??= state.allCurrency.first;
                return calculatorScreen(state,null);
              }
              if (state is CurrencyLoadedState) {
                return calculatorScreen(state,null);
              } else if (state is CurrencyFailedState) {
                return calculatorScreen(state,state.error);
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

  Widget calculatorScreen(CurrencyState currencyState,String? error) {
    return SingleChildScrollView(
      child:
          Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    !isOffline ? "Offline" : "Online",
                    style: const TextStyle(color: Colors.black),
                  ),
                  Icon(CupertinoIcons.circle_fill,color: !isOffline ?Colors.red:Colors.green,size: 16,)
                ],
              ),

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
                        CupertinoIcons.add,
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
                        CupertinoIcons.minus,
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
                        CupertinoIcons.multiply,
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
                        CupertinoIcons.divide,
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
                              : Currency(
                              currencyName: 'United Arab Emirates Dirham',
                              currencyCode: 'AED'),
                          isHint: true)),
                  const SizedBox(
                    width: 100,
                  ),
                  TextButton(
                      onPressed: () {
                        int totalOutputCurrency = 0;
                        _currencyBloc.totalAmount=1.0;
                        for (int i = 0; i < editController.length; i++) {
                          if (editController[i].text != null &&
                              editController[i].text.isNotEmpty &&
                              double.parse(editController[i].text) > 0.0) {
                            _currencyBloc.add(
                              ConvertCurrenciesEvent(
                                  amount: double.parse(
                                      editController.elementAt(i).text),
                                  baseCurrency:
                                  selectedCurrency.elementAt(i).currencyCode!,
                                  expression: operations.elementAt(i),
                                  isSingleValue: editController.length==1,
                                  isFirstValue: i==0,
                                  toCurrency: outputCurrency?.currencyCode ?? ''),
                            );
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Please select valid value"),
                            ));
                            break;
                          }

                          int convertedValue = 0;
                          totalOutputCurrency =
                              totalOutputCurrency + convertedValue;
                        }
                      },
                      child:Text(
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
              ),

              if (error != null && error.isNotEmpty)
                const SizedBox(
                  height: 16,
                ),
              if (error != null && error.isNotEmpty) Text("Error: $error"),
            ],
          ),


    );
  }
}
