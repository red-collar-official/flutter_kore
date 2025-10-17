package com.example.flutter_kore_template.base

import android.annotation.SuppressLint
import android.content.Context
import android.os.Handler

@SuppressLint("StaticFieldLeak")
object AppUtility {
    var context: Context? = null
    var handler: Handler? = null
}
