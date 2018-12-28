#!/usr/bin/env bash
set -e

STAMP='default'

WEB_APP_VERSION='1.0.0-rc19'
HIPILER_VERSION='1.3.1'
SERVER_VERSION='1.8.0-rc2'
LIBRARY_VERSION='1.3.0-rc.5'
MULTIVEC_VERSION='0.2.0-rc.1'
CLODIUS_VERSION='0.10.0.rc4'
TIME_INTERVAL_TRACK_VERSION='0.2.0-rc.2'
SIMPLE_HTTPFS_VERSION='0.1.3'

usage() {
  echo "USAGE: $0 -w WORKERS [-s STAMP] [-l]" >&2
  exit 1
}

while getopts 's:w:l' OPT; do
  case $OPT in
    s)
      STAMP=$OPTARG
      ;;
    w)
      WORKERS=$OPTARG
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z $WORKERS ]; then
  usage
fi

set -o verbose # Keep this after the usage message to reduce clutter.

# When development settles down, consider going back to static Dockerfile.
perl -pne "s/<TIME_INTERVAL_TRACK_VERSION>/$TIME_INTERVAL_TRACK_VERSION/g; s/<CLODIUS_VERSION>/$CLODIUS_VERSION/g; s/<HGTILES_VERSION>/$HGTILES_VERSION/g; s/<MULTIVEC_VERSION>/$MULTIVEC_VERSION/g; s/<SERVER_VERSION>/$SERVER_VERSION/g; s/<WEB_APP_VERSION>/$WEB_APP_VERSION/g; s/<LIBRARY_VERSION>/$LIBRARY_VERSION/g; s/<HIPILER_VERSION>/$HIPILER_VERSION/g; s/<SIMPLE_HTTPFS_VERSION>/$SIMPLE_HTTPFS_VERSION/g" \
          web-context/Dockerfile.template > web-context/Dockerfile

REPO=gehlenborglab/higlass
#docker pull $REPO # Defaults to "latest", but just speeds up the build, so precise version doesn't matter.
#docker build --cache-from $REPO \
docker build --cache-from image-$STAMP \
             --build-arg WORKERS=$WORKERS \
             --tag image-$STAMP \
             web-context

rm web-context/Dockerfile # Ephemeral: We want to prevent folks from editing it by mistake.

