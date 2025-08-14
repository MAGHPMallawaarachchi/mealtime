import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/meal_slot.dart';

class TimePickerModal extends StatefulWidget {
  final TimeOfDay initialTime;
  final String mealCategory;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerModal({
    super.key,
    required this.initialTime,
    required this.mealCategory,
    required this.onTimeSelected,
  });

  @override
  State<TimePickerModal> createState() => _TimePickerModalState();
}

class _TimePickerModalState extends State<TimePickerModal> {
  late TimeOfDay selectedTime;
  int selectedPresetIndex = -1;

  // Common time presets for quick selection
  static const List<TimePreset> timePresets = [
    TimePreset('6:00 AM', TimeOfDay(hour: 6, minute: 0)),
    TimePreset('7:00 AM', TimeOfDay(hour: 7, minute: 0)),
    TimePreset('8:00 AM', TimeOfDay(hour: 8, minute: 0)),
    TimePreset('8:30 AM', TimeOfDay(hour: 8, minute: 30)),
    TimePreset('12:00 PM', TimeOfDay(hour: 12, minute: 0)),
    TimePreset('12:30 PM', TimeOfDay(hour: 12, minute: 30)),
    TimePreset('1:00 PM', TimeOfDay(hour: 13, minute: 0)),
    TimePreset('6:00 PM', TimeOfDay(hour: 18, minute: 0)),
    TimePreset('6:30 PM', TimeOfDay(hour: 18, minute: 30)),
    TimePreset('7:00 PM', TimeOfDay(hour: 19, minute: 0)),
    TimePreset('7:30 PM', TimeOfDay(hour: 19, minute: 30)),
    TimePreset('8:00 PM', TimeOfDay(hour: 20, minute: 0)),
  ];

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
    _findMatchingPreset();
  }

  void _findMatchingPreset() {
    for (int i = 0; i < timePresets.length; i++) {
      if (timePresets[i].time.hour == selectedTime.hour &&
          timePresets[i].time.minute == selectedTime.minute) {
        selectedPresetIndex = i;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildCurrentTimeDisplay(),
          const SizedBox(height: 24),
          _buildQuickPresets(),
          const SizedBox(height: 20),
          _buildCustomTimeButton(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            PhosphorIcons.clock(),
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Choose time for ${widget.mealCategory.toLowerCase()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              PhosphorIcons.x(),
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTimeDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Selected Time',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTimeOfDay(selectedTime),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Select',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            timePresets.length,
            (index) => _buildPresetChip(index),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(int index) {
    final preset = timePresets[index];
    final isSelected = selectedPresetIndex == index;

    return GestureDetector(
      onTap: () => _selectPreset(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          preset.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTimeButton() {
    return OutlinedButton.icon(
      onPressed: _showCustomTimePicker,
      icon: Icon(PhosphorIcons.gear()),
      label: const Text('Custom Time'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: AppColors.primary),
        foregroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _confirmSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _selectPreset(int index) {
    setState(() {
      selectedPresetIndex = index;
      selectedTime = timePresets[index].time;
    });
  }

  void _showCustomTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
        selectedPresetIndex = -1; // Clear preset selection
        _findMatchingPreset(); // Check if it matches a preset
      });
    }
  }

  void _confirmSelection() {
    widget.onTimeSelected(selectedTime);
    Navigator.of(context).pop();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class TimePreset {
  final String label;
  final TimeOfDay time;

  const TimePreset(this.label, this.time);
}

// Helper function to show the modal
void showTimePickerModal({
  required BuildContext context,
  required TimeOfDay initialTime,
  required String mealCategory,
  required Function(TimeOfDay) onTimeSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TimePickerModal(
      initialTime: initialTime,
      mealCategory: mealCategory,
      onTimeSelected: onTimeSelected,
    ),
  );
}