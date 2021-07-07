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