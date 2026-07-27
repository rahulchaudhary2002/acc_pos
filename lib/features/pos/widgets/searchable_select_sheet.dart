import 'package:flutter/material.dart';

import 'package:acc_pos/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Generic searchable option: a modal bottom sheet with a search field and a
/// filtered list, mirroring the web POS's `SearchableSelect` combobox. Unlike
/// `showProductPicker` (which is product-specific), this is reusable for any
/// `T` — e.g. picking a purchase bill by number.
Future<T?> showSearchableSelectSheet<T>(
  BuildContext context, {
  required List<T> options,
  required String Function(T) labelOf,
  String Function(T)? subtitleOf,
  String? searchHint,
  String? emptyMessage,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SearchableSelectSheet<T>(
      options: options,
      labelOf: labelOf,
      subtitleOf: subtitleOf,
      searchHint: searchHint,
      emptyMessage: emptyMessage,
    ),
  );
}

class _SearchableSelectSheet<T> extends StatefulWidget {
  final List<T> options;
  final String Function(T) labelOf;
  final String Function(T)? subtitleOf;
  final String? searchHint;
  final String? emptyMessage;

  const _SearchableSelectSheet({
    required this.options,
    required this.labelOf,
    this.subtitleOf,
    this.searchHint,
    this.emptyMessage,
  });

  @override
  State<_SearchableSelectSheet<T>> createState() => _SearchableSelectSheetState<T>();
}

class _SearchableSelectSheetState<T> extends State<_SearchableSelectSheet<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalizedQuery = _query.trim().toLowerCase();
    final filtered = normalizedQuery.isEmpty
        ? widget.options
        : widget.options.where((option) {
            final label = widget.labelOf(option).toLowerCase();
            final subtitle = widget.subtitleOf?.call(option).toLowerCase() ?? '';
            return label.contains(normalizedQuery) || subtitle.contains(normalizedQuery);
          }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.section)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.field),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: widget.searchHint ?? l10n.searchableSelectSheetSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        widget.emptyMessage ?? l10n.searchableSelectSheetEmptyMessage,
                        style: AppTextStyles.helper,
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final option = filtered[index];
                        final subtitle = widget.subtitleOf?.call(option);
                        return ListTile(
                          title: Text(widget.labelOf(option), style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: subtitle != null && subtitle.isNotEmpty ? Text(subtitle) : null,
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
