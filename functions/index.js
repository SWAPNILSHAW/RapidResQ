const functions = require("firebase-functions");
const admin = require("firebase-admin");
const twilio = require("twilio");
require("dotenv").config();

admin.initializeApp();
const db = admin.firestore();

// Twilio setup
const twilioClient = twilio(process.env.TWILIO_SID, process.env.TWILIO_AUTH_TOKEN);
const twilioPhone = process.env.TWILIO_PHONE_NUMBER;

// Function to send SMS
exports.sendSms = functions.https.onRequest(async (req, res) => {
  const { phone, message } = req.body;

  if (!phone || !message) {
    return res.status(400).json({ error: "Phone number and message are required" });
  }

  try {
    const response = await twilioClient.messages.create({
      body: message,
      from: twilioPhone,
      to: phone,
    });

    await db.collection("sms_logs").add({
      phone,
      message,
      status: "sent",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).json({ success: true, response });
  } catch (error) {
    console.error("Twilio Error:", error);
    res.status(500).json({ error: "Failed to send SMS" });
  }
});
