import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class WebFetch extends StatefulWidget {
  const WebFetch({super.key});

  @override
  State<WebFetch> createState() => WebFetchState();
}

class WebFetchState extends State<WebFetch> {
  int currentPage = 0;
  static const int pageSize = 5;
  final List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: _appBar(),
        body: _futureBuilder(),
      ),
    );
  }

  Future<List<dynamic>> _fetchData() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Widget _futureBuilder() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchData(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          List<dynamic> data = snapshot.data!;
          return _buildWidget(data);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildWidget(List<dynamic> data) {
    int start = currentPage * pageSize;
    int end = start + pageSize;
    List<dynamic> pageData = data.sublist(start, end);

    return Expanded(
      child: ListView.builder(
        itemCount: pageData.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Text(pageData[index]['id'].toString()),
            title: Text(pageData[index]['title']),
            subtitle: Text(pageData[index]['body']),
          );
        },
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text('Web Fetch'),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              currentPage--;
              if (currentPage < 0) {
                currentPage = 0;
              }
            });
          },
          icon: const Icon(Icons.arrow_back),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              currentPage++;
              if (currentPage < (_data.length / pageSize).floor()) {
                currentPage++;
              }
            });
          },
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
}
