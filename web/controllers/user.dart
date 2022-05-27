import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:supabase/supabase.dart';

import '../server.dart';

class Users {
  final client = SupabaseClient(url, key);

  Handler get handler {
    final router = Router(
        notFoundHandler: (Request request) =>
            Response.notFound('We dont have an API for this request'));

    /// Create new user

    router.post('/users/create', (Request request) async {
      final payload = jsonDecode(await request.readAsString());

      // If the payload is passed properly
      if (payload.containsKey('name') && payload.containsKey('age')) {
        // Create operation
        final res = await client
            .from('user')
            .insert({'name': payload['name'], 'age': payload['age']}).execute();

        // If Create operation fails
        if (res.error != null) {
          return Response.notFound(
              jsonEncode({
                'success': false,
                'data': res.error.message,
              }),
              headers: {'Content-type': 'application/json'});
        }

        // Return the newly added data
        print(res.data.toString());
        return Response.ok(
          jsonEncode({'success': true, 'data': res.data}),
          headers: {'Content-type': 'application/json'},
        );
      }

      // If data sent as payload is not as per the rules
      return Response.notFound(
          jsonEncode({
            'success': false,
            'data': 'Invalid data sent to API',
          }),
          headers: {'Content-type': 'application/json'});
    });

    /// Read all users

    router.get('/users', (Request request) async {
      final res = await client.from('user').select().execute();

      // If the select operation fails
      if (res.error != null) {
        return Response.notFound(
            jsonEncode({'success': false, 'data': res.error.message}),
            headers: {'Content-type': 'application/json'});
      }

      final result = {
        'success': true,
        'data': res.data,
      };

      return Response.ok(jsonEncode(result),
          headers: {'Content-type': 'application/json'});
    });

    /// Read user data with id

    router.get('/users/<id>', (Request request, String id) async {
      final res =
          await client.from('user').select().match({'id': id}).execute();

      // res.data is null if we pass a string as ID eg: 11a
      if (res.data == null) {
        return Response.notFound(
            jsonEncode({'success': false, 'data': 'Invalid ID'}),
            headers: {'Content-type': 'application/json'});
      }

      // res.data.length is 0 if an entry with given ID is not present
      if (res.data.length != 0) {
        final result = {'success': true, 'data': res.data};

        return Response.ok(jsonEncode(result),
            headers: {'Content-type': 'application/json'});
      } else {
        return Response.notFound(
            jsonEncode({
              'success': false,
              'data': 'No data available for selected ID'
            }),
            headers: {'Content-type': 'application/json'});
      }
    });

    /// Update user using Id

    router.put('/users/update/<id>', (Request request, String id) async {
      final payload = jsonDecode(await request.readAsString());

      final res =
          await client.from('user').update(payload).match({'id': id}).execute();

      // if update operation was successful
      if (res.data != null) {
        final result = {'success': true, 'data': res.data};

        return Response.ok(jsonEncode(result),
            headers: {'Content-type': 'application/json'});
      }

      // if update operation failed
      else if (res.error != null) {
        // if the Id passed does not exist in the DB
        if (res.error.message.toString() == '[]') {
          return Response.notFound(
              jsonEncode({
                'success': false,
                'data': 'Id does not exist',
              }),
              headers: {'Content-type': 'application/json'});
        }

        // If any internal issue or the data passed is invalid
        return Response.notFound(
            jsonEncode({
              'success': false,
              'data': res.error.message,
            }),
            headers: {'Content-type': 'application/json'});
      }
    });

    /// Delete a user using ID

    router.delete('/users/delete/<id>', (Request request, String id) async {
      final res =
          await client.from('user').delete().match({'id': id}).execute();

      // if delete operation was successful
      if (res.data != null) {
        if (res.data.toString() == '[]') {
          return Response.notFound(
              jsonEncode({'success': false, 'data': 'Id not found'}),
              headers: {'Content-type': 'application/json'});
        }
        final result = {'success': true, 'data': res.data};

        return Response.ok(jsonEncode(result),
            headers: {'Content-type': 'application/json'});
      }

      // if delete operation failed
      else if (res.error != null) {
        // if the Id passed does not exist in the DB
        if (res.error.message.toString() == '[]') {
          return Response.notFound(
              jsonEncode({
                'success': false,
                'data': 'Id does not exist',
              }),
              headers: {'Content-type': 'application/json'});
        }

        // If any internal issue or the data passed is invalid
        return Response.notFound(
            jsonEncode({
              'success': false,
              'data': res.error.message,
            }),
            headers: {'Content-type': 'application/json'});
      }
    });
    return router;
  }
}
