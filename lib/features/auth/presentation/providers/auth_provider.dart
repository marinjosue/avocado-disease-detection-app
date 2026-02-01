import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/user_model.dart';
import '../../data/models/workspace_model.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  
  UserModel? _currentUser;
  WorkspaceModel? _currentWorkspace;
  List<WorkspaceModel> _workspaces = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  WorkspaceModel? get currentWorkspace => _currentWorkspace;
  List<WorkspaceModel> get workspaces => _workspaces;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId != null) {
        await _loadUserData(userId);
      }
    } catch (e) {
      // Silenciosamente ignorar errores de inicialización
      // La app funcionará sin datos de usuario por ahora
      print('Error during auth initialization: $e');
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final userData = await _dbHelper.getUser(userId);
      if (userData != null) {
        _currentUser = UserModel.fromJson(userData);
        
        // Cargar workspaces del usuario
        await _loadWorkspaces();
        
        // Cargar workspace actual si existe
        if (_currentUser!.currentWorkspaceId != null) {
          final workspaceData = await _dbHelper.getWorkspace(_currentUser!.currentWorkspaceId!);
          if (workspaceData != null) {
            _currentWorkspace = WorkspaceModel.fromJson(workspaceData);
          }
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);
        notifyListeners();
      }
    } catch (e) {
      // Ignorar errores de carga de datos de usuario
      // La app funcionará sin estos datos por ahora
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadWorkspaces() async {
    if (_currentUser == null) return;
    
    try {
      final workspacesList = await _dbHelper.getWorkspaces(_currentUser!.id);
      _workspaces = workspacesList.map((w) => WorkspaceModel.fromJson(w)).toList();
      notifyListeners();
    } catch (e) {
      // Ignorar errores de carga de workspaces
      print('Error loading workspaces: $e');
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Buscar usuario por email (simulación simple)
      // En producción, deberías tener una tabla de credenciales con hash de contraseña
      final prefs = await SharedPreferences.getInstance();
      final storedPassword = prefs.getString('password_$email');
      
      if (storedPassword == null) {
        _errorMessage = 'Usuario no encontrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      if (storedPassword != password) {
        _errorMessage = 'Contraseña incorrecta';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final userId = prefs.getString('userId_$email');
      if (userId != null) {
        await _loadUserData(userId);
        await _updateLastLogin(userId);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Verificar si el usuario ya existe
      final existingPassword = prefs.getString('password_$email');
      if (existingPassword != null) {
        _errorMessage = 'El email ya está registrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Crear nuevo usuario
      final userId = _uuid.v4();
      final user = UserModel(
        id: userId,
        email: email,
        name: name,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _dbHelper.insertUser(user.toJson());
      
      // Guardar credenciales
      await prefs.setString('password_$email', password);
      await prefs.setString('userId_$email', userId);
      await prefs.setString('user_id', userId);
      
      // Crear workspace por defecto
      await createWorkspace('Mi Espacio', 'other', 'Espacio de trabajo principal');
      
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateUserProfile({String? name, String? photoUrl}) async {
    if (_currentUser == null) return;

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      
      if (updates.isNotEmpty) {
        await _dbHelper.updateUser(_currentUser!.id, updates);
        _currentUser = _currentUser!.copyWith(name: name, photoUrl: photoUrl);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _updateLastLogin(String userId) async {
    await _dbHelper.updateUser(userId, {
      'lastLogin': DateTime.now().toIso8601String(),
    });
  }

  // Workspace management
  Future<bool> createWorkspace(String name, String type, String? description) async {
    if (_currentUser == null) return false;

    try {
      final workspaceId = _uuid.v4();
      final workspace = WorkspaceModel(
        id: workspaceId,
        name: name,
        type: type,
        description: description,
        createdAt: DateTime.now(),
      );

      await _dbHelper.insertWorkspace({
        ...workspace.toJson(),
        'userId': _currentUser!.id,
      });

      // Si es el primer workspace, establecerlo como actual
      if (_workspaces.isEmpty) {
        await setCurrentWorkspace(workspaceId);
      }

      await _loadWorkspaces();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateWorkspace(String workspaceId, {String? name, String? type, String? description}) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (type != null) updates['type'] = type;
      if (description != null) updates['description'] = description;

      if (updates.isNotEmpty) {
        await _dbHelper.updateWorkspace(workspaceId, updates);
        
        // Actualizar workspace actual si es el que se está editando
        if (_currentWorkspace?.id == workspaceId) {
          _currentWorkspace = _currentWorkspace!.copyWith(
            name: name,
            type: type,
            description: description,
          );
        }
        
        await _loadWorkspaces();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWorkspace(String workspaceId) async {
    try {
      await _dbHelper.deleteWorkspace(workspaceId);
      
      // Si es el workspace actual, limpiar
      if (_currentWorkspace?.id == workspaceId) {
        _currentWorkspace = null;
        if (_currentUser != null) {
          await _dbHelper.updateUser(_currentUser!.id, {'currentWorkspaceId': null});
        }
      }
      
      await _loadWorkspaces();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> setCurrentWorkspace(String workspaceId) async {
    if (_currentUser == null) return;

    try {
      final workspaceData = await _dbHelper.getWorkspace(workspaceId);
      if (workspaceData != null) {
        _currentWorkspace = WorkspaceModel.fromJson(workspaceData);
        
        await _dbHelper.updateUser(_currentUser!.id, {
          'currentWorkspaceId': workspaceId,
        });
        
        _currentUser = _currentUser!.copyWith(currentWorkspaceId: workspaceId);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    
    _currentUser = null;
    _currentWorkspace = null;
    _workspaces = [];
    notifyListeners();
  }
}
