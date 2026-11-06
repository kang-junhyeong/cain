import '../models/service.dart';

abstract class ServiceRepository {
  Future<List<ServiceModel>> getAll();
  Future<ServiceModel?> getById(String id);
  Future<List<ServiceModel>> getByCategory(String categoryId);
  Future<List<ServiceModel>> search(String query, String locale);
}
