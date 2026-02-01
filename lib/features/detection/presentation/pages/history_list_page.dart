import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/database/database_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HistoryListPage extends StatefulWidget {
  const HistoryListPage({Key? key}) : super(key: key);

  @override
  State<HistoryListPage> createState() => _HistoryListPageState();
}

class _HistoryListPageState extends State<HistoryListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _detections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetections();
  }

  Future<void> _loadDetections() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) {
      setState(() {
        _detections = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    final detections = await _dbHelper.getDetections(
      authProvider.currentUser!.id,
      limit: 100,
    );

    setState(() {
      _detections = detections;
      _isLoading = false;
    });
  }

  Future<void> _deleteDetection(String id, int index) async {
    await _dbHelper.deleteDetection(id);
    setState(() {
      _detections.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final historyLabel = l10n?.history ?? 'History';
    final noHistoryLabel = l10n?.noHistoryFound ?? 'No history found';
    final healthyLabel = l10n?.healthy ?? 'Healthy';
    final manchaNegraLabel = l10n?.manchaNegra ?? 'Black Spot';
    final ronaLabel = l10n?.rona ?? 'Scab';
    final confidenceLabel = l10n?.confidence ?? 'Confidence';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(historyLabel),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDetections,
              child: _detections.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            noHistoryLabel,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _detections.length,
                      itemBuilder: (context, index) {
                        final detection = _detections[index];
                        return _buildDetectionCard(
                          detection,
                          index,
                          healthyLabel,
                          manchaNegraLabel,
                          ronaLabel,
                          confidenceLabel,
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildDetectionCard(
    Map<String, dynamic> detection,
    int index,
    String healthyLabel,
    String manchaNegraLabel,
    String ronaLabel,
    String confidenceLabel,
  ) {
    final disease = detection['disease'] as String;
    final confidence = (detection['confidence'] as double) * 100;
    final timestamp = DateTime.parse(detection['timestamp'] as String);

    Color diseaseColor;
    IconData diseaseIcon;
    String diseaseLabel;

    switch (disease) {
      case 'healthy':
        diseaseColor = const Color(0xFF388E3C);
        diseaseIcon = Icons.check_circle;
        diseaseLabel = healthyLabel;
        break;
      case 'manchaNegra':
        diseaseColor = const Color(0xFFF57C00);
        diseaseIcon = Icons.warning;
        diseaseLabel = manchaNegraLabel;
        break;
      case 'rona':
        diseaseColor = const Color(0xFFD32F2F);
        diseaseIcon = Icons.error;
        diseaseLabel = ronaLabel;
        break;
      default:
        diseaseColor = Colors.grey;
        diseaseIcon = Icons.help;
        diseaseLabel = disease;
    }

    return Dismissible(
      key: Key(detection['id'] as String),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteDetection(detection['id'] as String, index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Detección eliminada'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: diseaseColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: diseaseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(diseaseIcon, color: diseaseColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diseaseLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: diseaseColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$confidenceLabel: ${confidence.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
