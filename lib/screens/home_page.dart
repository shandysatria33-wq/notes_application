import 'package:flutter/material.dart';
import '../models/note.dart';
import 'edit_note.dart';
import 'package:intl/intl.dart';
import 'login.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];
  String search = '';

  // ─── Tambah atau update note ──────────────────────────────────────────────
  void addOrUpdate(Note note) {
    setState(() {
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index >= 0) {
        notes[index] = note;
      } else {
        notes.add(note);
      }
    });
  }

  // ─── Hapus note ───────────────────────────────────────────────────────────
  void deleteNote(String id) {
    setState(() => notes.removeWhere((note) => note.id == id));
  }

  // ─── Navigasi ke EditNotePage & tangkap hasil ─────────────────────────────
  Future<void> _openEditPage({Note? note}) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(note: note)),
    );

    if (result == null) return;

    // Hasil hapus
    if (result is Map && result['delete'] != null) {
      deleteNote(result['delete'] as String);
      return;
    }

    // Hasil simpan
    if (result is EditNoteResult) {
      addOrUpdate(result.updatedNote);
    }
  }

  // ─── Helper: ambil preview teks dari konten JSON Quill ────────────────────
  String _previewText(String content) {
    try {
      final json = jsonDecode(content) as List;
      return json
          .map((e) => (e['insert'] ?? '').toString())
          .join()
          .trim();
    } catch (_) {
      return content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = notes.where((n) {
      final q = search.toLowerCase();
      return n.title.toLowerCase().contains(q) ||
          _previewText(n.content).toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFDAD9D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF293B42),
        elevation: 0,
        title: const Text(
          'NOTES',
          style: TextStyle(
            color: Color(0xFFDAD9D4),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          if (AccountPage.isLoggedIn)
            const Center(
              child: Text(
                'Welcome, Shandy',
                style: TextStyle(color: Color(0xFFDAD9D4), fontSize: 12),
              ),
            ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountPage()),
                );
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0x665D6E75),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFFDAD9D4),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── SEARCH ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x26293B42),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x4D5D6E75)),
              ),
              child: TextField(
                style: const TextStyle(color: Color(0xFF293B42)),
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle:
                      TextStyle(color: Color(0xB35D6E75), fontSize: 14),
                  prefixIcon:
                      Icon(Icons.search, color: Color(0xCC5D6E75)),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                ),
                onChanged: (value) => setState(() => search = value),
              ),
            ),
          ),

          // ── LIST ───────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada catatan',
                      style:
                          TextStyle(color: Color(0x995D6E75), fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final note = filtered[index];
                      return GestureDetector(
                        onTap: () => _openEditPage(note: note),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0x2E5D6E75),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0x405D6E75)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(note.date),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xCC5D6E75),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  note.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF293B42),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _previewText(note.content),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xA6293B42),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ── TAMBAH NOTE ────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF293B42),
        onPressed: () => _openEditPage(),
        child: const Icon(Icons.add, color: Color(0xFFDAD9D4)),
      ),
    );
  }
}