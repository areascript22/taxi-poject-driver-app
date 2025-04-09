package com.example.driver_app

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

class MyForegroundService : Service() {

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        // Crear una notificación para el Foreground Service
        val notification = NotificationCompat.Builder(this, "your_channel_id")
            .setContentTitle("App en segundo plano")
            .setContentText("La app está en segundo plano y ejecutando tareas.")
            .setSmallIcon(R.drawable.notification_icon)
            .build()

        // Iniciar el servicio en el primer plano
        startForeground(1, notification)

        // Realiza otras tareas aquí si lo necesitas (por ejemplo, escuchar Firebase)

        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}