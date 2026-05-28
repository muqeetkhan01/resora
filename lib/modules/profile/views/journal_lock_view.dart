import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import 'widgets/settings_flow_widgets.dart';

class JournalLockView extends StatefulWidget {
  const JournalLockView({super.key});

  @override
  State<JournalLockView> createState() => _JournalLockViewState();
}

class _JournalLockViewState extends State<JournalLockView> {
  final controller = Get.find<ProfileController>();
  final _digits = <String>[];
  List<String>? _firstPin;
  String _step = 'set';
  String _error = '';
  bool _showSaved = false;

  @override
  void initState() {
    super.initState();
    _step = controller.hasJournalPin ? 'manage' : 'set';
  }

  void _onKey(String key) {
    if (_digits.length >= 4) return;

    setState(() {
      _digits.add(key);
      _error = '';
    });

    if (_digits.length != 4) return;

    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      if (_step == 'set') {
        setState(() {
          _firstPin = List<String>.from(_digits);
          _digits.clear();
          _step = 'confirm';
        });
        return;
      }

      final matches = _firstPin != null && _digits.join() == _firstPin!.join();
      if (matches) {
        controller.setJournalPin(_digits.join());
        setState(() => _showSaved = true);
      } else {
        setState(() {
          _error = 'PINs do not match. Try again.';
          _digits.clear();
          _firstPin = null;
          _step = 'set';
        });
      }
    });
  }

  void _deleteDigit() {
    if (_digits.isEmpty) return;
    setState(() {
      _digits.removeLast();
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsFlowColors.offWhite,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: SettingsTopBack(title: ''),
                ),
                const SizedBox(height: 8),
                Text('journal lock',
                    style: SettingsFlowText.display(context, size: 32)),
                const SizedBox(height: 20),
                if (_step == 'manage')
                  _manageState(context)
                else
                  _pinState(context),
              ],
            ),
          ),
          if (_showSaved)
            _CheckmarkOverlay(
              label: 'PIN set',
              onDone: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  Widget _manageState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        children: [
          Text(
            'Your journal is protected. You can remove or update your PIN anytime.',
            textAlign: TextAlign.center,
            style: SettingsFlowText.body(context, size: 13),
          ),
          const SizedBox(height: 32),
          SettingsPrimaryButton(
            label: 'change pin',
            onTap: () {
              setState(() {
                _step = 'set';
                _digits.clear();
                _firstPin = null;
                _error = '';
              });
            },
          ),
          const SizedBox(height: 22),
          SettingsUnderlineButton(
            label: 'remove lock',
            color: SettingsFlowColors.terracotta,
            onTap: () {
              controller.clearJournalPin();
              setState(() {
                _step = 'set';
                _digits.clear();
                _firstPin = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _pinState(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            _step == 'set' ? 'Set your PIN' : 'Confirm your PIN',
            style: SettingsFlowText.title(
              context,
              size: 13,
            ).copyWith(color: SettingsFlowColors.muted),
          ),
          const SizedBox(height: 6),
          Text(
            _step == 'set'
                ? 'Choose a 4-digit PIN for your journal.'
                : 'Enter the same PIN again.',
            style: SettingsFlowText.body(context, size: 11),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _error,
              style: SettingsFlowText.body(
                context,
                size: 11,
                color: SettingsFlowColors.terracotta,
              ),
            ),
          ],
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Container(
                width: 44,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: index < _digits.length
                    ? SettingsFlowColors.warmDark
                    : SettingsFlowColors.mutedLight,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                for (final row in const [
                  ['1', '2', '3'],
                  ['4', '5', '6'],
                  ['7', '8', '9'],
                  ['', '0', 'del'],
                ])
                  Row(
                    children: row.map((key) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: key.isEmpty
                              ? null
                              : key == 'del'
                                  ? _deleteDigit
                                  : () => _onKey(key),
                          child: Container(
                            height: 60,
                            alignment: Alignment.center,
                            child: key == 'del'
                                ? Text(
                                    '⌫',
                                    style: SettingsFlowText.title(
                                      context,
                                      size: 20,
                                    ).copyWith(
                                      color: SettingsFlowColors.muted,
                                    ),
                                  )
                                : Text(
                                    key,
                                    style: SettingsFlowText.display(
                                      context,
                                      size: 28,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckmarkOverlay extends StatefulWidget {
  const _CheckmarkOverlay({
    required this.label,
    required this.onDone,
  });

  final String label;
  final VoidCallback onDone;

  @override
  State<_CheckmarkOverlay> createState() => _CheckmarkOverlayState();
}

class _CheckmarkOverlayState extends State<_CheckmarkOverlay> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1100), widget.onDone);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SettingsFlowColors.overlay,
      child: Center(
        child: Container(
          color: SettingsFlowColors.offWhite,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check,
                color: SettingsFlowColors.terracotta,
                size: 42,
              ),
              const SizedBox(height: 16),
              Text(widget.label,
                  style: SettingsFlowText.caps(context, size: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
