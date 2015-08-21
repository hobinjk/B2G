# Unedited Flamdroid notes for posterity

App Startup

Dalvik Process

ART:
  JNI_CreateJavaVM is a thing, appears to create a JavaVM class and then
  Missing in frameworks/base/core/jni/AndroidRuntime.cpp
  run it on the main thread

  runtime/runtime.cc:
    Appears to be nice

    JNI is a thing, requires loading a ton of stuff

    Harmony is not meaningful

    libdvm/libart: Verry promising

Terms:
  Bionic: Android's libc
  Harmony: Apache nonsense in Dalvik
  JNI: Java Native Interface, overused and underpaid
  Zygote: Initial system process, no associated APK

frameworks/base/cmds/app_process/app_main.cpp:
  "Starts the interpreted runtime, then starts up the application."
  Launches arbitrary classes
  inherits from AndroidRuntime:


ARChon:
  Very promising
  Uses quite a few nonsenses
  Has some kind of entry point:
    am start $launch --activity-reset-task-if-needed
    Where $launch is hopefully the APK????
  Known issues:
    WhatsApp and Skype both don't properly work
    No native library support


app_process:
  Starts app processes using runtime
  Need AndroidRuntime and other things mentioned in its Android.mk

am:
  Successfully tries to start, but segfaults somewhere

Dax:
  Continued process of hoisting whatever directory the build fails on
  compiler_rt and rs require clang to be in use
  LOCAL_CLANG appears to be set:
    What side effects do we expect?
  LOCAL_CLANG is cleared by build/core/binary.mk, mentions B2G in comment

  Definitely compiles, has libart.so

Doesn't work, can't start JavaVM

Now trying to incorporate dalvik again
dexdeps.jar

Manually copying appears to have worked

private api stubs are what

Changes to frameworks/base

Okay, the jar we need isn't provided
It also throws a SIGABRT

PRODUCT_BOOT_JARS and BOOTCLASSPATH

Need core.jar, ext.jar, framework.jar, android.policy.jar, and services.jar at least
No jars get created in /system/framework directory. Appears to be due to a
modification of B2G's android.mk

build/core/config.mk is evil

proguard and apicheck are both disabled, may be an issue


steps to reproduce:
  frameworks/base/app_process compiles and is included
  Java libraries build
  external things: bouncycastle, okhttp, guava, jsr305, proguard

now the problem is that R.java is missing in some way, it could alternatively be that the support libraries aren't done compiling despite being requested as a STATIC_JAVA_LIBRARY
  apicheck
  frameworks/support because android sdks

Wow, still a problem. Adding things in has had no effect yet, but other errors
have been fixed because of races in the build
Error may be debuggable using aapt

android distro for flame? nope

setBuffersSize

removed development apps dir because it doesn't link R.stamp

weirdo approach #10017:
  lunch flame-eng
  Need bootable/bootloader/lk and kernel/
  Somewhere may be lacking src (after frameworks/base)
  Also needs system/bluetooth(d?)

/index.html isn't cooperating


uggggh, differences in frameworks/base because of course there are

adding in generic common

complete source tree parity
B2G = B2G \bigcup Android

Those overriding old commands are doing terrible things

Somehow dalvik-host can be made

For some reason JarFile isn't loaded despite it existing
Need verbosity

dalvikvim can be directly invoked as a test

AUGH

frameworks/base that would work mismatches with the overlays provided in qcom
device

nuke android-source, try cyanogen for ZTE Open C?

All I need is the libraries and a VM

maybe manifest smooshing

Build with caf

JarFile is overloaded

Manifest.xml approach is Just Better (TM)

Branches:
build -> reinstate-jvm
device/qcom/common -> b2g-without-overlay

gonk-misc makes package_export.apk empty

`gonk/nativewindow/*KK.*` is dumb and doesn't match up with `frameworks/native/*/gui/BufferQueue.*` and friends, copied the implementation over

Possibly something funky with boot "java.lang.IllegalStateException: Cannot broadcast before boot completed"

SyncManager dies wanting /data/system/sync/pending.xml
Probably want /data/system/packages.list

Oh jesus it actually wants WebView's stuff
Also libvideoeditor_jni.so and libemoji.so

Almost definitely need {apache-xml,webviewchromium,telephony-msim}.jar

fuuuutuuuure:
  host forks and put them in the manifese
  contacts DB
  keyboard API
  telephony
  app launches
  back button

  hopefully provided:
    rotation
    gps
    internet
    APIs in general

bluetooth api is now 21, everything else is still 19. Fun times ensue

services need to exist

system partition now doesn't have enough space
back to the thing

java.lang.UnsafeByteSequence is missing


Okay now:
E/MountService( 1333): Error processing initial volume state
E/MountService( 1333): java.lang.NullPointerException: Attempt to invoke virtual method 'java.lang.String android.os.storage.StorageVolume.getPath()' on a null object reference
E/MountService( 1333):  at com.android.server.MountService.updatePublicVolumeState(MountService.java:663)
E/MountService( 1333):  at com.android.server.MountService.access$1500(MountService.java:107)
E/MountService( 1333):  at com.android.server.MountService$4.run(MountService.java:757)

I/SystemServer( 1333): Audio Service
E/AndroidRuntime( 1333): ** FATAL EXCEPTION IN SYSTEM PROCESS: AudioService
E/AndroidRuntime( 1333): java.lang.NullPointerException: Attempt to read from field 'int android.media.AudioService$VolumeStreamState.mIndexMax' on a null object reference
E/AndroidRuntime( 1333):  at android.media.AudioService$VolumeStreamState.access$5400(AudioService.java:2843)
E/AndroidRuntime( 1333):  at android.media.AudioService$AudioHandler.handleMessage(AudioService.java:3596)
E/AndroidRuntime( 1333):  at android.os.Handler.dispatchMessage(Handler.java:102)
E/AndroidRuntime( 1333):  at android.os.Looper.loop(Looper.java:136)
E/AndroidRuntime( 1333):  at android.media.AudioService$AudioSystemThread.run(AudioService.java:3219)

E/LocationManagerService( 1677): no fused location provider found
E/LocationManagerService( 1677): java.lang.IllegalStateException: Location service needs a fused location provider
E/LocationManagerService( 1677):  at com.android.server.LocationManagerService.loadProvidersLocked(LocationManagerService.java:420)
E/LocationManagerService( 1677):  at com.android.server.LocationManagerService.systemRunning(LocationManagerService.java:250)
E/LocationManagerService( 1677):  at com.android.server.ServerThread$2.run(SystemServer.java:1093)
E/LocationManagerService( 1677):  at com.android.server.am.ActivityManagerService.systemReady(ActivityManagerService.java:9410)
E/LocationManagerService( 1677):  at com.android.server.am.ActivityManagerService$13$1.run(ActivityManagerService.java:9293)
E/LocationManagerService( 1677):  at android.os.Handler.handleCallback(Handler.java:733)
E/LocationManagerService( 1677):  at android.os.Handler.dispatchMessage(Handler.java:95)
E/LocationManagerService( 1677):  at android.os.Looper.loop(Looper.java:136)
E/LocationManagerService( 1677):  at com.android.server.am.ActivityManagerService$AThread.run(ActivityManagerService.java:1876)
E/LocationManagerService( 1677): no geocoder provider found
E/LocationManagerService( 1677): No FusedProvider found.
E/LocationManagerService( 1677): no geofence provider found

E/ActivityThread( 2558): Failed to find provider info for com.android.launcher2.settings

service media /system/bin/mediaserver in an init.rc

blob free piggyback doesn't work because unmkbootimg is sad

ANDROID_TARGET_static compilation might help, might not -> it didn't
There are mangling mismatches that appear to not be actual incompatibilities

beginning to use LD_LIBRARY_PATH which is only good for some things
SurfaceFlinger somehow loads from /system/lib/hw/hwcomposer.ohwatiotoasdf
using scripts/weirdo directory
init.rc refuses to show changes: confirmed
Files are loaded from RAMDISK

Okay, direct injection works, now it's just SurfaceFlinger

DisplayEventReceiver fails because mDataChannel is null, probably the composer service

07-24 18:23:40.780  1127  1144 V DisplayEventReceiver: Event connection could not be created
  getInterfaceDescriptor: Might fail because ??
  remote()
  transact because CHECK_INTERFACE
  Where is BitTube defined?

Manually starting surface flinger seems to fix this

  - [COMPLETE] Update builds
  - [COMPLETE]  Test more
  - Failed to initialize display event receiver.  status=-19
  - frameworks/base/core/jni/android_view_DisplayEventReceiver.cpp:86
  - initCheck of ./frameworks/native/include/gui/DisplayEventReceiver.h
    - mDataChannel is null
  - ComposerService::getComposerService is fine but createDisplayEventConnection fails
  - Might be FakeSurfaceComposer's fault
  - Both scheduling_policy and permission services are being overwritten
  - Now Volume at /mnt/media_rw/sdcard already exists but no alarm logs
  - Wake lock not active at com.android.server.power.PowerManagerService.updateWakeLockWorkSourceInternal(PowerManagerService.java:820)
    - CNE spoof might fix
    - Really not the proper way to fix it
  - "No emulated storage" causes Zygote to abort
    - Need proper settings of EMULATED_STORAGE_SOURCE, EMULATED_STORAGE_TARGET, and EXTERNAL_STORAGE
    - 06-14 19:17:17.750   213   565 I AutoMounter: UpdateState: Volume sdcard1 is NoMedia and missing
    - Permissions are off
    - Seemingly fixed except for the getPath nullpointer
      "06-15 02:35:01.649   931   991 I MountService: Updating path /storage/sdcard with valid state mounted
      06-15 02:35:01.649   931   991 E MountService: Error processing initial volume state
      06-15 02:35:01.649   931   991 E MountService: java.lang.NullPointerException: Attempt to invoke virtual method 'java.lang.String android.os.storage.StorageVolume.getPath()' on a null object reference
      06-15 02:35:01.649   931   991 E MountService:  at com.android.server.MountService.updatePublicVolumeState(MountService.java:663)
      06-15 02:35:01.649   931   991 E MountService:  at com.android.server.MountService.access$1500(MountService.java:107)
      06-15 02:35:01.649   931   991 E MountService:  at com.android.server.MountService$4.run(MountService.java:757)"
    - /storage/sdcard vs /storage/sdcard
    - /data/dalvik-cache is said to be non-writeable
    - /system/bin/dexopt needs to be execl'd
    - MISSING KEYGUARD OUT OF LEFT FIELD?
    - Keywhatever gets overwritten because Gecko is terrible
  - Some things were rebased on the wrong revision for weeeird reasons
