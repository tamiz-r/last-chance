// lib/screens/history/history_screen.dart  (USER APP)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/poll_model.dart';
import '../../services/firestore_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return StreamBuilder<List<UserSelectionModel>>(
      stream: service.mySelections,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final selections = snap.data ?? [];
        if (selections.isEmpty) {
          return const Center(
            child: Text('No history yet.\nStart voting!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 14, height: 1.6)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          itemCount: selections.length,
          itemBuilder: (_, i) {
            final s = selections[i];
            final won = s.resultProcessed && s.earnedAmount != null && s.earnedAmount! > 0;
            final pending = !s.resultProcessed;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                border: Border.all(
                  color: pending
                      ? Colors.white12
                      : won
                          ? const Color(0xFF1D9E75).withOpacity(0.4)
                          : const Color(0xFFE24B4A).withOpacity(0.4),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    pending
                        ? Icons.hourglass_top
                        : won
                            ? Icons.check_circle
                            : Icons.cancel,
                    color: pending
                        ? Colors.white30
                        : won
                            ? const Color(0xFF1D9E75)
                            : const Color(0xFFE24B4A),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Poll: ${s.pollId}',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11, letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text('Chose: Option ${s.selectedOption}',
                            style: const TextStyle(color: Colors.white, fontSize: 13)),
                        Text(
                          DateFormat('d MMM yyyy, h:mm a').format(s.selectedAt),
                          style: const TextStyle(color: Colors.white30, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  if (pending)
                    const Text('Pending',
                        style: TextStyle(color: Colors.white30, fontSize: 11))
                  else
                    Text(
                      won ? '+₹${s.earnedAmount!.toStringAsFixed(2)}' : '₹0',
                      style: TextStyle(
                        color: won ? const Color(0xFF1D9E75) : const Color(0xFFE24B4A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
