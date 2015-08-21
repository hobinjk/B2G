# How To Run Flamdroid
Clone two hobinjk/B2G repositories. One will be the runtime donor, the other will be
the host.

## Host build
```bash
GITREPO=git://github.com/hobinjk/b2g-manifest BRANCH=flamdroid-host ./config.sh flame-kk
./build.sh && ./flash.sh
```

## Donor build
```bash
git checkout flamdroid
GITREPO=git://github.com/hobinjk/b2g-manifest BRANCH=flamdroid ./config.sh flame-kk
./build.sh
cd scripts/flamdroid/
./bootstrap.sh
```

When the phone starts up B2G and Android will fight for control of the display.
Android tends to win and will display its homescreen.

TODO
====
- Fix phone app crashes
- Create an API for handing off the screen between Android and B2G
- Allow B2G to spawn and install Android apps
- Use the B2G keyboard as an Android InputMethod
- Test more complicated apps
