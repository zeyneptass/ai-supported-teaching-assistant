import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_summary.dart';
import '../viewmodels/notes_view_model.dart';
import 'quiz_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  String? _selectedFileName;
  String? _summaryTitle;
  String? _summaryText;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickTextFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['txt'],
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final content = utf8.decode(bytes);
      final title = file.name.replaceFirst(
        RegExp(r'\.txt$', caseSensitive: false),
        '',
      );
      setState(() {
        _selectedFileName = file.name;
        _titleController.text = title;
        _textController.text = content;
      });
      _invalidateSummary(context.read<NotesViewModel>());
    } on FormatException {
      if (mounted) _showMessage('Dosya UTF-8 biçiminde okunamadı.');
    } catch (error) {
      if (mounted) _showMessage('Dosya seçilemedi: $error');
    }
  }

  void _onLessonChanged() {
    final viewModel = context.read<NotesViewModel>();
    final summary = viewModel.summary;
    if (summary != null &&
        (_titleController.text.trim() != _summaryTitle ||
            _textController.text.trim() != _summaryText)) {
      _invalidateSummary(viewModel);
    }
  }

  void _invalidateSummary(NotesViewModel viewModel) {
    _summaryTitle = null;
    _summaryText = null;
    if (viewModel.summary != null) viewModel.clearSummary();
  }

  bool _validate() => _formKey.currentState?.validate() ?? false;

  Future<void> _summarize(NotesViewModel viewModel) async {
    if (!_validate() || viewModel.isLoading) return;
    final title = _titleController.text.trim();
    final text = _textController.text.trim();
    await viewModel.summarize(title: title, text: text);
    if (!mounted) return;
    if (viewModel.summary != null) {
      _summaryTitle = title;
      _summaryText = text;
    }
  }

  Future<void> _createQuiz(NotesViewModel viewModel) async {
    if (!_validate() || viewModel.isLoading) return;
    final title = _titleController.text.trim();
    final text = _textController.text.trim();

    var summary = viewModel.summary;
    if (summary == null || _summaryTitle != title || _summaryText != text) {
      await viewModel.summarize(title: title, text: text);
      if (!mounted) return;
      summary = viewModel.summary;
      if (summary == null) return;
      _summaryTitle = title;
      _summaryText = text;
    }

    final quiz = await viewModel.generateQuiz(
      sourceId: summary.sourceId,
      title: title,
      text: text,
    );
    if (!mounted || quiz == null) return;
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => QuizScreen(quiz: quiz)));
  }

  Future<void> _copySummary(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) _showMessage('Özet panoya kopyalandı.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotesViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Notları'),
        leading: IconButton(
          tooltip: 'Sohbete dön',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _buildIntro(context),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                enabled: !viewModel.isLoading,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Ders başlığı',
                  hintText: 'Örn. Nesne Yönelimli Programlama',
                  prefixIcon: Icon(Icons.menu_book_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ders başlığını girin.'
                    : null,
                onChanged: (_) => _onLessonChanged(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _textController,
                enabled: !viewModel.isLoading,
                minLines: 8,
                maxLines: 14,
                textCapitalization: TextCapitalization.sentences,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Ders notu metni',
                  hintText: 'Ders notlarınızı buraya yazın veya yapıştırın...',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 120),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Özetlemek veya test oluşturmak için not metni gerekli.'
                    : null,
                onChanged: (_) => _onLessonChanged(),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: viewModel.isLoading ? null : _pickTextFile,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('TXT Dosyası Seç'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              if (_selectedFileName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 17,
                      color: AppTheme.accent,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        _selectedFileName!,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: const Color(0xFF475569)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: viewModel.isLoading
                          ? null
                          : () => _summarize(viewModel),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 19),
                      label: const Text('Özetle'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: viewModel.isLoading
                          ? null
                          : () => _createQuiz(viewModel),
                      icon: const Icon(Icons.quiz_outlined, size: 19),
                      label: const Text('Test Oluştur'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (viewModel.isLoading) ...[
                const SizedBox(height: 18),
                const LinearProgressIndicator(),
                const SizedBox(height: 10),
                Text(
                  viewModel.statusMessage ?? 'İşleminiz sürüyor...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: const Color(0xFF64748B)),
                ),
              ],
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildError(viewModel.errorMessage!),
              ],
              if (viewModel.summary case final summary?) ...[
                const SizedBox(height: 24),
                _buildSummaryCard(context, viewModel, summary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Notlarınızı yapay zeka ile özetleyin veya kişisel bir test '
              'hazırlayın.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: const Color(0xFF334155), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF991B1B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    NotesViewModel viewModel,
    LessonSummary summary,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ders Özeti',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Özeti kopyala',
                onPressed: () => _copySummary(summary.summary),
                icon: const Icon(Icons.copy_rounded),
              ),
              IconButton(
                tooltip: 'Özeti temizle',
                onPressed: viewModel.clearSummary,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          Text(
            summary.title,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          SelectableText(
            summary.summary,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
