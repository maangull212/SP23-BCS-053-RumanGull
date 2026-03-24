package com.rumangull.taskmate

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.time.ZoneId
import java.util.*

class MainActivity : FlutterActivity() {

    private val TIMEZONE_CHANNEL = "taskmate/timezone"
    private val ALARM_CHANNEL = "taskmate/alarms"
    private val CHANNEL_ID = "taskmate_tasks"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TIMEZONE_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getTimezone") {
                    try {
                        val tz = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            ZoneId.systemDefault().id
                        } else {
                            java.util.TimeZone.getDefault().id
                        }
                        result.success(tz)
                    } catch (e: Exception) {
                        result.success("UTC")
                    }
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAlarm" -> {
                        val id = call.argument<Int>("id") ?: 0
                        val epochMillis = call.argument<Long>("epochMillis") ?: 0L
                        val title = call.argument<String>("title") ?: "Task Reminder"
                        val body = call.argument<String>("body") ?: ""
                        scheduleNativeAlarm(id, epochMillis, title, body)
                        result.success(true)
                    }
                    "cancelAlarm" -> {
                        val id = call.argument<Int>("id") ?: 0
                        cancelNativeAlarm(id)
                        result.success(true)
                    }
                    "cancelAllForTask" -> {
                        val baseIds = call.argument<List<Int>>("ids") ?: emptyList()
                        baseIds.forEach { cancelNativeAlarm(it) }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        ensureNotificationChannel()
    }

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(CHANNEL_ID) == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Taskmate Tasks",
                    NotificationManager.IMPORTANCE_HIGH
                )
                channel.description = "Task reminders, repeats & summary"
                nm.createNotificationChannel(channel)
            }
        }
    }

    private fun scheduleNativeAlarm(id: Int, epochMillis: Long, title: String, body: String) {
        if (epochMillis <= 0) return
        val ctx = applicationContext
        val intent = Intent(ctx, AlarmReceiver::class.java).apply {
            putExtra("id", id)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("channelId", CHANNEL_ID)
        }
        val flags = PendingIntent.FLAG_CANCEL_CURRENT or
                (if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
        val pi = PendingIntent.getBroadcast(ctx, id, intent, flags)
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, epochMillis, pi)
            } else {
                am.setExact(AlarmManager.RTC_WAKEUP, epochMillis, pi)
            }
        } catch (e: Exception) {
            // fallback inexact
            am.set(AlarmManager.RTC_WAKEUP, epochMillis, pi)
        }
    }

    private fun cancelNativeAlarm(id: Int) {
        val ctx = applicationContext
        val intent = Intent(ctx, AlarmReceiver::class.java)
        val flags = PendingIntent.FLAG_NO_CREATE or
                (if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
        val pi = PendingIntent.getBroadcast(ctx, id, intent, flags)
        if (pi != null) {
            val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            am.cancel(pi)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
}
