package com.example.flutter_kore_template

import io.flutter.embedding.android.FlutterActivity
import com.example.flutter_kore_template.plugins.DeviceLocalePlugin

import android.annotation.SuppressLint

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    @SuppressLint("UnspecifiedRegisterReceiverFlag", "WrongConstant")
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.plugins.add(DeviceLocalePlugin())

        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

}