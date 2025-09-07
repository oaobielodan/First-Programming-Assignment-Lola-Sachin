// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp();

// Take the text parameter passed to this HTTP endpoint and insert it into
// Firestore under the paths /playlists/:documentId/genre and
// /playlists/:documentId/length
exports.addPlaylist = onRequest(async (req, res) => {
  const genre = req.query.genre || "pop"; // grab the genre parameter
  const length = req.query.length || "30"; // grab the length parameter
  const writeResult = await getFirestore() // push new message into Firestore
      .collection("playlists")
      .add({genre: genre, length: length});
  // send back a message that we've successfully written the genre
  res.json({result: `Genre with ID: ${writeResult.id} added.`});
});

// Listens for new messages added to /playlists/:documentId/genre
// and saves a playlist associated with that genre and the cook time
// to /playlists/:documentId/playlist
exports.makePlaylist = onDocumentCreated("/playlists/{documentId}", (event) => {
  // grab the current value of what was written to Firestore.
  const genre = event.data.data().genre;
  const length = event.data.data().length;

  // access the parameter `{documentId}` with `event.params`
  logger.log("making playlist", event.params.documentId, genre, length);

  // THIS IS WHERE WE MAKE PLAYLIST
  const playlist = `${genre} and ${length}`;

  // you must return a Promise when performing asynchronous tasks inside a
  // function such as writing to Firestore.
  // setting an 'playlist' field in Firestore document returns a Promise.
  return event.data.ref.set({playlist}, {merge: true});
});
