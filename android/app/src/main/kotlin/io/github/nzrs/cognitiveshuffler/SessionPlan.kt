package io.github.nzrs.cognitiveshuffler

import org.json.JSONObject

data class Cue(val word: String, val atMs: Long)

data class NoiseConfig(
    val enabled: Boolean,
    val volume: Float,
    val color: Float,
    val warmth: Float,
)

class SessionPlan private constructor(
    val cues: List<Cue>,
    val language: String,
    val rate: Float,
    val speechVolume: Float,
    val timerMinutes: Int,
    val fadeInMs: Long,
    val fadeOutMs: Long,
    val noise: NoiseConfig,
    val keepScreenOn: Boolean,
) {
    companion object {
        fun fromJson(raw: String): SessionPlan {
            val root = JSONObject(raw)
            val array = root.getJSONArray("cues")
            val cues = ArrayList<Cue>(array.length())
            for (index in 0 until array.length()) {
                val item = array.getJSONObject(index)
                cues.add(
                    Cue(
                        word = item.getString("w"),
                        atMs = item.optLong("t", 0L).coerceAtLeast(0L),
                    ),
                )
            }
            val noise = root.optJSONObject("noise")
            return SessionPlan(
                cues = cues,
                language = root.optString("language", "en"),
                rate = root.optDouble("rate", 0.9).toFloat().coerceIn(0.5f, 1.4f),
                speechVolume = root.optDouble("speechVolume", 0.8)
                    .toFloat().coerceIn(0f, 1f),
                timerMinutes = root.optInt("timerMinutes", 30).coerceAtLeast(0),
                fadeInMs = root.optLong("fadeInMs", 15_000L).coerceAtLeast(0L),
                fadeOutMs = root.optLong("fadeOutMs", 60_000L).coerceAtLeast(0L),
                noise = NoiseConfig(
                    enabled = noise?.optBoolean("enabled", true) ?: true,
                    volume = (noise?.optDouble("volume", 0.35) ?: 0.35)
                        .toFloat().coerceIn(0f, 1f),
                    color = (noise?.optDouble("color", 0.3) ?: 0.3)
                        .toFloat().coerceIn(0f, 1f),
                    warmth = (noise?.optDouble("warmth", 0.45) ?: 0.45)
                        .toFloat().coerceIn(0f, 1f),
                ),
                keepScreenOn = root.optBoolean("keepScreenOn", false),
            )
        }
    }
}
