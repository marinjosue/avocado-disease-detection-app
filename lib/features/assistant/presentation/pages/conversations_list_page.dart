import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aplication_tesis/core/widgets/app_states.dart';
import 'package:aplication_tesis/features/assistant/domain/conversation.dart';
import 'package:aplication_tesis/features/assistant/presentation/pages/chat_page.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/assistant_provider.dart';
import 'package:aplication_tesis/l10n/app_localizations.dart';

class ConversationsListPage extends StatefulWidget {
  const ConversationsListPage({super.key});

  @override
  State<ConversationsListPage> createState() => _ConversationsListPageState();
}

class _ConversationsListPageState extends State<ConversationsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AssistantProvider>().loadConversations();
    });
  }

  String _relativeTime(DateTime updatedAt, AppLocalizations? l10n) {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inDays > 0) {
      final days = difference.inDays;
      if (l10n != null) {
        return l10n.agoDays(days, days > 1 ? 's' : '');
      }
      return 'Hace $days día${days > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      if (l10n != null) {
        return l10n.agoHours(hours, hours > 1 ? 's' : '');
      }
      return 'Hace $hours hora${hours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      if (l10n != null) {
        return l10n.agoMinutes(minutes, minutes > 1 ? 's' : '');
      }
      return 'Hace $minutes minuto${minutes > 1 ? 's' : ''}';
    } else {
      return l10n?.agoMoment ?? 'Hace un momento';
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AssistantProvider provider,
    Conversation conv,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.deleteConversation ?? 'Eliminar conversación'),
        content: Text(
          l10n?.deleteConversationMsg ??
              'Esta conversación se eliminará permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n?.delete ?? 'Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.deleteConversation(conv.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.conversationDeleted ?? 'Conversación eliminada'),
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteAll(
    BuildContext context,
    AssistantProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.deleteAllConversations ?? 'Eliminar todas'),
        content: Text(
          l10n?.deleteAllConversationsMsg ??
              'Todas las conversaciones se eliminarán permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n?.delete ?? 'Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.deleteAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<AssistantProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n?.conversations ?? 'Conversaciones'),
            actions: [
              if (provider.conversations.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: l10n?.deleteAllConversations ?? 'Eliminar todas',
                  onPressed: () => _confirmDeleteAll(context, provider),
                ),
            ],
          ),
          body: provider.conversations.isEmpty
              ? EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: l10n?.noConversations ?? 'Aún no hay conversaciones',
                  message:
                      l10n?.noConversationsMsg ?? 'Inicia un chat con el asistente.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  itemCount: provider.conversations.length,
                  itemBuilder: (context, index) {
                    final conv = provider.conversations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: conv.context?.imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(conv.context!.imagePath!),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    child: Icon(
                                      Icons.chat_bubble_outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                        title: Text(
                          conv.title.isNotEmpty
                              ? conv.title
                              : (l10n?.untitledConversation ?? 'Conversación'),
                        ),
                        subtitle: Text(
                          _relativeTime(conv.updatedAt, l10n),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              _confirmDelete(context, provider, conv),
                        ),
                        onTap: () async {
                          await provider.openConversation(conv.id!);
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChatPage(),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: Text(l10n?.newConversation ?? 'Nueva conversación'),
            onPressed: () async {
              await provider.createGeneral();
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatPage(),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
