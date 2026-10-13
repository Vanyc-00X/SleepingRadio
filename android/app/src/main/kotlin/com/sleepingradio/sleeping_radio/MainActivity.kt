package com.sleepingradio.sleeping_radio

import android.content.Intent
import android.os.Bundle
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val channelName = "com.sleepingradio/share"
    private var channel: MethodChannel? = null
    private var pendingShare: HashMap<String, String>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialShared" -> {
                    result.success(pendingShare)
                    pendingShare = null
                }
                else -> result.notImplemented()
            }
        }
        handleShareIntent(intent, fromNewIntent = false)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleShareIntent(intent, fromNewIntent = false)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleShareIntent(intent, fromNewIntent = true)
    }

    private fun handleShareIntent(intent: Intent?, fromNewIntent: Boolean) {
        if (intent == null) return
        val action = intent.action ?: return
        if (action != Intent.ACTION_SEND) return

        val type = intent.type ?: return
        if (!type.startsWith("text/")) return

        val shared = intent.getStringExtra(Intent.EXTRA_TEXT)?.trim().orEmpty()
        if (shared.isEmpty()) return

        val payload = HashMap<String, String>()
        val url = extractUrl(shared)
        if (url != null) {
            payload["url"] = url
        } else {
            payload["text"] = shared
        }

        if (fromNewIntent && channel != null) {
            channel?.invokeMethod("onShared", payload)
        } else {
            pendingShare = payload
        }
    }

    private fun extractUrl(text: String): String? {
        val match = Regex("""https?://\S+""").find(text)
        return match?.value?.trimEnd('.', ',', ')', ']')
    }
}
