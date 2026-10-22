// Project imports:
import '../imports.dart';
import '../models/avatar_setting_model.dart';

class EditProfileController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final TextEditingController nameController = TextEditingController();

  bool isLoading = true;

  AvatarSettingModel? setting;

  /// The avatar picked; the player's own to start with.
  AvatarModel? avatar;

  EditProfileController() {
    _load();
  }

  Future<void> _load() async {
    await ApiService.api.getAvatarSetting(
      onSuccess: (response) {
        if (response.data is! Map) return;

        final AvatarSettingModel value = AvatarSettingModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        setting = value;
        avatar = value.avatars
            .where((element) => element.id == value.avatarId)
            .firstOrNull;
        nameController.text = value.name ?? '';
      },
    );

    isLoading = false;
    update();
  }

  /// The picked avatar's picture, else the player's own.
  String? get avatarImage => avatar?.image ?? setting?.avatarImage;

  void onSelectAvatar(AvatarModel value) {
    if (value.id == avatar?.id) return;

    avatar = value;
    update();
  }

  /// The name back to the player's own.
  void onResetName() => nameController.text = setting?.name ?? '';

  /// 儲存: the name, the picked avatar and the player's frame (none: null);
  /// once saved, back to the profile, which catches up.
  Future<void> onSave() async {
    final String name = nameController.text.trim();
    if (name.isEmpty) {
      ToastHelper.showToast(context.tr(AppStrings.enterNickname));
      return;
    }

    bool isSaved = false;
    await ApiService.api.updateAvatarSetting(
      name: name,
      avatarId: avatar?.id ?? setting?.avatarId,
      frameId: setting?.frameId,
      showLoader: true,
      onSuccess: (response) {
        isSaved = true;
        response.showMessage();
      },
    );
    if (!isSaved || _isDisposed) return;

    context.read<AppController>().getUser();
    AppNavigator.pop(context);
  }

  @override
  void dispose() {
    _isDisposed = true;
    nameController.dispose();
    super.dispose();
  }

  void update() {
    if (!_isDisposed) notifyListeners();
  }
}
