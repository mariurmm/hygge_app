package com.example.hygge_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // Канал для напоминаний о занятиях (высокий приоритет — показывает heads-up)
            val classRemindersChannel = NotificationChannel(
                "class_reminders",
                "Напоминания о занятиях",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Уведомления с подтверждением посещения занятия"
                enableVibration(true)
                enableLights(true)
            }

            // Канал для общих уведомлений
            val generalChannel = NotificationChannel(
                "general",
                "Общие уведомления",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Новости и обновления студии"
            }

            manager.createNotificationChannels(
                listOf(classRemindersChannel, generalChannel)
            )
        }
    }
}
