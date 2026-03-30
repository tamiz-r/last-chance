// lib/screens/home/home_screen.dart  (USER APP)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/poll_model.dart';
import 'poll_card.dart';
import '../history/history_screen.dart';
import '../wallet/wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildTabBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LAST CHANCE',
                  style: GoogleFonts.bebasNeue(
                      fontSize: 28, color: Colors.white, letterSpacing: 2)),
              Text(
                DateFormat('EEEE, d MMMM').format(DateTime.now()).toUpperCase(),
                style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 2),
              ),
            ],
          ),
          const Spacer(),
          // Wallet balance chip
          StreamBuilder<UserWalletModel?>(
            stream: _firestoreService.myWallet,
            builder: (ctx, snap) {
              final balance = snap.data?.balance ?? 0.0;
              return GestureDetector(
                onTap: () => setState(() => _selectedTab = 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    border: Border.all(color: Colors.white12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          color: Colors.white38, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '₹${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              await _authService.signOut();
            },
            child: const Icon(Icons.logout, color: Colors.white30, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = ['TODAY', 'HISTORY', 'WALLET'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = _selectedTab == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.transparent,
                border: Border.all(color: active ? Colors.white : Colors.white24),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  color: active ? Colors.black : Colors.white38,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedTab) {
      case 0:
        return _buildTodayPolls();
      case 1:
        return const HistoryScreen();
      case 2:
        return const WalletScreen();
      default:
        return _buildTodayPolls();
    }
  }

  Widget _buildTodayPolls() {
    return StreamBuilder<List<PollModel>>(
      stream: _firestoreService.todayPolls,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
              child: Text('Error: ${snap.error}',
                  style: const TextStyle(color: Colors.red)));
        }
        final polls = snap.data ?? [];
        if (polls.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_empty, color: Colors.white24, size: 48),
                const SizedBox(height: 16),
                Text("No polls today.",
                    style: TextStyle(color: Colors.white38, fontSize: 14, letterSpacing: 2)),
                const SizedBox(height: 8),
                Text("Check back later.",
                    style: TextStyle(color: Colors.white24, fontSize: 12)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          itemCount: polls.length,
          itemBuilder: (_, i) => PollCard(poll: polls[i]),
        );
      },
    );
  }
}
