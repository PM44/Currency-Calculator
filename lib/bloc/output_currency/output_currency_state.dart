part of 'output_currency_bloc.dart';

abstract class OutputCurrencyState {}

class OutputCurrencyInitial extends OutputCurrencyState {}

class OutputLoadedState extends OutputCurrencyState {
  final Currency selectedCurrency;

  OutputLoadedState(this.selectedCurrency);
}
