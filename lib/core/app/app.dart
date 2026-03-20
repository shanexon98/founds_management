import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_funds/features/funds/presentation/cubit/funds_cubit.dart';
import 'package:management_funds/features/funds/presentation/pages/funds_home_page.dart';
import 'package:management_funds/core/services/aws_notification_service.dart';
import 'package:management_funds/core/ui/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Management Funds',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: BlocProvider(
        create: (_) => FundsCubit(
          initialBalance: 500000,
          notifier: AwsNotificationService(),
        ),
        child: const FundsHomePage(),
      ),
    );
  }
}
