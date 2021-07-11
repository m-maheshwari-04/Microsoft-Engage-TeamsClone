const express = require("express");
const admin = require("firebase-admin");
var serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const app = express();
app.use(express.json());

app.listen(process.env.PORT || 5000, () => {
  console.log("App listening on port 5000!");
});

/// Notification of message send to users
/// Notifications using FCM token
app.post("/sendNotification", function (req, res, next) {
  const { tokens, message, from } = req.body;

  console.log(tokens);
  console.log(message);
  console.log(from);

  const payload = {
    notification: {
      title: `You have a message from ${from}`,
      body: message,
      badge: "1",
      sound: "default",
    },
  };

  admin
    .messaging()
    .sendToDevice(tokens, payload)
    .then((response) => {
      res.status(200).json({
        success: true,
        data: response,
      });
      console.log("Successfully sent message:", response);
    })
    .catch((error) => {
      res.status(400).json({
        success: false,
        data: error,
      });
      console.log("Error sending message:", error);
    });
});

/// Called from jitsi
/// Message added to firebase
app.post("/addMessageToGroup", function (req, res, next) {
  const { message, from, roomName, time } = req.body;

  var groupId = roomName;
  groupId = groupId.toUpperCase();
  if (groupId.length == 10) {
    groupId += "!@#%^&*(";
  }

  var dateIST = new Date(time);
  dateIST.setHours(dateIST.getHours() + 5);
  dateIST.setMinutes(dateIST.getMinutes() + 30);

  db.collection(groupId).add({
    text: message,
    sender: from,
    time: dateIST.toISOString(),
  });
  db.collection("chat").doc(groupId).set({
    text: message,
    sender: from,
    time: dateIST.toISOString(),
  });

  res.status(200).json({
    success: true,
  });
});
