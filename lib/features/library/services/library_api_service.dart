import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/library_models.dart';

class LibraryApiService {
  final ApiClient _api = ApiClient();

  Future<List<LibraryFolder>> getLibraryHome() async {
    final result = await _api.get<List<LibraryFolder>>(
      endpoint: ApiConstants.library.home,
      fromJsonT: (json) => (json['folders'] as List? ?? const [])
          .map(
            (item) =>
                LibraryFolder.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<List<LibraryItem>> getItems({
    required String folder,
    required String category,
    String? search,
  }) async {
    final result = await _api.get<List<LibraryItem>>(
      endpoint: ApiConstants.library.items,
      queryParameters: {
        'folder': folder,
        'category': category,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
      fromJsonT: (json) => (json['items'] as List? ?? const [])
          .map(
            (item) =>
                LibraryItem.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }
}
