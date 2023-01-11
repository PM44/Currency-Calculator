part of 'currency_bloc.dart';

abstract class CurrencyState {
  const CurrencyState();
}

class CurrencyInitialState extends CurrencyState {}

class CurrencyLoadingState extends CurrencyState {
  bool? isScreenShown = false;
  CurrencyLoadingState(this.isScreenShown);
}

class CurrencyFetchedState extends CurrencyState {
  final List<Currency> allCurrency;
  const CurrencyFetchedState(this.allCurrency);
}

class CurrencyLoadedState extends CurrencyState {
  num totalAmount;
  CurrencyLoadedState(this.totalAmount);
}

class CurrencyFailedState extends CurrencyState {
  final String error;
  const CurrencyFailedState({required this.error});
}
