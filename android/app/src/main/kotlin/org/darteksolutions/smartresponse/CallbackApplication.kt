package org.darteksolutions.smartresponse

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.pathprovider.PathProviderPlugin
import io.flutter.view.FlutterMain
import rekab.app.background_locator.LocatorService
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin

//import io.flutter.plugins.firebase.cloudfirestore.CloudFirestorePlugin




class CallbackApplication : FlutterApplication(), PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate()
        LocatorService.setPluginRegistrant(this)
        FlutterMain.startInitialization(this)
    }

    override fun registerWith(registry: PluginRegistry?) {
        if (!registry!!.hasPlugin("io.flutter.plugins.pathprovider")) {
            PathProviderPlugin.registerWith(registry!!.registrarFor("io.flutter.plugins.pathprovider"))
        }
        if(!registry!!.hasPlugin("io.flutter.plugins.firebase.firestore")) {
            FlutterFirebaseFirestorePlugin.registerWith(registry!!.registrarFor("io.flutter.plugins.firebase.firestore"))
        }
        if(!registry!!.hasPlugin("io.flutter.plugins.firebase.core")) {
            FlutterFirebaseCorePlugin.registerWith(registry!!.registrarFor("io.flutter.plugins.firebase.core"))
        }

    }
}