import 'package:currency_converter/data/model/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'selected_currency_event.dart';
part 'selected_currency_state.dart';

class SelectedCurrencyBloc
    extends Bloc<SelectedCurrencyEvent, SelectedCurrencyState> {
  List<String> operations = <String>[];
  List<TextEditingController> editController = <TextEditingController>[];
  List<Currency> editControllerCurrency = <Currency>[];
  SelectedCurrencyBloc() : super(SelectedCurrencyInitial()) {
    on<SelectedCurrencyEvent>((event, emit) {
      if (event is AddCurrencyEvent) {
        operations.add(event.operation);
        editController.add(event.textEditingController);
        editControllerCurrency.add(event.selectedCurrency);
        emit(SelectedCurrencyLoadedState());
      }
      if (event is RemoveCurrencyEvent) {
        operations.removeAt(event.index);
        editController.removeAt(event.index);
        editControllerCurrency.removeAt(event.index);
        emit(SelectedCurrencyLoadedState());
      }
      if (event is AddCurrencyIndexEvent) {
        editControllerCurrency.insert(event.index, event.currency);
        emit(SelectedCurrencyLoadedState());
      }
    });
  }
}
