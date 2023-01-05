part of 'currency_bloc.dart';

abstract class CurrencyState {
  const CurrencyState();
  List<Object> get props => [];
}

class CurrencyInitialState extends CurrencyState {}

class CurrencyLoadingState extends CurrencyState {
  bool? isScreenShown=false;
  CurrencyLoadingState(this.isScreenShown);
}

class CurrencyFetchedState extends CurrencyState {
  final List<Currency> allCurrency;
  const CurrencyFetchedState(this.allCurrency);
}

class CurrencyLoadedState extends CurrencyState {
  final ConvertResponse currencyPairModel;
  const CurrencyLoadedState(this.currencyPairModel);

  @override
  List<Object> get props => [currencyPairModel];

  Map<String, dynamic> toJson() {
    return {'value': currencyPairModel.toJson()};
  }

  factory CurrencyLoadedState.fromJson(Map<String, dynamic> json) {
    return CurrencyLoadedState(ConvertResponse.fromJson(json['value']));
  }
}

class CurrencyFailedState extends CurrencyState {
  final String error;
  const CurrencyFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
