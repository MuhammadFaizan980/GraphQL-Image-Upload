import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

main() async {
  runApp(
    const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            XFile? xFile = await ImagePicker().pickImage(
              source: ImageSource.camera,
              imageQuality: 10,
            );
            if (xFile != null) {
              uploadImage(xFile.path);
            }
          },
          child: Text('PRESS ME'),
        ),
      ),
    );
  }

  GraphQLClient getGithubGraphQLClient() {
    final Link _link =
        HttpLink('http://10.0.2.2:1337/graphql', defaultHeaders: {
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNjQwNjEwMDcwLCJleHAiOjE2NDMyMDIwNzB9.k-WEn23_dUkERiaHGCJQwCEHTne8nmGBGXM4or3Wc6U',
    });

    return GraphQLClient(
      cache: GraphQLCache(),
      link: _link,
    );
  }

  Future<void> uploadImage(String filePath) async {
    final GraphQLClient _client = getGithubGraphQLClient();
    const String uploadFile = r"""
                                mutation($file: Upload!) {
                                  upload(file: $file) {
                                    data {
                                      id
                                    }
                                  }
                                }
                              """;
    var multipartFile = MultipartFile.fromBytes(
      'photo',
      File(filePath).readAsBytesSync(),
      filename: '${DateTime.now().second}.jpg',
      contentType: MediaType("image", "jpg"),
    );

    final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(uploadFile),
          variables: {
            'file': multipartFile,
          },
        )
    );
    print(result.data!['highights']['data']);
  }
}
