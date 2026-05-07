import 'package:flutter/material.dart';
import '../models/note.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';

// ─── Result wrapper ───────────────────────────────────────────────────────────
class EditNoteResult {
  final Note updatedNote;
  EditNoteResult({required this.updatedNote});
}

class EditNotePage extends StatefulWidget {
  final Note? note;
  const EditNotePage({super.key, this.note});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController titleController;
  late QuillController quillController;
  DateTime selectedDate = DateTime.now();
  bool _showFontPanel = false;

  static const _bgDark  = Color(0xFF293B42);
  static const _bgLight = Color(0xFFDAD9D4);

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    selectedDate = widget.note?.date ?? DateTime.now();

    try {
      if (widget.note?.content != null && widget.note!.content.isNotEmpty) {
        final json = jsonDecode(widget.note!.content);
        quillController = QuillController(
          document: Document.fromJson(json),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        quillController = QuillController.basic();
      }
    } catch (_) {
      quillController = QuillController.basic();
      if (widget.note?.content != null && widget.note!.content.isNotEmpty) {
        quillController.document.insert(0, widget.note!.content);
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    super.dispose();
  }

  String getJsonContent() =>
      jsonEncode(quillController.document.toDelta().toJson());

  void saveNote() {
    final note = Note(
      id: widget.note?.id ?? Random().nextDouble().toString(),
      title: titleController.text.trim().isEmpty
          ? 'Tanpa Judul'
          : titleController.text.trim(),
      content: getJsonContent(),
      date: selectedDate,
    );
    Navigator.pop(context, EditNoteResult(updatedNote: note));
  }

  Future<void> deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xCC3A5260),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline, color: Color(0xFFDAD9D4), size: 32),
              const SizedBox(height: 12),
              const Text(
                'Hapus Catatan',
                style: TextStyle(
                  color: Color(0xFFDAD9D4),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda yakin ingin menghapus catatan ini?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFDAD9D4).withOpacity(0.75),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Tidak',
                          style: TextStyle(
                            color: Color(0xFFDAD9D4),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.withOpacity(0.4)),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Ya, Hapus',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      if (widget.note != null) {
        Navigator.pop(context, {'delete': widget.note!.id});
      } else {
        Navigator.pop(context);
      }
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _bgDark,
            onPrimary: _bgLight,
            surface: _bgLight,
            onSurface: _bgDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final base64Str = 'data:image/png;base64,${base64Encode(bytes)}';
      final docLen = quillController.document.length;
      final rawOffset = quillController.selection.baseOffset;
      final index = (rawOffset >= 0 && rawOffset < docLen) ? rawOffset : docLen - 1;
      quillController.document.insert(index, BlockEmbed.image(base64Str));
      setState(() {});
    }
  }

  // ─── Format helpers ───────────────────────────────────────────────────────

  bool _isInlineActive(Attribute attr) =>
      quillController.getSelectionStyle().attributes.containsKey(attr.key);

  bool _isBlockActive(Attribute attr) =>
      quillController.getSelectionStyle().attributes[attr.key]?.value == attr.value;

  void _toggleInline(Attribute attr) {
    final isActive = _isInlineActive(attr);
    quillController.formatSelection(
      isActive ? Attribute.clone(attr, null) : attr,
    );
  }

  void _toggleBlock(Attribute attr) {
    final isActive = _isBlockActive(attr);
    quillController.formatSelection(
      isActive ? Attribute.clone(attr, null) : attr,
    );
  }

  void _clearFormat() {
    for (final attr in [
      Attribute.bold,
      Attribute.italic,
      Attribute.underline,
      Attribute.strikeThrough,
    ]) {
      quillController.formatSelection(Attribute.clone(attr, null));
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        leading: const BackButton(color: _bgLight),
        title: Row(
          children: [
            _appBarIconBtn(Icons.undo, 'Undo', () => quillController.undo()),
            const SizedBox(width: 2),
            _appBarIconBtn(Icons.redo, 'Redo', () => quillController.redo()),
          ],
        ),
        actions: [
          _appBarToggle(
            label: 'Aa',
            isActive: _showFontPanel,
            onTap: () => setState(() => _showFontPanel = !_showFontPanel),
          ),
          _appBarIconBtn(Icons.image_outlined, 'Sisipkan Gambar', pickImage),
          _appBarIconBtn(Icons.delete_outline, 'Hapus Catatan', deleteNote),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          if (_showFontPanel) _buildFontPanel(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tanggal ──────────────────────────────────────────────
                  GestureDetector(
                    onTap: pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0x2E5D6E75),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x4D5D6E75)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Color(0xCC5D6E75)),
                          const SizedBox(width: 8),
                          Text(DateFormat('dd/MM/yyyy').format(selectedDate),
                              style: const TextStyle(color: _bgDark, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ── Judul ────────────────────────────────────────────────
                  TextField(
                    controller: titleController,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600, color: _bgDark),
                    decoration: const InputDecoration(
                      hintText: 'Judul...',
                      hintStyle: TextStyle(
                          color: Color(0x805D6E75),
                          fontSize: 22,
                          fontWeight: FontWeight.w600),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(color: Color(0x4D5D6E75), thickness: 1),
                  const SizedBox(height: 8),
                  // ── Editor ───────────────────────────────────────────────
                  Expanded(
                    child: QuillEditor.basic(
                      controller: quillController,
                      config: QuillEditorConfig(
                        placeholder: 'Tulis catatanmu di sini...',
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                        autoFocus: false,
                        expands: false,
                        scrollable: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ── Tombol Simpan ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _bgDark,
                        foregroundColor: _bgLight,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Simpan',
                          style: TextStyle(fontSize: 15, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CUSTOM FONT PANEL ────────────────────────────────────────────────────
  // Dibangun sepenuhnya manual — tidak pakai QuillSimpleToolbar —
  // sehingga tidak ada ToggleButtons bawaan Flutter yang memunculkan lingkaran putih.
  Widget _buildFontPanel() {
    return AnimatedBuilder(
      animation: quillController,
      builder: (context, _) {
        // Baca state format saat ini
        final isBold      = _isInlineActive(Attribute.bold);
        final isItalic    = _isInlineActive(Attribute.italic);
        final isUnderline = _isInlineActive(Attribute.underline);
        final isStrike    = _isInlineActive(Attribute.strikeThrough);

        final isH1 = _isBlockActive(Attribute.h1);
        final isH2 = _isBlockActive(Attribute.h2);
        final isH3 = _isBlockActive(Attribute.h3);

        final isAlignLeft    = _isBlockActive(Attribute.leftAlignment);
        final isAlignCenter  = _isBlockActive(Attribute.centerAlignment);
        final isAlignRight   = _isBlockActive(Attribute.rightAlignment);
        final isAlignJustify = _isBlockActive(Attribute.justifyAlignment);

        final isBullet    = _isBlockActive(Attribute.ul);
        final isOrdered   = _isBlockActive(Attribute.ol);
        final isChecklist = _isBlockActive(Attribute.checked);

        return Container(
          color: _bgDark,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Baris 1: inline + heading ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    _toolBtn(
                      icon: Icons.format_bold,
                      isActive: isBold,
                      tooltip: 'Bold',
                      onTap: () => _toggleInline(Attribute.bold),
                    ),
                    _toolBtn(
                      icon: Icons.format_italic,
                      isActive: isItalic,
                      tooltip: 'Italic',
                      onTap: () => _toggleInline(Attribute.italic),
                    ),
                    _toolBtn(
                      icon: Icons.format_underline,
                      isActive: isUnderline,
                      tooltip: 'Underline',
                      onTap: () => _toggleInline(Attribute.underline),
                    ),
                    _toolBtn(
                      icon: Icons.format_strikethrough,
                      isActive: isStrike,
                      tooltip: 'Strikethrough',
                      onTap: () => _toggleInline(Attribute.strikeThrough),
                    ),
                    _toolBtn(
                      icon: Icons.format_clear,
                      isActive: false,
                      tooltip: 'Hapus Format',
                      onTap: _clearFormat,
                    ),
                    _vDivider(),
                    _labelBtn('H1', isActive: isH1,
                        onTap: () => _toggleBlock(Attribute.h1)),
                    _labelBtn('H2', isActive: isH2,
                        onTap: () => _toggleBlock(Attribute.h2)),
                    _labelBtn('H3', isActive: isH3,
                        onTap: () => _toggleBlock(Attribute.h3)),
                  ],
                ),
              ),
              Divider(height: 1, color: _bgLight.withOpacity(0.1)),
              // ── Baris 2: alignment + list + indent ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    _toolBtn(
                      icon: Icons.format_align_left,
                      isActive: isAlignLeft,
                      tooltip: 'Rata Kiri',
                      onTap: () => _toggleBlock(Attribute.leftAlignment),
                    ),
                    _toolBtn(
                      icon: Icons.format_align_center,
                      isActive: isAlignCenter,
                      tooltip: 'Tengah',
                      onTap: () => _toggleBlock(Attribute.centerAlignment),
                    ),
                    _toolBtn(
                      icon: Icons.format_align_right,
                      isActive: isAlignRight,
                      tooltip: 'Rata Kanan',
                      onTap: () => _toggleBlock(Attribute.rightAlignment),
                    ),
                    _toolBtn(
                      icon: Icons.format_align_justify,
                      isActive: isAlignJustify,
                      tooltip: 'Justify',
                      onTap: () => _toggleBlock(Attribute.justifyAlignment),
                    ),
                    _vDivider(),
                    _toolBtn(
                      icon: Icons.format_list_bulleted,
                      isActive: isBullet,
                      tooltip: 'Bullet List',
                      onTap: () => _toggleBlock(Attribute.ul),
                    ),
                    _toolBtn(
                      icon: Icons.format_list_numbered,
                      isActive: isOrdered,
                      tooltip: 'Numbered List',
                      onTap: () => _toggleBlock(Attribute.ol),
                    ),
                    _toolBtn(
                      icon: Icons.checklist,
                      isActive: isChecklist,
                      tooltip: 'Checklist',
                      onTap: () => _toggleBlock(Attribute.checked),
                    ),
                    _vDivider(),
                    _toolBtn(
                      icon: Icons.format_indent_decrease,
                      isActive: false,
                      tooltip: 'Outdent',
                      onTap: () => quillController.indentSelection(false),
                    ),
                    _toolBtn(
                      icon: Icons.format_indent_increase,
                      isActive: false,
                      tooltip: 'Indent',
                      onTap: () => quillController.indentSelection(true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Custom toolbar icon button ───────────────────────────────────────────
  Widget _toolBtn({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    String tooltip = '',
  }) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 34,
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            // Aktif: fill transparan + border halus. Tidak ada fill putih solid.
            color: isActive ? _bgLight.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: isActive ? _bgLight.withOpacity(0.5) : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? Colors.white : _bgLight.withOpacity(0.65),
          ),
        ),
      ),
    );
  }

  // ─── Heading label button ─────────────────────────────────────────────────
  Widget _labelBtn(
    String label, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34,
        height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive ? _bgLight.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: isActive
                ? _bgLight.withOpacity(0.5)
                : _bgLight.withOpacity(0.2),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : _bgLight.withOpacity(0.65),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // ─── Thin vertical divider ────────────────────────────────────────────────
  Widget _vDivider() => Container(
        width: 1,
        height: 22,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: _bgLight.withOpacity(0.18),
      );

  // ─── AppBar helpers ───────────────────────────────────────────────────────
  Widget _appBarIconBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: _bgLight, size: 22),
      tooltip: tooltip,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }

  Widget _appBarToggle({
    IconData? icon,
    String? label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? _bgLight.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? _bgLight.withOpacity(0.55)
                : _bgLight.withOpacity(0.25),
            width: 1.2,
          ),
        ),
        child: label != null
            ? Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : _bgLight.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Icon(
                icon,
                color: isActive ? Colors.white : _bgLight.withOpacity(0.8),
                size: 20,
              ),
      ),
    );
  }
}