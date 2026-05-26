package app.petanque.ui.camera

import androidx.camera.core.CameraSelector
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.lifecycle.LifecycleOwner

/// Привязывает CameraX use-кейсы (preview) к жизненному циклу.
///
/// На P1 здесь же будет добавлен `ImageAnalysis` use case с
/// `YuvToRgbConverter` для пересылки кадров детектору.
internal fun bindCameraUseCases(
    provider: ProcessCameraProvider,
    previewView: PreviewView,
    lifecycleOwner: LifecycleOwner
) {
    val preview = Preview.Builder().build().also {
        it.surfaceProvider = previewView.surfaceProvider
    }

    val selector = CameraSelector.Builder()
        .requireLensFacing(CameraSelector.LENS_FACING_BACK)
        .build()

    provider.unbindAll()
    provider.bindToLifecycle(lifecycleOwner, selector, preview)
}
