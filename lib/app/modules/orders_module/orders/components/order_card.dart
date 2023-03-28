import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medusa_admin/app/modules/components/adaptive_icon.dart';
import 'package:medusa_admin/app/modules/orders_module/orders/components/fulfillment_label.dart';
import 'package:medusa_admin/app/modules/orders_module/orders/components/payment_status_label.dart';
import 'package:medusa_admin/app/routes/app_pages.dart';

import '../../../../data/models/store/order.dart';

class OrderCard extends StatelessWidget {
  const OrderCard(this.order, {Key? key, this.onTap}) : super(key: key);
  final Order order;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final smallTextStyle = Theme.of(context).textTheme.titleSmall;
    final mediumTextStyle = Theme.of(context).textTheme.titleMedium;
    // final largeTextStyle = Theme.of(context).textTheme.titleLarge;
    // const space = SizedBox(height: 12.0);
    Color lightWhite = Get.isDarkMode ? Colors.white54 : Colors.black54;
    String? getName() {
      String? name;

      if (order.billingAddress?.firstName != null && order.billingAddress?.lastName != null) {
        name = '${order.billingAddress!.firstName ?? ''} ${order.billingAddress!.lastName ?? ''}';
      }
      if (order.shippingAddress?.firstName != null && order.shippingAddress?.lastName != null) {
        name = '${order.shippingAddress!.firstName ?? ''} ${order.shippingAddress!.lastName ?? ''}';
      }
      if (order.customer?.firstName != null && order.customer?.lastName != null) {
        name = '${order.customer!.firstName ?? ''} ${order.customer!.lastName ?? ''}';
      }
      return name;
    }

    return InkWell(
      onTap: onTap ?? () => Get.toNamed(Routes.ORDER_DETAILS, arguments: order.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: const BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${order.displayId}', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2.0),
                    Text(
                      order.cart!.createdAt != null
                          ? 'on ${DateFormat.MEd().format(order.cart!.createdAt!)} at ${DateFormat.jm().format(order.cart!.createdAt!)}'
                          : '',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                Text(
                  '${order.total} ${order.currencyCode?.toUpperCase()} ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            // if (order.items != null)
            //   Padding(
            //     padding: const EdgeInsets.symmetric(vertical: 8.0),
            //     child: buildImages(context),
            //   ),
            const Divider(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Status',
                      style: smallTextStyle!.copyWith(color: lightWhite),
                    ),
                    Text(
                      'Customer',
                      style: smallTextStyle.copyWith(color: lightWhite),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: PaymentStatusLabel(paymentStatus: order.paymentStatus),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            child: Text(getName()?[0] ?? order.customer!.email[0]),
                          ),
                          const SizedBox(width: 6.0),
                          if (getName() != null) Flexible(child: Text(getName()!, style: smallTextStyle)),
                          if (getName() == null)
                            Flexible(
                                child: Text(order.customer!.email,
                                    style: mediumTextStyle, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    )
                  ],
                )
                // Opacity(
                //   opacity: order.status != OrderStatus.pending ? 1 : 0,
                //   child: InkWell(
                //     onTap: order.status != OrderStatus.pending ? () {} : null,
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                //       decoration: BoxDecoration(
                //           border: Border.all(
                //             color: ColorManager.primary,
                //             width: 2,
                //           ),
                //           borderRadius: const BorderRadius.all(Radius.circular(4))),
                //       child: Row(
                //         children: [
                //           Icon(Icons.refresh, color: ColorManager.primary),
                //           Text(
                //             'Reorder',
                //             style: Theme.of(context).textTheme.titleSmall!.copyWith(color: ColorManager.primary),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImages(BuildContext context) {
    if (order.items!.length > 3) {
      return Row(
        children: [
          ...List.generate(
              3,
              (index) => Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: Colors.grey.shade300),
                            image: DecorationImage(
                                fit: BoxFit.cover, image: CachedNetworkImageProvider(order.items![index].thumbnail!))),
                      ),
                      const SizedBox(width: 10)
                    ],
                  )),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
                child: Text('+ ${order.items!.length - 3}',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: Get.isDarkMode ? Colors.white : Colors.grey))),
          ),
        ],
      );
    }

    return Row(
      children: List.generate(
          order.items!.length,
          (index) => Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.grey.shade300),
                        image: DecorationImage(
                            fit: BoxFit.cover, image: CachedNetworkImageProvider(order.items![index].thumbnail!))),
                  ),
                  const SizedBox(width: 10)
                ],
              )),
    );
  }
}

class AlternativeOrderCard extends StatelessWidget {
  const AlternativeOrderCard(this.order, {Key? key, this.onTap}) : super(key: key);
  final Order order;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final smallTextStyle = Theme.of(context).textTheme.titleSmall;
    final mediumTextStyle = Theme.of(context).textTheme.titleMedium;
    // final largeTextStyle = Theme.of(context).textTheme.titleLarge;
    String? getName() {
      String? name;

      if (order.billingAddress?.firstName != null && order.billingAddress?.lastName != null) {
        name = '${order.billingAddress!.firstName ?? ''} ${order.billingAddress!.lastName ?? ''}';
      }
      if (order.shippingAddress?.firstName != null && order.shippingAddress?.lastName != null) {
        name = '${order.shippingAddress!.firstName ?? ''} ${order.shippingAddress!.lastName ?? ''}';
      }
      if (order.customer?.firstName != null && order.customer?.lastName != null) {
        name = '${order.customer!.firstName ?? ''} ${order.customer!.lastName ?? ''}';
      }
      return name;
    }

    return InkWell(
      onTap: onTap ?? () => Get.toNamed(Routes.ORDER_DETAILS, arguments: order.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: const BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${order.displayId}', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${order.currency?.symbol ?? ''} ${order.total}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.cart!.createdAt != null
                        ? '${DateFormat.yMMMd().format(order.cart!.createdAt!)} at ${DateFormat.jm().format(order.cart!.createdAt!)}'
                        : '',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: const Color(0xff6B7280)),
                  ),
                  Text(
                    order.currencyCode?.toUpperCase() ?? '',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: const Color(0xff6B7280)),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        child: Text(getName()?[0] ?? order.customer!.email[0]),
                      ),
                      const SizedBox(width: 6.0),
                      if (getName() != null) Flexible(child: Text(getName()!, style: smallTextStyle)),
                      if (getName() == null)
                        Flexible(
                            child:
                                Text(order.customer!.email, style: mediumTextStyle, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                Flexible(
                  child: PaymentStatusDot(paymentStatus: order.paymentStatus),
                ),
              ],
            ),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text(
            //           'Payment Status',
            //           style: smallTextStyle!.copyWith(color: lightWhite),
            //         ),
            //         Text(
            //           'Customer',
            //           style: smallTextStyle.copyWith(color: lightWhite),
            //         ),
            //       ],
            //     ),
            //     const SizedBox(height: 6.0),
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Flexible(
            //           child: PaymentStatusLabel(paymentStatus: order.paymentStatus),
            //         ),
            //         Flexible(
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.end,
            //             children: [
            //               CircleAvatar(
            //                 radius: 16,
            //                 child: Text(getName()?[0] ?? order.customer!.email[0]),
            //               ),
            //               const SizedBox(width: 6.0),
            //               if (getName() != null) Flexible(child: Text(getName()!, style: smallTextStyle)),
            //               if (getName() == null)
            //                 Flexible(
            //                     child: Text(order.customer!.email,
            //                         style: mediumTextStyle, overflow: TextOverflow.ellipsis)),
            //             ],
            //           ),
            //         )
            //       ],
            //     )
            //     // Opacity(
            //     //   opacity: order.status != OrderStatus.pending ? 1 : 0,
            //     //   child: InkWell(
            //     //     onTap: order.status != OrderStatus.pending ? () {} : null,
            //     //     child: Container(
            //     //       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            //     //       decoration: BoxDecoration(
            //     //           border: Border.all(
            //     //             color: ColorManager.primary,
            //     //             width: 2,
            //     //           ),
            //     //           borderRadius: const BorderRadius.all(Radius.circular(4))),
            //     //       child: Row(
            //     //         children: [
            //     //           Icon(Icons.refresh, color: ColorManager.primary),
            //     //           Text(
            //     //             'Reorder',
            //     //             style: Theme.of(context).textTheme.titleSmall!.copyWith(color: ColorManager.primary),
            //     //           ),
            //     //         ],
            //     //       ),
            //     //     ),
            //     //   ),
            //     // ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildImages(BuildContext context) {
    if (order.items!.length > 3) {
      return Row(
        children: [
          ...List.generate(
              3,
              (index) => Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: Colors.grey.shade300),
                            image: DecorationImage(
                                fit: BoxFit.cover, image: CachedNetworkImageProvider(order.items![index].thumbnail!))),
                      ),
                      const SizedBox(width: 10)
                    ],
                  )),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
                child: Text('+ ${order.items!.length - 3}',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: Get.isDarkMode ? Colors.white : Colors.grey))),
          ),
        ],
      );
    }

    return Row(
      children: List.generate(
          order.items!.length,
          (index) => Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.grey.shade300),
                        image: DecorationImage(
                            fit: BoxFit.cover, image: CachedNetworkImageProvider(order.items![index].thumbnail!))),
                  ),
                  const SizedBox(width: 10)
                ],
              )),
    );
  }
}

class CustomerOrderCard extends StatelessWidget {
  const CustomerOrderCard(this.order, {Key? key, this.onTap, this.cardColor, this.onTransferTap}) : super(key: key);
  final Order order;
  final void Function()? onTap;
  final void Function()? onTransferTap;
  final Color? cardColor;
  @override
  Widget build(BuildContext context) {
    final smallTextStyle = Theme.of(context).textTheme.titleSmall;
    Color lightWhite = Get.isDarkMode ? Colors.white54 : Colors.black54;

    return InkWell(
      onTap: onTap ?? () => Get.toNamed(Routes.ORDER_DETAILS, arguments: order.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
            color: cardColor ?? Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        borderRadius: const BorderRadius.all(Radius.circular(6.0))),
                    child: Text('#${order.displayId}', style: Theme.of(context).textTheme.titleMedium)),
                Row(
                  children: [
                    Text(
                      order.cart!.createdAt != null
                          ? '${DateFormat.yMMMd().format(order.cart!.createdAt!)} at ${DateFormat.jm().format(order.cart!.createdAt!)}'
                          : '',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(color: const Color(0xff6B7280)),
                    ),
                    AdaptiveIcon(onPressed: onTransferTap, icon: const Icon(CupertinoIcons.arrow_2_circlepath))
                  ],
                )
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Status',
                      style: smallTextStyle!.copyWith(color: lightWhite),
                    ),
                    const SizedBox(height: 6.0),
                    PaymentStatusLabel(paymentStatus: order.paymentStatus)
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fulfillment',
                      style: smallTextStyle.copyWith(color: lightWhite),
                    ),
                    const SizedBox(height: 6.0),
                    FulfillmentStatusLabel(fulfillmentStatus: order.fulfillmentStatus)
                  ],
                ),
              ],
            )
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text(
            //           'Payment Status',
            //           style: smallTextStyle!.copyWith(color: lightWhite),
            //         ),
            //         Text(
            //           'Customer',
            //           style: smallTextStyle.copyWith(color: lightWhite),
            //         ),
            //       ],
            //     ),
            //     const SizedBox(height: 6.0),
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Flexible(
            //           child: PaymentStatusLabel(paymentStatus: order.paymentStatus),
            //         ),
            //         Flexible(
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.end,
            //             children: [
            //               CircleAvatar(
            //                 radius: 16,
            //                 child: Text(getName()?[0] ?? order.customer!.email[0]),
            //               ),
            //               const SizedBox(width: 6.0),
            //               if (getName() != null) Flexible(child: Text(getName()!, style: smallTextStyle)),
            //               if (getName() == null)
            //                 Flexible(
            //                     child: Text(order.customer!.email,
            //                         style: mediumTextStyle, overflow: TextOverflow.ellipsis)),
            //             ],
            //           ),
            //         )
            //       ],
            //     )
            //     // Opacity(
            //     //   opacity: order.status != OrderStatus.pending ? 1 : 0,
            //     //   child: InkWell(
            //     //     onTap: order.status != OrderStatus.pending ? () {} : null,
            //     //     child: Container(
            //     //       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            //     //       decoration: BoxDecoration(
            //     //           border: Border.all(
            //     //             color: ColorManager.primary,
            //     //             width: 2,
            //     //           ),
            //     //           borderRadius: const BorderRadius.all(Radius.circular(4))),
            //     //       child: Row(
            //     //         children: [
            //     //           Icon(Icons.refresh, color: ColorManager.primary),
            //     //           Text(
            //     //             'Reorder',
            //     //             style: Theme.of(context).textTheme.titleSmall!.copyWith(color: ColorManager.primary),
            //     //           ),
            //     //         ],
            //     //       ),
            //     //     ),
            //     //   ),
            //     // ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildImages(BuildContext context) {
    if (order.items!.length > 3) {
      return Row(
        children: [
          ...List.generate(
              3,
              (index) => Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: Colors.grey.shade300),
                            image: DecorationImage(
                                fit: BoxFit.cover, image: CachedNetworkImageProvider(order.items![index].thumbnail!))),
                      ),
                      const SizedBox(width: 10)
                    ],
                  )),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
                child: Text('+ ${order.items!.length - 3}',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: Get.isDarkMode ? Colors.white : Colors.grey))),
          ),
        ],
      );
    }

    return Row(
      children: List.generate(
          order.items!.length,
          (index) => Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.grey.shade300),
                        image: DecorationImage(
                            fit: BoxFit.cover, image: CachedNetworkImageProvider(order.items![index].thumbnail!))),
                  ),
                  const SizedBox(width: 10)
                ],
              )),
    );
  }
}