import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:medusa_admin/app/data/models/store/index.dart';
import 'package:medusa_admin/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../core/utils/enums.dart';
import '../controllers/products_controller.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductsController>(
      builder: (controller) {
        return Scaffold(
          appBar: const AnimatedAppBar(),
          body: SafeArea(
            child: controller.viewOptions == ViewOptions.grid ? const ProductsGridView() : const ProductsListView(),
          ),
        );
      },
    );
  }
}

class AnimatedAppBar extends StatefulWidget with PreferredSizeWidget {
  const AnimatedAppBar({Key? key}) : super(key: key);

  @override
  State<AnimatedAppBar> createState() => _AnimatedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AnimatedAppBarState extends State<AnimatedAppBar> {
  bool search = false;
  final ProductsController controller = Get.find<ProductsController>();
  final searchCtrl = TextEditingController();
  final searchNode = FocusNode();
  static const kDuration = Duration(milliseconds: 200);
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
        firstChild: AppBar(
          title: const Text('Products'),
          centerTitle: true,
          // 56 is the default leading width value
          leadingWidth: 56 * 3,
          leading: Row(
            children: [
              IconButton(
                  onPressed: () => controller.changeViewOption(),
                  icon: Icon(controller.viewOptions == ViewOptions.list ? Icons.grid_view_rounded : Icons.list)),
              IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.sort_down_circle_fill)),
              IconButton(
                  onPressed: () async {
                    setState(() {
                      search = true;
                    });
                    await Future.delayed(kDuration);
                    searchNode.requestFocus();
                  },
                  icon: const Icon(CupertinoIcons.search)),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  await Get.toNamed(Routes.ADD_UPDATE_PRODUCT)?.then((result) {
                    if (result != null && result is bool && result == true) {
                      controller.pagingController.refresh();
                    }
                  });
                },
                icon: const Icon(Icons.add)),
            IconButton(
                onPressed: () async {
                  final result = await showModalActionSheet(context: context, actions: <SheetAction>[
                    const SheetAction(label: 'Export Products'),
                    const SheetAction(label: 'Import Products'),
                  ]);
                },
                icon: const Icon(Icons.more_horiz))
          ],
        ),
        secondChild: AppBar(
          leadingWidth: double.maxFinite,
          leading: Row(
            children: [
              // Expanded(child: TextFormField()),
              const SizedBox(width: 12.0),
              Expanded(
                  child: CupertinoSearchTextField(
                focusNode: searchNode,
                controller: searchCtrl,
                onChanged: (val) {
                  controller.searchTerm = val;
                  controller.pagingController.refresh();
                },
              )),
              CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    // await Future.delayed(Duration(milliseconds: 150));
                    setState(() {
                      search = false;
                      if (controller.searchTerm.isNotEmpty) {
                        controller.searchTerm = '';
                        controller.pagingController.refresh();
                      }
                      searchCtrl.clear();
                    });
                  }),
            ],
          ),
        ),
        crossFadeState: search ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: kDuration);
  }
}

class ProductsGridView extends GetView<ProductsController> {
  const ProductsGridView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: controller.gridRefreshController,
      onRefresh: () => controller.pagingController.refresh(),
      header: GetPlatform.isIOS ? const ClassicHeader(completeText: '') : const MaterialClassicHeader(),
      child: PagedGridView(
        pagingController: controller.pagingController,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        builderDelegate: PagedChildBuilderDelegate<Product>(
            itemBuilder: (context, product, index) => GestureDetector(
                  onTap: () async {
                    await Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product.id)?.then((result) {
                      // A product has been deleted, reload data
                      if (result is bool && result == true) {
                        controller.pagingController.refresh();
                      }
                    });
                  },
                  child: Card(
                    child: Column(
                      children: [
                        if (product.thumbnail != null)
                          Expanded(
                            flex: 3,
                            child: CachedNetworkImage(
                                imageUrl: product.thumbnail!,
                                placeholder: (context, text) =>
                                    const Center(child: CircularProgressIndicator.adaptive()),
                                errorWidget: (context, string, error) =>
                                    const Icon(Icons.warning_rounded, color: Colors.redAccent)),
                          ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(product.title!, style: Theme.of(context).textTheme.titleMedium),
                        )),
                      ],
                    ),
                  ),
                ),
            firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator.adaptive())),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 100 / 150,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          crossAxisCount: 3,
        ),
      ),
    );
  }
}

class ProductsListView extends GetView<ProductsController> {
  const ProductsListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: controller.listRefreshController,
      onRefresh: () => controller.pagingController.refresh(),
      header: GetPlatform.isIOS ? const ClassicHeader(completeText: '') : const MaterialClassicHeader(),
      child: PagedListView(
        pagingController: controller.pagingController,
        builderDelegate: PagedChildBuilderDelegate<Product>(
            itemBuilder: (context, product, index) => ListTile(
                  onTap: () async {
                    await Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product.id)?.then((result) {
                      // A product has been deleted, reload data
                      if (result is bool && result == true) {
                        controller.pagingController.refresh();
                      }
                    });
                  },
                  title: Text(product.title!),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getStatusIcon(product.status),
                      const SizedBox(width: 4.0),
                      Text(product.status.name.capitalize ?? product.status.name,
                          style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                  leading: product.thumbnail != null
                      ? SizedBox(
                          width: 45,
                          child: CachedNetworkImage(
                            imageUrl: product.thumbnail!,
                            placeholder: (context, text) => const Center(child: CircularProgressIndicator.adaptive()),
                            errorWidget: (context, string, error) =>
                                const Icon(Icons.warning_rounded, color: Colors.redAccent),
                          ))
                      : null,
                  trailing: IconButton(
                      onPressed: () async {
                        await showModalActionSheet(context: context, actions: <SheetAction>[
                          const SheetAction(label: 'Edit'),
                          SheetAction(
                              label: product.status == ProductStatus.published ? 'Unpublish' : 'Publish',
                              key: 'publish'),
                          const SheetAction(label: 'Duplicate'),
                          const SheetAction(label: 'Delete', isDestructiveAction: true, key: 'delete'),
                        ]).then((result) async {
                          if (result == 'delete') {
                            final confirmDelete = await showOkCancelAlertDialog(
                                context: context,
                                title: 'Confirm product deletion',
                                message: 'Are you sure you want to delete this product? \n This action is irreversible',
                                isDestructiveAction: true);

                            if (confirmDelete != OkCancelResult.ok) {
                              return;
                            }
                            await controller.deleteProduct(product.id!);
                          } else if (result == 'publish') {
                            await controller.updateProduct(Product(
                              id: product.id!,
                              discountable: product.discountable,
                              status: product.status == ProductStatus.published
                                  ? ProductStatus.draft
                                  : ProductStatus.published,
                            ));
                          }
                        });
                      },
                      icon: const Icon(Icons.more_horiz)),
                ),
            firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator.adaptive())),
      ),
    );
  }

  Widget _getStatusIcon(ProductStatus status) {
    switch (status) {
      case ProductStatus.draft:
        return const Icon(Icons.circle, color: Colors.grey, size: 12);
      case ProductStatus.proposed:
        return const Icon(Icons.circle, color: Colors.grey, size: 12);

      case ProductStatus.published:
        return const Icon(Icons.circle, color: Colors.green, size: 12);

      case ProductStatus.rejected:
        return const Icon(Icons.circle, color: Colors.red, size: 12);
    }
  }
}
