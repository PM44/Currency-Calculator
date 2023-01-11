import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:currency_converter/bloc/currency_bloc/currency_bloc.dart';
import 'package:currency_converter/bloc/output_currency/output_currency_bloc.dart';
import 'package:currency_converter/bloc/selected_currency/selected_currency_bloc.dart';
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
  Map _source = {ConnectivityResult.none: false};
  final MyConnectivity _connectivity = MyConnectivity.instance;
  bool isOffline = false;

  @override
  void initState() {
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _connectivity.disposeStream();
    _currencyBloc.close();
  }

  List<Widget> getTextFields(SelectedCurrencyBloc selectedCurrencyBloc) {
    List<Widget> widgets = <Widget>[];
    List<TextEditingController> textEditingController =
        selectedCurrencyBloc.editController;
    if (_currencyBloc.allCurrency.isNotEmpty) {
      for (int i = 0; i < textEditingController.length; i++) {
        widgets.add(Column(
          children: [
            if (i != 0)
              Center(
                child: Text(
                  selectedCurrencyBloc.operations[i],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            CurrencyTextField(
              index: i,
              editingController: selectedCurrencyBloc.editController[i],
              selected: selectedCurrencyBloc.editControllerCurrency[i],
              allCurrency: _currencyBloc.allCurrency,
              callbak: (Currency currency, int index) {
                selectedCurrencyBloc
                    .add(AddCurrencyIndexEvent(index, currency));
              },
              itemRemoveCallback: (int index) {
                if (index != 0) {
                  selectedCurrencyBloc.add(RemoveCurrencyEvent(index));
                }
              },
            ),
          ],
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
        child: BlocProvider(
          create: (context) => SelectedCurrencyBloc(),
          child: BlocProvider(
            create: (context) => OutputCurrencyBloc(),
            child: SafeArea(
              child: BlocConsumer<CurrencyBloc, CurrencyState>(
                listener: (context, state) {
                  if (state is CurrencyFetchedState) {
                    BlocProvider.of<SelectedCurrencyBloc>(context).add(
                        AddCurrencyEvent('=', _currencyBloc.allCurrency.first,
                            TextEditingController()));
                  }
                },
                builder: (context, state) {
                  if (state is CurrencyLoadingState) {
                    return Stack(children: [
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      if (state.isScreenShown!)
                        calculatorScreen(state, null,
                            BlocProvider.of<SelectedCurrencyBloc>(context))
                    ]);
                  }
                  if (state is CurrencyFetchedState) {
                    BlocProvider.of<OutputCurrencyBloc>(context)
                        .add(SetOutPutCurrency(state.allCurrency.first));
                    return calculatorScreen(state, null,
                        BlocProvider.of<SelectedCurrencyBloc>(context));
                  }
                  if (state is CurrencyLoadedState) {
                    return calculatorScreen(state, null,
                        BlocProvider.of<SelectedCurrencyBloc>(context));
                  } else if (state is CurrencyFailedState) {
                    return calculatorScreen(state, state.error,
                        BlocProvider.of<SelectedCurrencyBloc>(context));
                  }
                  return Container();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showModalBottomSheet(bool isBaseCurrency, OutputCurrencyBloc bloc) {
    showModalBottomSheet(
        clipBehavior: Clip.hardEdge,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        context: context,
        builder: (context) => BlocProvider.value(
              value: _currencyBloc,
              child: SearchCurrencyBottomSheet(
                isBaseCurrency: isBaseCurrency,
                allCurrency: _currencyBloc.allCurrency,
                callbak: (Currency currency) {
                  bloc.add(SetOutPutCurrency(currency));
                },
              ),
            ));
  }

  Widget calculatorScreen(CurrencyState currencyState, String? error,
      SelectedCurrencyBloc selectedCurrencyBloc) {
    return BlocConsumer<SelectedCurrencyBloc, SelectedCurrencyState>(
      listener: (context, state) {},
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
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
                  Icon(
                    CupertinoIcons.circle_fill,
                    color: !isOffline ? Colors.red : Colors.green,
                    size: 16,
                  )
                ],
              ),
              if (selectedCurrencyBloc.editController.isNotEmpty)
                Column(
                  children: getTextFields(selectedCurrencyBloc),
                ),
              Container(
                margin: const EdgeInsets.only(top: 16, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        selectedCurrencyBloc.add(AddCurrencyEvent(
                            '+',
                            _currencyBloc.allCurrency.first,
                            TextEditingController()));
                      },
                      icon: const Icon(
                        CupertinoIcons.add,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        selectedCurrencyBloc.add(AddCurrencyEvent(
                            '-',
                            _currencyBloc.allCurrency.first,
                            TextEditingController()));
                      },
                      icon: const Icon(
                        CupertinoIcons.minus,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        selectedCurrencyBloc.add(AddCurrencyEvent(
                            '*',
                            _currencyBloc.allCurrency.first,
                            TextEditingController()));
                      },
                      icon: const Icon(
                        CupertinoIcons.multiply,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        selectedCurrencyBloc.add(AddCurrencyEvent(
                            '/',
                            _currencyBloc.allCurrency.first,
                            TextEditingController()));
                      },
                      icon: const Icon(
                        CupertinoIcons.divide,
                      ),
                    )
                  ],
                ),
              ),
              BlocConsumer<OutputCurrencyBloc, OutputCurrencyState>(
                listener: (context, state) {},
                builder: (context, state) {
                  return Row(
                    children: [
                      const SizedBox(
                        width: 16,
                      ),
                      Text(
                        "Output in",
                        style: AppTextStyles.titleWhiteMedium.copyWith(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      state is OutputLoadedState
                          ? GestureDetector(
                              onTap: () {
                                _showModalBottomSheet(
                                    true,
                                    BlocProvider.of<OutputCurrencyBloc>(
                                        context));
                              },
                              child: CurrencyTile(
                                  currency: BlocProvider.of<OutputCurrencyBloc>(
                                          context)
                                      .selectedCurrency,
                                  isHint: true))
                          : Container(),
                      const SizedBox(
                        width: 100,
                      ),
                      state is OutputLoadedState
                          ? TextButton(
                              onPressed: () {
                                List<TextEditingController> editController =
                                    BlocProvider.of<SelectedCurrencyBloc>(
                                            context)
                                        .editController;

                                _currencyBloc.totalAmount = 0;
                                for (int i = 0;
                                    i < editController.length;
                                    i++) {
                                  if (editController[i].text.isNotEmpty &&
                                      double.parse(editController[i].text) >
                                          0.0) {
                                    _currencyBloc.add(
                                      ConvertCurrenciesEvent(
                                          amount: double.parse(
                                              editController.elementAt(i).text),
                                          baseCurrency: BlocProvider.of<
                                                  SelectedCurrencyBloc>(context)
                                              .editControllerCurrency[i]
                                              .currencyCode!,
                                          expression: BlocProvider.of<
                                                  SelectedCurrencyBloc>(context)
                                              .operations[i],
                                          isSingleValue:
                                              editController.length == 1,
                                          isFirstValue: i == 0,
                                          toCurrency: state.selectedCurrency
                                                  .currencyCode ??
                                              ''),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content:
                                          Text("Please select valid value"),
                                    ));
                                    break;
                                  }
                                }
                                _currencyBloc.add(CalculateCurrencyEvent(
                                    toCurrency:
                                        state.selectedCurrency.currencyCode ??
                                            ''));
                              },
                              child: Text(
                                "Calculate",
                                style: AppTextStyles.titleWhiteMedium.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              ))
                          : Container()
                    ],
                  );
                },
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
                    error != null && error.isNotEmpty
                        ? "0.0"
                        : _currencyBloc.totalAmount.toString(),
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
      },
    );
  }
}
