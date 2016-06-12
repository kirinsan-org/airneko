const firebase = require('firebase');
// Initialize the app with a service account, granting admin privileges
firebase.initializeApp({
  databaseURL: 'https://project-8755291933643910997.firebaseio.com/',
  serviceAccount: './airneko-dae0a807c93f.json'
});

module.exports = firebase.database();