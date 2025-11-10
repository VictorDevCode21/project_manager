// lib/views/projects/manage_members_dialog.dart
import 'package:flutter/material.dart';
import 'package:prolab_unimet/controllers/project_controller.dart';

/// Dialog to manage project members and invites (View - MVC).
/// UI strings are in Spanish; code comments are in English as requested.
class ManageMembersDialog extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ManageMembersDialog({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ManageMembersDialog> createState() => _ManageMembersDialogState();
}

class _ManageMembersDialogState extends State<ManageMembersDialog> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _controller = ProjectController();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    final inviter = _controller.currentUserUid;
    if (inviter == null) {
      setState(() => _error = 'No hay usuario autenticado.');
      return;
    }

    setState(() => _busy = true);
    try {
      // Creates invite and emails via Lambda URL from .env.
      await _controller.createInviteAndSendEmail(
        projectId: widget.projectId,
        recipientEmail: _emailCtrl.text,
      );

      if (!mounted) return;
      _emailCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitación enviada correctamente.')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(String uid) async {
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      await _controller.removeMember(
        projectId: widget.projectId,
        memberUid: uid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Miembro eliminado.')));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _confirmRemove(ProjectMember m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: Text(
          '¿Eliminar a ${m.displayName.isNotEmpty ? m.displayName : m.email} de este proyecto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff253f8d),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _remove(m.uid);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.group, color: Color(0xff253f8d)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Gestionar miembros • ${widget.projectName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff253f8d),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _busy ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Invita colaboradores por correo (recibirán un enlace de aceptación) y gestiona los miembros existentes.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),

                // Invite form
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailCtrl,
                          enabled: !_busy,
                          decoration: InputDecoration(
                            hintText: 'example@correo.unimet.edu.ve',
                            labelText: 'Introduzca el correo del invitado',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) {
                            final value = (v ?? '').trim().toLowerCase();
                            if (value.isEmpty) return 'El correo es requerido.';
                            // Adjust the regex if you plan to allow more domains.
                            final ok = RegExp(
                              r'^[\w\.-]+@(correo\.unimet\.edu\.ve|unimet\.edu\.ve)$',
                            ).hasMatch(value);
                            if (!ok) {
                              return 'Correo inválido. Permitidos: unimet.edu.ve o correo.unimet.edu.ve';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _busy ? null : _invite,
                          icon: const Icon(
                            Icons.person_add_alt_1,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: _busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Invitar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff253f8d),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Pending invites list (client-side filter to avoid composite index)
                StreamBuilder<List<ProjectInvite>>(
                  // Do not pass a Firestore status filter to avoid composite index.
                  stream: _controller.streamInvites(widget.projectId),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Error cargando invitaciones: ${snap.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final all = snap.data ?? const <ProjectInvite>[];
                    // Only show PENDING
                    final invites = all
                        .where((i) => (i.status).toUpperCase() == 'PENDING')
                        .toList();

                    if (invites.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final double _invitesListHeight =
                        (MediaQuery.of(context).size.height * 0.28).clamp(
                          220.0,
                          360.0,
                        ); // 28% viewport, clamped

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Invitaciones pendientes',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),

                        // Fixed-height, scrollable list to avoid overflow inside SingleChildScrollView
                        SizedBox(
                          height: _invitesListHeight,
                          child: ListView.separated(
                            // Do not use shrinkWrap here; let the SizedBox constraint drive it
                            itemCount: invites.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final ivt = invites[i];
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.mail_outline),
                                title: Text(ivt.email),
                                subtitle: Text('Estado: ${ivt.status}'),
                                trailing: IconButton(
                                  tooltip: 'Cancelar invitación',
                                  icon: const Icon(Icons.close),
                                  onPressed: _busy
                                      ? null
                                      : () => _controller.cancelInvite(
                                          widget.projectId,
                                          ivt.id,
                                        ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),

                // Members list
                StreamBuilder<List<ProjectMember>>(
                  stream: _controller.streamMembers(widget.projectId),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Error cargando miembros: ${snap.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final members = snap.data ?? const <ProjectMember>[];
                    if (members.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.black38),
                            SizedBox(width: 8),
                            Text(
                              'Aún no hay miembros. Invita a alguien arriba.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      );
                    }

                    final double _membersListHeight =
                        (MediaQuery.of(context).size.height * 0.30).clamp(
                          220.0,
                          420.0,
                        ); // 30% viewport, clamped

                    return SizedBox(
                      height: _membersListHeight,
                      child: ListView.separated(
                        // Do not use shrinkWrap; the SizedBox gives bounded height
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: members.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final m = members[i];
                          final subtitle = m.displayName.isNotEmpty
                              ? '${m.displayName} • ${m.email}'
                              : m.email;
                          final isSelf = m.uid == _controller.currentUserUid;

                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              radius: 18,
                              child: Icon(Icons.person, size: 18),
                            ),
                            title: Text(subtitle),
                            subtitle: Text(
                              m.addedAt != null
                                  ? 'Agregado el ${m.addedAt}'
                                  : 'Fecha pendiente',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              tooltip: isSelf
                                  ? 'No puedes eliminarte a ti mismo'
                                  : 'Eliminar',
                              onPressed: (_busy || isSelf)
                                  ? null
                                  : () => _confirmRemove(m),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
