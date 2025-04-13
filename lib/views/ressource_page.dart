import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../services/ressources_service.dart';

class ResourcePage extends StatefulWidget {
  const ResourcePage({super.key});

  @override
  State<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();

  List<Resource> _resources = [];

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    final data = await ResourceService().getAllResources();
    setState(() {
      _resources = data;
    });
  }

  Future<void> _addResource() async {
    if (_formKey.currentState!.validate()) {
      final newResource = Resource(
        name: _nameController.text,
        type: _typeController.text,
        description: _descriptionController.text,
        capacity: int.parse(_capacityController.text),
      );
      await ResourceService().insertResource(newResource);
      _clearForm();
      Navigator.pop(context);
      _loadResources();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ressource ajoutée")),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _typeController.clear();
    _descriptionController.clear();
    _capacityController.clear();
  }

  Future<void> _deleteResource(int id) async {
    await ResourceService().deleteResource(id);
    _loadResources();
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter une ressource"),
        content: Form(
          key: _formKey,
          child: SizedBox(
            height: 250,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) => value!.isEmpty ? "Champ requis" : null,
                  ),
                  TextFormField(
                    controller: _typeController,
                    decoration: const InputDecoration(labelText: 'Type'),
                    validator: (value) => value!.isEmpty ? "Champ requis" : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value!.isEmpty ? "Champ requis" : null,
                  ),
                  TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Capacité'),
                    validator: (value) => value!.isEmpty ? "Champ requis" : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(onPressed: _addResource, child: const Text("Ajouter")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ressources disponibles"),
      ),
      body: ListView.builder(
        itemCount: _resources.length,
        itemBuilder: (context, index) {
          final resource = _resources[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(resource.name),
              subtitle: Text("${resource.type} • Capacité : ${resource.capacity}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteResource(resource.id!),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
