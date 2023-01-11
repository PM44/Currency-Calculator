part of 'selected_currency_bloc.dart';

@immutable
abstract class SelectedCurrencyState {}

class SelectedCurrencyInitial extends SelectedCurrencyState {}

class SelectedCurrencyLoadedState extends SelectedCurrencyState {
  SelectedCurrencyLoadedState();
}
