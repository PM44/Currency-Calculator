import 'package:currency_converter/bloc/currency_bloc/currency_bloc.dart';
import 'package:currency_converter/core/consts/app_text_styles.dart';
import 'package:currency_converter/data/model/currency.dart';
import 'package:currency_converter/screen/search_currency.dart';
import 'package:currency_converter/screen/widget/currency_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyTextField extends StatefulWidget {
  const CurrencyTextField(
      {super.key,
      required this.editingController,
      required this.index,
      required this.allCurrency,
      required this.callbak,
      required this.itemRemoveCallback,
      this.selected});

  final TextEditingController editingController;
  final int index;
  final List<Currency> allCurrency;
  final Currency? selected;
  final void Function(Currency, int) callbak;
  final void Function(int) itemRemoveCallback;

  @override
  State<CurrencyTextField> createState() => _CurrencyTextFieldState();
}

class _CurrencyTextFieldState extends State<CurrencyTextField> {
  late CurrencyBloc _currencyBloc;

  Currency? selectedCurrency;

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
                allCurrency: _currencyBloc.allCurrency,
                callbak: (Currency currency) {
                  widget.callbak(currency, widget.index);
                  setState(() {
                    selectedCurrency = currency;
                  });
                },
              ),
            ));
  }

  @override
  void initState() {
    _currencyBloc = BlocProvider.of<CurrencyBloc>(context);
    if (widget.selected != null) {
      selectedCurrency = widget.selected;
    } else if (_currencyBloc.allCurrency.isNotEmpty) {
      selectedCurrency = _currencyBloc.allCurrency.first;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        border: Border.all(width: 1.0, color: Colors.black),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 0,
            child: GestureDetector(
                onTap: () => _showModalBottomSheet(true),
                child: CurrencyTile(
                  currency: selectedCurrency ??
                      widget.selected ??
                      widget.allCurrency.first,
                  isHint: true,
                )),
          ),
          Expanded(
              flex: 1,
              child: TextField(
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.titleWhiteBig.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: .0, horizontal: 10.0),
                  ),
                  readOnly: false,
                  controller: widget.editingController)),
          IconButton(
              onPressed: () {
                widget.itemRemoveCallback(widget.index);
              },
              icon: const Icon(
                Icons.close,
              ))
        ],
      ),
    );
  }
}
