import 'package:flutter/material.dart';

import '../../data/ai_access_prefs.dart';
import 'ai_unlock_page.dart';

/// Shows [child] only when the AI has been unlocked with the access code;
/// otherwise shows [AiUnlockPage] inline (no push) and swaps to [child]
/// as soon as unlocking + model download complete.
class AiGate extends StatefulWidget {
  const AiGate({super.key, required this.child});

  final Widget child;

  @override
  State<AiGate> createState() => _AiGateState();
}

class _AiGateState extends State<AiGate> {
  bool? _unlocked;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await AiAccessPrefs().isUnlocked();
    if (!mounted) return;
    setState(() => _unlocked = unlocked);
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = _unlocked;
    if (unlocked == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (unlocked) {
      return widget.child;
    }
    return AiUnlockPage(onUnlocked: () => setState(() => _unlocked = true));
  }
}
