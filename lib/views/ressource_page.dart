import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../services/ressources_service.dart';
import '../services/authorization_service.dart';

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
  final _authorizationService = AuthorizationService();

  List<Resource> _resources = [];
  List<String> _resourceTypes = ['Tous'];
  String _selectedType = 'Tous';
  bool _isLoading = true;
  bool _hasPermission = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadResources();
  }

  Future<void> _checkPermissionAndLoadResources() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Vérifier si l'utilisateur a le droit de gérer les ressources
      final canManageResources = await _authorizationService.canAddResource();

      if (mounted) {
        setState(() {
          _hasPermission = canManageResources;
        });

        if (canManageResources) {
          _loadResources();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Vous n\'avez pas les droits pour gérer les ressources.';
          });

          // Afficher un message et rediriger vers la page d'accueil
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vous n\'avez pas les droits pour gérer les ressources.'),
              backgroundColor: Colors.red,
            ),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur lors de la vérification des droits: $e';
        });
      }
    }
  }

  Future<void> _loadResources() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await ResourceService().getAllResources();

      // Afficher un message de débogage
      print('Ressources chargées: ${data.length}');
      for (var res in data) {
        print('Ressource ID: ${res.id}, Nom: ${res.name}, Type: ${res.type}');
      }

      // Si aucune ressource n'est trouvée, insérer des ressources de test
      if (data.isEmpty) {
        await _insertTestResources();
        // Recharger les ressources après l'insertion
        final updatedData = await ResourceService().getAllResources();

        if (mounted) {
          setState(() {
            _resources = updatedData;
            _resourceTypes = ['Tous', ...{...updatedData.map((e) => e.type)}];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _resources = data;
            _resourceTypes = ['Tous', ...{...data.map((e) => e.type)}];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des ressources: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des ressources: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Insérer des ressources de test
  Future<void> _insertTestResources() async {
    final resourceService = ResourceService();

    // Liste des ressources de test
    final testResources = [
      Resource(
        name: 'Salle de réunion A',
        type: 'Salle',
        description: 'Grande salle de réunion avec projecteur',
        capacity: 20,
      ),
      Resource(
        name: 'Salle de conférence B',
        type: 'Salle',
        description: 'Salle de conférence avec équipement audio',
        capacity: 50,
      ),
      Resource(
        name: 'Ordinateur portable',
        type: 'Équipement',
        description: 'Ordinateur portable pour présentations',
        capacity: 1,
      ),
      Resource(
        name: 'Projecteur',
        type: 'Équipement',
        description: 'Projecteur HD pour présentations',
        capacity: 1,
      ),
      Resource(
        name: 'Voiture de service',
        type: 'Véhicule',
        description: 'Voiture de service pour déplacements professionnels',
        capacity: 5,
      ),
    ];

    // Insérer chaque ressource
    for (var resource in testResources) {
      await resourceService.insertResource(resource);
    }

    print('Ressources de test insérées avec succès');
  }

  List<Resource> get _filteredResources {
    if (_selectedType == 'Tous') return _resources;
    return _resources.where((r) => r.type == _selectedType).toList();
  }

  Future<void> _addResource() async {
    // Vérifier à nouveau les autorisations
    if (!_hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous n\'avez pas les droits pour ajouter une ressource.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_formKey.currentState!.validate()) {
      final newResource = Resource(
        name: _nameController.text,
        type: _typeController.text,
        description: _descriptionController.text,
        capacity: int.parse(_capacityController.text),
      );

      try {
        await ResourceService().insertResource(newResource);
        _clearForm();

        if (mounted) {
          Navigator.pop(context);
          _loadResources();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Ressource ajoutée"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erreur lors de l'ajout: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _typeController.clear();
    _descriptionController.clear();
    _capacityController.clear();
  }

  Future<void> _deleteResource(int id) async {
    // Vérifier à nouveau les autorisations
    if (!_hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous n\'avez pas les droits pour supprimer une ressource.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      await ResourceService().deleteResource(id);

      if (mounted) {
        _loadResources();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ressource supprimée"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la suppression: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResources,
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            tooltip: 'Accueil',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasPermission
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Accès refusé',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: const Text('Retour à l\'accueil'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        value: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                        items: _resourceTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: _filteredResources.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.info_outline, color: Colors.blue, size: 48),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Aucune ressource disponible',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text('Ajouter une ressource'),
                                    onPressed: _openAddDialog,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredResources.length,
                              itemBuilder: (context, index) {
                                final resource = _filteredResources[index];
                                return Card(
                                  margin: const EdgeInsets.all(8),
                                  elevation: 2,
                                  child: ListTile(
                                    title: Text(
                                      resource.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Type: ${resource.type}"),
                                        Text("Capacité: ${resource.capacity}"),
                                        Text("Description: ${resource.description}"),
                                      ],
                                    ),
                                    isThreeLine: true,
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteResource(resource.id!),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: _hasPermission
          ? FloatingActionButton(
              onPressed: _openAddDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
