import '../../domain/entities/lesson_summary.dart';

class LessonSummaryModel extends LessonSummary {
  const LessonSummaryModel({
    required super.sourceId,
    required super.title,
    required super.summary,
  });

  factory LessonSummaryModel.fromJson(Map<String, dynamic> json) {
    final sourceId = json['source_id'];
    final title = json['title'];
    final summary = json['summary'];
    if (sourceId is! String || title is! String || summary is! String) {
      throw const FormatException('Özet yanıtında gerekli alanlar eksik.');
    }

    return LessonSummaryModel(
      sourceId: sourceId,
      title: title,
      summary: summary,
    );
  }
}
