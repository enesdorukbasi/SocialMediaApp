const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

exports.followerFunction = functions.firestore
  .document('followers/{followedid}/usersfollowers/{followingid}')
  .onCreate(async (snapshot, context) => { 
    const followedid = context.params.followedid;
    const followingid = context.params.followingid;

    const postSnapshot = await admin.firestore().collection("posts").doc(followedid).collection("usersposts").get();
    postSnapshot.forEach((doc) => {
      if(doc.exists){
        const postId = doc.id;
        const postData = doc.data();

        admin.firestore().collection("homepages").doc(followingid).collection("usershomepages").doc(postId).set(postData);
      }
    })
  });

  exports.unfollowerFunction = functions.firestore
  .document('followers/{followedid}/usersfollowers/{followingid}')
  .onDelete(async (snapshot, context) => { 
    const unfollowedid = context.params.followedid;
    const unfollowingid = context.params.followingid;

    const postSnapshot = await admin.firestore().collection("homepages").doc(unfollowingid).collection("usershomepages").where("publishedById", "==",unfollowedid).get();
    postSnapshot.forEach((doc) => {
      if(doc.exists){
        doc.ref.delete();
      }
    })
  });

  exports.newPosts = functions.firestore
  .document('posts/{followedid}/usersposts/{postid}')
  .onCreate(async (snapshot, context) => {
    const followedid = context.params.followedid;
    const postid = context.params.postid;

    const newPostData = snapshot.data();

    const followersSnapshot = await admin.firestore().collection("followers").doc(followedid).collection("usersfollowers").get();

    followersSnapshot.forEach((doc) =>{
      const followerId = doc.id;
      admin.firestore().collection("homepages").doc(followerId).collection("usershomepages").doc(postid).set(newPostData);
    })
  });

  exports.updatePosts = functions.firestore
  .document('posts/{followedid}/usersposts/{postid}')
  .onUpdate(async (snapshot, context) => {
    const followedid = context.params.followedid;
    const postid = context.params.postid;
    
    const newPostData = snapshot.after.data();

    const followersSnapshot = await admin.firestore().collection("followers").doc(followedid).collection("usersfollowers").get();

    followersSnapshot.forEach((doc) =>{
      const followerId = doc.id;
      admin.firestore().collection("homepages").doc(followerId).collection("usershomepages").doc(postid).update(newPostData);
    })
  });

  exports.deletePosts = functions.firestore
  .document('posts/{followedid}/usersposts/{postid}')
  .onDelete(async (snapshot, context) => {
    const followedid = context.params.followedid;
    const postid = context.params.postid;

    const followersSnapshot = await admin.firestore().collection("followers").doc(followedid).collection("usersfollowers").get();


    followersSnapshot.forEach(doc=>{
      const followerid = doc.id;
      admin.firestore().collection("homepages").doc(followerid).collection("usershomepages").doc(postid).delete();
    })
  });


  /*
exports.entryDelete = functions.firestore
.document('deneme/{docId}')
.onDelete((change, context) => { 
  admin.firestore().collection("daily").add({
      "content" : "denemeden kayıt silindi."
  });
});

exports.entryUpdate = functions.firestore
  .document('deneme/{docId}')
  .onUpdate((change, context) => { 
    admin.firestore().collection("daily").add({
        "content" : "denemede kayıt güncellendi."
    });
  });*/