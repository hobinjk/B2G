# Flamdroid

libdvm or libart creates the Zygote JavaVM, which it then uses to load a list
of system classes. These classes are kept in the `/system/framework/` directory
in jar files. At some point it will attempt to cache the processed form of the
classes (dex or oat) in `/data/dalvik-cache`.

If Zygote initializes successfully, all of the Android services will attempt to
spin up. There appear to be two classes of Java-based services, but both
require `app_process` which requires Zygote to be running.

## `app_process` and `am`
The `app_process` and `am` utilities provide command-line spawning of APKs and
standard Java classes. `am` is slightly more tied to Android's services,
spawning using Intents. `app_process` is generic and can spawn any Java class
or the Zygote process itself. See `run_apk.sh` for an untested way to spawn an
APK at-will.

## Changes required
### Base version
The most far-reaching changes required were between `kk_3.5` and `b2g_kk_3.5`.
There were many API changes that required guesswork to paper over. Search for
`setBuffersSize` and `bt_av_*` for examples. The differences lead to binary
incompatibility which `init.rc`'s `LD_LIBRARY_PATH` definition and
`bootstrap.sh` mitigate. A production-ready implementation would have to ensure
that the parasite was binary-compatible with the host by changing the AOSP
libraries to match B2G's interface. In developing this project initially, I
targeted a join build of AOSP integrated with B2G by modifying the smallest
possible surface, which meant that I was usually changing B2G to be compatible
with AOSP. Because the final architecture of the system is the drastically
modified parasite being dropped into a mostly unchanged B2G, limiting
compatibility changes to the AOSP libraries would have kept binary
compatibility intact.

### `init.rc` and `init.environ.rc.in`
The initialization file had to be changed heavily. The largest change is
referring to the parasite zygote.sh file in the definition of the zygote
startup task. The `LD_LIBRARY_PATH` variable has the parasite directory added
to it. Many directories are created to appease the configuration of the storage
service, see "Emulated storage" below. `init.rc` also remounts the root
directory as read-write because of Zygote's need to write to
`/data/dalvik-cache` and other files. Zygote also loses its `onrestart`
settings because it is not the focal point of the operating system.

### Selinux
Selinux was set to permissive mode with `setenforce permissive`. This is not in
response to a specific bug, but was a preventative measure in the event that
selinux would cause problems.

### Emulated storage
`storage_list.xml` and its overlay were initially incompatible with T2M's
provided vold and mountpoint configuration. This required guesswork to fix and
is necessary for native access to any storage.

### Mocks
Gecko and gonk-misc define several fake Android services, most of which have
some level of functionality. For example, FakeSurfaceComposer advertises the
surface composer service, which will kill the Zygote launched AOSP surface
composer. An additional example is the scheduling-policy service. Gecko
actually appears to implement a small subset of the actual SchedulingPolicy's
functionality. For the purposes of this project, I renamed all of Gecko and
gonk-misc's implementations to allow the real AOSP services to take over. This
is a clear area for better cooperation between the host and Zygote.

## `bootstrap.sh`
This script injects the parasite build's files into the host system. Most of
the injection paths are the normal paths for the files. For example,
`bootstrap.sh` pushes the jar files in
`out/target/product/flame/system/framework` to `/system/framework`.

### `LD_LIBRARY_PATH` usage
Where the story gets more interesting is bootstrapping the parts of the
parasite that are not binary compatible with the host. First, the script pushes
every library from `/system/lib` to `/system/dalvy-walvy`. The wrappers for
Zygote, `dexopt`, `am` and `settings` then use a redefinition of
`LD_LIBRARY_PATH` with `/system/dalvy-walvy` prefixed.

## Unsolved bugs
 - Text rendering doesn't work
 - Sounds don't play
 - Zygote's Home and B2G fight for the display
 - Binary incompatibility is unnecessary
 - Contacts DB is not shared between host and parasite
 - Parasite should use host's keyboard for input
 - B2G has no interface for starting or installing APKs
