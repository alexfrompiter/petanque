package app.petanque.ui.camera

import android.Manifest
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat

/// Полноэкранный CameraX preview. На P0 — только видео без анализа кадров.
/// На P1 сюда добавится ImageAnalysis use case, отдающий кадры детектору.
@Composable
fun CameraView(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current

    var hasPermission by remember {
        mutableStateOf(
            ContextCompat.checkSelfPermission(
                context, Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_GRANTED
        )
    }

    val permissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted -> hasPermission = granted }

    LaunchedEffect(Unit) {
        if (!hasPermission) permissionLauncher.launch(Manifest.permission.CAMERA)
    }

    Box(modifier = modifier.background(Color.Black)) {
        if (hasPermission) {
            AndroidView(
                modifier = Modifier.fillMaxSize(),
                factory = { ctx ->
                    PreviewView(ctx).apply {
                        implementationMode = PreviewView.ImplementationMode.PERFORMANCE
                        scaleType = PreviewView.ScaleType.FILL_CENTER
                    }
                },
                update = { previewView ->
                    val providerFuture = ProcessCameraProvider.getInstance(context)
                    providerFuture.addListener(
                        {
                            val provider = providerFuture.get()
                            bindCameraUseCases(
                                provider = provider,
                                previewView = previewView,
                                lifecycleOwner = lifecycleOwner
                            )
                        },
                        ContextCompat.getMainExecutor(context)
                    )
                }
            )
        } else {
            CameraPermissionDeniedMessage(
                modifier = Modifier.align(Alignment.Center).padding(32.dp),
                onOpenSettings = {
                    val intent = android.content.Intent(
                        Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                        Uri.fromParts("package", context.packageName, null)
                    )
                    intent.flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
                    context.startActivity(intent)
                }
            )
        }
    }
}

@Composable
private fun CameraPermissionDeniedMessage(
    modifier: Modifier = Modifier,
    onOpenSettings: () -> Unit
) {
    Box(
        modifier = modifier
            .background(Color.Black.copy(alpha = 0.6f), shape = RoundedCornerShape(16.dp))
            .padding(PaddingValues(24.dp))
    ) {
        androidx.compose.foundation.layout.Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = androidx.compose.foundation.layout.Arrangement.spacedBy(12.dp)
        ) {
            Text(
                "Нет доступа к камере",
                color = Color.White,
                style = MaterialTheme.typography.titleMedium
            )
            Text(
                "Разрешите доступ в настройках, чтобы видеть площадку.",
                color = Color.White.copy(alpha = 0.8f),
                style = MaterialTheme.typography.bodyMedium
            )
            Button(onClick = onOpenSettings) { Text("Открыть настройки") }
        }
    }
}
