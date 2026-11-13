import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/http_service_impl.dart';
import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/usecases/ask_question.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/chat/presentation/viewmodels/chat_view_model.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final httpService = HttpServiceImpl();
        final remoteDataSource = ChatRemoteDataSourceImpl(httpService);
        final repository = ChatRepositoryImpl(remoteDataSource);
        return ChatViewModel(AskQuestion(repository));
      },
      child: MaterialApp(
        title: 'AI Destekli Öğretim Asistanı',
        theme: AppTheme.light,
        home: const LoginScreen(),
      ),
    );
  }
}
