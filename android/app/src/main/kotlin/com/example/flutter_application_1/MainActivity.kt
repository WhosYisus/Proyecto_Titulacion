package com.example.flutter_application_1

import android.os.Bundle
import android.Manifest
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import org.vosk.Recognizer
import org.vosk.Model
import org.vosk.android.RecognitionListener
import org.vosk.android.SpeechService
import org.vosk.android.SpeechServiceFactory
import android.util.Log

class MainActivity : FlutterActivity(), RecognitionListener {

    private val CHANNEL = "vosk"
    private lateinit var speechService: SpeechService
    private lateinit var recognizer: Recognizer
    private lateinit var model: Model
    private var resultText: String = ""

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "startVosk" -> {
                    if (checkPermission()) {
                        startVoskRecognition()
                        result.success("Reconocimiento iniciado")
                    } else {
                        requestPermission()
                        result.error("PERMISSION_DENIED", "No se concedió el permiso de micrófono", null)
                    }
                }
                "stopVosk" -> {
                    stopVoskRecognition()
                    result.success(resultText)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkPermission(): Boolean {
        return ActivityCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestPermission() {
        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), 1)
    }

    private fun startVoskRecognition() {
        Thread {
            try {
                model = Model("vosk-model-small-es-0.42") // Ruta relativa desde assets
                recognizer = Recognizer(model, 16000.0f)
                speechService = SpeechServiceFactory.recognizer(recognizer, 16000.0f)
                speechService.startListening(this)
            } catch (e: Exception) {
                Log.e("VOSK", "Error al iniciar modelo: ${e.message}")
            }
        }.start()
    }

    private fun stopVoskRecognition() {
        speechService.stop()
    }

    override fun onPartialResult(hypothesis: String?) {
    Log.d("VOSK", "Parcial: $hypothesis")
    hypothesis?.let {
        Handler(Looper.getMainLooper()).post {
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("onPartialResult", it)
        }
    }
}


    override fun onResult(hypothesis: String?) {
    Log.d("VOSK", "Resultado final: $hypothesis")
    hypothesis?.let {
        resultText = it
    }
}

override fun onFinalResult(hypothesis: String?) {
    Log.d("VOSK", "Resultado final completo: $hypothesis")
    hypothesis?.let {
        resultText = it
    }
}


    override fun onError(exception: java.lang.Exception?) {
        Log.e("VOSK", "Error: ${exception?.message}")
    }

    override fun onTimeout() {
        Log.d("VOSK", "Reconocimiento finalizado por inactividad")
    }
}
