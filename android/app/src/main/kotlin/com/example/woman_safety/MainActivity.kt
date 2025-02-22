package com.example.woman_safety

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.telephony.SmsManager
import android.widget.Toast
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sos_channel"
    private val CALL_PERMISSION_REQUEST = 1
    private val SMS_PERMISSION_REQUEST = 2
    private var pendingPhoneNumber: String? = null
    private var pendingMessage: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "makeCall" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    if (phoneNumber != null) {
                        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE) == PackageManager.PERMISSION_GRANTED) {
                            makePhoneCall(phoneNumber)
                            result.success(true)
                        } else {
                            pendingPhoneNumber = phoneNumber
                            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CALL_PHONE), CALL_PERMISSION_REQUEST)
                            result.success(false)
                        }
                    } else {
                        result.error("INVALID_NUMBER", "Phone number is null", null)
                    }
                }
                "sendSMS" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    if (phoneNumber != null && message != null) {
                        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED) {
                            sendSMS(phoneNumber, message)
                            result.success(true)
                        } else {
                            pendingPhoneNumber = phoneNumber
                            pendingMessage = message
                            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.SEND_SMS), SMS_PERMISSION_REQUEST)
                            result.success(false)
                        }
                    } else {
                        result.error("INVALID_INPUT", "Phone number or message is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun makePhoneCall(phoneNumber: String) {
        try {
            val intent = Intent(Intent.ACTION_CALL)
            intent.data = Uri.parse("tel:$phoneNumber")
            startActivity(intent)
        } catch (e: Exception) {
            Toast.makeText(this, "❌ Error making call: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }

    private fun sendSMS(phoneNumber: String, message: String) {
        try {
            val smsManager = SmsManager.getDefault()
            val messageParts = smsManager.divideMessage(message)
            smsManager.sendMultipartTextMessage(phoneNumber, null, messageParts, null, null)
            Toast.makeText(this, "✅ SOS SMS sent", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            Toast.makeText(this, "❌ Error sending SMS: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == CALL_PERMISSION_REQUEST) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                pendingPhoneNumber?.let { makePhoneCall(it) }
                pendingPhoneNumber = null
            } else {
                Toast.makeText(this, "🚨 Call permission denied", Toast.LENGTH_SHORT).show()
            }
        }

        if (requestCode == SMS_PERMISSION_REQUEST) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                pendingPhoneNumber?.let { number ->
                    pendingMessage?.let { message ->
                        sendSMS(number, message)
                    }
                }
                pendingPhoneNumber = null
                pendingMessage = null
            } else {
                Toast.makeText(this, "🚨 SMS permission denied", Toast.LENGTH_SHORT).show()
            }
        }
    }
}
