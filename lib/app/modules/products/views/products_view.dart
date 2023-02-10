import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:medusa_admin/app/data/models/store/index.dart';
import 'package:medusa_admin/app/routes/app_pages.dart';
import '../../../../core/utils/enums.dart';
import '../controllers/products_controller.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductsController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Products'),
            centerTitle: true,
            leading: IconButton(
                onPressed: () => controller.changeViewOption(),
                icon: Icon(controller.viewOptions == ViewOptions.list ? Icons.grid_view_rounded : Icons.list)),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz))
            ],
          ),
          body: SafeArea(
            child: controller.viewOptions == ViewOptions.grid
                ? buildGridProducts(controller)
                : buildListProducts(controller),
          ),
        );
      },
    );
  }

  PagedGridView<int, Product> buildGridProducts(ProductsController controller) {
    return PagedGridView(
      pagingController: controller.pagingController,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      builderDelegate: PagedChildBuilderDelegate<Product>(
          itemBuilder: (context, product, index) => GestureDetector(
            onTap: () => Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product.id),
            child: Card(
              child: Column(
                    children: [
                      if (product.thumbnail != null)
                        Expanded(flex: 3, child: CachedNetworkImage(imageUrl: product.thumbnail!)),
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
    );
  }

  PagedListView<int, Product> buildListProducts(ProductsController controller) {
    return PagedListView(
      pagingController: controller.pagingController,
      builderDelegate: PagedChildBuilderDelegate<Product>(
          itemBuilder: (context, product, index) => ListTile(
            onTap: () => Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product.id),
                title: Text(product.title!),
                subtitle: Text(product.status.name.capitalize ?? product.status.name,
                    style: Theme.of(context).textTheme.titleSmall),
                leading: product.thumbnail != null ? CachedNetworkImage(imageUrl: product.thumbnail!) : null,
                trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
              ),
          firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator.adaptive())),
    );
  }
}
