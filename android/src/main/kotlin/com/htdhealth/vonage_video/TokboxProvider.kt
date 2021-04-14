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
import java.lang.IllegalArgumentException

const val TAG = "TOKBOX"

class TokboxProvider
    : MethodChannel.MethodCallHandler,
        Session.SessionListener,
        PublisherKit.PublisherListener,
        PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    private val subscribers = mutableMapOf<String, Subscriber>()

    lateinit var channel: MethodChannel
    lateinit var context: Context
    private var session: Session? = null
    private var publisher: Publisher? = null
    private var publisherName = ""

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connect" -> connect(call, result)
            "disconnect" -> disconnect(call, result)
            "publish" -> publish(call, result)
            "setAudioPublishing" -> setAudioPublishing(call, result)
            "setVideoPublishing" -> setVideoPublishing(call, result)
            else -> result.notImplemented()
        }
    }

    private fun connect(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as Map<String, String>
        publisherName = args["publisherName"]!!
        session = Session.Builder(context, args["apiKey"], args["sessionId"]).build()
        session?.setSessionListener(this)
        try {
            session?.connect(args["token"])
            result.success("success")
        } catch (e: Exception) {
            result.error("error", e.message, null)
        }
    }

    private fun disconnect(call: MethodCall, result: MethodChannel.Result) {
        session?.disconnect()
        result.success("success")
    }

    private fun publish(call: MethodCall, result: MethodChannel.Result) {
        publisher = Publisher.Builder(context).name(publisherName).build()
        publisher?.setPublisherListener(this)
        session?.publish(publisher)
        result.success("success")
    }

    private fun setAudioPublishing(call: MethodCall, result: MethodChannel.Result) {
        val status = call.arguments as Boolean
        publisher?.publishAudio = status
    }

    private fun setVideoPublishing(call: MethodCall, result: MethodChannel.Result) {
        val status = call.arguments as Boolean
        publisher?.publishVideo = status
    }

    private fun getSubscriberView(id: String): View {
        if (subscribers.contains(id)) return subscribers[id]?.view!!
        throw IllegalArgumentException("Subscriber $id not found");
    }

    // SessionListener methods

    override fun onStreamReceived(session: Session?, stream: Stream?) {
        Log.d(TAG, "SessionListener::onStreamReceived")
        val subscriber = Subscriber.Builder(context, stream).build()
        session?.subscribe(subscriber)
        subscribers[stream?.streamId!!] = subscriber
        invokeSubscribersUpdate()
    }

    override fun onStreamDropped(session: Session?, stream: Stream?) {
        Log.d(TAG, "SessionListener::onStreamDropped")
        subscribers.remove(stream?.streamId)
        invokeSubscribersUpdate()
    }

    override fun onConnected(session: Session?) {
        Log.d(TAG, "SessionListener::onConnected")
        channel.invokeMethod("sessionConnected", null)
    }

    override fun onDisconnected(session: Session?) {
        Log.d(TAG, "SessionListener::onDisconnected")
        channel.invokeMethod("sessionDisconnected", null)
    }

    override fun onError(session: Session?, exception: OpentokError?) {
        Log.d(TAG, "SessionListener::onError")
    }

    // PublisherListener methods

    override fun onStreamCreated(publisher: PublisherKit?, stream: Stream?) {
        Log.d(TAG, "PublisherListener::onStreamCreated")
        channel.invokeMethod("publisherStreamCreated", null)
    }

    override fun onStreamDestroyed(publisher: PublisherKit?, stream: Stream?) {
        Log.d(TAG, "PublisherListener::onStreamDestroyed")
        channel.invokeMethod("publisherStreamDestroyed", null)
    }

    override fun onError(publisher: PublisherKit?, exception: OpentokError?) {
        Log.d(TAG, "PublisherListener::onStreamError")
    }

    // PlatformViewFactory methods

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        Log.d(TAG, "Created platform view for id $viewId")
        val id = args as String
        return when (id) {
            "publisher" -> TokboxVideoView(publisher?.view!!)
            else -> TokboxVideoView(getSubscriberView(id))
        }
    }

    private fun invokeSubscribersUpdate() {
        val subs = subscribers.values.map {
            subscriberToMap(it)
        }
        channel.invokeMethod("subscribersListUpdated", subs)
    }

    private fun subscriberToMap(subscriber: Subscriber): HashMap<String, String> {
        return hashMapOf(
                "id" to subscriber.stream.streamId,
                "name" to subscriber.stream.name
        )
    }
}

class TokboxVideoView(private val videoView: View) : PlatformView {
    override fun getView(): View {
        return videoView
    }

    override fun dispose() {
    }
}
