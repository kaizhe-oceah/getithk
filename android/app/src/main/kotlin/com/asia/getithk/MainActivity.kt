package com.asia.getithk

import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import androidx.webkit.WebSettingsCompat
import androidx.webkit.WebViewFeature
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.asia.getithk/webview")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Google Pay in a web view needs the Payment Request API,
                    // which WebView (137+) keeps off unless the app turns it on
                    "enablePaymentRequest" -> {
                        val viewId = call.argument<Int>("viewId")
                        val webView = viewId?.let {
                            findWebView(
                                flutterEngine.platformViewsControllerDelegator
                                    .getPlatformViewById(it)
                            )
                        }
                        val enabled = webView != null &&
                            WebViewFeature.isFeatureSupported(WebViewFeature.PAYMENT_REQUEST)
                        if (enabled) {
                            WebSettingsCompat.setPaymentRequestEnabled(webView!!.settings, true)
                        }
                        result.success(enabled)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // the plugin's view is the web view, or a pull-to-refresh layout around it
    private fun findWebView(view: View?): WebView? = when (view) {
        is WebView -> view
        is ViewGroup -> (0 until view.childCount).firstNotNullOfOrNull {
            findWebView(view.getChildAt(it))
        }
        else -> null
    }
}
