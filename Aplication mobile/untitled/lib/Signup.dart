import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}
class _SignUpState extends State<SignUp>{
  var myusername,mypassword,myemail;
  GlobalKey<FormState> formstate =new GlobalKey<FormState>();

  signUp() async{
    var formdata= formstate.currentState;
    if (formdata!= null) {
      if (formdata.validate()) {
        print('valid');
        formdata.save();

        try {
          final  credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: myemail,
            password: mypassword,
          );
          return credential ;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {AwesomeDialog(context: context, title:"Error",body:Text('password too weak'))
            ..show();

            //print('The password provided is too weak.');
          } else if (e.code == 'email-already-in-use') {
            AwesomeDialog(context: context, title:"Error",body:Text('The account already exists for that email.'))..show();
            //print('The account already exists for that email.');
          }
        } catch (e) {
          print(e);
        }


      } else {
        print('not valid!');
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
                TextFormField(
                  onSaved: (val){
                    myusername=val;
                  }
                  ,
                  validator:(val){
                    if(val != null){
                    if(val.length>100){
                      return "username can't be larger than 100 letter";
                    }
                    if(val.length<2){
                      return "username can't be less than 2 letter";
                    }}
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText:"username",
                    border: OutlineInputBorder(borderSide: BorderSide(width: 1)),

                  ),
                ),
                SizedBox(height:20),
                TextFormField(
                    onSaved: (val){
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
                TextFormField(
                    onSaved: (val){
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
                      Text('if you have account'),
                      InkWell(
                        onTap:(){
                          Navigator.of(context).pushNamed("login");
                      },
                        child: Text("Click Here",
                        style : TextStyle(color: Colors.blue),)
                      )

                    ],

                  ),

                ),

               Container( child: ElevatedButton(onPressed:() async{
                 var response=  await signUp();
                 print("=====================");
                 if (response!= null) {
                   Navigator.of(context).pushNamed("MyHomePge");
                 }else {
                   print("sign up failed");
                 }
                 print("=====================");
               },child:Text("Sign Up"),style: ElevatedButton.styleFrom(textStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold ),elevation: 10,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),primary: Colors.teal,)


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