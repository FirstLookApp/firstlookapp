package com.example.firstlook

import android.content.ActivityNotFoundException
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    companion object {
        private const val INSTAGRAM_STORY_CHANNEL = "com.firstlook/instagram_story_share"
        private const val INSTAGRAM_PACKAGE = "com.instagram.android"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INSTAGRAM_STORY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareImage" -> shareImageToInstagram(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun shareImageToInstagram(call: MethodCall, result: MethodChannel.Result) {
        val imagePath = call.argument<String>("imagePath")
        val imageFile = imagePath?.let(::File)
        if (imageFile == null || !imageFile.exists()) {
            result.error("invalid_image", null, null)
            return
        }

        val imageUri = FileProvider.getUriForFile(
            this,
            "$packageName.firstlook.share",
            imageFile,
        )
        val storyIntent = Intent("com.instagram.share.ADD_TO_STORY").apply {
            setDataAndType(imageUri, "image/png")
            setPackage(INSTAGRAM_PACKAGE)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            call.argument<String>("attributionUrl")
                ?.takeIf(String::isNotBlank)
                ?.let { putExtra("content_url", it) }
        }

        try {
            startActivity(storyIntent)
            result.success(true)
        } catch (_: ActivityNotFoundException) {
            result.error("instagram_not_installed", null, null)
        }
    }
}
