import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:management_funds/features/funds/presentation/pages/funds_page.dart';
import 'package:management_funds/features/funds/presentation/pages/my_funds_page.dart';
import 'package:management_funds/features/funds/presentation/pages/transactions_page.dart';

class FundsHomePage extends StatefulWidget {
  const FundsHomePage({super.key});

  @override
  State<FundsHomePage> createState() => _FundsHomePageState();
}

class _FundsHomePageState extends State<FundsHomePage> {
  int _index = 1;

  final _pages = const [
    MyFundsPage(),
    FundsPage(),
    TransactionsPage(),
  ];

  final _titles = const [
    'Mis fondos',
    'Fondos disponibles',
    'Transacciones',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) {
          final slide = Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(anim);
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: _pages[_index],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.creditcard),
                  activeIcon: const Icon(CupertinoIcons.creditcard_fill),
                  label: 'Mis fondos',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.list_bullet),
                  label: 'Disponibles',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.doc_text),
                  activeIcon: const Icon(CupertinoIcons.doc_text_fill),
                  label: 'Transacciones',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
