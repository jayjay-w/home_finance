const functions = require('firebase-functions');
exports.helloWorld = functions.https.onRequest((req, res) => {
    res.send("Hello from Firebase!");
});


exports.updateAccountBalances = 
    functions.database.ref('/users/{userId}/transactions').onWrite(event => {
        field
    });