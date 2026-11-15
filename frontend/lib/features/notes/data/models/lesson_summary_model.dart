import '../../domain/entities/lesson_summary.dart';

class LessonSummaryModel extends LessonSummary {
  const LessonSummaryModel({
    required super.sourceId,
    required super.title,
    required super.summary,
  });

  factory LessonSummaryModel.fromJson(Map<String, dynamic> json) {
    final sourceId = _sourceIdFromJson(json['source_id']);
    final title = json['title'];
    final summary = json['summary'];
    if (title is! String) {
      throw const FormatException('Özet yanıtında title alanı geçersiz.');
    }
    if (summary is! String) {
      throw const FormatException('Özet yanıtında summary alanı geçersiz.');
    }

    return LessonSummaryModel(
      sourceId: sourceId,
      title: title,
      summary: summary,
    );
  }

  static String _sourceIdFromJson(Object? value) {
    if (value is String) return value;

    final source = _asMap(value);
    final buffer = _asMap(source?['buffer']);
    if (buffer != null) {
      final indexedBytes = <MapEntry<int, int>>[];
      for (final entry in buffer.entries) {
        final index = int.tryParse(entry.key);
        final byte = _asByte(entry.value);
        if (index != null && index >= 0 && byte != null) {
          indexedBytes.add(MapEntry(index, byte));
        }
      }
      indexedBytes.sort((left, right) => left.key.compareTo(right.key));
      if (indexedBytes.isNotEmpty) {
        return indexedBytes
            .map((entry) => entry.value.toRadixString(16).padLeft(2, '0'))
            .join();
      }
    }

    return 'source-${DateTime.now().microsecondsSinceEpoch}';
  }

  static Map<String, Object?>? _asMap(Object? value) {
    if (value is! Map) return null;
    return {
      for (final entry in value.entries) entry.key.toString(): entry.value,
    };
  }

  static int? _asByte(Object? value) {
    final byte = value is int
        ? value
        : value is num && value == value.roundToDouble()
        ? value.toInt()
        : int.tryParse('$value');
    return byte != null && byte >= 0 && byte <= 255 ? byte : null;
  }
}
