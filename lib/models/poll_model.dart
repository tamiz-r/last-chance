// lib/models/poll_model.dart
// Shared model — copy this file to both apps

class PollModel {
  final String id;
  final String question;
  final String optionA;
  final String optionB;
  final double rewardA;   // money earned if option A wins
  final double rewardB;   // money earned if option B wins
  final String? result;   // 'A' | 'B' | null
  final bool showResult;  // admin toggles this to reveal result to users
  final DateTime date;    // the day this poll is active
  final bool isActive;

  PollModel({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.rewardA,
    required this.rewardB,
    this.result,
    required this.showResult,
    required this.date,
    required this.isActive,
  });

  factory PollModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PollModel(
      id: id,
      question: data['question'] ?? '',
      optionA: data['optionA'] ?? 'Option A',
      optionB: data['optionB'] ?? 'Option B',
      rewardA: (data['rewardA'] ?? 0).toDouble(),
      rewardB: (data['rewardB'] ?? 0).toDouble(),
      result: data['result'],
      showResult: data['showResult'] ?? false,
      date: (data['date'] as dynamic).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'rewardA': rewardA,
      'rewardB': rewardB,
      'result': result,
      'showResult': showResult,
      'date': date,
      'isActive': isActive,
    };
  }
}

class UserSelectionModel {
  final String id;
  final String userId;
  final String userEmail;
  final String pollId;
  final String selectedOption; // 'A' or 'B'
  final DateTime selectedAt;
  final double? earnedAmount;  // filled after result revealed
  final bool resultProcessed;

  UserSelectionModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.pollId,
    required this.selectedOption,
    required this.selectedAt,
    this.earnedAmount,
    required this.resultProcessed,
  });

  factory UserSelectionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserSelectionModel(
      id: id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      pollId: data['pollId'] ?? '',
      selectedOption: data['selectedOption'] ?? '',
      selectedAt: (data['selectedAt'] as dynamic).toDate(),
      earnedAmount: data['earnedAmount']?.toDouble(),
      resultProcessed: data['resultProcessed'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'pollId': pollId,
      'selectedOption': selectedOption,
      'selectedAt': selectedAt,
      'earnedAmount': earnedAmount,
      'resultProcessed': resultProcessed,
    };
  }
}

class UserWalletModel {
  final String userId;
  final String email;
  final double balance;
  final double totalEarned;
  final DateTime lastUpdated;

  UserWalletModel({
    required this.userId,
    required this.email,
    required this.balance,
    required this.totalEarned,
    required this.lastUpdated,
  });

  factory UserWalletModel.fromFirestore(Map<String, dynamic> data) {
    return UserWalletModel(
      userId: data['userId'] ?? '',
      email: data['email'] ?? '',
      balance: (data['balance'] ?? 0).toDouble(),
      totalEarned: (data['totalEarned'] ?? 0).toDouble(),
      lastUpdated: (data['lastUpdated'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'email': email,
      'balance': balance,
      'totalEarned': totalEarned,
      'lastUpdated': lastUpdated,
    };
  }
}
