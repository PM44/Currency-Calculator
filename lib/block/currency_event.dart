part of 'currency_bloc.dart';

abstract class CurrencyEvent {
  const CurrencyEvent();
}

class ConvertCurrenciesEvent extends CurrencyEvent {
  final String baseCurrency;
  final String toCurrency;
  final double amount;
  final String expression;

  const ConvertCurrenciesEvent({
    required this.amount,
    required this.baseCurrency,
    required this.toCurrency,
    required this.expression,
  });

  List<Object> get props => [baseCurrency, toCurrency, amount, expression];
}

class GetAllCurrency extends CurrencyEvent {
  const GetAllCurrency();
  List<Object> get props => [];
}
