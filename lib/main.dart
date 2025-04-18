import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class Mahasiswa {
  final String namaDepan;
  final String namaBelakang;

  Mahasiswa(this.namaDepan, this.namaBelakang);

  String get namaLengkap => '$namaDepan $namaBelakang';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mahasiswa &&
          runtimeType == other.runtimeType &&
          namaDepan == other.namaDepan &&
          namaBelakang == other.namaBelakang;

  @override
  int get hashCode => namaDepan.hashCode ^ namaBelakang.hashCode;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'UTS Aplikasi Bergerak',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final List<Mahasiswa> _semuaMahasiswa = [
    Mahasiswa("Shahibul", "Fikri"),
    Mahasiswa("Bayu", "Aji"),
    Mahasiswa("Yani", "Alifen"),
    Mahasiswa("Husen", "Masang"),
    Mahasiswa("Abdullah", "Muhtahir"),
    Mahasiswa("Ari", "Rahadian"),
    Mahasiswa("Aldi", "Oktavian"),
    Mahasiswa("Ikhsan", "Robani"),
    Mahasiswa("Rafi", "Firdaus"),
    Mahasiswa("Mukhsin", "Naufal"),
    Mahasiswa("Afrika", "Wirandau"),
    Mahasiswa("M", "Hilham"),
    Mahasiswa("Khairil", " "),
    Mahasiswa("Daffa", "G.J.P"),
  ];

  final List<Mahasiswa> favorites = [];
  final List<Mahasiswa> history = [];

  Mahasiswa current = Mahasiswa("Shahibul", "Fikri");
  late GlobalKey<AnimatedListState> historyListKey;

  void getNext() {
    final next = (_semuaMahasiswa.toList()..shuffle()).first;
    history.insert(0, current);
    final animatedList = historyListKey.currentState;
    animatedList?.insertItem(0);
    current = next;
    notifyListeners();
  }

  void toggleFavorite(Mahasiswa mahasiswa) {
    if (favorites.contains(mahasiswa)) {
      favorites.remove(mahasiswa);
    } else {
      favorites.add(mahasiswa);
    }
    notifyListeners();
  }

  void removeFavorite(Mahasiswa mahasiswa) {
    favorites.remove(mahasiswa);
    notifyListeners();
  }
}

// MyHomePage, Navigation, and Pages
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('No widget for index $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: MediaQuery.of(context).size.width >= 600,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.menu),
                  label: Text('Mahasiswa'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.star_border),
                  label: Text('Vote'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(child: Container(color: Theme.of(context).colorScheme.primaryContainer, child: page)),
        ],
      ),
    );
  }
}

// GeneratorPage
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var mahasiswa = appState.current;

    IconData icon = appState.favorites.contains(mahasiswa)
        ? Icons.star
        : Icons.star_border;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 3, child: HistoryListView()),
          SizedBox(height: 10),
          BigCard(mahasiswa: mahasiswa),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(mahasiswa);
                },
                icon: Icon(icon),
                label: Text('Vote'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

// BigCard Widget
class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.mahasiswa});

  final Mahasiswa mahasiswa;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  mahasiswa.namaDepan + ' ',
                  style: style.copyWith(fontWeight: FontWeight.w200),
                ),
                Text(
                  mahasiswa.namaBelakang,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// HistoryListView
class HistoryListView extends StatefulWidget {
  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    final appState = context.read<MyAppState>();
    appState.historyListKey = _key;
  }

  @override
  Widget build(BuildContext context) {
  final appState = context.watch<MyAppState>();
  return AnimatedList(
    key: _key,
    reverse: true,
    padding: EdgeInsets.all(8),
    initialItemCount: appState.history.length,
    itemBuilder: (context, index, animation) {
      final mahasiswa = appState.history[index];
      final isFavorite = appState.favorites.contains(mahasiswa);

      return SizeTransition(
        sizeFactor: animation,
        child: Card(
          child: ListTile(
            leading: isFavorite
                ? Icon(
                    Icons.star,
                    color: const Color.fromARGB(255, 65, 49, 4),
                  )
                : null, // Tidak ada ikon kalau belum di-like
            title: Text(mahasiswa.namaLengkap),
          ),
        ),
      );
    },
  );
}

}

// FavoritesPage
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(child: Text('Belum ada yang kamu Vote.'));
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Mahasiswa yang kamu Vote:', style: Theme.of(context).textTheme.titleLarge),
        ),
        for (var mahasiswa in appState.favorites)
          ListTile(
            leading: Icon(Icons.person),
            title: Text(mahasiswa.namaLengkap),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                appState.removeFavorite(mahasiswa);
              },
            ),
          ),
      ],
    );
  }
}
