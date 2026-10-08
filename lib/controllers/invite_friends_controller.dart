// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../imports.dart';
import '../models/invite_point_model.dart';

class InviteFriendsController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  bool isLoading = true;

  InvitePointModel? invitePoint;

  InviteFriendsController() {
    _load();
  }

  Future<void> _load() async {
    isLoading = true;
    update();

    await ApiService.api.getInvitePointListing(
      onSuccess: (response) {
        if (response.data is Map) {
          invitePoint = InvitePointModel.fromJson(
            Map<String, dynamic>.from(response.data),
          );
        }
      },
    );

    isLoading = false;
    update();
  }

  Future<void> onRefresh() async {
    await _load();
    refreshController.refreshCompleted();
  }

  String? get inviteCode => context.read<AppController>().user?.referralCode;

  void onCopyCode() {
    final String? code = inviteCode;
    if (code == null || code.isEmpty) return;

    copyToClipboard(contentToCopy: code);
  }

  Future<void> onInvite() async {
    final String? code = inviteCode;
    if (code == null || code.isEmpty) return;

    await SharePlus.instance.share(
      ShareParams(text: context.tr(AppStrings.inviteShareText, args: [code])),
    );
  }

  void onClaimAll() => ToastHelper.showToast(context.tr(AppStrings.comingSoon));

  void onClaim(InvitePointTierModel tier) =>
      ToastHelper.showToast(context.tr(AppStrings.comingSoon));

  @override
  void dispose() {
    _isDisposed = true;
    refreshController.dispose();
    super.dispose();
  }

  void update() {
    if (!_isDisposed) notifyListeners();
  }
}
