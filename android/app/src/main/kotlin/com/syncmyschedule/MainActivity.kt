package com.syncmyschedule

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.channel/calendar"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchCalendar") {
                val timestampStr = call.argument<String>("timestamp")
                val calendarId = call.argument<String>("calendarId")
                val timestamp = timestampStr?.toLongOrNull()

                if (timestamp != null) {
                    try {
                        // Build URI for calendar at given timestamp
                        val uriBuilder = Uri.parse("content://com.android.calendar/time/").buildUpon()
                        uriBuilder.appendPath(timestamp.toString())
                        if (!calendarId.isNullOrEmpty()) {
                            uriBuilder.appendQueryParameter("calendar_id", calendarId)
                        }
                        val uri = uriBuilder.build()

                        val intent = Intent(Intent.ACTION_VIEW).setData(uri)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)

                        result.success(true)
                    } catch (e: Exception) {
                        result.error("FAILED", e.message, null)
                    }
                } else {
                    result.error("INVALID_TIMESTAMP", "Timestamp missing or invalid", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
