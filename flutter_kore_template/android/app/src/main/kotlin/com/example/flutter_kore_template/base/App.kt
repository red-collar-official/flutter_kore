package com.example.flutter_kore_template.base

import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper
import io.flutter.app.FlutterApplication

class App: FlutterApplication() {
    @SuppressLint("AuthLeak")
    override fun onCreate() {
        super.onCreate()

        AppUtility.context = this
        AppUtility.handler = Handler(Looper.getMainLooper())
    }
}
