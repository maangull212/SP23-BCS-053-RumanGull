package com.rumangull.taskmate

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.graphics.Color

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getIntExtra("id", 0)
        val title = intent.getStringExtra("title") ?: "Task Reminder"
        val body = intent.getStringExtra("body") ?: ""
        val channelId = intent.getStringExtra("channelId") ?: "taskmate_tasks"

        ensureChannel(context, channelId)

        val notif = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setColor(Color.parseColor("#FF9800"))
            .setAutoCancel(true)
            .build()

        NotificationManagerCompat.from(context).notify(id, notif)
    }

    private fun ensureChannel(ctx: Context, channelId: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(channelId) == null) {
                val ch = NotificationChannel(
                    channelId,
                    "Taskmate Tasks",
                    NotificationManager.IMPORTANCE_HIGH
                )
                ch.description = "Task reminders, repeats & summary"
                nm.createNotificationChannel(ch)
            }
        }
    }
}
