import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../models/product.dart';
import '../providers/pos_data_provider.dart';
import 'product_card.dart';

/// "Add Product" modal from `PosTerminal.jsx`: 420px card, dark header,
/// category tabs, searchable 2-col product grid.
Future<void> showProductPicker(
  BuildContext context, {
  required void Function(Product) onSelected,
  bool showPrice = true,
}) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.section),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 640),
        child: _ProductPickerContent(onSelected: onSelected, showPrice: showPrice),
      ),
    ),
  );
}

class _ProductPickerContent extends StatefulWidget {
  final void Function(Product) onSelected;
  final bool showPrice;

  const _ProductPickerContent({required this.onSelected, required this.showPrice});

  @override
  State<_ProductPickerContent> createState() => _ProductPickerContentState();
}

class _ProductPickerContentState extends State<_ProductPickerContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<PosDataProvider>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.section),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.card),
            color: AppColors.sectionDark,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Product', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
                SizedBox(height: 2),
                Text('Select products to add to the current sale', style: TextStyle(fontSize: 12, color: AppColors.textOnDarkMuted)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.card),
            child: TextField(
              controller: _searchController,
              onChanged: data.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search products…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.card),
              children: PosDataProvider.categories.map((category) {
                final active = category == data.categoryFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.field),
                  child: ChoiceChip(
                    label: Text(
                      category[0].toUpperCase() + category.substring(1),
                      style: AppTextStyles.tabLabel.copyWith(color: active ? Colors.white : AppColors.textMuted),
                    ),
                    selected: active,
                    selectedColor: AppColors.info,
                    backgroundColor: AppColors.surfaceTotals,
                    onSelected: (_) => data.setCategoryFilter(category),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.field),
          Expanded(
            child: data.filteredProducts.isEmpty
                ? const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'No records found',
                    subtitle: 'No products in this category yet.',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.card),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.item,
                      crossAxisSpacing: AppSpacing.item,
                      // Fixed chrome (padding, icon, gaps) + text rows that
                      // grow with the user's system font scale, so the 2-line
                      // name, price, stock and pill always fit.
                      mainAxisExtent: 110 + MediaQuery.textScalerOf(context).scale(85),
                    ),
                    itemCount: data.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = data.filteredProducts[index];
                      return ProductCard(
                        product: product,
                        showPrice: widget.showPrice,
                        onTap: () {
                          widget.onSelected(product);
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.card),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
