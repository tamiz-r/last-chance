// lib/screens/home/poll_card.dart  (USER APP)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/poll_model.dart';
import '../../services/firestore_service.dart';

class PollCard extends StatelessWidget {
  final PollModel poll;
  const PollCard({super.key, required this.poll});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return StreamBuilder<UserSelectionModel?>(
      stream: service.selectionForPoll(poll.id),
      builder: (context, snap) {
        final selection = snap.data;
        return _PollCardInner(
          poll: poll,
          selection: selection,
          service: service,
        );
      },
    );
  }
}

class _PollCardInner extends StatefulWidget {
  final PollModel poll;
  final UserSelectionModel? selection;
  final FirestoreService service;

  const _PollCardInner({
    required this.poll,
    required this.selection,
    required this.service,
  });

  @override
  State<_PollCardInner> createState() => _PollCardInnerState();
}

class _PollCardInnerState extends State<_PollCardInner> {
  bool _submitting = false;

  Future<void> _select(String option) async {
    if (_submitting || widget.selection != null) return;
    setState(() => _submitting = true);
    try {
      await widget.service.submitSelection(widget.poll.id, option);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final poll = widget.poll;
    final selection = widget.selection;
    final hasSelected = selection != null;
    final showResult = poll.showResult && poll.result != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(
          color: showResult
              ? _resultColor(poll.result!, selection?.selectedOption).withOpacity(0.5)
              : Colors.white12,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status bar
            Row(
              children: [
                _statusChip(showResult, hasSelected, selection, poll),
                const Spacer(),
                Text(
                  '₹${poll.rewardA.toStringAsFixed(0)} / ₹${poll.rewardB.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white30, fontSize: 11, letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question
            Text(
              poll.question,
              style: GoogleFonts.bebasNeue(
                  fontSize: 22, color: Colors.white, letterSpacing: 1, height: 1.2),
            ),
            const SizedBox(height: 20),

            // Result revealed banner
            if (showResult) _buildResultBanner(poll, selection),

            // Option buttons
            if (!showResult) ...[
              _buildOptionButton(
                label: poll.optionA,
                option: 'A',
                reward: poll.rewardA,
                selected: selection?.selectedOption == 'A',
                disabled: hasSelected || _submitting,
                onTap: () => _select('A'),
              ),
              const SizedBox(height: 10),
              _buildOptionButton(
                label: poll.optionB,
                option: 'B',
                reward: poll.rewardB,
                selected: selection?.selectedOption == 'B',
                disabled: hasSelected || _submitting,
                onTap: () => _select('B'),
              ),
              if (!hasSelected) ...[
                const SizedBox(height: 12),
                const Text(
                  'You can change your vote anytime until results are revealed.',
                  style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 0.5),
                ),
              ]
            ],

            // Waiting message after selection, before result
            if (hasSelected && !showResult) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: Colors.white38),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your choice: ${selection.selectedOption == "A" ? poll.optionA : poll.optionB} — Awaiting result...',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String label,
    required String option,
    required double reward,
    required bool selected,
    required bool disabled,
    required VoidCallback onTap,
  }) {
    final color = option == 'A' ? const Color(0xFFBA7517) : const Color(0xFFE24B4A);
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : const Color(0xFF1E1E1E),
          border: Border.all(
            color: selected ? color : Colors.white12,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              width: 26, height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? color : Colors.transparent,
                border: Border.all(color: selected ? color : Colors.white24),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(option,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white38,
                    fontSize: 12, fontWeight: FontWeight.bold,
                  )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 14,
                  )),
            ),
            Text(
              '₹${reward.toStringAsFixed(0)}',
              style: TextStyle(
                color: selected ? color : Colors.white38,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBanner(PollModel poll, UserSelectionModel? selection) {
    final won = selection != null && selection.selectedOption == poll.result;
    final userPicked = selection?.selectedOption;
    final winLabel = poll.result == 'A' ? poll.optionA : poll.optionB;
    final userLabel = userPicked == 'A' ? poll.optionA : poll.optionB;
    final reward = poll.result == 'A' ? poll.rewardA : poll.rewardB;

    return Column(
      children: [
        // Winning option
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1D9E75).withOpacity(0.12),
            border: Border.all(color: const Color(0xFF1D9E75).withOpacity(0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('WINNING RESULT',
                  style: TextStyle(fontSize: 9, letterSpacing: 3, color: Color(0xFF1D9E75))),
              const SizedBox(height: 4),
              Text(winLabel,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // User result
        if (selection != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: won
                  ? const Color(0xFF1D9E75).withOpacity(0.08)
                  : const Color(0xFFE24B4A).withOpacity(0.08),
              border: Border.all(
                  color: won
                      ? const Color(0xFF1D9E75).withOpacity(0.4)
                      : const Color(0xFFE24B4A).withOpacity(0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(won ? Icons.check_circle : Icons.cancel,
                    color: won ? const Color(0xFF1D9E75) : const Color(0xFFE24B4A),
                    size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(won ? 'YOU WON' : 'YOU LOST',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: won ? const Color(0xFF1D9E75) : const Color(0xFFE24B4A),
                          )),
                      Text('Your pick: $userLabel',
                          style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                if (won)
                  Text('+₹${reward.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Color(0xFF1D9E75),
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white10),
            ),
            child: const Text('You did not participate in this poll.',
                style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _statusChip(bool showResult, bool hasSelected,
      UserSelectionModel? selection, PollModel poll) {
    if (showResult) {
      final won = selection != null && selection.selectedOption == poll.result;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: won ? const Color(0xFF1D9E75).withOpacity(0.15) : const Color(0xFFE24B4A).withOpacity(0.15),
          border: Border.all(
              color: won ? const Color(0xFF1D9E75) : const Color(0xFFE24B4A),
              width: 0.5),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(won ? 'RESULT: WIN' : 'RESULT: LOSS',
            style: TextStyle(
                fontSize: 9,
                letterSpacing: 2,
                color: won ? const Color(0xFF1D9E75) : const Color(0xFFE24B4A))),
      );
    }
    if (hasSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFBA7517).withOpacity(0.12),
          border: Border.all(color: const Color(0xFFBA7517), width: 0.5),
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Text('VOTED', style: TextStyle(fontSize: 9, letterSpacing: 2, color: Color(0xFFBA7517))),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white24, width: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: const Text('OPEN', style: TextStyle(fontSize: 9, letterSpacing: 2, color: Colors.white38)),
    );
  }

  Color _resultColor(String result, String? userPick) {
    if (userPick == null) return Colors.white24;
    return userPick == result ? const Color(0xFF1D9E75) : const Color(0xFFE24B4A);
  }
}
