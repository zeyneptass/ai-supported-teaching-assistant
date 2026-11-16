import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../notes/domain/entities/saved_lesson.dart';
import '../../../notes/presentation/screens/notes_screen.dart';
import '../../../notes/presentation/screens/quiz_screen.dart';
import '../../../notes/presentation/viewmodels/notes_view_model.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/continue_learning_card.dart';
import '../widgets/lesson_empty_state.dart';
import '../widgets/saved_lesson_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.userName = 'Zeynep'});

  final String userName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  SavedLessonFilter _filter = SavedLessonFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotesViewModel>().loadSavedLessons();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SavedLesson> _visibleLessons(NotesViewModel viewModel) {
    final normalizedQuery = _query.trim().toLowerCase();
    return viewModel.savedLessons
        .where((lesson) {
          final matchesQuery =
              normalizedQuery.isEmpty ||
              lesson.title.toLowerCase().contains(normalizedQuery);
          final matchesFilter = switch (_filter) {
            SavedLessonFilter.all => true,
            SavedLessonFilter.summarized => lesson.isSummarized,
            SavedLessonFilter.quizSolved => lesson.hasSolvedQuiz,
          };
          return matchesQuery && matchesFilter;
        })
        .toList(growable: false);
  }

  void _openLesson(SavedLesson lesson) {
    final quiz = lesson.latestQuiz;
    if (quiz != null && lesson.latestResult != null) {
      context.read<NotesViewModel>().restartQuiz(quiz);
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: quiz == null
            ? const RouteSettings(name: NotesScreen.routeName)
            : null,
        builder: (_) => quiz == null
            ? NotesScreen(initialLesson: lesson)
            : QuizScreen(quiz: quiz),
      ),
    );
  }

  void _openNewLesson() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: NotesScreen.routeName),
        builder: (_) => const NotesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotesViewModel>();
    final lessons = _visibleLessons(viewModel);
    final canContinue = _filter == SavedLessonFilter.all && _query.isEmpty;
    final continueLesson = canContinue && viewModel.savedLessons.isNotEmpty
        ? viewModel.savedLessons.first
        : null;
    final hasHistoryError = viewModel.savedLessonsError != null;
    final isInitialLoading =
        viewModel.isLoadingSavedLessons && viewModel.savedLessons.isEmpty;
    final isEmpty = lessons.isEmpty && !isInitialLoading && !hasHistoryError;
    final bodyItemCount =
        (hasHistoryError ? 1 : 0) +
        (isInitialLoading || isEmpty ? 1 : lessons.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Listesi'),
        actions: [
          IconButton(
            tooltip: 'Öğretim Asistanı',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const ChatScreen())),
            icon: const Icon(Icons.auto_awesome_outlined),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: 5 + bodyItemCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _GreetingHeader(userName: widget.userName);
          }
          if (index == 1) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 18),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Ders başlığı ara',
                leading: const Icon(Icons.search_rounded),
                onChanged: (value) => setState(() => _query = value),
                trailing: [
                  if (_query.isNotEmpty)
                    IconButton(
                      tooltip: 'Aramayı temizle',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
              ),
            );
          }
          if (index == 2) {
            if (continueLesson == null) return const SizedBox(height: 4);
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ContinueLearningCard(
                lesson: continueLesson,
                onContinue: () => _openLesson(continueLesson),
              ),
            );
          }
          if (index == 3) {
            return CategoryFilterBar(
              selected: _filter,
              onSelected: (filter) => setState(() => _filter = filter),
            );
          }
          if (index == 4) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ders notların',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '${lessons.length} ders',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          var bodyIndex = index - 5;
          if (hasHistoryError) {
            if (bodyIndex == 0) {
              return _HistoryError(
                message: viewModel.savedLessonsError!,
                onRetry: viewModel.loadSavedLessons,
              );
            }
            bodyIndex--;
          }
          if (isInitialLoading) {
            return const Padding(
              padding: EdgeInsets.all(36),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (isEmpty) return LessonEmptyState(hasQuery: _query.isNotEmpty);

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: SavedLessonCard(
              lesson: lessons[bodyIndex],
              onTap: () => _openLesson(lessons[bodyIndex]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewLesson,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Ders Notu Ekle'),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Merhaba, $userName 👋',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  'Notların ve testlerin tek bir yerde.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 21,
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.onPrimaryContainer,
            child: Text(
              userName.isEmpty ? '?' : userName.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Card(
        child: ListTile(
          leading: Icon(
            Icons.cloud_off_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Ders listesi yüklenemedi'),
          subtitle: Text(message),
          trailing: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tekrar Dene'),
          ),
        ),
      ),
    );
  }
}
