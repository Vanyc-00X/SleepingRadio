package com.sleepingradio.sleeping_radio

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class SleepingRadioWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.sleeping_radio_widget)
            val title = widgetData.getString("title", null)?.takeIf { it.isNotBlank() }
                ?: "Сонное радио"
            val timer = widgetData.getString("timer", null) ?: "Таймер выкл."
            val playing = widgetData.getBoolean("playing", false)

            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_timer, timer)
            views.setTextViewText(
                R.id.widget_status,
                if (playing) "Играет" else "На паузе",
            )
            views.setTextViewText(
                R.id.widget_play,
                if (playing) "Pause" else "Play",
            )

            val openIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
            )
            views.setOnClickPendingIntent(R.id.widget_root, openIntent)

            val toggleUri = Uri.parse("sleepingradio://widget/toggle_play")
            val toggleIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                toggleUri,
            )
            views.setOnClickPendingIntent(R.id.widget_play, toggleIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
