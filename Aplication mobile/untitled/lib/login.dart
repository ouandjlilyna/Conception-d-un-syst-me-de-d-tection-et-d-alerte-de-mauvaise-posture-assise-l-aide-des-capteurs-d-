import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}
class _LoginState extends State<Login>{
  var mypassword,myemail;
  GlobalKey<FormState> formstate =new GlobalKey<FormState>();


  signIn() async {
    var formdata= formstate.currentState;
    if (formdata!= null) {
      if (formdata.validate()) {
        print('valid');
        formdata.save();

        try {
          final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: myemail,
              password: mypassword,
          );
          return credential ;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            AwesomeDialog(context: context, title:"Error",body:Text('No user found for that email.'))
              ..show();

          } else if (e.code == 'wrong-password') {
            AwesomeDialog(context: context, title:"Error",body:Text('Wrong password provided for that user.'))
              ..show();

          }
        }


      }
    else{
      print("not valid!");
      }
    }

  }

   @override
  Widget build(BuildContext context) {
     // TODO: implement build
     //throw UnimplementedError();
     return Scaffold( body: ListView(

       children: [

         SizedBox(height:80),
         Center(child: Image.asset("images/baaad.png",height: 200, width: 200,)),
         Container(
           padding: EdgeInsets.all(20),
           child: Form(
               key: formstate,
               child:Column(
                 children: [
                   TextFormField( onSaved: (val){
                     myemail=val;
                   },
                     validator:(val){
                       if(val != null){
                         if(val.length>100){
                           return "email can't be larger than 100 letter";
                         }
                         if(val.length<2){
                           return "email can't be less than 2 letter";
                         }}
                       return null;
                     },
                     decoration: InputDecoration(
                       prefixIcon: Icon(Icons.person),
                       hintText:"email",
                       border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                     ),
                   ),
                   SizedBox(height:20),
                   TextFormField( onSaved: (val){
                     mypassword=val;
                   },
                     validator:(val){
                       if(val != null){
                         if(val.length>100){
                           return "password can't be larger than 100 letter";
                         }
                         if(val.length<4){
                           return "password can't be less than 4 letter";
                         }}
                       return null;
                     },
                     obscureText: true,
                     decoration: InputDecoration(
                       prefixIcon: Icon(Icons.person),
                       hintText:"password",
                       border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                     ),
                   ),

                   Container(
                     margin:EdgeInsets.all(10),
                     child: Row(
                       children: [
                         Text('if you have not an account'),
                         InkWell(
                             onTap:(){
                               Navigator.of(context).pushNamed("signup");
                             },
                             child: Text("Click Here",
                               style : TextStyle(color: Colors.blue),)
                         )

                       ],

                     ),

                   ),

                   Container( child: ElevatedButton(onPressed:() async{
                     var user=  await signIn();
                     if (user!=null){
                       Navigator.of(context).pushNamed("MyHomePge");}
                        }


                   ,child:Text("Sign In"),style: ElevatedButton.styleFrom(textStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold ),elevation: 10,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),primary: Colors.teal,)


                   ),


                   )


                 ],


               )

           ),




         )



       ],



     ),

     );


   }
}