import 'package:flutter/material.dart';
import '../../models/contact.dart';
import '../widgets/contact_tile.dart';
import '../widgets/empty_view.dart';
import 'edit_contact_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Contact> _contacts = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Contact> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _contacts;
    return _contacts.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          (c.email ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _addContact() async {
    final result = await Navigator.of(context).push<Contact>(
      MaterialPageRoute(builder: (_) => const EditContactScreen()),
    );
    if (result != null) {
      setState(() => _contacts.add(result));
      _showSnack('Contact ajouté');
    }
  }

  Future<void> _editContact(Contact contact) async {
    final idx = _contacts.indexWhere((c) => c.id == contact.id);
    if (idx == -1) return;
    final result = await Navigator.of(context).push<Contact>(
      MaterialPageRoute(builder: (_) => EditContactScreen(contact: contact)),
    );
    if (result != null) {
      setState(() => _contacts[idx] = result);
      _showSnack('Contact mis à jour');
    }
  }

  Future<void> _deleteContact(Contact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce contact ?'),
        content: Text('« ${contact.name} » sera définitivement supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _contacts.removeWhere((c) => c.id == contact.id));
      _showSnack('Contact supprimé');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYTMO CONTACT'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addContact,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Rechercher un contact…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),

          // Liste / vide
          Expanded(
            child: _filtered.isEmpty
                ? const EmptyView(
                    title: 'Aucun contact',
                    message:
                        'Ajoutez votre premier contact avec le bouton « Ajouter ».',
                    icon: Icons.contacts_outlined,
                  )
                : ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (_, i) {
                      final c = _filtered[i];
                      return ContactTile(
                        contact: c,
                        onTap: () => _editContact(c),
                        onEdit: () => _editContact(c),
                        onDelete: () => _deleteContact(c),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
