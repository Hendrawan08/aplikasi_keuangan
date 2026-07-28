import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/ai_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/ai_belum_siap.dart';

class _Msg {
  final String role; // 'user' | 'assistant'
  final String content;
  const _Msg(this.role, this.content);
}

/// DanaBot — chat keuangan via Edge Function proxy ke Gemini.
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _ctrl = TextEditingController();
  final List<_Msg> _msgs = [];
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _konteks() {
    final d = ref.read(dashboardProvider);
    return 'Anggaran: ${rp(d.anggaran)} | Pemasukan: ${rp(d.totalPemasukan)} | '
        'Pengeluaran: ${rp(d.totalPengeluaran)} | Net: ${rp(d.net)} | '
        'Health Score: ${d.health.total}/100';
  }

  Future<void> _kirim() async {
    final teks = _ctrl.text.trim();
    if (teks.isEmpty || _busy) return;
    setState(() {
      _msgs.add(_Msg('user', teks));
      _ctrl.clear();
      _busy = true;
    });
    try {
      final reply = await ref
          .read(aiServiceProvider)
          .chat(
            messages: _msgs
                .map((m) => {'role': m.role, 'content': m.content})
                .toList(),
            konteks: _konteks(),
          );
      if (mounted) setState(() => _msgs.add(_Msg('assistant', reply)));
    } catch (e) {
      if (mounted) {
        setState(() => _msgs.add(_Msg('assistant', 'Maaf, error: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AiConfig.configured) {
      return Scaffold(
        appBar: AppBar(title: const Text('🤖 DanaBot')),
        body: const AiBelumSiap(),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('🤖 DanaBot — AI Keuangan')),
      body: Column(
        children: [
          Expanded(
            child: _msgs.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Tanya apa saja soal keuanganmu.\n'
                        'Mis. "Gimana cara hemat bulan ini?"',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.text2),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _msgs.length,
                    itemBuilder: (_, i) => _Bubble(_msgs[i]),
                  ),
          ),
          if (_busy) const LinearProgressIndicator(minHeight: 2),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Tanya DanaBot…',
                      ),
                      onSubmitted: (_) => _kirim(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _busy ? null : _kirim,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.msg);
  final _Msg msg;

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser ? AppColors.accent2 : AppColors.bg2,
          borderRadius: BorderRadius.circular(14),
          border: isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          msg.content,
          style: TextStyle(color: isUser ? Colors.white : AppColors.text),
        ),
      ),
    );
  }
}
