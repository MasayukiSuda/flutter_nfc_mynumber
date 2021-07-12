package com.daasuu.flutter_nfc_mynumber

import android.app.Activity
import android.nfc.NfcAdapter
import android.nfc.tech.IsoDep
import android.nfc.tech.NfcB
import android.nfc.tech.TagTechnology
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException
import java.lang.reflect.InvocationTargetException

/** FlutterNfcMynumberPlugin */
class FlutterNfcMynumberPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

  private lateinit var activity: Activity
  private lateinit var channel: MethodChannel
  private var tagTechnology: TagTechnology? = null

  companion object {
    private val TAG = FlutterNfcMynumberPlugin::class.java.name
    private fun TagTechnology.transceive(data: ByteArray): ByteArray {
      val timeoutMethod = this.javaClass.getMethod("setTimeout", Int::class.java)
      timeoutMethod.invoke(this, 600000000)

      val transceiveMethod = this.javaClass.getMethod("transceive", ByteArray::class.java)
      return transceiveMethod.invoke(this, data) as ByteArray
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_nfc_mynumber")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    handleMethodCall(call, MethodResultWrapper(result))
  }

  private fun handleMethodCall(call: MethodCall, result: Result) {
    val nfcAdapter = NfcAdapter.getDefaultAdapter(activity)

    if (nfcAdapter?.isEnabled != true && call.method != "getNFCAvailability") {
      result.error("404", "NFC not available", null)
      return
    }

    when (call.method) {
      "getNFCAvailability" -> getNFCAvailability(nfcAdapter, result)
      "startSession" -> startSession(nfcAdapter, result)
      "finishSession" -> finishSession(nfcAdapter, result)
      "transceive" -> transceive(result, call)
      else -> result.notImplemented()
    }
  }

  private fun getNFCAvailability(nfcAdapter: NfcAdapter?, result: Result) {
    if (nfcAdapter == null) {
      result.success("not_supported")
      return
    }
    if (nfcAdapter.isEnabled) {
      result.success("available")
    } else {
      result.success("disabled")
    }
  }

  private fun startSession(nfcAdapter: NfcAdapter, result: Result) {
    nfcAdapter.enableReaderMode(activity, { tag ->
      if (tag.techList.contains(NfcB::class.java.name)) {
        if (tag.techList.contains(IsoDep::class.java.name)) {
          val isoDep = IsoDep.get(tag)
          tagTechnology = isoDep
          result.success("success")
        } else {
          result.error("400", "This is Not Mynumber", null)
        }
      } else {
        result.error("400", "This is Not Mynumber", null)
      }
    }, NfcAdapter.FLAG_READER_NFC_B, null)
  }

  private fun finishSession(nfcAdapter: NfcAdapter, result: Result) {
    try {
      val tagTech = tagTechnology
      if (tagTech != null && tagTech.isConnected) {
        tagTech.close()
      }
    } catch (ex: IOException) {
      Log.e(TAG, "Close tag error", ex)
    }
    nfcAdapter.disableReaderMode(activity)
    result.success("")
  }

  private fun transceive(result: Result, call: MethodCall) {
    val tagTech = tagTechnology
    val req = call.argument<ByteArray>("data")
    if (req == null) {
      result.error("400", "Bad argument", null)
      return
    }
    if (tagTech == null) {
      result.error("406", "No tag polled", null)
      return
    }

    try {
      if (!tagTech.isConnected) {
        tagTech.connect()
      }
      val resp = tagTech.transceive(req)
      result.success(resp)
    } catch (ex: IOException) {
      Log.e(TAG, "Transceive Error: $req", ex)
      result.error("500", "Communication error", ex.localizedMessage)
    } catch (ex: InvocationTargetException) {
      Log.e(TAG, "Transceive Error: $req", ex.cause ?: ex)
      result.error("500", "Communication error", ex.cause?.localizedMessage)
    } catch (ex: IllegalArgumentException) {
      Log.e(TAG, "Command Error: $req", ex)
      result.error("400", "Command format error", ex.localizedMessage)
    } catch (ex: NoSuchMethodException) {
      Log.e(TAG, "Transceive not supported: $req", ex)
      result.error("405", "Transceive not supported for this type of card", null)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {}

  override fun onDetachedFromActivity() {
    tagTechnology = null
  }

  private class MethodResultWrapper internal constructor(result: Result) : Result {

    private val methodResult: Result = result
    private var hasError: Boolean = false;

    companion object {
      // a Handler is always thread-safe, so use a singleton here
      private val handler: Handler by lazy {
        Handler(Looper.getMainLooper())
      }
    }

    override fun success(result: Any?) {
      handler.post {
        ignoreIllegalState {
          methodResult.success(result)
        }
      }
    }

    override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
      handler.post {
        ignoreIllegalState {
          methodResult.error(errorCode, errorMessage, errorDetails)
        }
      }
    }

    override fun notImplemented() {
      handler.post {
        ignoreIllegalState {
          methodResult.notImplemented()
        }
      }
    }

    private fun ignoreIllegalState(fn: () -> Unit) {
      try {
        if (!hasError) fn()
      } catch (e: IllegalStateException) {
        hasError = true;
        Log.w(TAG, "Exception occurred when using MethodChannel.Result: $e")
        Log.w(TAG, "Will ignore all following usage of object: $methodResult")
      }
    }
  }
}
