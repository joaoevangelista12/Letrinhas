// arquivo: lib/widgets/protected_activity.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';
import '../utils/accessibility_scaler.dart';
import '../main.dart';
import '../models/activity_model.dart';
import '../services/firestore_service.dart';

/// Widget que protege o acesso a atividades baseado no nível do usuário.
///
/// Este widget atua como um guard de rota, validando se o usuário
/// tem permissão para acessar a atividade antes de renderizá-la.
///
/// **Proteção em Múltiplas Camadas:**
/// 1. Verifica autenticação do usuário
/// 2. Carrega nível atual do Firestore
/// 3. Valida se o nível permite acesso à atividade
/// 4. Bloqueia acesso mesmo com navegação forçada
///
/// **Uso:**
/// ```dart
/// ProtectedActivity(
///   activityId: Activities.matchWordsId,
///   child: ActivityMatchWords(),
/// )
/// ```
class ProtectedActivity extends StatefulWidget {
  /// ID da atividade a ser protegida
  final String activityId;

  /// Widget da atividade a ser exibido se o acesso for permitido
  final Widget child;

  const ProtectedActivity({
    super.key,
    required this.activityId,
    required this.child,
  });

  @override
  State<ProtectedActivity> createState() => _ProtectedActivityState();
}

class _ProtectedActivityState extends State<ProtectedActivity> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  bool _hasAccess = false;
  String? _errorMessage;
  ActivityModel? _activity;
  int? _userLevel;

  @override
  void initState() {
    super.initState();
    _validateAccess();
  }

  /// Valida se o usuário tem acesso à atividade.
  ///
  /// Processo de validação:
  /// 1. Obtém dados do usuário autenticado
  /// 2. Busca informações da atividade
  /// 3. Verifica nível necessário vs nível do usuário
  /// 4. Define se deve permitir ou bloquear acesso
  Future<void> _validateAccess() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // 1. VALIDA AUTENTICAÇÃO
      if (userProvider.uid == null) {
        setState(() {
          _errorMessage = 'Você precisa estar logado para acessar esta atividade.';
          _hasAccess = false;
          _isLoading = false;
        });
        return;
      }

      // 2. BUSCA DADOS DO USUÁRIO NO FIRESTORE
      final userData = await _firestoreService.getUser(userProvider.uid!);
      if (userData == null) {
        setState(() {
          _errorMessage = 'Erro ao carregar dados do usuário.';
          _hasAccess = false;
          _isLoading = false;
        });
        return;
      }

      // 3. BUSCA INFORMAÇÕES DA ATIVIDADE
      final activity = Activities.getById(widget.activityId);
      if (activity == null) {
        setState(() {
          _errorMessage = 'Atividade não encontrada.';
          _hasAccess = false;
          _isLoading = false;
        });
        return;
      }

      // 4. VALIDA NÍVEL DE ACESSO
      final canAccess = activity.canAccess(userData.level);

      setState(() {
        _activity = activity;
        _userLevel = userData.level;
        _hasAccess = canAccess;
        _errorMessage = canAccess
            ? null
            : 'Você precisa estar no nível ${activity.requiredLevel} para acessar esta atividade.\n\nSeu nível atual: ${userData.level}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao validar acesso: $e';
        _hasAccess = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tela de carregamento
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Carregando...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Tela de acesso negado
    if (!_hasAccess) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Acesso Negado'),
          backgroundColor: Colors.red[700],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: context.scaleIcon(80),
                  color: Colors.red[700],
                ),
                const SizedBox(height: 24),
                Text(
                  'Atividade Bloqueada',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                if (_activity != null && _userLevel != null)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[300]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Como Desbloquear',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete as atividades anteriores para subir de nível e desbloquear "${_activity!.name}".',
                          style: TextStyle(color: Colors.orange[900]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back),
                  label: Text('Voltar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Acesso permitido - renderiza a atividade
    return widget.child;
  }
}
