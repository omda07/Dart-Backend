import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import 'controllers/user.dart';

String url = "https://opchcovhgfbakdyiqpwy.supabase.co";
String key =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9wY2hjb3ZoZ2ZiYWtkeWlxcHd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2NTM1NjgzMTAsImV4cCI6MTk2OTE0NDMxMH0.8TZYsSNJKTKueKwNQMgQsWHF5aK5bolYPw-fsRolUOg';

void main(List<String> args) async {
  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(Users().handler);

  var server = await io.serve(handler, 'localhost', 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}
