import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class CreateTransaction {
  final TransactionRepository repository;

  CreateTransaction(this.repository);

  Future<Either<Failure, Transaction>> call(Transaction transaction) {
    return repository.createTransaction(transaction);
  }
}
