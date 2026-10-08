// Project imports:
import '../utils/parser.dart';

/// The invite-friends rewards, from the invite-point-listing API: how many
/// friends joined, the points to claim, and this round's reward tiers.
class InvitePointModel {
  String? banner;
  bool canClaimAll = false;
  int claimableCount = 0;
  double claimablePoint = 0;
  bool hasClaimable = false;

  /// The current round (1-based) of [totalRounds].
  int round = 1;
  int totalRounds = 1;
  int successfulInvites = 0;
  double totalClaimedPoint = 0;
  int totalSlots = 0;
  int totalUnlockedCount = 0;
  int unlockedInRound = 0;

  /// This round's tiers: the reward for the nth friend.
  List<InvitePointTierModel> tiers = [];

  InvitePointModel.fromJson(Map<String, dynamic> json) {
    banner = json['banner']?.toString();
    canClaimAll = parseBool(json['can_claim_all']);
    claimableCount = parseInt(json['claimable_count']);
    claimablePoint = parseDouble(json['claimable_point']);
    hasClaimable = parseBool(json['has_claimable']);
    round = parseInt(json['round'], 1);
    totalRounds = parseInt(json['total_rounds'], 1);
    successfulInvites = parseInt(json['successful_invites']);
    totalClaimedPoint = parseDouble(json['total_claimed_point']);
    totalSlots = parseInt(json['total_slots']);
    totalUnlockedCount = parseInt(json['total_unlocked_count']);
    unlockedInRound = parseInt(json['unlocked_in_round']);
    tiers = InvitePointTierModel.listFromJson(json['tiers']);
  }

  /// Stand-in values for the page's loading skeleton.
  InvitePointModel.placeholder() {
    tiers = [
      for (int i = 1; i <= 5; i++)
        InvitePointTierModel.fromJson({'position': i, 'point_amount': 10}),
    ];
  }
}

/// One reward of the round: [pointAmount] for the [position]th friend.
class InvitePointTierModel {
  int position = 0;
  double pointAmount = 0;

  /// Not reached yet (fewer friends than [position]).
  bool isLocked = true;

  /// Reached and still to claim.
  bool isAvailable = false;

  InvitePointTierModel.fromJson(Map<String, dynamic> json) {
    position = parseInt(json['position']);
    pointAmount = parseDouble(json['point_amount']);
    isLocked = parseBool(json['is_locked'], true);
    isAvailable = parseBool(json['is_available']);
  }

  /// Reached and already claimed.
  bool get isClaimed => !isLocked && !isAvailable;

  static List<InvitePointTierModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              InvitePointTierModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
