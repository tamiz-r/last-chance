// lib/screens/wallet/wallet_screen.dart  (USER APP)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/poll_model.dart';
import '../../services/firestore_service.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return StreamBuilder<UserWalletModel?>(
      stream: service.myWallet,
      builder: (context, snap) {
        final wallet = snap.data;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CURRENT BALANCE',
                        style: TextStyle(
                            fontSize: 10, letterSpacing: 3, color: Colors.white38)),
                    const SizedBox(height: 10),
                    Text(
                      wallet != null
                          ? '₹${wallet.balance.toStringAsFixed(2)}'
                          : '₹0.00',
                      style: GoogleFonts.bebasNeue(
                          fontSize: 48, color: Colors.white, letterSpacing: 2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total earned: ₹${(wallet?.totalEarned ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats row
              Row(
                children: [
                  _statBox('BALANCE', '₹${(wallet?.balance ?? 0).toStringAsFixed(2)}',
                      const Color(0xFF1D9E75)),
                  const SizedBox(width: 12),
                  _statBox('TOTAL EARNED', '₹${(wallet?.totalEarned ?? 0).toStringAsFixed(2)}',
                      const Color(0xFFBA7517)),
                ],
              ),
              const SizedBox(height: 28),

              const Text('HOW REWARDS WORK',
                  style: TextStyle(fontSize: 10, letterSpacing: 3, color: Colors.white38)),
              const SizedBox(height: 14),

              _infoRow(Icons.how_to_vote_outlined,
                  'Vote on a daily poll by choosing Option A or B.'),
              _infoRow(Icons.timer_outlined,
                  'You can change your vote anytime during the day.'),
              _infoRow(Icons.notifications_outlined,
                  'When the admin reveals the result, the winning option is announced.'),
              _infoRow(Icons.account_balance_wallet_outlined,
                  'If your vote matches the winning option, the reward is added to your wallet instantly.'),
              _infoRow(Icons.info_outline,
                  'Reward amounts are set per poll and shown on each option button.'),
            ],
          ),
        );
      },
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 9, letterSpacing: 2, color: color)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white24, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
