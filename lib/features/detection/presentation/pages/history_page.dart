import 'package:flutter/material.dart';
import '../../domain/entities/detection_result.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../widgets/result_card.dart';

class HistoryPage extends StatefulWidget {
  final List<DetectionResult> history;

  const HistoryPage({
    Key? key,
    required this.history,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late List<DetectionResult> _filteredHistory;

  @override
  void initState() {
    super.initState();
    _filteredHistory = widget.history;
  }

  void _deleteItem(int index) {
    setState(() {
      _filteredHistory.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.history),
        backgroundColor: AppColors.primary,
      ),
      body: _filteredHistory.isEmpty
          ? Center(
              child: Text(
                AppStrings.noHistoryFound,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredHistory.length,
              itemBuilder: (context, index) {
                final result = _filteredHistory[index];
                return Dismissible(
                  key: Key(result.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteItem(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Result deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            setState(() {
                              _filteredHistory.insert(index, result);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  background: Container(
                    color: AppColors.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(
                      Icons.delete,
                      color: AppColors.white,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ResultCard(result: result),
                  ),
                );
              },
            ),
    );
  }
}
