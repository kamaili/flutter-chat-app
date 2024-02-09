import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat/services/local_storage.dart';
import 'package:chat/services/messages_streams.dart';
import 'package:chat/model/message.dart';
import 'package:chat/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseIO {
  static User? currentUser;
  static List<Map<String, dynamic>?> conversations = [];
  static String currentConversationId = "";

  static void createUser(username, email, password) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    String documentId = usersCollection.doc().id;
    var bytes = utf8.encode(password);

    // Create a SHA-256 hash
    var digest = sha256.convert(bytes);
    String passwordHash = digest.toString();

    // Data to be inserted into the document
    Map<String, dynamic> userData = {
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      // Add other fields as needed
    };

    try {
      // Add the document with the generated ID
      await usersCollection.doc(documentId).set(userData);

      currentUser = User(username: username);
      currentUser!.userId = documentId;
      debugPrint('User document created successfully. ****************');
    } catch (e) {
      debugPrint('Error creating user document: $e');
    }
  }

  static Future<bool> isUsernameAvailable(String username) async {
    // Reference to the Firestore collection
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    try {
      // Query the Firestore collection for the specified username
      QuerySnapshot querySnapshot =
          await usersCollection.where('username', isEqualTo: username).get();

      // Check if any documents match the query
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      // Handle errors, such as Firestore read failures
      debugPrint('Error checking username availability: $e');
      return false;
    }
  }

  static Future<void> saveProfilePicture(File file) async {
    final FirebaseStorage storage =
        FirebaseStorage.instanceFor(bucket: 'gs://chat-ae387.appspot.com');
    final reference =
        storage.ref().child('profile_pictures/${currentUser!.userID}.jpg');
    await reference.putFile(file);
    currentUser!.logoImage = 'profile_pictures/${currentUser!.userID}.jpg';
  }

  static Future<bool> establishConnection(
      String username, String password) async {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    // Hash the password using SHA-256
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    String passwordHash = digest.toString();

    try {
      // Query the Firestore collection for the specified username and password hash
      QuerySnapshot querySnapshot = await usersCollection
          .where('username', isEqualTo: username)
          .where('password_hash', isEqualTo: passwordHash)
          .get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        currentUser = User(username: querySnapshot.docs.first['username']);
        currentUser?.userId = querySnapshot.docs.first.id;
        return true;
      }
      return false;
    } catch (e) {
      // Handle errors, such as Firestore read failures
      debugPrint('Error checking user existence: $e');
      return false;
    }
  }
  static Future<void> loadUser(String id)async{
    CollectionReference conversationsCollection =
    FirebaseFirestore.instance.collection('users');
    DocumentSnapshot userDoc = await
    conversationsCollection.doc(id).get();
    currentUser = User(username: (userDoc.data() as Map<String,dynamic>)['username']);
    currentUser?.userId = userDoc.id;
  }


  static User getCurrentUser(){
    return currentUser!;
  }

  static Future<void> fetchLastMessage(String receiverRef)async {
    CollectionReference conversationsCollection =
    FirebaseFirestore.instance.collection('conversations');

    QuerySnapshot f1 = await conversationsCollection
        .where('user1_ref', isEqualTo: currentUser!.userID)
        .where('user2_ref', isEqualTo: receiverRef)
        .get();

    if (f1.docs.isNotEmpty) {
      currentConversationId = f1.docs.first.id;
    } else {
      QuerySnapshot f2 = await conversationsCollection
          .where('user2_ref', isEqualTo: currentUser!.userID)
          .where('user1_ref', isEqualTo: receiverRef)
          .get();
      if (f2.docs.isNotEmpty) {
        currentConversationId = f2.docs.first.id;
      } else {
       currentConversationId = "";
       return;
      }
    }
    debugPrint('i am here bitches');
    DocumentSnapshot conv = await conversationsCollection.doc(currentConversationId).get();
    Map<String,dynamic> data = conv.data() as Map<String,dynamic>;
    if(data.isNotEmpty && (data['messages'] as List).isNotEmpty){
      List<dynamic> messages = data['messages'] as List<dynamic>;
      String msgId = messages.last;
      Message message =
      Message.fromJson(await fetchSingleMessage(msgId), currentUser!.userID,msgId);
      _messagesSubject.add(message);
      MessagesStream.addStream(message,currentUser!.userID);
    }
    /*Stream<List<Message>> messagesStream = conversationsCollection
        .doc(currentConversationId)
        .snapshots()
        .asyncMap((DocumentSnapshot snapshot) async {
      if (!snapshot.exists) {
        return [];
      } else {
        // Access the data field from the snapshot
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Extract the 'messages' field and convert it to List<Message>
        List<Message> messages = [];
        for (var msgId in (data['messages'] as List)) {
          // Use `await` here to fetch each message
          Message message =
          Message.fromJson(await fetchSingleMessage(msgId), currentUser!.userID,msgId);
          messages.add(message);
          MessagesStream.addStream(message,currentUser!.userID);
        }

        return messages;
      }
    });*/

    //yield* messagesStream;
  }
  static Future<List<Message>> fetchLast10Messages(String receiverRef)async {
    CollectionReference conversationsCollection =
    FirebaseFirestore.instance.collection('conversations');

    QuerySnapshot f1 = await conversationsCollection
        .where('user1_ref', isEqualTo: currentUser!.userID)
        .where('user2_ref', isEqualTo: receiverRef)
        .get();

    if (f1.docs.isNotEmpty) {
      currentConversationId = f1.docs.first.id;
    } else {
      QuerySnapshot f2 = await conversationsCollection
          .where('user2_ref', isEqualTo: currentUser!.userID)
          .where('user1_ref', isEqualTo: receiverRef)
          .get();
      if (f2.docs.isNotEmpty) {
        currentConversationId = f2.docs.first.id;
      } else {
        currentConversationId = "";
        return [];
      }
    }
    debugPrint('conv id: $currentConversationId');
    DocumentSnapshot conv = await conversationsCollection.doc(currentConversationId).get();
   // debugPrint('conv data: ${conv.data()}');
    Map<String,dynamic> data = conv.data() as Map<String,dynamic>;
    List<Message> messages = [];
    List messagesArray = data['messages'] as List;
    messagesArray = messagesArray.sublist(messagesArray.length - 10);
    if(data.isNotEmpty && messagesArray.isNotEmpty){
      for(String msg in messagesArray) {
        String msgId = msg;
        Message message =
        Message.fromJson(
            await fetchSingleMessage(msgId), currentUser!.userID, msgId);
        messages.add(message);
        MessagesStream.addStream(message, currentUser!.userID);
      }
    }
    return messages;//(messages.length<=10)?messages:messages.sublist(messages.length - 10);
  }


  static Future<bool> fetchConversationsForUser() async {
    conversations!.clear();
    CollectionReference conversationsCollection =
        FirebaseFirestore.instance.collection('conversations');

    try {
      // Query the Firestore collection for documents where either sender_ref or receiver_ref is equal to userID
      QuerySnapshot querySnapshot = await conversationsCollection
          .where('user1_ref', isEqualTo: currentUser!.userID)
          .get();

      QuerySnapshot receiverQuerySnapshot = await conversationsCollection
          .where('user2_ref', isEqualTo: currentUser!.userID)
          .get();
      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await conversationsCollection
            .where('user2_ref', isEqualTo: currentUser!.userID)
            .get();
        receiverQuerySnapshot = await conversationsCollection
            .where('user1_ref', isEqualTo: currentUser!.userID)
            .get();
      }

      // Combine the results from both queries
      if (querySnapshot.docs.isEmpty) {
        debugPrint('No conversations found for the user.');
        return true;
      }
      // Extract sender_ref and receiver_ref from each document
      List<Map<String, dynamic>?> list1 = querySnapshot.docs.map((doc) {
          return {
          'doc_id' : doc.id,
          'user1_ref': doc.get('user1_ref'),
          'user2_ref': doc.get('user2_ref'),
        };
      }).toList();
      List<Map<String, dynamic>?> list2 = receiverQuerySnapshot.docs.map((doc) {
          return {
            'doc_id' : doc.id,
            'user1_ref': doc.get('user1_ref'),
            'user2_ref': doc.get('user2_ref'),
          };
      }).toList();
      conversations = list1 + list2;

      return true;
    } catch (e) {
      // Handle errors, such as Firestore read failures
      debugPrint('Error fetching conversations for user:  $e');
      return false;
    }
  }




  static final BehaviorSubject<List<User>> _friendsSubject = BehaviorSubject<List<User>>();
  static final BehaviorSubject<Message> _messagesSubject = BehaviorSubject<Message>();

  static Stream<List<User>> getFriends() {

    return _friendsSubject.stream;
  }
  static Stream<Message> getMessages() {

    return _messagesSubject.stream;
  }
  static void listenForUpdates() {
    FirebaseFirestore.instance.collection('conversations').snapshots().listen((event) {
      fetchFriends(); // Update the friends list when changes occur
    });
  }
  static void listenForMessagesUpdates(String receiverRef) {
    FirebaseFirestore.instance.collection('conversations').doc(currentConversationId).snapshots().listen((event) {
      fetchLastMessage(receiverRef); // Update the friends list when changes occur
    });
  }


  static Future<void> fetchFriends() async {
    try {
      await fetchConversationsForUser();
      List<User> list = [];

      for (var map in conversations) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot;
        String otherUserId;

        if (map!['user1_ref'] == currentUser!.userID) {
          otherUserId = map!['user2_ref'];
        } else {
          otherUserId = map!['user1_ref'];
        }

        userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUserId)
            .get();

        User user = User(username: userSnapshot.data()?['username']);
        user.userId = userSnapshot.id;

        try {
          user.logoImage = await getImage(userSnapshot.id);
        } catch (_) {
          user.logoImage =
          "https://firebasestorage.googleapis.com/v0/b/chat-ae387.appspot.com/o/profile_pictures%2Fdefault.jpg?alt=media&token=91fbb9c4-1556-45ee-9d90-072912dd05cd";
        }

        list.add(user);
      }

      _friendsSubject.add(list);
    } catch (e) {
      print('Error getting user document: $e');
    }
  }
  static Future<String> getImage(String id) async {
    final FirebaseStorage _storage =
        FirebaseStorage.instanceFor(bucket: 'gs://chat-ae387.appspot.com');

    Reference reference = _storage.ref().child("profile_pictures/$id.jpg");

    // Get the download URL for the image
    return await reference.getDownloadURL();

    // Load the image using Image.network
  }

  static Future<void> insertMessage(
      User receiver, String content, String type) async {
    try {

      // Create a new message map
      Map<String, dynamic> messageMap = {
        'sender_ref': currentUser!.userID,
        'content': content,
        'feeling' : '',
        'type': type,
        'timestamp': DateTime.now(), // Firestore server timestamp
      };
      DocumentReference documentReference =
      FirebaseFirestore.instance.collection('messages').doc();

      await documentReference.set(messageMap);

      try{
       await FirebaseFirestore.instance.collection('conversations').doc(currentConversationId).update({
       'messages': FieldValue.arrayUnion([documentReference.id])});

      } catch(_) {
        // If a conversation document exists, update the existing one
       var newConv = await FirebaseFirestore.instance.collection('conversations')
             .add({'messages': [documentReference.id],'user1_ref':currentUser!.userID,
         'user2_ref':receiver.userID});
       currentConversationId = newConv.id;
       Message msg = Message.fromJson(messageMap, currentUser!.userID, newConv.id);
       MessagesStream.addStream(msg, currentUser!.userID);

      }
    } catch (e) {
      print('Error inserting message: $e');
    }
  }

  static Future<List<User>> getUsersByUsername(String text) async {
    // Get a reference to the Firestore collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Use a workaround for substring search
    List<User> list = [];
    QuerySnapshot querySnapshot = await users.get();
    List<DocumentSnapshot> documents = querySnapshot.docs
        .where((doc) =>
            doc['username'] is String && doc['username'].contains(text))
        .toList();
    for (DocumentSnapshot doc in documents) {
      User user = User.snapShotToUser(doc);
      try {
        user.logoImage = await DatabaseIO.getImage(user.userID);
      } catch (_) {
        user.logoImage =
            "https://firebasestorage.googleapis.com/v0/b/chat-ae387.appspot.com/o/profile_pictures%2Fdefault.jpg?alt=media&token=91fbb9c4-1556-45ee-9d90-072912dd05cd";
      }
      list.add(user);
    }
    return list;
  }
  static Future<void> changeFeeling(Message msg,String feeling)async{
    await FirebaseFirestore.instance.collection('messages').doc(msg.messageID).update({'feeling': feeling});
    msg.setFeeling(feeling);
  }

  static Future<Map<String, dynamic>> fetchSingleMessage(msgId)async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance.collection('messages').doc(msgId).get();
    return doc.data()!;
  }

}
