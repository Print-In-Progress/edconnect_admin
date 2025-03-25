import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:edconnect_admin/data/datasource/group_data_source.dart';

class FirebaseGroupDataSource implements GroupDataSource {
  final FirebaseFirestore _firestore;

  FirebaseGroupDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Reference to groups collection
  CollectionReference get _groupsCollection => _firestore
      .collection('$customerSpecificRootCollectionName/newsapp/groups');

  // Reference to users collection
  CollectionReference get _usersCollection =>
      _firestore.collection(customerSpecificCollectionUsers);

  @override
  Stream<List<Map<String, dynamic>>> watchGroups() {
    return _groupsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }).toList();
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getGroups() async {
    final snapshot = await _groupsCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {...data, 'id': doc.id};
    }).toList();
  }

  @override
  Stream<Map<String, dynamic>?> watchGroup(String groupId) {
    return _groupsCollection.doc(groupId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return {...data, 'id': doc.id};
    });
  }

  @override
  Future<Map<String, dynamic>?> getGroup(String groupId) async {
    final doc = await _groupsCollection.doc(groupId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return {...data, 'id': doc.id};
  }

  @override
  Future<String> createGroup(Map<String, dynamic> groupData) async {
    final docRef = await _groupsCollection.add(groupData);
    return docRef.id;
  }

  @override
  Future<void> updateGroup(
      String groupId, Map<String, dynamic> groupData) async {
    // Remove the ID field as it's not stored in the document itself
    final dataToSave = Map<String, dynamic>.from(groupData);
    dataToSave.remove('id');

    await _groupsCollection.doc(groupId).update(dataToSave);
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    // Get the group data to find member_ids
    final groupDoc = await _groupsCollection.doc(groupId).get();
    if (groupDoc.exists) {
      final data = groupDoc.data() as Map<String, dynamic>;
      final memberIds = List<String>.from(data['member_ids'] ?? []);

      // Batch operation to remove group reference from all members
      if (memberIds.isNotEmpty) {
        final batch = _firestore.batch();
        for (final userId in memberIds) {
          batch.update(_usersCollection.doc(userId), {
            'groups': FieldValue.arrayRemove([groupId])
          });
        }
        await batch.commit();
      }
    }

    // Delete the group document
    await _groupsCollection.doc(groupId).delete();
  }

  @override
  Future<List<String>> getUserGroups(String userId) async {
    final userDoc = await _usersCollection.doc(userId).get();
    if (!userDoc.exists) return [];

    final userData = userDoc.data() as Map<String, dynamic>;
    return List<String>.from(userData['groups'] ?? []);
  }

  @override
  Future<void> addUserToGroup(String userId, String groupId) async {
    final batch = _firestore.batch();

    // Add user to group's member_ids
    batch.update(_groupsCollection.doc(groupId), {
      'member_ids': FieldValue.arrayUnion([userId])
    });

    // Add group to user's groups
    batch.update(_usersCollection.doc(userId), {
      'groups': FieldValue.arrayUnion([groupId])
    });

    await batch.commit();
  }

  @override
  Future<void> removeUserFromGroup(String userId, String groupId) async {
    final batch = _firestore.batch();

    // Remove user from group's member_ids
    batch.update(_groupsCollection.doc(groupId), {
      'member_ids': FieldValue.arrayRemove([userId])
    });

    // Remove group from user's groups
    batch.update(_usersCollection.doc(userId), {
      'groups': FieldValue.arrayRemove([groupId])
    });

    await batch.commit();
  }

  @override
  Future<void> updateUserGroups(
    String userId,
    List<String> newGroupIds,
    List<String> groupsToAdd,
    List<String> groupsToRemove,
  ) async {
    final batch = _firestore.batch();

    // Update user's groups array
    batch.update(_usersCollection.doc(userId), {'groups': newGroupIds});

    // Add user to new groups
    for (final groupId in groupsToAdd) {
      batch.update(_groupsCollection.doc(groupId), {
        'member_ids': FieldValue.arrayUnion([userId])
      });
    }

    // Remove user from old groups
    for (final groupId in groupsToRemove) {
      batch.update(_groupsCollection.doc(groupId), {
        'member_ids': FieldValue.arrayRemove([userId])
      });
    }

    await batch.commit();
  }
}
