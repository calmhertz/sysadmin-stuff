#!/usr/bin/env bash

set -e

if [ -n "$1" ]; then
    TARGET_LINK="$1"
else
    printf "Please paste the YouTube Topic link: "
    read -r TARGET_LINK
fi

if [ -z "$TARGET_LINK" ]; then
    echo "Error: No link provided." >&2
    exit 1
fi


TITLE=$(yt-dlp --no-warnings --quiet --print "%(title)s" "$TARGET_LINK" 2>/dev/null || true)
ARTIST=$(yt-dlp --no-warnings --quiet --print "%(artist)s" "$TARGET_LINK" 2>/dev/null || true)
ALBUM=$(yt-dlp --no-warnings --quiet --print "%(album)s" "$TARGET_LINK" 2>/dev/null || true)
UPLOADER=$(yt-dlp --no-warnings --quiet --print "%(uploader)s" "$TARGET_LINK" 2>/dev/null || true)


if [ -z "$TITLE" ] || [ "$TITLE" = "NA" ]; then
    TITLE="Unknown Track"
fi
if [ -z "$ARTIST" ] || [ "$ARTIST" = "NA" ]; then
    if [ -n "$UPLOADER" ] && [ "$UPLOADER" != "NA" ]; then
        ARTIST="$UPLOADER"
    else
        ARTIST="Unknown Artist"
    fi
fi
if [ -z "$ALBUM" ] || [ "$ALBUM" = "NA" ]; then
    ALBUM="${TITLE} - Single"
fi

CLEAN_TITLE=$(echo "$TITLE" | tr '/\\:*?"<>|' '-')
FINAL_FILE="${CLEAN_TITLE}.opus"


yt-dlp --no-warnings --quiet --extract-audio --audio-format opus -o "temp_audio.opus" "$TARGET_LINK"
yt-dlp --no-warnings --quiet --write-thumbnail --skip-download --convert-thumbnails jpg -o "temp_thumb.%(ext)s" "$TARGET_LINK"

THUMB_FILE=$(ls temp_thumb.* 2>/dev/null | head -n 1)


if [ -n "$THUMB_FILE" ] && [ -f "$THUMB_FILE" ]; then
    ffmpeg -v error -y -i "$THUMB_FILE" -vf "crop=ih:ih" temp_square.jpg
    SQUARE_THUMB="temp_square.jpg"
else
    SQUARE_THUMB="NONE"
fi


python3 - "temp_audio.opus" "$TITLE" "$ARTIST" "$ALBUM" "$SQUARE_THUMB" << 'EOF'
import sys
import base64

try:
    from mutagen.oggopus import OggOpus
    from mutagen.flac import Picture
except ImportError:
    print("Error: python3-mutagen missing. Run: sudo dnf install python3-mutagen", file=sys.stderr)
    sys.exit(1)

audio = OggOpus(sys.argv[1])
audio["title"] = sys.argv[2]
audio["artist"] = sys.argv[3]
audio["album"] = sys.argv[4]

if sys.argv[5] != "NONE":
    pic = Picture()
    with open(sys.argv[5], "rb") as f:
        pic.data = f.read()
    pic.type = 3  
    pic.mime = "image/jpeg"
    audio["metadata_block_picture"] = [base64.b64encode(pic.write()).decode('ascii')]

audio.save()
EOF


mv temp_audio.opus "$FINAL_FILE"
rm -f temp_thumb.* temp_square.jpg

echo "Successfully completed: $FINAL_FILE"
