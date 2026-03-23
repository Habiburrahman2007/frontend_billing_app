import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, Transaction>> createTransaction(Transaction transaction);
}
