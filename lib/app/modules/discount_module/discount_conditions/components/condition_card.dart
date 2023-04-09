import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medusa_admin/app/modules/components/adaptive_icon.dart';

import '../../../../data/models/store/discount_condition.dart';
import 'index.dart';

class ConditionCard extends StatelessWidget {
  const ConditionCard({Key? key, required this.title, required this.subtitle, this.onTap}) : super(key: key);
  final String title, subtitle;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final mediumTextStyle = Theme.of(context).textTheme.titleMedium;
    Color lightWhite = Get.isDarkMode ? Colors.white54 : Colors.black54;
    return InkWell(
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            color: Theme.of(context).appBarTheme.backgroundColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title),
                  Text(subtitle, style: mediumTextStyle?.copyWith(color: lightWhite)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: lightWhite, size: 20),
          ],
        ),
      ),
    );
  }
}

class DetailedConditionCard extends StatelessWidget {
  const DetailedConditionCard({
    Key? key,
    required this.discountCondition,
    this.onDeleteTap,
    this.onEditTap,
  }) : super(key: key);
  final DiscountCondition discountCondition;
  final void Function()? onDeleteTap;
  final void Function(DiscountConditionType? discountConditionType)? onEditTap;

  @override
  Widget build(BuildContext context) {
    final mediumTextStyle = Theme.of(context).textTheme.titleMedium;
    final smallTextStyle = Theme.of(context).textTheme.titleSmall;
    Color lightWhite = Get.isDarkMode ? Colors.white54 : Colors.black54;
    String title = '', subtitle = '';
    void Function()? defaultEdit;

    switch (discountCondition.type) {
      case DiscountConditionType.products:
        title = 'Product';
        subtitle = 'Discount is applicable to specific products';
        defaultEdit = () => Get.to(() => const ConditionProductView());
        break;
      case DiscountConditionType.productType:
        title = 'Product Type';
        subtitle = 'Discount is applicable to specific product types';
        defaultEdit = () => Get.to(() => const ConditionTypeView());

        break;
      case DiscountConditionType.productCollections:
        title = 'Collection';
        subtitle = 'Discount is applicable to specific collections';
        defaultEdit = () => Get.to(() => const ConditionCollectionView());
        break;
      case DiscountConditionType.productTags:
        title = 'Tag';
        subtitle = 'Discount is applicable to specific product tags';
        defaultEdit = () => Get.to(() => const ConditionTagView());
        break;
      case DiscountConditionType.customerGroups:
        title = 'Customer Group';
        subtitle = 'Discount is applicable to specific customer group';
        defaultEdit = () => Get.to(() => const ConditionCustomerGroupView());
        break;
      case null:
        defaultEdit = () {};
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4.0)), color: Theme.of(context).scaffoldBackgroundColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: mediumTextStyle),
                Text(subtitle, style: smallTextStyle?.copyWith(color: lightWhite)),
              ],
            ),
          ),
          AdaptiveIcon(
              onPressed: () async {
                await showModalActionSheet<int>(
                    title: 'Manage condition',
                    message: title,
                    context: context,
                    actions: <SheetAction<int>>[
                      const SheetAction(label: 'Edit', key: 0),
                      const SheetAction(label: 'Delete', isDestructiveAction: true, key: 1),
                    ]).then((result) {
                  if (result == null) return;
                  switch (result) {
                    case 0:
                      if (onEditTap != null) {
                        onEditTap!(discountCondition.type);
                      } else {
                        defaultEdit!();
                      }
                      break;
                    case 1:
                      if (onDeleteTap != null) {
                        onDeleteTap!();
                      }
                      break;
                  }
                });
              },
              icon: Icon(Icons.more_horiz, color: lightWhite)),
        ],
      ),
    );
  }
}
