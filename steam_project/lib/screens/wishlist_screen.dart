import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:steam_project/resources/resources.dart';

import '../components/buttons/svg_button.dart';
import '../components/game_card.dart';

class WishListPage extends StatefulWidget {
  const WishListPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WishListPageState createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Images.backgroundEmpty),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 65,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      width: 2,
                      color: Color.fromARGB(97, 0, 0, 0),
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const SizedBox(width: 12),
                        SvgClickableComponent(
                          svgPath: VectorialImages.close,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Ma liste de souhaits',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'GoogleSans',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('wishlist')
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data.docs.isNotEmpty) {
                      return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GameCard(
                            appId: snapshot.data.docs[index].id,
                            gameName: snapshot.data.docs[index]['name'],
                            backgroundImage: snapshot.data.docs[index]
                                ['background'],
                            gameEditor: snapshot.data.docs[index]['developers'],
                            free: snapshot.data.docs[index]['free'].toString(),
                            gameImage: snapshot.data.docs[index]['headerImage'],
                            price:
                                snapshot.data.docs[index]['price'].toString(),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgClickableComponent(
                                  svgPath: VectorialImages.emptyWhishlist,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                              const SizedBox(height: 50),
                              const Text(
                                  'Vous n’avez encore pas liké de contenu.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Proxima',
                                    color: Colors.white,
                                  )),
                              const SizedBox(height: 10),
                              const Text(
                                "Cliquez sur l'étoile pour en rajouter.",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Proxima',
                                  color: Colors.white,
                                ),
                              ),
                            ]),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
