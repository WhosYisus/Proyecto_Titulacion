package com.example.flutter_application_1

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.vosk.Recognizer
import org.vosk.Model
import org.vosk.android.RecognitionListener
import org.vosk.android.SpeechService
import java.io.File

class MainActivity : FlutterActivity(), RecognitionListener {

    private val CHANNEL = "vosk"
    private lateinit var speechService: SpeechService
    private lateinit var recognizer: Recognizer
    private lateinit var model: Model
    private var resultText: String = ""

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVosk" -> {
                    if (checkPermission()) {
                        startVoskRecognition()
                        result.success("Reconocimiento iniciado")
                    } else {
                        requestPermission()
                        result.success("Esperando permisos") // 🚀 Ya no lanzamos VOSK aquí
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

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == 1) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                startVoskRecognition() // 🔥 Solo ahora arrancamos VOSK
            } else {
                Log.e("VOSK", "Permiso de micrófono DENEGADO")
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
                
                System.loadLibrary("jnidispatch")

                val modelPath = "${filesDir.absolutePath}/vosk-model-small-es-0.42" // Modelo en almacenamiento nativo
                Log.d("VOSK", "Cargando modelo desde: $modelPath")

                model = Model(modelPath)
                recognizer = Recognizer(model, 16000.0f)
                speechService = SpeechService(recognizer, 16000.0f)
                speechService.startListening(this)

                Log.d("VOSK", "Reconocimiento iniciado correctamente")

            } catch (e: Exception) {
                Log.e("VOSK", "Error al iniciar el reconocimiento: ${e.message}")
                Handler(Looper.getMainLooper()).post {
                    MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                        .invokeMethod("onModelLoadError", e.message ?: "Error desconocido")
                }
            }
        }.start()
    }

    private fun stopVoskRecognition() {
        if (::speechService.isInitialized) {
            speechService.stop()
        } else {
            Log.w("VOSK", "speechService no inicializado, no hay nada que detener")
        }
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

    override fun onError(exception: Exception?) {
        Log.e("VOSK", "Error: ${exception?.message}")
    }

    override fun onTimeout() {
        Log.d("VOSK", "Reconocimiento finalizado por inactividad, reiniciando...")

        try {
            if (::speechService.isInitialized) {
                speechService.stop()
            }
        } catch (e: Exception) {
            Log.e("VOSK", "Error al detener SpeechService: ${e.message}")
        }

        Handler(Looper.getMainLooper()).postDelayed({
            try {
                recognizer = Recognizer(model, 16000.0f)
                speechService = SpeechService(recognizer, 16000.0f)
                speechService.startListening(this)
                Log.d("VOSK", "SpeechService reiniciado correctamente")
            } catch (e: Exception) {
                Log.e("VOSK", "Error al reiniciar SpeechService: ${e.message}")
            }
        }, 500)
    }
}
