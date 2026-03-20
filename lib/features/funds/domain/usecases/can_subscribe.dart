import '../entities/fund.dart';

class CanSubscribe {
  bool call({required int balance, required Fund fund}) {
    return balance >= fund.minAmount;
  }
}
