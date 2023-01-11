part of 'output_currency_bloc.dart';

abstract class OutputCurrencyEvent {}

class SetOutPutCurrency extends OutputCurrencyEvent {
  final Currency selectedCurrency;
  SetOutPutCurrency(this.selectedCurrency);
}
