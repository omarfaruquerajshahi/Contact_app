import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/contact.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Contact> contacts = [];
  String searchText = '';
  bool showFavorites = false;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final data = await DBHelper.getContacts(
      search: searchText,
      onlyFavorites: showFavorites,
    );
    setState(() => contacts = data);
  }

  Future<void> openForm([Contact? contact]) async {
    final saved = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditScreen(contact: contact)),
    );
    if (saved == true) loadContacts();
  }

  Future<void> toggleFavorite(Contact c) async {
    c.isFavorite = !c.isFavorite;
    await DBHelper.updateContact(c);
    loadContacts();
  }

  Future<void> confirmDelete(Contact c) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Delete "${c.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (yes == true) {
      await DBHelper.deleteContact(c.id!);
      loadContacts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showFavorites ? 'Favorite Contacts' : 'All Contacts'),
        actions: [
          IconButton(
            tooltip: showFavorites ? 'Show all' : 'Show favorites',
            icon: Icon(showFavorites ? Icons.star : Icons.star_border),
            onPressed: () {
              setState(() => showFavorites = !showFavorites);
              loadContacts();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                searchText = value;
                loadContacts();
              },
            ),
          ),
          // Contact list
          Expanded(
            child: contacts.isEmpty
                ? const Center(child: Text('No contacts found'))
                : ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final c = contacts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(c.name[0].toUpperCase()),
                          ),
                          title: Text(c.name),
                          subtitle: Text(c.phone),
                          onTap: () => openForm(c), // tap to update
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  c.isFavorite ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () => toggleFavorite(c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () => confirmDelete(c),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
