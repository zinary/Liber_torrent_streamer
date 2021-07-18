import 'package:flutter/material.dart';

import 'movie_detail_page.dart';

class MoviesGridView extends StatelessWidget {
  const MoviesGridView({
    Key key,
    this.snapshot,
  }) : super(key: key);
  final snapshot;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: GridView.builder(
          // shrinkWrap: true,
          scrollDirection: Axis.vertical,
          // physics: BouncingScrollPhysics(),
          itemCount: snapshot.data.length - 2,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              color: Colors.grey[900],
              // height: 280,
              child: GestureDetector(
                  child: Hero(
                    tag: snapshot.data[index].title,
                    child: Card(
                      color: Colors.transparent,
                      shadowColor: Colors.black,
                      elevation: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          color: Colors.transparent,

                          // height: 250,
                          child: Image.network(
                            snapshot.data[index].poster_path,
                            fit: BoxFit.cover,
                            height: 250,
                            width: 180,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MovieDetailPage(snapshot.data[index]),
                      ),
                    );
                  }),
            );
          },
        ),
      ),
    );
  }
}
