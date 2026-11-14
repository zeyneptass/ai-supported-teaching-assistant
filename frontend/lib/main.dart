import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/http_service_impl.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/usecases/ask_question.dart';
import 'features/chat/presentation/viewmodels/chat_view_model.dart';
import 'features/notes/data/datasources/notes_remote_data_source.dart';
import 'features/notes/data/repositories/notes_repository_impl.dart';
import 'features/notes/domain/usecases/generate_quiz.dart';
import 'features/notes/domain/usecases/summarize_lesson.dart';
import 'features/notes/domain/usecases/submit_quiz.dart';
import 'features/notes/presentation/viewmodels/notes_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final httpService = HttpServiceImpl();
            final remoteDataSource = ChatRemoteDataSourceImpl(httpService);
            final repository = ChatRepositoryImpl(remoteDataSource);
            return ChatViewModel(AskQuestion(repository));
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final dataSource = NotesRemoteDataSourceImpl(HttpServiceImpl());
            final repository = NotesRepositoryImpl(dataSource);
            return NotesViewModel(
              SummarizeLesson(repository),
              GenerateQuiz(repository),
              SubmitQuiz(repository),
            );
          },
        ),
      ],
      child: MaterialApp(
        title: 'AI Destekli Öğretim Asistanı',
        theme: AppTheme.light,
        home: const LoginScreen(),
      ),
    );
  }
}
