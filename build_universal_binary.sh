#!/bin/bash

set -euo pipefail
set +x

usage() {
    echo "
Usage: $0 [OPTIONS]

-r, --revision
    Revision SHA

-o, --output_dir
    Final binary output
"
}

REVISION=""
OUTDIR=""

CURRENT_FLAG=""
while [ ! $# -eq 0 ]; do
    case "$1" in
        --revision | -r)
            CURRENT_FLAG="r";;
        --output_dir | -o)
            CURRENT_FLAG="o";;
        *)
            if [[ $CURRENT_FLAG == "r" ]]; then

                REVISION="$1"

            elif [[ $CURRENT_FLAG == "o" ]]; then

                OUTDIR="$1"

            else
                # To stderr
                echo "'$1' not a valid argument." >&2

                # Exit the script
                exit 1
            fi;;
    esac

    # Remove first argument, $2 becomes $1
    shift
done

if [[ $OUTDIR == "" ]]; then

    # To stderr
    echo "Missing dependency arguments." >&2

    # Print usage
    usage

    # Exit the script
    exit 1

fi

if [[ $REVISION == "" ]]; then

    REVISION=9b79ad33af747f0df3297a9c171341c2ca50fe23

    echo "Revision set to default: $REVISION"

fi

./build.sh -d -t ios -c arm64 -n Release -r $REVISION -F "webrtcbuilds-%to%-%tc%" -P "webrtcbuilds"
./build.sh -d -t ios -c arm -n Release -r $REVISION -F "webrtcbuilds-%to%-%tc%" -P "webrtcbuilds"
./build.sh -d -t ios -c x86 -n Release -r $REVISION -F "webrtcbuilds-%to%-%tc%" -P "webrtcbuilds"
./build.sh -d -t ios -c x64 -n Release -r $REVISION -F "webrtcbuilds-%to%-%tc%" -P "webrtcbuilds"

lipo -create \
    out/webrtcbuilds-ios-arm/lib/Release_ios_arm64/libwebrtc_full.a \
    out/webrtcbuilds-ios-arm/lib/Release_ios_arm/libwebrtc_full.a \
    out/webrtcbuilds-ios-x64/lib/Release_ios_x64/libwebrtc_full.a \
    out/webrtcbuilds-ios-x86/lib/Release_ios_x86/libwebrtc_full.a \
    -output $OUTDIR
