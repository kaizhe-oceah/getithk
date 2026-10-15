// Project imports:
import '../components/default/bottom_sheet_phone_country.dart';
import '../controllers/address_controller.dart';
import '../imports.dart';
import '../models/address_model.dart';

class AddressPage extends StatelessWidget {
  /// Picking an address for checkout: a radio on each, 選擇地址 at the
  /// bottom, no 編輯 or 刪除.
  final bool isSelect;

  /// The address picked so far, ticked to start with; null: the default one.
  final int? selectedId;

  const AddressPage({this.isSelect = false, this.selectedId, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AddressController(isSelect: isSelect, selectedId: selectedId),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          // under the provider, for 新增 while picking
          Builder(
            builder: (context) => AppBarWidget(
              text: context.tr(AppStrings.shippingAddress),
              centerTitle: true,
              backgroundColor: AppColors.whiteColor,
              leading: const AppBarBackButton(),
              actions: [
                if (isSelect)
                  InkWellWrapper(
                    onTap: context.read<AddressController>().onAdd,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12).r,
                      child: Icon(
                        Iconsax.add_copy,
                        size: 22.r,
                        color: AppColors.loginTextColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        child: Consumer<AddressController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, AddressController controller) {
    return Column(
      children: [
        Expanded(
          child: SmartRefresherWrapper(
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            enablePullUp:
                !controller.isLoading && controller.addresses.isNotEmpty,
            onLoading: controller.onLoading,
            child: _addresses(context, controller),
          ),
        ),
        _bottomBar(context, controller),
      ],
    );
  }

  Widget _addresses(BuildContext context, AddressController controller) {
    final EdgeInsets padding = const EdgeInsets.fromLTRB(
      kHorizontalPadding,
      12,
      kHorizontalPadding,
      20,
    ).r;
    final bool placeholder =
        controller.isLoading && controller.addresses.isEmpty;

    if (!placeholder && controller.addresses.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: padding,
            sliver: const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: NoDataWidget()),
            ),
          ),
        ],
      );
    }

    final List<AddressModel> addresses = placeholder
        ? List.generate(2, (_) => AddressModel.placeholder())
        : controller.addresses;

    return ListView.separated(
      padding: padding,
      itemCount: addresses.length,
      separatorBuilder: (_, _) => 12.heightSpace,
      itemBuilder: (context, index) => AppSkeletonizer(
        enabled: placeholder,
        child: _addressCard(context, controller, addresses[index]),
      ),
    );
  }

  Widget _addressCard(
    BuildContext context,
    AddressController controller,
    AddressModel address,
  ) {
    final bool isSelect = controller.isSelect;
    final bool isSelected =
        isSelect && address.shippingAddressId == controller.selectedId;
    final Widget details = _details(context, controller, address);

    return InkWellWrapper(
      onTap: isSelect ? () => controller.onSelect(address) : null,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 14, 16, isSelect ? 14 : 12).r,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(14).r,
          border: Border.all(color: AppColors.greyLightColor),
        ),
        child: isSelect
            ? Row(
                children: [
                  _radio(context, isSelected),
                  12.widthSpace,
                  Expanded(child: details),
                ],
              )
            : details,
      ),
    );
  }

  /// A round radio: a primary ring and dot when [selected].
  Widget _radio(BuildContext context, bool selected) {
    final Color primary = context.color.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20.r,
      height: 20.r,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? primary : AppColors.greyLightColor,
          width: 1.5,
        ),
      ),
      child: selected
          ? DecoratedBox(
              decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
            )
          : null,
    );
  }

  Widget _details(
    BuildContext context,
    AddressController controller,
    AddressModel address,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8.r,
                runSpacing: 4.r,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppText(
                    address.name ?? '',
                    fontSize: kFont14,
                    fontWeight: FontWeight.w600,
                  ),
                  if (address.isDefault) _defaultBadge(context),
                ],
              ),
            ),
            8.widthSpace,
            _country(address),
          ],
        ),
        10.heightSpace,
        _detail(Iconsax.call_copy, address.phone),
        6.heightSpace,
        _detail(Iconsax.location_copy, address.address ?? ''),
        10.heightSpace,
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.greyLight2Color,
        ),
        if (!controller.isSelect) ...[
          10.heightSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionButton(
                context.tr(AppStrings.edit),
                textColor: AppColors.loginTextColor,
                onTap: () => controller.onEdit(address),
              ),
              8.widthSpace,
              _actionButton(
                context.tr(AppStrings.delete),
                textColor: context.color.primary,
                onTap: () => controller.onDelete(address),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _country(AddressModel address) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PhoneCountryFlag(countryCode: address.countryCode, width: 18.r),
        6.widthSpace,
        AppText(
          address.countryName ?? '',
          fontSize: kFont12,
          color: AppColors.loginHintColor,
        ),
      ],
    );
  }

  Widget _detail(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.r),
          child: Icon(icon, size: 14.r, color: AppColors.loginHintColor),
        ),
        8.widthSpace,
        Expanded(
          child: AppText(
            text,
            fontSize: kFont12,
            color: AppColors.textLightColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _defaultBadge(BuildContext context) {
    final Color primary = context.color.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2).r,
      decoration: BoxDecoration(
        color: primary.wOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: AppText(
        context.tr(AppStrings.defaultAddress),
        fontSize: kFont11,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
    );
  }

  Widget _actionButton(
    String text, {
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return AppButtonWidget(
      text: text,
      isMinWidth: true,
      radius: 10,
      textSize: kFont12,
      fontWeight: FontWeight.w500,
      buttonColor: AppColors.greyBackgroundColor,
      textColor: textColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8).r,
      onTap: onTap,
    );
  }

  /// 新增收貨地址; picking, 選擇地址 instead (but 新增 while there's none to
  /// pick).
  Widget _bottomBar(BuildContext context, AddressController controller) {
    final bool canSelect =
        controller.isSelect &&
        (controller.isLoading || controller.addresses.isNotEmpty);
    return Container(
      padding: EdgeInsets.fromLTRB(
        kHorizontalPadding.r,
        10.r,
        kHorizontalPadding.r,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.wOpacity(0.08),
            blurRadius: 8.r,
            offset: Offset(0, -2.r),
          ),
        ],
      ),
      child: canSelect
          ? AppButtonWidget(
              text: context.tr(AppStrings.selectAddress),
              radius: 10,
              fontWeight: FontWeight.w600,
              textColor: AppColors.whiteColor,
              gradient: AppColors.brandGradientColor,
              // nothing picked yet (still loading): greyed out
              onTap: controller.selectedAddress != null
                  ? controller.onConfirmSelect
                  : null,
            )
          : AppButtonWidget(
              text: context.tr(AppStrings.newShippingAddress),
              radius: 10,
              fontWeight: FontWeight.w600,
              textColor: AppColors.whiteColor,
              gradient: AppColors.brandGradientColor,
              onTap: controller.onAdd,
            ),
    );
  }
}
