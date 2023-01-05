import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:currency_converter/core/database_helper.dart';
import 'package:currency_converter/data/model/convert_response.dart';
import 'package:currency_converter/data/model/currency.dart';
import 'package:currency_converter/data/repositories/currency_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
part 'currency_event.dart';
part 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState>
    with HydratedMixin {
  final CurrencyRepository currencyRepository;
  List<Currency> currency = <Currency>[];
  num totalAmount = 0.0;
  final Connectivity _connectivity = Connectivity();

  CurrencyBloc({required this.currencyRepository})
      : super(CurrencyInitialState()) {
    on<GetAllCurrency>((event, emit) async {
      var connectivityResult=await _connectivity.checkConnectivity();
      if(connectivityResult == ConnectivityResult.mobile||connectivityResult == ConnectivityResult.wifi||currency.isEmpty)
      {
        try {
          currency.clear();
          emit(CurrencyLoadingState(false));
          List<Currency> response = await currencyRepository.getAllCurrencies();
          currency.addAll(response);
          DatabaseHelper.insertCurrencyList(currency);
          emit(CurrencyFetchedState(currency));
        } catch (e) {
          emit(CurrencyFailedState(error: e.toString()));
        }
      } else {
        emit(CurrencyLoadingState(false));
        currency.addAll(await DatabaseHelper.getCurrencyList());
        emit(CurrencyFetchedState(currency));
      }
    });
    on<ConvertCurrenciesEvent>(((event, emit) async {
      try {
        emit(CurrencyLoadingState(true));
        ConvertResponse currencyPair =
            await currencyRepository.convertCurrencies(
          baseCurrency: event.baseCurrency,
          toCurrency: event.toCurrency,
          amount: event.amount,
        );
        if(currencyPair.success!){
        if(event.isSingleValue){
          totalAmount=currencyPair.result!;
          emit(CurrencyLoadedState(currencyPair));
        }
        if(event.isFirstValue){
          totalAmount=currencyPair.result!;
        }
        else {
          try {
            switch (event.expression) {
              case '+':
                totalAmount = totalAmount + currencyPair.result!;
                break;
              case '-':
                totalAmount = totalAmount - currencyPair.result!;
                break;
              case '*':
                totalAmount = totalAmount * currencyPair.result!;
                break;
              case '/':
                totalAmount = totalAmount / currencyPair.result!;
                break;
            }
          } catch (e) {
            emit(const CurrencyFailedState(
                error: 'Arithmetic operation failed'));
          }
          emit(CurrencyLoadedState(currencyPair));
        }
        }else{
          emit( CurrencyFailedState(
              error: currencyPair.message!));
        }
      } catch (e) {
        emit(const CurrencyFailedState(
            error: 'Something went wrong :( \n Please try again'));
        rethrow;
      }
    }));
  }

  @override
  CurrencyState? fromJson(Map<String, dynamic> json) {
    return CurrencyLoadedState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(CurrencyState state) {
    if (state is CurrencyLoadedState) {
      return state.toJson();
    }
    return null;
  }
}
