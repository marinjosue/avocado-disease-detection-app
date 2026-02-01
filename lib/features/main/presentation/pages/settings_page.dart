import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/models/workspace_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // Definir todas las traducciones con valores por defecto
    final settingsTitle = l10n?.settings ?? 'Settings';
    final loginLabel = l10n?.login ?? 'Login';
    final registerLabel = l10n?.register ?? 'Register';
    final languageLabel = l10n?.language ?? 'Language';
    final editLabel = l10n?.edit ?? 'Edit';
    final profileLabel = l10n?.profile ?? 'Profile';
    final logoutLabel = l10n?.logout ?? 'Logout';
    final cancelLabel = l10n?.cancel ?? 'Cancel';
    final saveLabel = l10n?.save ?? 'Save';
    final confirmLabel = l10n?.save ?? 'Confirm';
    final deleteLabel = l10n?.delete ?? 'Delete';
    final appNameLabel = l10n?.appName ?? 'AvoScan AI';
    final appVersionLabel = l10n?.appVersion ?? '1.0.0';
    final appDescriptionLabel = l10n?.appDescription ?? 'Avocado Disease Detection';
    final addWorkspaceLabel = l10n?.addWorkspace ?? 'Add Workspace';
    final workspaceNameLabel = l10n?.workspaceName ?? 'Workspace Name';
    final workspaceDescriptionLabel = l10n?.workspaceDescription ?? 'Description';
    final enterNameLabel = l10n?.enterName ?? 'Enter name';
    final optionalDescLabel = l10n?.optionalDescription ?? 'Optional description';
    final deleteWorkspaceLabel = l10n?.deleteWorkspace ?? 'Delete Workspace';
    final sureDeleteLabel = l10n?.sureDelete ?? 'Are you sure you want to delete';
    
    final authProvider = Provider.of<AuthProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(settingsTitle),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile/Auth Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: authProvider.isAuthenticated 
                    ? Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF2E7D32),
                            child: authProvider.currentUser?.photoUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      authProvider.currentUser!.photoUrl!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                        const Icon(Icons.person, size: 40, color: Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.person, size: 40, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authProvider.currentUser?.name ?? 'User',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  authProvider.currentUser?.email ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (authProvider.currentWorkspace != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getWorkspaceIcon(authProvider.currentWorkspace!.type),
                                          size: 16,
                                          color: const Color(0xFF2E7D32),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            authProvider.currentWorkspace!.name,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF2E7D32),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Icon(
                            Icons.account_circle,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Usuario Invitado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Inicia sesión para guardar tu historial de detecciones',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/login'),
                                  child: Text(loginLabel),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/register'),
                                  child: Text(registerLabel),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF2E7D32),
                                    side: const BorderSide(color: Color(0xFF2E7D32)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Settings Sections
            Text(
              settingsTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Language Setting
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.language, color: Color(0xFF2E7D32)),
                title: Text(languageLabel),
                trailing: DropdownButton<Locale>(
                  value: localeProvider.locale,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: Locale('es'),
                      child: Text('Español'),
                    ),
                    DropdownMenuItem(
                      value: Locale('en'),
                      child: Text('English'),
                    ),
                  ],
                  onChanged: (Locale? locale) {
                    if (locale != null) {
                      localeProvider.setLocale(locale);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Workspaces Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Espacios de Trabajo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF2E7D32)),
                  onPressed: () => _showAddWorkspaceDialog(context, authProvider, addWorkspaceLabel, cancelLabel, saveLabel, workspaceNameLabel, workspaceDescriptionLabel, enterNameLabel, optionalDescLabel),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Workspaces List
            if (authProvider.workspaces.isEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.work_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No tienes espacios de trabajo',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _showAddWorkspaceDialog(context, authProvider, addWorkspaceLabel, cancelLabel, saveLabel, workspaceNameLabel, workspaceDescriptionLabel, enterNameLabel, optionalDescLabel),
                          icon: const Icon(Icons.add),
                          label: const Text('Crear el primero'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...authProvider.workspaces.map((workspace) => 
                _buildWorkspaceCard(context, authProvider, workspace, editLabel, deleteLabel, cancelLabel, confirmLabel, deleteWorkspaceLabel, sureDeleteLabel, saveLabel, workspaceNameLabel, workspaceDescriptionLabel, enterNameLabel, optionalDescLabel)
              ),
            
            const SizedBox(height: 24),

            // Profile Settings
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit, color: Color(0xFF2E7D32)),
                    title: Text('$editLabel $profileLabel'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  InkWell(
                    onTap: () => _showAboutDialog(context, appNameLabel, appVersionLabel, appDescriptionLabel, cancelLabel),
                    child: ListTile(
                      leading: const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
                      title: const Text('Acerca de'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button (solo si está autenticado)
            if (authProvider.isAuthenticated) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(logoutLabel),
                        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(cancelLabel),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(logoutLabel),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true && context.mounted) {
                      await authProvider.signOut();
                      // No navegar a login, quedarse en la aplicación principal
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sesión cerrada correctamente'),
                          backgroundColor: Color(0xFF2E7D32),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(logoutLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceCard(
    BuildContext context, 
    AuthProvider authProvider, 
    WorkspaceModel workspace,
    String editLbl,
    String deleteLbl,
    String cancelLbl,
    String confirmLbl,
    String deleteWorkspaceLbl,
    String sureDeleteLbl,
    String saveLbl,
    String workspaceNameLbl,
    String workspaceDescriptionLbl,
    String enterNameLbl,
    String optionalDescLbl
  ) {
    final isCurrent = authProvider.currentWorkspace?.id == workspace.id;
    
    return Card(
      elevation: isCurrent ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrent 
          ? const BorderSide(color: Color(0xFF2E7D32), width: 2)
          : BorderSide.none,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getWorkspaceIcon(workspace.type),
            color: const Color(0xFF2E7D32),
          ),
        ),
        title: Text(
          workspace.name,
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          workspace.description ?? _getWorkspaceTypeLabel(workspace.type),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Actual',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'select') {
                  authProvider.setCurrentWorkspace(workspace.id);
                } else if (value == 'edit') {
                  _showEditWorkspaceDialog(context, authProvider, workspace, editLbl, cancelLbl, saveLbl, workspaceNameLbl, workspaceDescriptionLbl, enterNameLbl, optionalDescLbl);
                } else if (value == 'delete') {
                  _deleteWorkspace(context, authProvider, workspace, cancelLbl, deleteLbl, deleteWorkspaceLbl, sureDeleteLbl);
                }
              },
              itemBuilder: (context) => [
                if (!isCurrent)
                  PopupMenuItem<String>(
                    value: 'select',
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline),
                        const SizedBox(width: 8),
                        const Text('Seleccionar'),
                      ],
                    ),
                  ),
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit),
                      const SizedBox(width: 8),
                      const Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],  
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWorkspaceIcon(String type) {
    switch (type) {
      case 'farm':
        return Icons.agriculture;
      case 'greenhouse':
        return Icons.home_work;
      case 'laboratory':
        return Icons.science;
      case 'home':
        return Icons.home;
      default:
        return Icons.work;
    }
  }

  String _getWorkspaceTypeLabel(String type) {
    switch (type) {
      case 'farm':
        return 'Finca';
      case 'greenhouse':
        return 'Invernadero';
      case 'laboratory':
        return 'Laboratorio';
      case 'home':
        return 'Casa';
      default:
        return 'Otro';
    }
  }

  void _showAddWorkspaceDialog(
    BuildContext context, 
    AuthProvider authProvider, 
    String addWorkspaceLbl,
    String cancelLbl,
    String saveLbl,
    String workspaceNameLbl,
    String workspaceDescriptionLbl,
    String enterNameLbl,
    String optionalDescLbl
  ) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'farm';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(addWorkspaceLbl),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: workspaceNameLbl,
                    hintText: enterNameLbl,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'farm', child: Text('🌾 Finca')),
                    DropdownMenuItem(value: 'greenhouse', child: Text('🏗️ Invernadero')),
                    DropdownMenuItem(value: 'laboratory', child: Text('🔬 Laboratorio')),
                    DropdownMenuItem(value: 'home', child: Text('🏠 Casa')),
                    DropdownMenuItem(value: 'other', child: Text('📍 Otro')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: workspaceDescriptionLbl,
                    hintText: optionalDescLbl,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(cancelLbl),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  final success = await authProvider.createWorkspace(
                    nameController.text.trim(),
                    selectedType,
                    descriptionController.text.trim().isNotEmpty
                        ? descriptionController.text.trim()
                        : null,
                  );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Espacio de trabajo creado')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: Text(saveLbl),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditWorkspaceDialog(
    BuildContext context, 
    AuthProvider authProvider, 
    WorkspaceModel workspace,
    String editWorkspaceLbl,
    String cancelLbl,
    String saveLbl,
    String workspaceNameLbl,
    String workspaceDescriptionLbl,
    String enterNameLbl,
    String optionalDescLbl
  ) {
    final nameController = TextEditingController(text: workspace.name);
    final descriptionController = TextEditingController(text: workspace.description);
    String selectedType = workspace.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(editWorkspaceLbl),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: workspaceNameLbl,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'farm', child: Text('🌾 Finca')),
                    DropdownMenuItem(value: 'greenhouse', child: Text('🏗️ Invernadero')),
                    DropdownMenuItem(value: 'laboratory', child: Text('🔬 Laboratorio')),
                    DropdownMenuItem(value: 'home', child: Text('🏠 Casa')),
                    DropdownMenuItem(value: 'other', child: Text('📍 Otro')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: workspaceDescriptionLbl,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(cancelLbl),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  final success = await authProvider.updateWorkspace(
                    workspace.id,
                    name: nameController.text.trim(),
                    type: selectedType,
                    description: descriptionController.text.trim().isNotEmpty
                        ? descriptionController.text.trim()
                        : null,
                  );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Espacio actualizado')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: Text(saveLbl),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteWorkspace(
    BuildContext context, 
    AuthProvider authProvider, 
    WorkspaceModel workspace,
    String cancelLbl,
    String deleteLbl,
    String deleteWorkspaceLbl,
    String sureDeleteLbl
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(deleteWorkspaceLbl),
        content: Text('$sureDeleteLbl "${workspace.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelLbl),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await authProvider.deleteWorkspace(workspace.id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Espacio eliminado')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: Text(deleteLbl),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(
    BuildContext context, 
    String appNameLbl, 
    String appVersionLbl, 
    String appDescriptionLbl,
    String cancelLbl
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Text(appNameLbl),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: $appVersionLbl'),
            const SizedBox(height: 12),
            Text(
              appDescriptionLbl,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2026 ESPE - Thesis Project',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelLbl),
          ),
        ],
      ),
    );
  }
}
