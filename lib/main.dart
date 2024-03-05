import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Word Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EnterGridSizeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Word Search',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class EnterGridSizeScreen extends StatelessWidget {
  final TextEditingController _mController = TextEditingController();
  final TextEditingController _nController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Grid Size'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _mController,
              decoration: InputDecoration(labelText: 'Enter number of rows (m)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _nController,
              decoration: InputDecoration(labelText: 'Enter number of columns (n)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int m = int.tryParse(_mController.text) ?? 0;
                int n = int.tryParse(_nController.text) ?? 0;
                if (m > 0 && n > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnterAlphabetsScreen(m: m, n: n),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter valid values for m and n'),
                    ),
                  );
                }
              },
              child: Text('Create Grid'),
            ),
          ],
        ),
      ),
    );
  }
}

class EnterAlphabetsScreen extends StatelessWidget {
  final int m;
  final int n;
  final TextEditingController _textController = TextEditingController();

  EnterAlphabetsScreen({required this.m, required this.n});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Alphabets'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter alphabets for the grid (${m * n} characters required)',
              textAlign: TextAlign.center,
            ),
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Alphabets'),
              maxLength: m * n,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String input = _textController.text.toUpperCase();
                if (input.length == m * n) {
                  List<List<String>> grid = [];
                  for (int i = 0; i < m; i++) {
                    List<String> row = [];
                    for (int j = 0; j < n; j++) {
                      row.add(input[i * n + j]);
                    }
                    grid.add(row);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisplayGridScreen(grid: grid),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter exactly ${m * n} characters'),
                    ),
                  );
                }
              },
              child: Text('Display Grid'),
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayGridScreen extends StatelessWidget {
  final List<List<String>> grid;
  final TextEditingController _searchController = TextEditingController();

  DisplayGridScreen({required this.grid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Search'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: grid[0].length,
              ),
              itemCount: grid.length * grid[0].length,
              itemBuilder: (context, index) {
                int i = index ~/ grid[0].length;
                int j = index % grid[0].length;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: Text(
                      grid[i][j],
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(labelText: 'Enter text to search'),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                  onPressed: () {
                    String searchText = _searchController.text.toUpperCase();
                    if (searchText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter text to search'),
                        ),
                      );
                    } else {
                      List<List<bool>> highlights = searchInGrid(searchText, grid);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HighlightedGridScreen(grid: grid, highlights: highlights),
                        ),
                      );
                    }
                  },
                child: Text('Search'),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<List<bool>> searchInGrid(String searchText, List<List<String>> grid) {
    List<List<bool>> highlights = List.generate(grid.length, (i) => List.filled(grid[0].length, false));
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j] == searchText[0]) {
          // Check east
          bool foundEast = true;
          for (int k = 1; k < searchText.length; k++) {
            if (j + k >= grid[i].length || grid[i][j + k] != searchText[k]) {
              foundEast = false;
              break;
            }
          }
          if (foundEast) {
            for (int k = 0; k < searchText.length; k++) {
              highlights[i][j + k] = true;
            }
          }

          // Check south
          bool foundSouth = true;
          for (int k = 1; k < searchText.length; k++) {
            if (i + k >= grid.length || grid[i + k][j] != searchText[k]) {
              foundSouth = false;
              break;
            }
          }
          if (foundSouth) {
            for (int k = 0; k < searchText.length; k++) {
              highlights[i + k][j] = true;
            }
          }

          // Check southeast
          bool foundSE = true;
          for (int k = 1; k < searchText.length; k++) {
            if (i + k >= grid.length || j + k >= grid[i].length || grid[i + k][j + k] != searchText[k]) {
              foundSE = false;
              break;
            }
          }
          if (foundSE) {
            for (int k = 0; k < searchText.length; k++) {
              highlights[i + k][j + k] = true;
            }
          }
        }
      }
    }
    return highlights;
  }
}


class HighlightedGridScreen extends StatelessWidget {
  final List<List<String>> grid;
  final List<List<bool>> highlights;

  HighlightedGridScreen({required this.grid, required this.highlights});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Highlighted Grid'),
      ),
      body: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: grid[0].length,
            ),
            itemCount: grid.length * grid[0].length,
            itemBuilder: (context, index) {
              int i = index ~/ grid[0].length;
              int j = index % grid[0].length;
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: highlights[i][j] ? Colors.yellow : null,
                ),
                child: Center(
                  child: Text(
                    grid[i][j],
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Back'),
          ),
        ],
      ),
    );
  }
}
