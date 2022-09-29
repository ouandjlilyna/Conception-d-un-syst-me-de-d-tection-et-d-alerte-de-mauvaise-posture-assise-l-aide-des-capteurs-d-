import 'dart:ffi';
import 'package:flutter_local_notifications/flutter_local_notifications.dart ';
import 'package:flutter/material.dart';
import 'package:untitled/notification.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/Signup.dart';
import 'package:untitled/login.dart';
import 'package:untitled/bluetooth.dart';
import 'package:untitled/blue.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget{

   Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
         //home: MyHomePge(),
        home: MyHomePge(),
        routes: {
          "MyHomePge": (context) => MyHomePge(),
          "signup": (context) => SignUp(),
          "login": (context) => Login(),
          //"bluetooth": (context) => Bluetooth(),
          "blue": (context) => MyAppp(),
        },
      );
   }
}
class MyHomePge extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyHomePgeState() ;
  }
}

class MyHomePgeState extends State<MyHomePge>{
  int selectedindex=1;
  List widgetpages =[
    MyAppp(),
    Text(" "),
    advice(),

  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title : Text("SitWell", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold )),
        toolbarHeight: 70,
        backgroundColor: Colors.tealAccent[700],
        elevation: 8.8,
        centerTitle: true,
       /* flexibleSpace: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
              gradient: LinearGradient(
                  colors: [Colors.black,Colors.greenAccent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter
              )
          ),
        ),*/
      ),
      drawer: Drawer(backgroundColor: Colors.white),

      bottomNavigationBar: Stack(

        // we will have a custom container and bottom navigation bar on top of each other
        children: [
      Container(
      // this is the decoration of the container for gradient look
     /* decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
      gradient: LinearGradient(
          colors: [Colors.greenAccent,Colors.black],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter
      ),
    ),*/
    // i have found out the height of the bottom navigation bar is roughly 60

    height: 70,
    ),

      BottomNavigationBar(elevation: 20,
     backgroundColor: Colors.tealAccent[700],
      selectedItemColor: Colors.blueGrey[900],
      unselectedItemColor: Colors.white,
      currentIndex: selectedindex,

      onTap:(index) {print(index);
        setState(() { selectedindex=index;
                    }
                );
        },
      items: [

        BottomNavigationBarItem(label: " ",icon: Icon(Icons.bluetooth,size:40)),
        BottomNavigationBarItem(label: " ",icon: Icon(Icons.home,size:40)),
        BottomNavigationBarItem(label: " ",icon: Icon(Icons.list,size:40)),
        ],

      ),],),




      body:Container(
/*
          //color: Colors.green[100],
        padding: EdgeInsets.symmetric(horizontal: 5),
        width: 500,
        height:1500,
        decoration: const BoxDecoration(
           image: DecorationImage(
             image: AssetImage("images/vert.JPG"),
              fit:BoxFit.cover,
           ),


        ),*/
        child : Stack(
            children : [

              Container( margin: EdgeInsets.only(top: 60),
                // alignment:Alignment.center,
                //width: 400,
                height:90,
                child:
                Text(" Are you sitting with a good posture ?",textAlign: TextAlign.center,

                    style:TextStyle(fontSize: 30 ,fontWeight: FontWeight.bold , color:Colors.blueGrey[900],
                        //backgroundColor:Colors.grey[10],fontWeight: FontWeight.bold,
                        //shadows:[Shadow(color: Colors.black,blurRadius: 3.0,offset: Offset(2.0,2.0) )]
                    ),
                ),
                /*decoration: BoxDecoration(
                    color: Colors.white,
                    //border: Border.all(color: Colors.greenAccent ,width: 2),
                    boxShadow:[
                      BoxShadow(color:Colors.black12,blurRadius: 5,spreadRadius: 5,offset: Offset(4.0,7.0))
                    ]


                ),*/

              ),
              SizedBox(height:100),
              Center(child: Image.asset("images/unnamed.png",height: 200, width: 200,)),
         /*     Container(
                  width: 400,
                  height:400,
                  margin: EdgeInsets.only(top: 200),
                  padding: EdgeInsets.symmetric() ,
                  decoration: BoxDecoration(
                      image:DecorationImage(
                          fit:BoxFit.cover,

                          image: AssetImage("images/baaad.png"),
                          //centerSlice: Rect.fromCenter(center: Offset(200, 200), width: 100, height: 100),

                      ),
                     // boxShadow:[
                     //   BoxShadow(color:Colors.black12,blurRadius: 5,spreadRadius: 5,offset: Offset(4.0,7.0))
                    //  ]
                  )
              ),*/
              //Container( margin: EdgeInsets.only(left:330),
             //   child:Icon(Icons.circle_notifications_sharp ,size: 50, color: Colors.white,),),
              Container(width: 200,
                  height:40,

                  margin: EdgeInsets.only(top: 430,left: 100,right:100),
                  //margin: EdgeInsets.symmetric(horizontal),
                  //child:RaisedButton(splashColor : Colors.red,onPressed:(){}, child:Text("LOGIN"),color: Colors.green[300],
                  //textColor: Colors.white,elevation: 20,onLongPress:(){print('sign up');} ,)
                  child: ElevatedButton(onPressed:(){
                    showDialog(context: context, builder: (context){
                      return AlertDialog(
                       titlePadding: EdgeInsets.only(top: 20,left: 20),
                        contentPadding: EdgeInsets.all(20),
                        title: Text('Notice'),
                        content: Text('- you must activate the bluetooth of your phone.                                              - you need to activate the location of your phone.'),
                        contentTextStyle: TextStyle(color: Colors.blueGrey[900],fontWeight: FontWeight.bold ),
                        titleTextStyle: TextStyle(color : Colors.blueGrey[900],fontSize: 20,fontWeight: FontWeight.bold),
                        backgroundColor: Colors.white,
                        actions: <Widget>[
                         FlatButton(
                            color: Colors.teal,
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyAppp()));
                            },
                            child: Text('Next'),
                          ),
                        ],





                      );
                    });
                  }
                    ,child:Text("Start"),style: ElevatedButton.styleFrom
                      (textStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold ),
                      elevation: 10,shape: RoundedRectangleBorder
                        (borderRadius: BorderRadius.circular(30)),primary: Colors.blueGrey[900],

                  ),
                  )
                /*  child: ElevatedButton(onPressed:() async{
                    try {
                      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: "ferhataridj@gmail.com",
                        password: "123",
                      );
                      print(credential);
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        print('The password provided is too weak.');
                      } else if (e.code == 'email-already-in-use') {
                        print('The account already exists for that email.');
                      }
                    } catch (e) {
                      print(e);
                    }



                  },child:Text("Sign up"),style: ElevatedButton.styleFrom(textStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold ),elevation: 20,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),primary: Colors.green[700],)
              ),*/

  ),
        Container(child:widgetpages.elementAt(selectedindex),

        ),
            ]

        )

    ),
    );

  }
}


class blutooth extends StatelessWidget{
   Widget build(BuildContext context) {
      return Scaffold(
        //appBar: AppBar(backgroundColor: Colors.greenAccent,title : Text("Bluetooth")),
         drawer: Drawer(),
      );

   }
}
class advice extends StatelessWidget{
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //appBar: AppBar(backgroundColor: Colors.greenAccent,title : Text("Advices")),
      drawer: Drawer(),
        body:SingleChildScrollView(

        /*SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[


              //IconButton(icon: Icon(Icons.circle_notifications_sharp ,size: 40, color: Colors.grey),onPressed: (){_showNotification();}),
              Text("on the computer ",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold ,color: Colors.blueGrey[900],)),
              Image.asset("images/photo27.jpg",fit: BoxFit.fill),

              Text("driving",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold, color: Colors.blueGrey[900],)),
              Image.asset("images/photo12.jpg",fit: BoxFit.fill),

              Text("reading a book ",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold,color: Colors.blueGrey[900], )),
              Image.asset("images/photo25.jpg",fit: BoxFit.fill),


              Text("on the phone ",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold ,color: Colors.blueGrey[900], )),
              Image.asset("images/photo19.png",fit: BoxFit.fill),


              Text("watching television ",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold, color: Colors.blueGrey[900], )),
              Image.asset("images/photo26.jpg",fit: BoxFit.fitHeight),


            ],
          ),
        ),*/
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
          Container(
            margin: EdgeInsets.only(top: 20),
          child :Text(" Advice  ",textAlign: TextAlign.center,

          style:TextStyle(fontSize: 40 ,fontWeight: FontWeight.bold , color:Colors.lightBlueAccent,
            //backgroundColor:Colors.grey[10],fontWeight: FontWeight.bold,
            //shadows:[Shadow(color: Colors.black,blurRadius: 3.0,offset: Offset(2.0,2.0) )]
          ),
          ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
              child: Row(
                  children: <Widget> [
                    Expanded(
                      child: Container(
                        child: Center(
                          child: Text(
                            'Bad',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 30 ,fontWeight: FontWeight.bold ,
                            ),
                          ),
                        ),


                      ),
                    ),
                    Expanded(

                      child: Container(
                        child: Center(
                          child: Text(
                            'Good',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 30 ,fontWeight: FontWeight.bold ,
                            ),
                          ),

                        ),


                      ),
                    ),
                  ]
              )
          ),



          Container(
              margin: EdgeInsets.only(top: 5),
              child: Row(
                  children: <Widget> [
                    Expanded(
                      child: Container(
                        child: Center(
                          child: Icon(
                            Icons.cancel,
                            color:  Colors.red,
                          ),
                        ),


                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Center(
                          child: Icon(
                            Icons.check_circle,
                            color:  Colors.green,
                          ),
                        ),


                      ),
                    ),
                  ]
              )
          ),



          Container(
        margin: EdgeInsets.only(top: 20),
           height: 300,
            width: 500,

           child: PageView(

              children: [
                Image.asset("images/photo27.png",fit: BoxFit.fill),
                Image.asset("images/photo199.png",fit: BoxFit.fill),
                Image.asset("images/photo25.png",fit: BoxFit.fill),
                Image.asset("images/photo12.png",fit: BoxFit.fill),
                Image.asset("images/photo26.png",fit: BoxFit.fill),
                Image.asset("images/photo188.png",fit: BoxFit.fill),
                Image.asset("images/photo22.png",fit: BoxFit.fill),
                Image.asset("images/photo177.png",fit: BoxFit.fill),

              ],
          )



          ),

          Container(
              margin: EdgeInsets.only(top: 5),
              child: Row(
                  children: <Widget> [
                    Expanded(
                      child: Container(
                        child: Center(
                          child: Icon(
                            Icons.chevron_left,
                            color:  Colors.lightBlueAccent,
                              size :40
                          ),
                        ),


                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Center(
                          child: Icon(
                            Icons.chevron_right,
                            color:  Colors.lightBlueAccent,
                              size :40
                          ),
                        ),


                      ),
                    ),
                  ]
              )
          ),

            Container(
              margin: EdgeInsets.only(top: 50),
              child :Text(" Back exercises  ",textAlign: TextAlign.center,

                style:TextStyle(fontSize: 40 ,fontWeight: FontWeight.bold , color:Colors.lightBlueAccent,
                  //backgroundColor:Colors.grey[10],fontWeight: FontWeight.bold,
                  //shadows:[Shadow(color: Colors.black,blurRadius: 3.0,offset: Offset(2.0,2.0) )]
                ),
              ),
            ),



    Container(
    margin: EdgeInsets.only(top: 40),
    height: 320,
    width: 500,

    child: PageView(

    children: [
      Image.asset("images/posture7.png",fit: BoxFit.fill),
    Image.asset("images/posture11.jpg",fit: BoxFit.fill),
    Image.asset("images/posture5.jpg",fit: BoxFit.fill),
    Image.asset("images/posture8.png",fit: BoxFit.fill),
    Image.asset("images/posture9.png",fit: BoxFit.fill),
      Image.asset("images/posture10.jpg",fit: BoxFit.fill),


    ],
    )


    ),
            Container(
                margin: EdgeInsets.only(top: 5, bottom:50),
                child: Row(
                    children: <Widget> [
                      Expanded(
                        child: Container(
                          child: Center(
                            child: Icon(
                                Icons.chevron_left,
                                color:  Colors.lightBlueAccent,
                                size :40
                            ),
                          ),


                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Center(
                            child: Icon(
                                Icons.chevron_right,
                                color:  Colors.lightBlueAccent,
                                size :40
                            ),
                          ),


                        ),
                      ),
                    ]
                )
            ),

        ],
        ),
        ),

    );
  }
}
