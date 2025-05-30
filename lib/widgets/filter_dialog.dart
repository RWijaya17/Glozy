import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FilterDialog extends StatefulWidget {
  final String initialSort;
  final String initialFilter;
  final Function(String, String) onApply;

  const FilterDialog({
    Key? key,
    required this.initialSort,
    required this.initialFilter,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String _selectedSort;
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialSort;
    _selectedFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.primary,
      title: Text(
        'Filter & Sort',
        style: TextStyle(color: AppColors.text),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sort Options
            Text(
              'Sort By',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildSortOptions(),
            const SizedBox(height: 16),

            // Filter Options
            Text(
              'Filter',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildFilterOptions(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            widget.onApply(_selectedSort, _selectedFilter);
            Navigator.of(context).pop();
          },
          child: Text(
            'Apply',
            style: TextStyle(color: AppColors.secondary),
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text('Distance', style: TextStyle(color: AppColors.text)),
          value: 'distance',
          groupValue: _selectedSort,
          activeColor: AppColors.secondary,
          onChanged: (value) => setState(() => _selectedSort = value!),
        ),
        RadioListTile<String>(
          title: Text('Rating', style: TextStyle(color: AppColors.text)),
          value: 'rating',
          groupValue: _selectedSort,
          activeColor: AppColors.secondary,
          onChanged: (value) => setState(() => _selectedSort = value!),
        ),
        RadioListTile<String>(
          title: Text('Name (A-Z)', style: TextStyle(color: AppColors.text)),
          value: 'name',
          groupValue: _selectedSort,
          activeColor: AppColors.secondary,
          onChanged: (value) => setState(() => _selectedSort = value!),
        ),
      ],
    );
  }

  Widget _buildFilterOptions() {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text('All Salons', style: TextStyle(color: AppColors.text)),
          value: 'all',
          groupValue: _selectedFilter,
          activeColor: AppColors.secondary,
          onChanged: (value) => setState(() => _selectedFilter = value!),
        ),
        RadioListTile<String>(
          title: Text('Home Service', style: TextStyle(color: AppColors.text)),
          value: 'home_service',
          groupValue: _selectedFilter,
          activeColor: AppColors.secondary,
          onChanged: (value) => setState(() => _selectedFilter = value!),
        ),
        RadioListTile<String>(
          title: Text('Highly Rated (4+)',
              style: TextStyle(color: AppColors.text)),
          value: 'high_rated',
          groupValue: _selectedFilter,
          activeColor: AppColors.secondary,
          onChanged: (value) => setState(() => _selectedFilter = value!),
        ),
      ],
    );
  }
}
