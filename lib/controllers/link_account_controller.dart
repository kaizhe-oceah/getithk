// Project imports:
import '../imports.dart';
import '../models/social_account_model.dart';

class LinkAccountController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;
  bool _isLinking = false;

  final RefreshController refreshController = RefreshController();

  bool isLoading = true;

  List<SocialAccountModel> accounts = [];

  LinkAccountController() {
    _load();
  }

  // one unlinked row per provider for the loading skeleton
  List<SocialAccountModel> get displayAccounts => isLoading
      ? [
          for (final provider in SocialProvider.values)
            SocialAccountModel(provider),
        ]
      : accounts;

  Future<void> _load() async {
    await ApiService.api.getSocialAccounts(
      onSuccess: (response) {
        accounts = SocialAccountModel.listFromJson(response.data);
      },
    );

    isLoading = false;
    update();
  }

  Future<void> onRefresh() async {
    await _load();
    refreshController.refreshCompleted();
  }

  Future<void> onLink(SocialProvider provider) async {
    if (_isLinking) return;
    _isLinking = true;

    final String? token = await context.read<AppController>().socialToken(
      provider,
    );
    if (token != null) {
      await ApiService.api.linkSocialAccount(
        provider: provider,
        token: token,
        showLoader: true,
        onSuccess: (response) {
          response.showMessage();
          if (!_isDisposed) _load();
        },
      );
    }

    _isLinking = false;
  }

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
