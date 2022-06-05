import 'dart:collection';

import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_transaction.dart';
import 'package:flutwest/model/vars.dart';

class TransactionFilter {
  static const String allTypes = AccountTransaction.allTypes;
  static const List<String> types = AccountTransaction.types;

  static const String anyAmount = "Any amount";
  static const String otherAmount = "Other";

  static const Map<String, List<double?>> amounts = {
    anyAmount: [null, null],
    "Under \$20": [null, 20],
    "\$20 - \$50": [20, 50],
    "\$50 - \$100": [50, 100],
    "\$100 - \$250": [100, 250],
    "\$250 - \$500": [250, 500],
    "\$500 - \$1000": [500, 1000],
    "Over \$1000": [1000, null],
    otherAmount: [],
  };

  static const String anyDate = "Any date";
  static const String otherDate = "Other";

  static final DateTime now = DateTime.now();

  static final Map<String, List<DateTime?>> dates = {
    anyDate: [null, null],
    "Past 7 days": [DateTime(now.year, now.month, now.day - 7), now],
    "Past 14 days": [DateTime(now.year, now.month, now.day - 14), now],
    "Past 30 days": [DateTime(now.year, now.month, now.day - 30), now],
    "This month": [DateTime(now.year, now.month), now],
    "Last month": [
      DateTime(now.year, now.month - 1),
      DateTime(now.year, now.month, 0)
    ],
    "This quarter": [
      DateTime(now.year, (((now.month - 1) ~/ 3) * 3) + 1),
      DateTime(now.year, (((now.month - 1) ~/ 3) * 3) + 4, 0)
    ],
    "Last quarter": [
      DateTime(now.year, (((now.month - 1) ~/ 3) * 3) + 1 - 3),
      DateTime(now.year, (((now.month - 1) ~/ 3) * 3) + 4 - 3, 0)
    ],
    "This year": [DateTime(now.year), DateTime(now.year + 1, 1, 0)],
    "Last year": [DateTime(now.year - 1), DateTime(now.year, 1, 0)],
    "This financial year": [
      DateTime(now.year, 4),
      DateTime(now.year + 1, 4, 0)
    ],
    "Last financial year": [DateTime(now.year - 1), DateTime(now.year, 1, 0)],
    otherDate: []
  };

  final List<Account> allAccounts;
  final HashSet<Account> selectedAccounts;
  DateTime? startDate;
  DateTime? endDate;
  String date;
  String amount;
  double? startAmount;
  double? endAmount;
  String type;

  TransactionFilter({
    this.allAccounts = const [],
    HashSet<Account>? selectedAccounts,
    this.startDate,
    this.endDate,
    this.amount = anyAmount,
    this.startAmount,
    this.endAmount,
    this.date = anyDate,
    this.type = AccountTransaction.allTypes,
  }) : this.selectedAccounts = selectedAccounts ?? HashSet();

  DateTime? get getStartDate {
    //print("startDate in here = $date and this = ${dates[date]![0]}");
    if (date == otherDate) {
      return startDate;
    }

    return dates[date]![0];
  }

  DateTime? get getEndDate {
    if (date == otherDate) {
      return endDate;
    }

    return dates[date]![1];
  }

  double? get getStartAmount {
    if (amount == otherAmount) {
      return startAmount;
    }

    return amounts[amount]![0];
  }

  double? get getEndAmount {
    if (amount == otherAmount) {
      return endAmount;
    }

    return amounts[amount]![1];
  }

  String get getType => type;

  int getChangedCount(TransactionFilter resetFilter) {
    int count = allAccounts.length - selectedAccounts.length;

    count += getNormalChangedCount(resetFilter);

    return count;
  }

  int getNormalChangedCount(TransactionFilter resetFilter) {
    int count = 0;

    count += !isTypeEqual(resetFilter) ? 1 : 0;
    count += !isDateEqual(resetFilter) ? 1 : 0;
    count += !(isAmountEqual(resetFilter)) ? 1 : 0;

    return count;
  }

  bool isTypeEqual(TransactionFilter resetFilter) {
    return !(type != resetFilter.type);
  }

  bool isDateEqual(TransactionFilter resetFilter) {
    return date == resetFilter.date &&
        (date != otherDate ||
            (Vars.isSameDay(startDate, resetFilter.startDate) &&
                Vars.isSameDay(endDate, resetFilter.endDate)));
  }

  bool isAmountEqual(TransactionFilter resetFilter) {
    return amount == resetFilter.amount &&
        (amount != otherAmount ||
            (amountEqual(startAmount, resetFilter.startAmount) &&
                amountEqual(endAmount, resetFilter.endAmount)));
  }

  bool amountEqual(double? amount1, double? amount2) {
    if (amount1 == null || amount2 == null) {
      return false;
    }

    return amount1 == amount2;
  }

  bool isAllFilterAny() {
    return this.amount == anyAmount &&
        this.date == anyDate &&
        this.type == allTypes;
  }

  bool isFilterEqual(TransactionFilter other) {
    return type == other.type &&
        endAmount == other.endAmount &&
        startAmount == other.endAmount &&
        amount == other.amount &&
        date == other.date &&
        startDate == other.startDate &&
        endDate == other.endDate;
  }

  void resetFilter(TransactionFilter resetFilter) {
    startDate = resetFilter.startDate;
    endDate = resetFilter.endDate;
    amount = resetFilter.amount;
    startAmount = resetFilter.startAmount;
    endAmount = resetFilter.endAmount;
    date = resetFilter.date;
    type = resetFilter.type;
  }
}
