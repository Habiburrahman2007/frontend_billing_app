import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../services/transaction_service.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionService _transactionService;

  TransactionRepositoryImpl({TransactionService? transactionService})
      : _transactionService = transactionService ?? TransactionService();

  @override
  Future<Either<Failure, Transaction>> createTransaction(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final createdModel = await _transactionService.createTransaction(model);
      return Right(createdModel); // TransactionModel IS A Transaction
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
