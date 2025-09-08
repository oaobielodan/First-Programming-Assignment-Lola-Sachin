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
exports.makePlaylist =
onDocumentCreated("/playlists/{documentId}", async (event) => {
  // grab the current value of what was written to Firestore.
  const genre = event.data.data().genre;
  const length = event.data.data().length;

  // access the parameter `{documentId}` with `event.params`
  logger.log("making playlist", event.params.documentId, genre, length);

  // THIS IS WHERE WE MAKE PLAYLIST
  const recommendations = await getSpotifyPlaylist(genre, length);

  // you must return a Promise when performing asynchronous tasks inside a
  // function such as writing to Firestore.
  // setting an 'playlist' field in Firestore document returns a Promise.
  return recommendations;
});

const getSpotifyAccessToken = async () => {
  const clientId = logger.config().spotify.client_id;
  const clientSecret = logger.config().spotify.client_secret;

  const result = await fetch("https://accounts.spotify.com/api/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Basic " + btoa( clientId + ":" + clientSecret),
    },
    body: "grant_type=client_credentials",
  });

  const data = await result.json();
  return data.access_token;
};

// helper to get recommendations
const getRecommendations = async (token, genre, limit = 10) => {
  const result = await fetch(`https://api.spotify.com/v1/recommendations?seed_genres=${genre}&limit=${limit}`, {
    headers: {
      "Authorization": `Bearer ${token}`,
    },
  });

  return await result.json();
};

const getSpotifyPlaylist = async (genre, length) => {
  // this math is done under the assumption that the average song is about
  // 3 mins long (length is in mins) => 10 extra songs are added for variabiity
  const limit = (length / 3) + 10;
  const accessToekn = getSpotifyAccessToken();
  const recommendations = await getRecommendations(accessToekn, genre, limit);

  return recommendations;
};
