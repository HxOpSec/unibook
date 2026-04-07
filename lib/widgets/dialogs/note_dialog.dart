import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

/// Shows a dialog to add or edit a note.
///
/// Returns the note text when the user saves, or `null` on cancel.
Future<String?> showNoteDialog(
  BuildContext context, {
  String? initialText,
  String? title,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => NoteDialog(initialText: initialText, title: title),
  );
}

class NoteDialog extends StatefulWidget {
  const NoteDialog({super.key, this.initialText, this.title});

  final String? initialText;
  final String? title;

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title ?? 'Note'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        maxLines: 5,
        minLines: 3,
        decoration: const InputDecoration(
          hintText: 'Write your note here…',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final text = _ctrl.text.trim();
            Navigator.of(context).pop(text.isEmpty ? null : text);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
