class NumberToWord {
  String convert(double number) {
    if (number == 0) return 'Zero Naira Only';
    
    final int whole = number.floor();
    final int decimal = ((number - whole) * 100).round();
    
    String result = _convertWhole(whole);
    if (decimal > 0) {
      result += ' and ${_convertWhole(decimal)} Kobo';
    }
    
    return '$result Naira Only';
  }

  String _convertWhole(int number) {
    if (number == 0) return '';
    
    final List<String> units = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
      'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    final List<String> tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
    
    if (number < 20) return units[number];
    if (number < 100) return '${tens[number ~/ 10]} ${units[number % 10]}'.trim();
    if (number < 1000) return '${units[number ~/ 100]} Hundred ${_convertWhole(number % 100)}'.trim();
    if (number < 1000000) return '${_convertWhole(number ~/ 1000)} Thousand ${_convertWhole(number % 1000)}'.trim();
    return '${_convertWhole(number ~/ 1000000)} Million ${_convertWhole(number % 1000000)}'.trim();
  }
} 