import 'package:flutter/material.dart';
import 'package:implicitly_animated_list/implicitly_animated_list.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:meilisearch/meilisearch.dart';

import 'model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secrets',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Secrets'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  List<SecretModel> searchResults = [];
  var client = MeiliSearchClient('http://127.0.0.1:7700', 'masterKey');

  Future<void> searchSecrets(String _query) async {
    try {
      var index = client.index('secrets');
      var results = await index.search(_query);
      if (results.hits!.length == 0) {
        print('No results found');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("No results found")));
      }
      setState(() {
        searchResults =
            results.hits!.map((e) => SecretModel.fromSearch(e)).toList();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void addSecret() async {
    // An index where secrets are stored.
    var index = client.index('secrets');
    var documents = [
      {'sid': 123, 'author': 'Steven', 'secret': 'Pride and Prejudice'},
      {'sid': 456, 'author': 'Albert', 'secret': 'Le Petit Prince'},
      {'sid': 1, 'author': 'Mary', 'secret': 'Alice In Wonderland'},
      {'sid': 1344, 'author': 'Ogwal', 'secret': 'The Hobbit'},
      {
        'sid': 4,
        'author': 'Peter',
        'secret': 'Harry Potter and the Half-Blood Prince'
      },
      {
        'sid': 42,
        'author': 'Jame',
        'secret': 'The Hitchhiker\'s Guide to the Galaxy'
      }
    ];

    // Add documents into index we just created.
    var update = await index.addDocuments(documents);
    print(update.updateId); // => { "updateId": 0 }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          buildBody(),
          buildSearchBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addSecret,
        tooltip: 'write',
        child: Icon(Icons.edit),
      ),
    );
  }

  Widget buildSearchBar() {
    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      width: 600,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
        if (query.isNotEmpty)
          searchSecrets(query);
        else
          setState(() => isLoading = false);
      },
      onFocusChanged: (isFocused) {
        setState(() => searchResults.clear());
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      leadingActions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(
              Icons.bolt,
              size: 30,
              color: Colors.blue,
            ),
            onPressed: () {},
          ),
        ),
      ],
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return Material(
          elevation: 6.0,
          borderRadius: BorderRadius.circular(
            8.0,
          ),
          child: ImplicitlyAnimatedList(
            shrinkWrap: true,
            itemData: searchResults,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, SecretModel data) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text("${data.id}"),
                ),
                title: Text("${data.author}"),
                subtitle: Text("${data.secret}"),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildBody() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 100),
      itemCount: 20,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(index.toString()),
          ),
          title: Text("Lorem ipsum $index"),
          subtitle: Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
          ),
        ),
      ),
    );
  }
}
