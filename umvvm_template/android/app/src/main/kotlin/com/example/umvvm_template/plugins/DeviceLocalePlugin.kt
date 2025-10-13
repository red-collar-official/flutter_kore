package com.example.umvvm_template.plugins

import android.content.res.Resources
import com.example.umvvm_template.base.AppUtility
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class DeviceLocalePlugin: FlutterPlugin, MethodCallHandler {
    private val currentLocale: String
        get() {
            val locale =
                AppUtility.context?.resources?.configuration?.locales?.get(0)
                    ?: ""

            return locale.toString()
        }

    private val currentCountry: String
        get() {
            return AppUtility.context?.resources?.configuration?.locales?.get(0)?.country
                ?: ""
        }

    private val preferredLanguages: List<String>
        get() {
            val list = Resources.getSystem().configuration.locales

            val result = ArrayList<String>()
            for (i in 0 until list.size()) {
                result.add(list.get(i).toString())
            }

            return result
        }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(binding.binaryMessenger, "com.umvvm_template.plugins/device_locale")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "preferredLanguages" -> result.success(preferredLanguages)
            "currentLocale" -> result.success(currentLocale)
            "currentCountry" -> result.success(currentCountry)
            else -> result.notImplemented()
        }
    }
}
