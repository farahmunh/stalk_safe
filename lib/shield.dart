import 'package:flutter/material.dart';
import 'home.dart'; // Import home.dart

class Shield extends StatefulWidget {
  @override
  _ShieldState createState() => _ShieldState();
}

class _ShieldState extends State<Shield> {
  List<Map<String, String>> contacts = [
    {'name': 'Ayah', 'phone': '+601111222334'},
    {'name': 'Ibu', 'phone': '+601987654321'},
    {'name': 'Abang', 'phone': '+601135792468'},
    {'name': 'Kakak', 'phone': '+601246813579'},
  ];

  String? primaryContact;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _addNewContact() {
    if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
      setState(() {
        contacts.add({
          'name': _nameController.text,
          'phone': _phoneController.text,
        });
      });
      Navigator.of(context).pop();
      _nameController.clear();
      _phoneController.clear();
    }
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addNewContact,
              child: Text('Add Contact'),
            ),
          ],
        );
      },
    );
  }

  void _setPrimaryContact(String name) {
    setState(() {
      primaryContact = name;
    });
  }

  void _confirmDeleteContact(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Contact'),
          content: Text(
              'Are you sure you want to delete ${contacts[index]['name']} from your emergency contacts?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteContact(index);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length + 1, // +1 for the Add Contact button
                itemBuilder: (context, index) {
                  if (index == contacts.length) {
                    // Add Contact Button at the end of the list
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.green),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Icon(Icons.add_circle_rounded, color: Colors.black),
                        title: Text(
                          'Add New Contact',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        onTap: _showAddContactDialog,
                      ),
                    );
                  }

                  final contact = contacts[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.green),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: IconButton(
                        icon: Icon(
                          Icons.star,
                          color: primaryContact == contact['name']
                              ? Colors.amber
                              : Colors.grey,
                        ),
                        onPressed: () {
                          _setPrimaryContact(contact['name']!);
                        },
                      ),
                      title: Text(contact['name']!),
                      subtitle: Text(contact['phone']!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.message, color: Colors.green),
                            onPressed: () {
                              // Handle send message action
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.call, color: Colors.green),
                            onPressed: () {
                              // Handle call action
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.video_call, color: Colors.green),
                            onPressed: () {
                              // Handle video call action
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmDeleteContact(index);
                            },
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
      ),
      floatingActionButton: Container(
        width: 100,
        height: 100,
        child: FloatingActionButton(
          onPressed: () {
            // Handle Ask for Angela button tap
          },
          backgroundColor: Colors.green,
          shape: CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ask for',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'ANGELA',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          currentIndex: 1, // Set default to Shield (this page)
          onTap: _onBottomNavTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Location',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield),
              label: 'Shield',
            ),
          ],
        ),
      ),
    );
  }
}

