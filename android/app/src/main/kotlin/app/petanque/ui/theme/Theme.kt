package app.petanque.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val DarkColors = darkColorScheme(
    primary = PetanqueGreen,
    secondary = PetanqueYellow,
    background = PetanqueDarkBackground,
    surface = PetanqueDarkBackground,
    onPrimary = OnPetanqueDark,
    onBackground = OnPetanqueDark,
    onSurface = OnPetanqueDark,
)

/// Тема приложения. На P0 — только тёмная (приложение всегда поверх
/// видеопотока, светлая не нужна).
@Composable
fun PetanqueTheme(
    @Suppress("UNUSED_PARAMETER") darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = DarkColors,
        typography = PetanqueTypography,
        content = content
    )
}
