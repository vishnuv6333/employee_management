package com.example.employee_manage

import android.app.AlertDialog
import android.app.DatePickerDialog
import android.os.Build
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.employee_manage/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceInfo" -> {
                    val info = "Android ${Build.VERSION.RELEASE} (${Build.MODEL})"
                    result.success(info)
                }
                "getCellTowerLocation" -> {
                    // Mocked cell tower location for demonstration
                    result.success("Cell Tower ID: 310-410-12345 (Mocked)")
                }
                "showNativeDatePicker" -> {
                    val c = Calendar.getInstance()
                    val year = c.get(Calendar.YEAR)
                    val month = c.get(Calendar.MONTH)
                    val day = c.get(Calendar.DAY_OF_MONTH)

                    val dpd = DatePickerDialog(this, { _, selectedYear, selectedMonth, selectedDay ->
                        Toast.makeText(this, "Selected: $selectedDay/${selectedMonth + 1}/$selectedYear", Toast.LENGTH_SHORT).show()
                    }, year, month, day)
                    dpd.show()
                    result.success(null)
                }
                "showNativeBottomSheet" -> {
                    val builder = AlertDialog.Builder(this)
                    builder.setTitle("Native Action Sheet")
                    builder.setItems(arrayOf("Option 1", "Option 2", "Cancel")) { dialog, which ->
                        when (which) {
                            0 -> Toast.makeText(this, "Option 1 Selected", Toast.LENGTH_SHORT).show()
                            1 -> Toast.makeText(this, "Option 2 Selected", Toast.LENGTH_SHORT).show()
                            2 -> dialog.dismiss()
                        }
                    }
                    builder.show()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
