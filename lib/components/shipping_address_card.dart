// Project imports:
import '../imports.dart';
import '../models/address_model.dart';

/// 收貨地址: a truck by the title, then the recipient and phone, the address
/// under them; a prompt to add one when there's none, a skeleton while
/// [isLoading]. With [onTap], a › at the end and the card taps through to
/// it.
class ShippingAddressCard extends StatelessWidget {
  final AddressModel? address;
  final bool isLoading;
  final VoidCallback? onTap;

  const ShippingAddressCard({
    required this.address,
    this.isLoading = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = context.color.primary;
    final Widget card = Container(
      padding: const EdgeInsets.all(14).r,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14).r,
        border: Border.all(color: AppColors.greyLight2Color),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.wOpacity(0.06),
            blurRadius: 6.r,
            offset: Offset(0, 2.r),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.truck_fast, size: 20.r, color: primary),
                    8.widthSpace,
                    AppText(
                      context.tr(AppStrings.shippingAddress),
                      fontSize: kFont14,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                8.heightSpace,
                _details(context),
              ],
            ),
          ),
          if (onTap != null) ...[
            8.widthSpace,
            Icon(Iconsax.arrow_right_3_copy, size: 16.r, color: primary),
          ],
        ],
      ),
    );

    return onTap == null ? card : InkWellWrapper(onTap: onTap, child: card);
  }

  Widget _details(BuildContext context) {
    final AddressModel? shown = isLoading
        ? AddressModel.placeholder()
        : address;

    if (shown == null) {
      return AppText(
        context.tr(AppStrings.addShippingAddress),
        fontSize: kFont12,
        color: AppColors.loginHintColor,
      );
    }

    return AppSkeletonizer(
      enabled: isLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            '${shown.name ?? ''} (${shown.phone})',
            fontSize: kFont13,
            fontWeight: FontWeight.w700,
          ),
          4.heightSpace,
          AppText(
            shown.address ?? '',
            fontSize: kFont12,
            color: AppColors.textLightColor,
          ),
        ],
      ),
    );
  }
}
