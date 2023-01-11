part of 'selected_currency_bloc.dart';

@immutable
abstract class SelectedCurrencyEvent {}

class AddCurrencyEvent extends SelectedCurrencyEvent {
  final String operation;
  final Currency selectedCurrency;
  final TextEditingController textEditingController;
  AddCurrencyEvent(
      this.operation, this.selectedCurrency, this.textEditingController);
}

class RemoveCurrencyEvent extends SelectedCurrencyEvent {
  final int index;
  RemoveCurrencyEvent(this.index);
}

class AddCurrencyIndexEvent extends SelectedCurrencyEvent {
  final int index;
  final Currency currency;
  AddCurrencyIndexEvent(this.index, this.currency);
}
