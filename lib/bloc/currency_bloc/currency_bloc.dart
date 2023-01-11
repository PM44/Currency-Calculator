import 'package:currency_converter/core/database_helper.dart';
import 'package:currency_converter/data/model/convert_response.dart';
import 'package:currency_converter/data/model/currency.dart';
import 'package:currency_converter/data/repositories/currency_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'currency_event.dart';
part 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyRepository currencyRepository;
  List<Currency> allCurrency = <Currency>[];
  num totalAmount = 0.0;
  DateTime fetchedTime = DateTime.now();

  CurrencyBloc({required this.currencyRepository})
      : super(CurrencyInitialState()) {
    on<GetAllCurrency>((event, emit) async {
      allCurrency = [];
      allCurrency = await DatabaseHelper.getCurrencyList();
      if (allCurrency.isEmpty ||
          (DateTime.now().difference(fetchedTime).inDays > 0)) {
        try {
          allCurrency.clear();
          emit(CurrencyLoadingState(false));
          List<Currency> response = await currencyRepository.getAllCurrencies();
          allCurrency.addAll(response);
          List<String> currencyCode =
              allCurrency.map((Currency e) => e.currencyCode!).toList();
          ConvertResponse convertResponse = await currencyRepository
              .convertCurrencies(baseCurrency: 'USD', toCurrency: currencyCode);
          fetchedTime = DateTime.parse(convertResponse.date!);
          for (int i = 0; i < allCurrency.length; i++) {
            allCurrency[i].conversionRate =
                convertResponse.rates![allCurrency[i].currencyCode];
          }
          allCurrency.removeWhere((element) => element.conversionRate == null);
          DatabaseHelper.insertCurrencyList(allCurrency);
          emit(CurrencyFetchedState(allCurrency));
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
          emit(CurrencyFailedState(error: e.toString()));
        }
      } else {
        emit(CurrencyLoadingState(false));
        if (allCurrency.isNotEmpty) {
          emit(CurrencyFetchedState(allCurrency));
        } else {
          emit(const CurrencyFailedState(
              error: "No Data Available, Check your internet connection"));
        }
      }
    });
    on<CalculateCurrencyEvent>(((event, emit) async {
      num? value = await DatabaseHelper.getConversionRate(event.toCurrency);
      if (value != null) {
        totalAmount = totalAmount * value;
        emit(CurrencyLoadedState(totalAmount));
      } else {
        emit(const CurrencyFailedState(
            error: "Conversion Is not possible due to rates"));
      }
    }));

    on<ConvertCurrenciesEvent>(((event, emit) async {
      try {
        num? value = await DatabaseHelper.getConversionRate(event.baseCurrency);
        if (value != null && !value.isNegative) {
          if (event.isSingleValue) {
            totalAmount = (event.amount / value);
          }
          if (event.isFirstValue) {
            totalAmount = (event.amount / value);
          } else {
            try {
              switch (event.expression) {
                case '+':
                  totalAmount = totalAmount + (event.amount / value);
                  break;
                case '-':
                  totalAmount = totalAmount - (event.amount / value);
                  break;
                case '*':
                  totalAmount = totalAmount * (event.amount);
                  break;
                case '/':
                  totalAmount = totalAmount / (event.amount);
                  break;
              }
            } catch (e) {
              emit(const CurrencyFailedState(
                  error: 'Arithmetic operation failed'));
            }
          }
        } else {
          emit(const CurrencyFailedState(
              error: "Conversion rate is not available"));
        }
      } catch (e) {
        emit(const CurrencyFailedState(
            error: 'Something went wrong :( \n Please try again'));
        rethrow;
      }
    }));
  }
}
