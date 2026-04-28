import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:profanity_filter/profanity_filter.dart';

import 'auth_gate.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

// ------------------------------------------------------------
// TOXICITY CHECKER (Light Filtering)
// ------------------------------------------------------------
final profanityFilter = ProfanityFilter();
bool isTextToxic(String text) => profanityFilter.hasProfanity(text);

// ------------------------------------------------------------
// MAIN APP
// ------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const IittiCommunityApp());
}

class IittiCommunityApp extends StatelessWidget {
  const IittiCommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iitti Community Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AuthGate(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}

// ------------------------------------------------------------
// MAIN NAVIGATION
// ------------------------------------------------------------
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  bool get isAdmin =>
      FirebaseAuth.instance.currentUser?.email == "admin@iitti.fi";

  List<Widget> get screens => [
    const HomeScreen(),
    const HelpScreen(),
    const ServicesScreen(),
    const CityUpdatesScreen(),
    if (isAdmin) const AdminServicesScreen(),
    const ProfileScreen(),
  ];

  List<BottomNavigationBarItem> get navItems => [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    const BottomNavigationBarItem(
      icon: Icon(Icons.volunteer_activism),
      label: 'Help',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.handyman),
      label: 'Services',
    ),
    const BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Updates'),
    if (isAdmin)
      const BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings),
        label: 'Admin',
      ),
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iitti Community Platform'),
        centerTitle: true,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const CreatePostDialog(),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Post"),
            )
          : null,
    );
  }
}

// ------------------------------------------------------------
// HOME SCREEN
// ------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "No posts yet.\nCreate the first one!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return InfoCard(
              title: d['title'],
              subtitle: d['description'],
              icon: Icons.campaign,
              color: Colors.blue,
            );
          }).toList(),
        );
      },
    );
  }
}

// ------------------------------------------------------------
// HELP SCREEN
// ------------------------------------------------------------
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionTitle("Community Help"),
        const SizedBox(height: 8),
        const Text("Ask for or offer help in your community."),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const CreateHelpRequestDialog(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Help Request"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const CreateHelpOfferDialog(),
                  );
                },
                icon: const Icon(Icons.volunteer_activism),
                label: const Text("Offer Help"),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        const SectionTitle("Help Requests"),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('help_requests')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Text("No help requests yet.");

            return Column(
              children: docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return InfoCard(
                  title: d['title'],
                  subtitle:
                      "${d['description']}\nArea: ${d['area']}\nPhone: ${d['phone']}",
                  icon: Icons.help_outline,
                  color: Colors.orange,
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 24),
        const SectionTitle("Help Offers"),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('help_offers')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Text("No help offers yet.");

            return Column(
              children: docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return InfoCard(
                  title: d['title'],
                  subtitle:
                      "${d['description']}\nArea: ${d['area']}\nPhone: ${d['phone']}",
                  icon: Icons.volunteer_activism,
                  color: Colors.green,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// SERVICES SCREEN
// ------------------------------------------------------------
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionTitle("Local Services"),
        const SizedBox(height: 8),

        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const SubmitServiceDialog(),
            );
          },
          icon: const Icon(Icons.add_business),
          label: const Text("Submit Your Service"),
        ),

        const SizedBox(height: 16),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('services')
              .orderBy('name')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Text("No approved services yet.");

            return Column(
              children: docs.map((doc) {
                final s = doc.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(s['name']),
                    subtitle: Text(
                      "${s['type']}\n${s['phone']}\n${s['email']}",
                    ),
                    isThreeLine: true,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// CITY UPDATES SCREEN
// ------------------------------------------------------------
class CityUpdatesScreen extends StatelessWidget {
  const CityUpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(child: SectionTitle("City Announcements & Events")),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => const _CreateUpdateChooser(),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),
        const SectionTitle("Notices"),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notices')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Text("No notices yet.");

            return Column(
              children: docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return InfoCard(
                  title: d['title'],
                  subtitle: d['description'],
                  icon: Icons.campaign,
                  color: Colors.blue,
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 24),
        const SectionTitle("Events"),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Text("No events yet.");

            return Column(
              children: docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return InfoCard(
                  title: d['title'],
                  subtitle: d['description'],
                  icon: Icons.event,
                  color: Colors.purple,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// ADMIN SERVICES SCREEN
// ------------------------------------------------------------
class AdminServicesScreen extends StatelessWidget {
  const AdminServicesScreen({super.key});

  Future<void> approveService(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance.collection('services').add({
      'name': data['name'],
      'type': data['type'],
      'phone': data['phone'],
      'email': data['email'],
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('services_pending')
        .doc(doc.id)
        .delete();
  }

  Future<void> rejectService(DocumentSnapshot doc) async {
    await FirebaseFirestore.instance
        .collection('services_pending')
        .doc(doc.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin — Pending Services"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('services_pending')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No pending services.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.pending_actions),
                  title: Text(d['name']),
                  subtitle: Text("${d['type']}\n${d['phone']}\n${d['email']}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => approveService(doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => rejectService(doc),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------
// PROFILE SCREEN
// ------------------------------------------------------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionTitle("Profile"),
        const SizedBox(height: 8),

        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(user?.email ?? "Unknown user"),
          subtitle: const Text("Logged in"),
        ),

        const SizedBox(height: 24),
        const SectionTitle("My Area"),

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Select your area",
          ),
          items: const [
            DropdownMenuItem(value: "Kausala", child: Text("Kausala")),
            DropdownMenuItem(value: "Vuolenkoski", child: Text("Vuolenkoski")),
            DropdownMenuItem(value: "Sitikkala", child: Text("Sitikkala")),
            DropdownMenuItem(value: "Lyöttilä", child: Text("Lyöttilä")),
            DropdownMenuItem(value: "Perheniemi", child: Text("Perheniemi")),
          ],
          onChanged: (value) {},
        ),

        const SizedBox(height: 24),
        const SectionTitle("Settings"),

        SwitchListTile(
          title: const Text("Enable notifications"),
          value: true,
          onChanged: (v) {},
        ),

        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();

            await Future.delayed(const Duration(milliseconds: 300));

            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text("Logout"),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// REUSABLE WIDGETS
// ------------------------------------------------------------
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

// ------------------------------------------------------------
// DIALOGS
// ------------------------------------------------------------

// ------------------------------------------------------------
// CREATE POST
// ------------------------------------------------------------
class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({super.key});

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Post"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: "Description"),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
                  setState(() => loading = true);

                  // TOXICITY CHECK (Light)
                  if (isTextToxic(descriptionController.text)) {
                    setState(() => loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Your post contains inappropriate language.",
                        ),
                      ),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance.collection('posts').add({
                    'title': titleController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context);
                },
          child: loading
              ? const CircularProgressIndicator()
              : const Text("Post"),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// CREATE HELP REQUEST
// ------------------------------------------------------------
class CreateHelpRequestDialog extends StatefulWidget {
  const CreateHelpRequestDialog({super.key});

  @override
  State<CreateHelpRequestDialog> createState() =>
      _CreateHelpRequestDialogState();
}

class _CreateHelpRequestDialogState extends State<CreateHelpRequestDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final areaController = TextEditingController();
  final phoneController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Help Request"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: "Description"),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: areaController,
            decoration: const InputDecoration(labelText: "Area"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: "Phone"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
                  setState(() => loading = true);

                  // TOXICITY CHECK (Light)
                  if (isTextToxic(descriptionController.text)) {
                    setState(() => loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Your help request contains inappropriate language.",
                        ),
                      ),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance
                      .collection('help_requests')
                      .add({
                        'title': titleController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'area': areaController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                  Navigator.pop(context);
                },
          child: loading
              ? const CircularProgressIndicator()
              : const Text("Post"),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// CREATE HELP OFFER
// ------------------------------------------------------------
class CreateHelpOfferDialog extends StatefulWidget {
  const CreateHelpOfferDialog({super.key});

  @override
  State<CreateHelpOfferDialog> createState() => _CreateHelpOfferDialogState();
}

class _CreateHelpOfferDialogState extends State<CreateHelpOfferDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final areaController = TextEditingController();
  final phoneController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Offer Help"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: "Description"),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: areaController,
            decoration: const InputDecoration(labelText: "Area"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: "Phone"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
                  setState(() => loading = true);

                  // TOXICITY CHECK (Light)
                  if (isTextToxic(descriptionController.text)) {
                    setState(() => loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Your help offer contains inappropriate language.",
                        ),
                      ),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance
                      .collection('help_offers')
                      .add({
                        'title': titleController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'area': areaController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                  Navigator.pop(context);
                },
          child: loading
              ? const CircularProgressIndicator()
              : const Text("Post"),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// SUBMIT SERVICE (Light toxicity on service name only)
// ------------------------------------------------------------
class SubmitServiceDialog extends StatefulWidget {
  const SubmitServiceDialog({super.key});

  @override
  State<SubmitServiceDialog> createState() => _SubmitServiceDialogState();
}

class _SubmitServiceDialogState extends State<SubmitServiceDialog> {
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Submit Your Service"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Service Name"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: typeController,
            decoration: const InputDecoration(labelText: "Service Type"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: "Phone Number"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
                  setState(() => loading = true);

                  // TOXICITY CHECK (Light)
                  if (isTextToxic(nameController.text)) {
                    setState(() => loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Service name contains inappropriate language.",
                        ),
                      ),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance
                      .collection('services_pending')
                      .add({
                        'name': nameController.text.trim(),
                        'type': typeController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'email': emailController.text.trim(),
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                  Navigator.pop(context);
                },
          child: loading
              ? const CircularProgressIndicator()
              : const Text("Submit"),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// CREATE NOTICE
// ------------------------------------------------------------
class CreateNoticeDialog extends StatefulWidget {
  const CreateNoticeDialog({super.key});

  @override
  State<CreateNoticeDialog> createState() => _CreateNoticeDialogState();
}

class _CreateNoticeDialogState extends State<CreateNoticeDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Notice"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: "Description"),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
                  setState(() => loading = true);

                  // TOXICITY CHECK (Light)
                  if (isTextToxic(descriptionController.text)) {
                    setState(() => loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Your notice contains inappropriate language.",
                        ),
                      ),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance.collection('notices').add({
                    'title': titleController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context);
                },
          child: loading
              ? const CircularProgressIndicator()
              : const Text("Create"),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// CREATE EVENT
// ------------------------------------------------------------
class CreateEventDialog extends StatefulWidget {
  const CreateEventDialog({super.key});

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Event"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: "Description"),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: loading
              ? null
              : () async {
                  setState(() => loading = true);

                  // TOXICITY CHECK (Light)
                  if (isTextToxic(descriptionController.text)) {
                    setState(() => loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Your event contains inappropriate language.",
                        ),
                      ),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance.collection('events').add({
                    'title': titleController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context);
                },
          child: loading
              ? const CircularProgressIndicator()
              : const Text("Create"),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// UPDATE CREATION CHOOSER (Bottom Sheet)
// ------------------------------------------------------------
class _CreateUpdateChooser extends StatelessWidget {
  const _CreateUpdateChooser({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text("Create Notice"),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => const CreateNoticeDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text("Create Event"),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => const CreateEventDialog(),
              );
            },
          ),
        ],
      ),
    );
  }
}
