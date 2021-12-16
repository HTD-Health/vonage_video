package com.htdhealth.vonage_video

import android.content.Context
import android.util.Log
import android.view.View
import com.opentok.android.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import android.view.ViewGroup
import kotlin.IllegalArgumentException

const val TAG = "TOKBOX"

class TokboxProvider
    : MethodChannel.MethodCallHandler,
        Session.SessionListener,
        PublisherKit.PublisherListener,
        PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    lateinit var channel: MethodChannel
    lateinit var context: Context
    private var session: Session? = null
    private var publisher: Publisher? = null
    private var publisherName = ""
    private val subscribers = mutableListOf<Subscriber>()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connect" -> connect(call, result)
            "disconnect" -> disconnect(result)
            "publish" -> publish(result)
            "setAudioPublishing" -> setAudioPublishing(call, result)
            "setVideoPublishing" -> setVideoPublishing(call, result)
            else -> result.notImplemented()
        }
    }

    private fun connect(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as Map<*, *>
        publisherName = args["publisherName"] as String
        session = Session.Builder(context, args["apiKey"] as String, args["sessionId"] as String).build()
        session?.setSessionListener(this)
        try {
            session?.connect(args["token"] as String)
            result.success("success")
        } catch (e: Exception) {
            result.error("error", e.message, null)
        }
    }

    fun disconnectFromSession() {
        session?.disconnect()
    }

    private fun disconnect(result: MethodChannel.Result) {
        session?.disconnect()
        result.success("success")
    }

    private fun publish(result: MethodChannel.Result) {
        publisher = Publisher.Builder(context).name(publisherName).build()
        publisher?.setPublisherListener(this)
        session?.publish(publisher)
        result.success("success")
    }

    private fun setAudioPublishing(call: MethodCall, result: MethodChannel.Result) {
        val status = call.arguments as Boolean
        publisher?.publishAudio = status
        result.success("success")
    }

    private fun setVideoPublishing(call: MethodCall, result: MethodChannel.Result) {
        val status = call.arguments as Boolean
        publisher?.publishVideo = status
        result.success("success")
    }

    private fun getSubscriberForStreamId(id: String): Subscriber? {
        var subscriber: Subscriber? = null
        subscribers.forEach {
            if (it.stream.streamId == id) subscriber = it
        }
        return subscriber
    }

    // SessionListener methods

    override fun onStreamReceived(session: Session, stream: Stream) {
        Log.d(TAG, "SessionListener::onStreamReceived")
        val subscriber = Subscriber.Builder(context, stream).build()
        session.subscribe(subscriber)
        subscribers.add(subscriber)
        invokeSubscribersUpdate()
    }

    override fun onStreamDropped(session: Session, stream: Stream) {
        Log.d(TAG, "SessionListener::onStreamDropped")
        subscribers.remove(getSubscriberForStreamId(stream.streamId))
        invokeSubscribersUpdate()
    }

    override fun onConnected(session: Session) {
        Log.d(TAG, "SessionListener::onConnected")
        channel.invokeMethod("sessionConnected", null)
    }

    override fun onDisconnected(session: Session) {
        Log.d(TAG, "SessionListener::onDisconnected")
        channel.invokeMethod("sessionDisconnected", null)
    }

    override fun onError(session: Session, exception: OpentokError) {
        Log.d(TAG, "SessionListener::onError")
    }

    // PublisherListener methods

    override fun onStreamCreated(publisher: PublisherKit, stream: Stream) {
        Log.d(TAG, "PublisherListener::onStreamCreated")
        channel.invokeMethod("publisherStreamCreated", null)
    }

    override fun onStreamDestroyed(publisher: PublisherKit, stream: Stream) {
        Log.d(TAG, "PublisherListener::onStreamDestroyed")
        channel.invokeMethod("publisherStreamDestroyed", null)
    }

    override fun onError(publisher: PublisherKit, exception: OpentokError) {
        Log.d(TAG, "PublisherListener::onStreamError")
    }

    // PlatformViewFactory methods

    private fun parseVideoScale(scale: String?): String {
        return when (scale) {
            "VideoStyleFill" -> BaseVideoRenderer.STYLE_VIDEO_FILL
            "VideoStyleFit" -> BaseVideoRenderer.STYLE_VIDEO_FIT
            else -> throw IllegalArgumentException("Video Renderer scale '$scale' unknown")
        }
    }

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        Log.d(TAG, "Created platform view for id $viewId")
        val argMap = args as Map<*, *>
        val id = argMap["id"] ?: ""
        val videoScale = parseVideoScale(argMap["scale"] as String)
        return if (id == "publisher") {
            publisher!!.renderer.setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE, videoScale)
            TokboxVideoView(publisher!!.view)
        } else {
            val subscriber = getSubscriberForStreamId(id as String)!!
            subscriber.renderer.setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE, videoScale)
            TokboxVideoView(subscriber.view)
        }
    }

    private fun invokeSubscribersUpdate() {
        val subs = subscribers.map {
            hashMapOf(
                    "id" to it.stream.streamId,
                    "name" to it.stream.name
            )
        }
        channel.invokeMethod("subscribersListUpdated", subs)
    }
}

class TokboxVideoView(private val videoView: View) : PlatformView {
    init {
        val parent = videoView.parent as ViewGroup?
        parent?.removeView(videoView)
    }

    override fun getView(): View {
        return videoView
    }

    override fun dispose() {
    }
}
