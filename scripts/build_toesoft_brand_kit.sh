#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/assets/toesoft-brand-kit"
SRC="$OUT/source"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$SRC" "$OUT"/{avatar,square,banner,github,xianyu,preview}
find "$OUT"/{avatar,square,banner,github,xianyu,preview} -type f -name '*.png' -delete

# Build a high-resolution antialiased TS layer from the clean avatar source.
# Blue-channel separation removes the navy background without inheriting the
# noisy transparent fringe from the AI-generated horizontal logo.
magick "$ROOT/assets/toesoft-github-avatar-v1.png" -crop 760x760+247+247 +repage \
  -resize 3040x3040 -alpha off \
  \( +clone -colorspace RGB -fx '(b-r)>0.30?1:0' -blur 0x1.2 \) \
  -compose CopyOpacity -composite "$SRC/mark-clean-4x.png"

cd "$ROOT"
swift scripts/build_toesoft_brand_kit.swift

for theme in dark light; do
  for size in 512 256 128; do
    magick "$OUT/avatar/avatar-${theme}-1024.png" -filter Lanczos -resize "${size}x${size}" \
      "$OUT/avatar/avatar-${theme}-${size}.png"
  done
done

# Build the overview without labels so ImageMagick does not need a font delegate.
masters=(
  "$OUT/avatar/avatar-dark-1024.png" "$OUT/avatar/avatar-light-1024.png"
  "$OUT/square/brand-square-dark-1080.png" "$OUT/square/brand-square-light-1080.png"
  "$OUT/banner/banner-dark-1600x400.png" "$OUT/banner/banner-light-1600x400.png"
  "$OUT/github/github-social-dark-1280x640.png" "$OUT/github/github-social-light-1280x640.png"
  "$OUT/xianyu/xianyu-cover-dark-1080.png" "$OUT/xianyu/xianyu-cover-light-1080.png"
  "$OUT/xianyu/xianyu-services-dark-1080.png" "$OUT/xianyu/xianyu-services-light-1080.png"
)

thumbs=()
for i in "${!masters[@]}"; do
  thumb="$TMP_DIR/thumb-${i}.png"
  magick "${masters[$i]}" -thumbnail '480x280>' -background '#D7DCE7' -gravity center -extent 528x328 "$thumb"
  thumbs+=("$thumb")
done

for row in 0 1 2 3 4 5; do
  magick "${thumbs[$((row*2))]}" "${thumbs[$((row*2+1))]}" +append "$TMP_DIR/row-${row}.png"
done
magick "$TMP_DIR/row-0.png" "$TMP_DIR/row-1.png" "$TMP_DIR/row-2.png" "$TMP_DIR/row-3.png" "$TMP_DIR/row-4.png" "$TMP_DIR/row-5.png" -append \
  "$OUT/preview/toesoft-brand-kit-overview.png"

echo "Brand kit built at $OUT"
