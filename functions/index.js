const functions = require("firebase-functions");
const { MeiliSearch } = require('meilisearch');
const admin = require('firebase-admin');

admin.initializeApp();

// NB: You can always get a free MeiliSearch Sandbox instance from
// https://sandbox.meilisearch.com/
// For example
// hostURL: https://lousy-zucchini-lizard-muur.sandbox.meilisearch.dev
// apiKEY: NUMSgcbrxuMiwBZtdqYmiOUzSRUYjIHg

const client = new MeiliSearch({
  host: 'http://127.0.0.1:7700',
  apiKey: 'masterKey',
});

// Add the search index every time a secret post is written.
exports.onCreateSecret = functions.firestore
		.document('secrets/{id}')
		.onCreate((snap, context) => {

		// Create a document
		const documents = [
            {
                id: snapshot.id,
                secret: snapshot.data().secret,
                authorName: snapshot.data().authorName,
                authorUid: snapshot.data().authorUid,
                timestamp: new Date(timestamp.seconds*1000).toLocaleDateString()
            }
       ];

		// Write to the meilisearch index
      let response = await client.index('secrets').addDocuments(documents);
      console.log(response); // => { "updateId": 0 }
});