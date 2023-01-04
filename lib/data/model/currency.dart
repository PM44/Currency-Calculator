class Currency {
  final String currencyCode;
  final String currencyName;

  const Currency({
    required this.currencyName,
    required this.currencyCode,
  });

  List<Object?> get props => [
        currencyName,
        currencyCode,
      ];
}
