// lib/views/notifications/notifications_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prolab_unimet/models/notification_model.dart';
import 'package:prolab_unimet/providers/notification_provider.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final List<NotificationModel> notifications =
        notificationProvider.notifications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notificaciones',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: notificationProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No tienes notificaciones por ahora.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final bool isInvitation =
                        notification.type == 'project_invitation';

                    return Card(
                      child: ListTile(
                        title: Text(notification.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(notification.body),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimeAgo(notification.createdAt.toDate()),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        trailing: isInvitation
                            ? _InvitationActions(notification: notification)
                            : IconButton(
                                icon: const Icon(Icons.close),
                                tooltip: 'Descartar',
                                onPressed: () {
                                  notificationProvider.dismissNotification(
                                    notification.id,
                                  );
                                },
                              ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  static String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) return 'hace ${diff.inSeconds}s';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';

    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }
}

class _InvitationActions extends StatelessWidget {
  final NotificationModel notification;

  const _InvitationActions({required this.notification});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    final messenger = ScaffoldMessenger.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Aceptar invitación',
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () async {
            final bool success = await notificationProvider.acceptInvitation(
              notification,
            );

            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Has aceptado la invitación al proyecto.'
                      : 'No se pudo aceptar la invitación. Inténtalo de nuevo.',
                ),
              ),
            );
          },
        ),
        IconButton(
          tooltip: 'Rechazar invitación',
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () async {
            final bool success = await notificationProvider.declineInvitation(
              notification,
            );

            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Has rechazado la invitación.'
                      : 'No se pudo rechazar la invitación. Inténtalo de nuevo.',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
