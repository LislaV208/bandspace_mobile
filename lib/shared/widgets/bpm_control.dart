import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class BpmControl extends StatefulWidget {
  final int? initialBpm;
  final ValueChanged<int?> onBpmChanged;
  final bool showRemoveButton;
  final String? label;
  final String addButtonText;
  final IconData addButtonIcon;
  final bool disabled;

  const BpmControl({
    super.key,
    this.initialBpm,
    required this.onBpmChanged,
    this.showRemoveButton = false,
    this.label = 'Tempo (BPM)',
    this.addButtonText = 'Dodaj tempo',
    this.addButtonIcon = LucideIcons.music,
    this.disabled = false,
  });

  @override
  State<BpmControl> createState() => _BpmControlState();
}

class _BpmControlState extends State<BpmControl> {
  late final TextEditingController _bpmController;
  int? _bpm;

  @override
  void initState() {
    super.initState();
    _bpm = widget.initialBpm;
    _bpmController = TextEditingController(text: _bpm?.toString() ?? '');
  }

  @override
  void dispose() {
    _bpmController.dispose();
    super.dispose();
  }

  void _incrementBpm() {
    if (_bpm == null) return;
    setState(() {
      if (_bpm! < 300) {
        // Maximum reasonable BPM
        _bpm = _bpm! + 1;
        _bpmController.text = _bpm.toString();
        widget.onBpmChanged(_bpm);
      }
    });
  }

  void _decrementBpm() {
    if (_bpm == null) return;
    setState(() {
      if (_bpm! > 20) {
        // Minimum reasonable BPM
        _bpm = _bpm! - 1;
        _bpmController.text = _bpm.toString();
        widget.onBpmChanged(_bpm);
      }
    });
  }

  void _removeBpm() {
    setState(() {
      _bpm = null;
      _bpmController.clear();
    });
    widget.onBpmChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    if (_bpm == null) {
      return _buildAddBpmButton();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null || widget.showRemoveButton)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              if (widget.showRemoveButton)
                TextButton(
                  onPressed: widget.disabled ? null : _removeBpm,
                  child: const Text('Usuń'),
                ),
            ],
          ),
        if (widget.label != null || widget.showRemoveButton)
          const SizedBox(height: 8),
        Row(
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
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    if (_bpm == null) return const SizedBox.shrink();
    final bool isEnabled =
        !widget.disabled &&
        (icon == LucideIcons.minus ? _bpm! > 20 : _bpm! < 300);

    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        child: Icon(
          icon,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildBpmTextField() {
    return TextField(
      controller: _bpmController,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        hintText: '120',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      enabled: !widget.disabled,
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
    );
  }

  Widget _buildAddBpmButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        if (widget.label != null)
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.disabled
                ? null
                : () {
                    setState(() {
                      _bpm = 120;
                      _bpmController.text = '120';
                    });
                    widget.onBpmChanged(120);
                  },
            icon: Icon(
              widget.addButtonIcon,
              size: 20,
            ),
            label: Text(widget.addButtonText),
          ),
        ),
      ],
    );
  }
}
