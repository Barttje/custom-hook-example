import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink link = HttpLink(
      uri: 'https://brief-quagga-80.hasura.app/v1/graphql',
    );

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: link,
      ),
    );

    return GraphQLProvider(
        client: client,
        child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          home: Scaffold(
            appBar: AppBar(
              title: Text("Flutter Hooks Example"),
            ),
            body: Demo(),
          ),
        ));
  }
}

class Demo extends HookWidget {
  static String fetchResults = """query drivers {
      Driver {
      name
      }
  }""";

  static List<String> drivers = ["Gasly", "Albon", "Verstappen", "Kvyat"];

  @override
  Widget build(BuildContext context) {
    final result = useQuery(context, fetchResults);
    if (result.loading) {
      return Text("Loading");
    }
    return ListView.builder(
        itemCount: result.data['Driver'].length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(result.data['Driver'][index]['name']),
          );
        });
  }
}

QueryResult useQuery(BuildContext context, String query) {
  final client = GraphQLProvider.of(context).value;
  final state = useState<QueryResult>(QueryResult(loading: true));
  useEffect(() {
    final promise = client.query(
      QueryOptions(documentNode: gql(query)),
    );
    promise.then((result) {
      state.value = result;
    });
    return () {};
  }, []);
  return state.value;
}
