import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/centered_back_header.dart';
import '../controllers/profile_controller.dart';

class JournalLockView extends StatefulWidget {
  const JournalLockView({super.key});

  @override
  State<JournalLockView> createState() => _JournalLockViewState();
}

class _JournalLockViewState extends State<JournalLockView> {
  final controller = Get.find<ProfileController>();

  final _digits = <String>[];
  List<String>? _firstPin;
  String _error = '';
  String _step = 'set'; // set | confirm | manage

  @override
  void initState() {
    super.initState();
    _step = controller.hasJournalPin ? 'manage' : 'set';
  }

  void _onKey(String key) {
    if (_digits.length >= 4) {
      return;
    }

    setState(() {
      _digits.add(key);
      _error = '';
    });

    if (_digits.length == 4) {
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (!mounted) return;

        if (_step == 'set') {
          setState(() {
            _firstPin = List<String>.from(_digits);
            _digits.clear();
            _step = 'confirm';
          });
          return;
        }

        if (_step == 'confirm') {
          final matches =
              _firstPin != null && _digits.join() == _firstPin!.join();
          if (matches) {
            controller.setJournalPin(_digits.join());
            setState(() {
              _digits.clear();
              _step = 'manage';
            });
          } else {
            setState(() {
              _error = 'PINs do not match. Try again.';
              _digits.clear();
              _firstPin = null;
              _step = 'set';
            });
          }
        }
      });
    }
  }

  void _deleteDigit() {
    if (_digits.isEmpty) {
      return;
    }

    setState(() {
      _digits.removeLast();
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CenteredBackHeader(title: 'journal lock'),
              const SizedBox(height: AppSpacing.lg),
              if (_step == 'manage')
                _ManageState(
                  onChangePin: () {
                    setState(() {
                      _step = 'set';
                      _digits.clear();
                      _firstPin = null;
                      _error = '';
                    });
                  },
                  onRemoveLock: () {
                    controller.clearJournalPin();
                    setState(() {
                      _step = 'set';
                      _digits.clear();
                      _firstPin = null;
                      _error = '';
                    });
                  },
                )
              else
                Column(
                  children: [
                    Text(
                      _step == 'set' ? 'Set your PIN' : 'Confirm your PIN',
                      style: textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _step == 'set'
                          ? 'Choose a 4-digit PIN for your journal.'
                          : 'Enter the same PIN again.',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _error,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.terracotta,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (index) => Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            color: _digits.length > index
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.4,
                      children: const [
                        '1',
                        '2',
                        '3',
                        '4',
                        '5',
                        '6',
                        '7',
                        '8',
                        '9',
                        '',
                        '0',
                        'del',
                      ].map((key) {
                        if (key.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return _PinKey(digit: key);
                      }).toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageState extends StatelessWidget {
  const _ManageState({
    required this.onChangePin,
    required this.onRemoveLock,
  });

  final VoidCallback onChangePin;
  final VoidCallback onRemoveLock;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your journal is protected. You can remove or update your PIN anytime.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onChangePin,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            child: Text(
              'change pin',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: onRemoveLock,
            child: Text(
              'remove lock',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.terracotta,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({required this.digit});

  final String digit;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_JournalLockViewState>();
    final isDelete = digit == 'del';

    return InkWell(
      onTap: () {
        if (state == null) return;
        if (isDelete) {
          state._deleteDigit();
        } else {
          state._onKey(digit);
        }
      },
      child: Center(
        child: Text(
          isDelete ? '⌫' : digit,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: isDelete ? 20 : 28,
                color: isDelete ? AppColors.terracotta : AppColors.primary,
              ),
        ),
      ),
    );
  }
}
