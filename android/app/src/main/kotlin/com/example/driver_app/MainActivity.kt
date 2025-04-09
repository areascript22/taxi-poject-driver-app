package com.example.driver_app

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.os.Bundle
import io.flutter.plugin.common.MethodChannel
import android.content.Context



class MainActivity: FlutterActivity(){
    private val CHANNEL = "com.yourcompany.app/foregroundService"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Acceder al FlutterEngine y al BinaryMessenger
        val flutterEngine = flutterEngine ?: return
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "bringAppToForeground") {
                bringAppToForeground(this)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun bringAppToForeground(context: Context) {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        intent?.flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }
}
