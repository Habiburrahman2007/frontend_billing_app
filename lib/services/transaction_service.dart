import 'package:dio/dio.dart';
import '../../features/billing/data/models/transaction_model.dart';
import '../core/constants/api_constants.dart';

import 'api_client.dart';

class TransactionService {
  TransactionService._();
  static final TransactionService _instance = TransactionService._();
  factory TransactionService() => _instance;

  final _dio = ApiClient().dio;

  Future<List<TransactionModel>> getTransactions({int page = 1}) async {
    try {
      final response = await _dio.get(
        kTransactionsEndpoint,
        queryParameters: {'page': page},
      );
      // Laravel pagination puts items in 'data'
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => TransactionModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<TransactionModel> getTransaction(int id) async {
    try {
      final response = await _dio.get('$kTransactionsEndpoint/$id');
      final data = response.data['data'] ?? response.data;
      return TransactionModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    try {
      final response = await _dio.post(
        kTransactionsEndpoint,
        data: transaction.toJson(),
      );
      final data = response.data['data'] ?? response.data;
      return TransactionModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
