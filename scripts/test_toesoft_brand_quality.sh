#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/assets/toesoft-brand-kit/source"

test -f "$SRC/mark-clean-4x.png"
test -f "$SRC/lockup-clean-dark-4x.png"
test -f "$SRC/lockup-clean-light-4x.png"

mark_width=$(magick identify -format '%w' "$SRC/mark-clean-4x.png")
lockup_width=$(magick identify -format '%w' "$SRC/lockup-clean-dark-4x.png")
test "$mark_width" -ge 1024
test "$lockup_width" -ge 4000

# Alpha must contain partial coverage values, proving antialiased edges exist.
mark_alpha_colors=$(magick "$SRC/mark-clean-4x.png" -alpha extract -format '%k' info:)
lockup_alpha_colors=$(magick "$SRC/lockup-clean-dark-4x.png" -alpha extract -format '%k' info:)
test "$mark_alpha_colors" -gt 32
test "$lockup_alpha_colors" -gt 32

# Match the selected source lockup: text is about 71% of the TS mark height,
# the two elements share an optical center, and their gap is about 65 source px.
blue_box=$(magick "$SRC/lockup-clean-light-4x.png" -fx '(b-r)>0.20?1:0' \
  -trim -format '%@' info:)
text_box=$(magick "$SRC/lockup-clean-light-4x.png" -alpha extract \
  \( +clone -crop 3304x992+1380+0 +repage \) -delete 0 -trim -format '%@' info:)
blue_h=${blue_box#*x}; blue_h=${blue_h%%+*}
text_h=${text_box#*x}; text_h=${text_h%%+*}
ratio=$((text_h * 100 / blue_h))
test "$ratio" -ge 68
test "$ratio" -le 74

# The production renderer must use clean layers, not legacy noisy crops.
rg -q 'mark-clean-4x.png' "$ROOT/scripts/build_toesoft_brand_kit.swift"
rg -q 'lockup-clean-dark-4x.png' "$ROOT/scripts/build_toesoft_brand_kit.swift"
if rg -q 'withDesign\(.rounded\)|Arial Rounded|drawLockup|mark-alpha.png|wordmark-white.png|wordmark-dark.png|horizontal-lockup-dark.png|horizontal-lockup-light.png|wordmark-clean-dark-4x.png|wordmark-clean-light-4x.png' "$ROOT/scripts/build_toesoft_brand_kit.swift"; then
  echo 'renderer still references legacy noisy logo layers' >&2
  exit 1
fi

echo 'ToeSoft source-layer quality checks passed'
