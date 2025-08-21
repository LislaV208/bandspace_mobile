
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';

class BpmControl extends StatefulWidget {
  final int initialBpm;
  final ValueChanged<int> onBpmChanged;

  const BpmControl({
    super.key,
    this.initialBpm = 120,
    required this.onBpmChanged,
  });

  @override
  State<BpmControl> createState() => _BpmControlState();
}

class _BpmControlState extends State<BpmControl> {
  late final TextEditingController _bpmController;
  late int _bpm;

  @override
  void initState() {
    super.initState();
    _bpm = widget.initialBpm;
    _bpmController = TextEditingController(text: _bpm.toString());
  }

  @override
  void dispose() {
    _bpmController.dispose();
    super.dispose();
  }

  void _incrementBpm() {
    setState(() {
      if (_bpm < 300) { // Maximum reasonable BPM
        _bpm++;
        _bpmController.text = _bpm.toString();
        widget.onBpmChanged(_bpm);
      }
    });
  }

  void _decrementBpm() {
    setState(() {
      if (_bpm > 20) { // Minimum reasonable BPM
        _bpm--;
        _bpmController.text = _bpm.toString();
        widget.onBpmChanged(_bpm);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildControlButton(
          icon: LucideIcons.minus,
          onPressed: _decrementBpm,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBpmTextField(),
        ),
        const SizedBox(width: 12),
        _buildControlButton(
          icon: LucideIcons.plus,
          onPressed: _incrementBpm,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final bool isEnabled = icon == LucideIcons.minus ? _bpm > 20 : _bpm < 300;
    
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: isEnabled ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isEnabled 
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isEnabled 
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBpmTextField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _bpmController,
        textAlign: TextAlign.center,
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: '120',
          hintStyle: AppTextStyles.headlineSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            fontWeight: FontWeight.w700,
          ),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          final newBpm = int.tryParse(value);
          if (newBpm != null && newBpm >= 20 && newBpm <= 300) {
            setState(() {
              _bpm = newBpm;
              widget.onBpmChanged(_bpm);
            });
          }
        },
        onTap: () {
          // Select all text when tapped
          _bpmController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _bpmController.text.length,
          );
        },
      ),
    );
  }
}
