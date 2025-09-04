#!/bin/sh

# Description: Script to play files in apps by file extension or mime.
#
# Shell: POSIX compliant, preferentially dash.
# Usage: opener.sh filepath
#
# Integration with nnn:
#   1. Export the required config:
#         export NNN_OPENER=/opt/void-rice/opener.sh
#         # Otherwise, if opener.sh is in $PATH as opener
#         # export NNN_OPENER=opener
#   2. Run nnn with the program option to indicate a CLI opener
#         nnn -c
#         # The -c program option overrides option -e
#   3. Opener can use nnn plugins (e.g. mocq is used for audio), $PATH is updated.
#
# Details:
#   Inspired by ranger's scope.sh and nnn-s nuke.
#
#   Guards against accidentally opening mime types like executables, shared libs etc.
#
#   Tries to play 'file' (1st argument) in the following order:
#     1. by extension
#     2. by mime
#     3. by mime (prompt and run executables)
#
#   By default it starts GUI apps in a xorg sesssion. Set GUI=0 to disable
#   GUI apps. It starts GUI apps with devour to imitate CLI app behaviour.

if [ -z "$GUI"]; then
  if [ -n "$DISPLAY" ]; then
    GUI=1
  else
    GUI=0
  fi
fi
# Set to BIN=1 to enable binary execcution.
BIN="${BIN:-0}"

set -euf -o noclobber -o noglob -o nounset
IFS="$(printf '%b_' '\n')"
IFS="${IFS%_}" # Protect trailing \n .

IMAGE_CACHE_PATH="$(dirname "$1")"/.thumbs

FILEPATH="$1"
FILENAME=$(basename "$1")
EDITOR="${VISUAL:-${EDITOR:-vi}}"
PAGER="${PAGER:-less -R}"
EXTENSION="${FILENAME##*.}"
if [ -n "$EXTENSION" ]; then
  EXTENSION="$(printf "%s" "${EXTENSION}" | tr '[:upper:]' '[:lower:]')"
fi

TERMINAL_COLUMNS=$(tput cols)
TERMINAL_LINES=$(tput lines)
TERMINAL_FONT_WIDTH=5
TERMINAL_FONT_HEIGHT=10
TERMINAL_WIDTH=$(($TERMINAL_COLUMNS * $TERMINAL_FONT_WIDTH))
TERMINAL_HEIGHT=$(($TERMINAL_LINES * $TERMINAL_FONT_HEIGHT))

# Sets the variable absolute_path_target, this should be faster than calling printf.
absolute_path() {
  case "$1" in
  /*) absolute_path_target="$1" ;;
  *) absolute_path_target="$PWD/$1" ;;
  esac
}

handle_archive() {
  if command -v tar >/dev/null 2>&1; then
    tar --list --file "${FILEPATH}" | eval "$PAGER"
  elif command -v bsdtar >/dev/null 2>&1; then
    bsdtar --list --file "${FILEPATH}" | eval "$PAGER"
  elif command -v atool >/dev/null 2>&1; then
    atool --list -- "${FILEPATH}" | eval "$PAGER"
  else
    return
  fi
  exit 0
}

handle_7zip() {
  if command -v 7z >/dev/null 2>&1; then
    ## Avoid password prompt by providing empty password
    7z l -p -- "${FILEPATH}" | eval "$PAGER"
  else
    return
  fi
  exit 0
}

handle_rar() {
  if command -v unrar >/dev/null 2>&1; then
    ## Avoid password prompt by providing empty password
    unrar lt -p- -- "${FILEPATH}" | eval "$PAGER"
  elif command -v 7z >/dev/null 2>&1; then
    ## Avoid password prompt by providing empty password
    7z l -p -- "${FILEPATH}" | eval "$PAGER"
  else
    return
  fi
  exit 0
}

t_handle_image() {
  if command -v w3mimgdisplay >/dev/null 2>&1; then
    echo "0;1;0;0;${TERMINAL_WIDTH};${TERMINAL_HEIGHT};;;;;${FILEPATH}
3;" | w3mimgdisplay
  elif command -v viu >/dev/null 2>&1; then
    viu -n "${FILEPATH}" | eval "$PAGER"
  elif command -v img2txt >/dev/null 2>&1; then
    img2txt --gamma=0.6 -- "${FILEPATH}" | eval "$PAGER"
  elif command -v exiftool >/dev/null 2>&1; then
    exiftool "${FILEPATH}" | eval "$PAGER"
  else
    return
  fi
  exit 0
}

# Storing the result to a tmp file is faster than calling list_images twice.
list_images() {
  find -L "///${1%/*}" -maxdepth 1 -type f -print0 |
    grep -izZE '\.(jpe?g|png|gif|webp|tiff?|bmp|ico|svg|webp|xpm)$' |
    sort -zV | tee "$tmp"
}

load_image_dir() {
  absolute_path "$2"
  tmp="${TMPDIR:-/tmp}/opener_$$"
  trap 'rm -f -- "$tmp"' EXIT
  count="$(list_images "$absolute_path_target" |
    grep -a -m 1 -ZznF "$absolute_path_target" | cut -d: -f1)"

  if [ -n "$count" ]; then
    if [ "$GUI" -ne 0 ]; then
      devour xargs -0 nohup "$1" -n "$count" -- <"$tmp"
    else
      xargs -0 "$1" -n "$count" -- <"$tmp"
    fi
  else
    shift
    "$1" -- "$@" # fallback
  fi
}

handle_image() {
  if [ "$GUI" -ne 0 ]; then
    if command -v nsxiv >/dev/null 2>&1; then
      load_image_dir nsxiv "${FILEPATH}"
    elif command -v sxiv >/dev/null 2>&1; then
      load_image_dir sxiv "${FILEPATH}"
    elif command -v fim >/dev/null 2>&1; then
      devour fim "${FILEPATH}"
    elif command -v feh >/dev/null 2>&1; then
      devour feh "${FILEPATH}"
    elif command -v imv >/dev/null 2>&1; then
      load_image_dir imv "${FILEPATH}"
    elif command -v imvr >/dev/null 2>&1; then
      load_image_dir imvr "${FILEPATH}"
    elif command -v mupdf >/dev/null 2>&1; then
      devour mupdf "${FILEPATH}"
    else
      t_handle_image
      return
    fi
  else
    if command -v fim >/dev/null 2>&1; then
      fim "${FILEPATH}"
    elif command -v fbi >/dev/null 2>&1; then
      fbi "${FILEPATH}"
    elif command -v fbvis >/dev/null 2>&1; then
      fbvis "${FILEPATH}"
    elif command -v fbv >/dev/null 2>&1; then
      fbv "${FILEPATH}"
    elif command -v fbpdf >/dev/null 2>&1; then
      fbpdf "${FILEPATH}"
    else
      t_handle_image
      return
    fi
  fi
  exit 0
}

handle_svg() {
  if [ "$GUI" -ne 0 ]; then
    if command -v nsxiv >/dev/null 2>&1; then
      load_image_dir nsxiv "${FILEPATH}"
    elif command -v sxiv >/dev/null 2>&1; then
      load_image_dir sxiv "${FILEPATH}"
    elif command -v feh >/dev/null 2>&1; then
      devour feh "${FILEPATH}"
    elif command -v imv >/dev/null 2>&1; then
      load_image_dir imv "${FILEPATH}"
    elif command -v imvr >/dev/null 2>&1; then
      load_image_dir imvr "${FILEPATH}"
    elif command -v mupdf >/dev/null 2>&1; then
      devour mupdf "${FILEPATH}"
    elif command -v inkscape >/dev/null 2>&1; then
      devour inkscape "${FILEPATH}"
    else
      t_handle_image
      return
    fi
  else
    if command -v fbpdf >/dev/null 2>&1; then
      fbpdf "${FILEPATH}"
    elif command -v fbi >/dev/null 2>&1; then
      fbi "${FILEPATH}"
    elif command -v fbvis >/dev/null 2>&1; then
      fbvis "${FILEPATH}"
    elif command -v fbv >/dev/null 2>&1; then
      fbv "${FILEPATH}"
    else
      t_handle_image
      return
    fi
  fi
  exit 0
}

t_handle_djvu() {
  if command -v djvutxt >/dev/null 2>&1; then
    ## Preview as text conversion (requires djvulibre)
    djvutxt "${FILEPATH}" | eval "$PAGER"
  elif command -v exiftool >/dev/null 2>&1; then
    exiftool "${FILEPATH}" | eval "$PAGER"
  else
    return
  fi
  exit 0
}

handle_djvu() {
  if [ "$GUI" -ne 0 ]; then
    if command -v zathura >/dev/null 2>&1; then
      devour zathura "${FILEPATH}"
    elif command -v fim >/dev/null 2>&1; then
      devour fim "${FILEPATH}"
    else
      t_handle_djvu
      return
    fi
  else
    if command -v fbdjvu >/dev/null 2>&1; then
      fbdjvu "${FILEPATH}"
    elif command -v fim >/dev/null 2>&1; then
      devour fim "${FILEPATH}"
    else
      t_handle_djvu
      return
    fi
  fi
  exit 0
}

t_handle_pdf() {
  if command -v mutool >/dev/null 2>&1; then
    mutool draw -F txt -i -- "${FILEPATH}" 1-10 | eval "$PAGER"
  elif [ "pdf" = "${EXTENSION}" ] && command -v pdftotext >/dev/null 2>&1; then
    pdftotext -l 10 -nopgbrk -q -- "${FILEPATH}" - | eval "$PAGER"
  elif command -v exiftool >/dev/null 2>&1; then
    exiftool "${FILEPATH}" | eval "$PAGER"
  else
    return
  fi
  exit 0
}

handle_pdf() {
  if [ "$GUI" -ne 0 ]; then
    if command -v zathura >/dev/null 2>&1; then
      devour zathura "${FILEPATH}"
    elif command -v mupdf >/dev/null 2>&1; then
      devour mupdf "${FILEPATH}"
    else
      t_handle_pdf
      return
    fi
  else
    if command -v fbpdf >/dev/null 2>&1; then
      fbpdf "${FILEPATH}"
    else
      t_handle_pdf
      return
    fi
  fi
  exit 0
}

t_handle_epub() {
  if command -v mutool >/dev/null 2>&1; then
    mutool draw -F txt -i -- "${FILEPATH}" 1-10 | eval "$PAGER"
  elif command -v exiftool >/dev/null 2>&1; then
    exiftool "${FILEPATH}" | eval "$PAGER"
  else
    return
  fi
  exit 0
}

handle_epub() {
  # NOTE: Electronic book document.
  if [ "$GUI" -ne 0 ]; then
    if command -v zathura >/dev/null 2>&1; then
      devour zathura "${FILEPATH}"
    elif command -v mupdf >/dev/null 2>&1; then
      devour mupdf "${FILEPATH}"
    else
      t_handle_epub
      return
    fi
  else
    if command -v fbpdf >/dev/null 2>&1; then
      fbpdf "${FILEPATH}"
    else
      t_handle_epub
      return
    fi
  fi
  exit 0
}

t_handle_xps() {
  if command -v mutool >/dev/null 2>&1; then
    mutool draw -F txt -i -- "${FILEPATH}" 1-10 | eval "$PAGER"
  else
    return
  fi
  exit 0
}

handle_xps() {
  if [ "$GUI" -ne 0 ]; then
    if command -v zathura >/dev/null 2>&1; then
      devour zathura "${FILEPATH}"
    elif command -v mupdf >/dev/null 2>&1; then
      devour mupdf "${FILEPATH}"
    else
      t_handle_xps
      return
    fi
  else
    if command -v fbpdf >/dev/null 2>&1; then
      fbpdf "${FILEPATH}"
    else
      t_handle_xps
      return
    fi
  fi
  exit 0
}

t_handle_comic_book() {
  if command -v mutool >/dev/null 2>&1; then
    mutool draw -F txt -i -- "${FILEPATH}" 1-10 | eval "$PAGER"
  else
    return
  fi
  exit 0
}

handle_comic_book() {
  # NOTE: Comic book archive.
  if [ "$GUI" -ne 0 ]; then
    if command -v zathura >/dev/null 2>&1; then
      devour zathura "${FILEPATH}"
    elif command -v mupdf >/dev/null 2>&1; then
      devour mupdf "${FILEPATH}"
    else
      t_handle_comic_book
      return
    fi
  else
    if command -v fbpdf >/dev/null 2>&1; then
      fbpdf "${FILEPATH}"
    else
      t_handle_comic_book
      return
    fi
  fi
  exit 0
}

t_handle_mobi() {
  if command -v mutool >/dev/null 2>&1; then
    mutool draw -F txt -i -- "${FILEPATH}" 1-10 | eval "$PAGER"
  else
    return
  fi
  exit 0
}

handle_mobi() {
  # NOTE: Mobipocket e-book. Kindle e-book is its subclass.
  if [ "$GUI" -ne 0 ]; then
    if command -v mupdf >/dev/null 2>&1; then
      devour mupdf "${FILEPATH}"
    else
      t_handle_mobi
      return
    fi
  else
    if command -v fbpdf >/dev/null 2>&1; then
      fbpdf "${FILEPATH}"
    else
      t_handle_mobi
      return
    fi
  fi
  exit 0
}

t_handle_fictionbook() {
  if command -v mutool >/dev/null 2>&1; then
    mutool draw -F txt -i -- "${FILEPATH}" 1-10 | eval "$PAGER"
  else
    return
  fi
  exit 0
}

handle_fictionbook() {
  # NOTE: FictionBook document.
  if [ "$GUI" -ne 0 ]; then
    if command -v mupdf >/dev/null 2>&1; then
      devour mupdf "${FILEPATH}"
    else
      t_handle_fictionbook
      return
    fi
  else
    if command -v fbpdf >/dev/null 2>&1; then
      fbpdf "${FILEPATH}"
    else
      t_handle_fictionbook
      return
    fi
  fi
  exit 0
}

handle_postscript() {
  # NOTE: PostScript document.
  if [ "$GUI" -ne 0 ]; then
    if command -v zathura >/dev/null 2>&1; then
      devour zathura "${FILEPATH}"
    else
      return
    fi
  else
    return
  fi
  exit 0
}

handle_audio() {
  if command -v mpv >/dev/null 2>&1; then
    if [ "$GUI" -ne 0 ]; then
      devour mpv "${FILEPATH}"
    else
      mpv --vo=drm "${FILEPATH}"
    fi
  elif command -v mocp >/dev/null 2>&1 && command -v mocq >/dev/null 2>&1; then
    mocq "${FILEPATH}" "opener"
  elif command -v ffplay >/dev/null 2>&1; then
    if [ "$GUI" -ne 0 ]; then
      devour ffplay "${FILEPATH}"
    else
      ffplay "${FILEPATH}"
    fi
  elif command -v media_client >/dev/null 2>&1; then
    media_client play "${FILEPATH}"
  elif command -v mediainfo >/dev/null 2>&1; then
    mediainfo "${FILEPATH}" | eval "$PAGER"
  elif command -v exiftool >/dev/null 2>&1; then
    exiftool "${FILEPATH}" | eval "$PAGER"
  else
    return
  fi
  exit 0
}

t_handle_video() {
  if command -v w3mimgdisplay >/dev/null 2>&1 &&
    command -v ffmpegthumbnailer >/dev/null 2>&1; then
    # Thumbnail
    [ -d "${IMAGE_CACHE_PATH}" ] || mkdir "${IMAGE_CACHE_PATH}"
    ffmpegthumbnailer -i "${FILEPATH}" -o "${IMAGE_CACHE_PATH}/${FILENAME}.jpg" -s 0
    echo "0;1;0;0;${TERMINAL_WIDTH};${TERMINAL_HEIGHT};;;;;${IMAGE_CACHE_PATH}/${FILENAME}
3;" | w3mimgdisplay
  elif command -v viu >/dev/null 2>&1 &&
    command -v ffmpegthumbnailer >/dev/null 2>&1; then
    # Thumbnail
    [ -d "${IMAGE_CACHE_PATH}" ] || mkdir "${IMAGE_CACHE_PATH}"
    ffmpegthumbnailer -i "${FILEPATH}" -o "${IMAGE_CACHE_PATH}/${FILENAME}.jpg" -s 0
    viu -n "${IMAGE_CACHE_PATH}/${FILENAME}.jpg" | eval "$PAGER"
  elif command -v mediainfo >/dev/null 2>&1; then
    mediainfo "${FILEPATH}" | eval "$PAGER"
  elif command -v exiftool >/dev/null 2>&1; then
    exiftool "${FILEPATH}" | eval "$PAGER"
  else
    return
  fi
  exit 0
}

handle_video() {
  if [ "$GUI" -ne 0 ]; then
    if command -v mpv >/dev/null 2>&1; then
      devour mpv "${FILEPATH}"
    elif command -v smplayer >/dev/null 2>&1; then
      devour smplayer "${FILEPATH}"
    elif command -v ffplay >/dev/null 2>&1; then
      devour ffplay "${FILEPATH}"
    else
      t_handle_video
      return
    fi
  else
    if command -v mpv >/dev/null 2>&1; then
      mpv --vo=drm "${FILEPATH}"
    elif command -v ffplay >/dev/null 2>&1; then
      ffplay "${FILEPATH}"
    else
      t_handle_video
      return
    fi
  fi
  exit 0
}

t_handle_office_docs() {
  if command -v soffice >/dev/null 2>&1; then
    ## Preview as text conversion
    soffice --cat "${FILEPATH}" | eval "$PAGER"
  elif command -v odt2txt >/dev/null 2>&1; then
    ## Preview as text conversion
    odt2txt "${FILEPATH}" | eval "$PAGER"
  else
    return
  fi
  exit 0
}

handle_office_docs() {
  if [ "$GUI" -ne 0 ]; then
    if command -v soffice >/dev/null 2>&1; then
      devour soffice "${FILEPATH}"
    else
      t_handle_office_docs
      return
    fi
  else
    t_handle_office_docs
    return
  fi
  exit 0
}

t_handle_html() {
  if command -v w3m >/dev/null 2>&1; then
    w3m "${FILEPATH}"
  elif command -v lynx >/dev/null 2>&1; then
    lynx "${FILEPATH}"
  elif command -v elinks >/dev/null 2>&1; then
    elinks "${FILEPATH}"
  elif command -v bat >/dev/null 2>&1; then
    bat "${FILEPATH}"
  elif command -v "$PAGER" >/dev/null 2>&1; then
    "$PAGER" "${FILEPATH}"
  elif command -v "$EDITOR" >/dev/null 2>&1; then
    "$EDITOR" "${FILEPATH}"
  else
    return
  fi
  exit 0
}

handle_html() {
  if [ "$GUI" -ne 0 ]; then
    if command -v surf >/dev/null 2>&1; then
      devour surf "${FILEPATH}"
    elif command -v netsurf >/dev/null 2>&1; then
      devour netsurf "${FILEPATH}"
    elif command -v mupdf >/dev/null 2>&1; then
      devour mupdf "${FILEPATH}"
    else
      t_handle_html
      return
    fi
  else
    if command -v fbpdf >/dev/null 2>&1; then
      fbpdf "${FILEPATH}"
    else
      t_handle_html
      return
    fi
  fi
  exit 0
}

handle_markdown() {
  if command -v glow >/dev/null 2>&1; then
    glow -p "${FILEPATH}"
  elif command -v lowdown >/dev/null 2>&1; then
    lowdown -Tterm --term-width="$TERMINAL_COLUMNS" \
      --term-column="$TERMINAL_COLUMNS" "${FILEPATH}" | eval "$PAGER"
  elif command -v bat >/dev/null 2>&1; then
    bat "${FILEPATH}"
  elif command -v "$PAGER" >/dev/null 2>&1; then
    "$PAGER" "${FILEPATH}"
  elif command -v "$EDITOR" >/dev/null 2>&1; then
    "$EDITOR" "${FILEPATH}"
  else
    return
  fi
  exit 0
}

handle_json() {
  if command -v fx >/dev/null 2>&1; then
    fx "${FILEPATH}"
  elif command -v dasel >/dev/null 2>&1; then
    dasel --pretty --colour -f "${FILEPATH}" | eval "$PAGER"
  elif command -v jq >/dev/null 2>&1; then
    jq --color-output . "${FILEPATH}" | eval "$PAGER"
  elif command -v bat >/dev/null 2>&1; then
    bat "${FILEPATH}"
  elif command -v "$PAGER" >/dev/null 2>&1; then
    "$PAGER" "${FILEPATH}"
  elif command -v "$EDITOR" >/dev/null 2>&1; then
    "$EDITOR" "${FILEPATH}"
  elif command -v python >/dev/null 2>&1; then
    python -m json.tool -- "${FILEPATH}" | eval "$PAGER"
  else
    return
  fi
  exit 0
}

handle_yaml() {
  if command -v fx >/dev/null 2>&1; then
    fx "${FILEPATH}"
  elif command -v dasel >/dev/null 2>&1; then
    dasel --pretty --colour -f "${FILEPATH}" | eval "$PAGER"
  elif command -v yq >/dev/null 2>&1; then
    yq --color-output . "${FILEPATH}" | eval "$PAGER"
  elif command -v bat >/dev/null 2>&1; then
    bat "${FILEPATH}"
  elif command -v "$PAGER" >/dev/null 2>&1; then
    "$PAGER" "${FILEPATH}"
  elif command -v "$EDITOR" >/dev/null 2>&1; then
    "$EDITOR" "${FILEPATH}"
  else
    return
  fi
  exit 0
}

handle_data_format() {
  if command -v dasel >/dev/null 2>&1; then
    dasel --pretty --colour -f "${FILEPATH}" | eval "$PAGER"
  elif command -v jq >/dev/null 2>&1; then
    yq --color-output . "${FILEPATH}" | eval "$PAGER"
  elif command -v bat >/dev/null 2>&1; then
    bat "${FILEPATH}"
  elif command -v "$PAGER" >/dev/null 2>&1; then
    "$PAGER" "${FILEPATH}"
  elif command -v "$EDITOR" >/dev/null 2>&1; then
    "$EDITOR" "${FILEPATH}"
  else
    return
  fi
  exit 0
}

handle_bittorrent() {
  if command -v btinfo >/dev/null 2>&1; then
    btinfo "${FILEPATH}" | eval "$PAGER"
  elif command -v rtorrent >/dev/null 2>&1; then
    rtorrent "${FILEPATH}"
  elif command -v transmission-show >/dev/null 2>&1; then
    transmission-show -- "${FILEPATH}"
  else
    return
  fi
  exit 0
}

handle_extension() {
  case "${EXTENSION}" in

  a | ar | ace | alz | arc | arj | bz | bz2 | bz3 | cab | cpio | deb | udeb | \
    gz | jar | tha | lz | lzh | lha | lzma | lzo | rpm | rz | t7z | tar | tbz | \
    tbz2 | tbz3 | tgz | tlz | txz | tZ | tzo | war | xpi | xz | Z | zip | zipx)
    handle_archive
    exit 1
    ;;

  7z)
    handle_7zip
    exit 1
    ;;

  rar)
    handle_rar
    exit 1
    ;;

  bmp | jpg | jpeg | png | tif | tiff | gif | ico | webp | xpm)
    handle_image
    exit 1
    ;;

  svg)
    handle_svg
    exit 1
    ;;

  djvu | djv)
    handle_djvu
    exit 1
    ;;

  pdf)
    handle_pdf
    exit 1
    ;;

  epub)
    handle_epub
    exit 1
    ;;

  oxps | xps)
    handle_xps
    exit 1
    ;;

  cbt | cbz | cbr | cb7)
    handle_comic_book
    exit 1
    ;;

  mobi | azw3 | kfx)
    handle_mobi
    exit 1
    ;;

  fb2)
    handle_fictionbook
    exit 1
    ;;

  ps)
    handle_postscript
    exit 1
    ;;

  aac | flac | m4a | mid | midi | mpa | mp2 | mp3 | ogg | wav | wma | aiff | \
    alac | pcm)
    handle_audio
    exit 1
    ;;

  avi | flv | webm | wma | wmw | m2v | m4a | m4v | mkv | mov | mp4 | mpeg | \
    mpg | ogv)
    handle_video
    exit 1
    ;;

  ## Log files
  log)
    "$EDITOR" "${FILEPATH}"
    exit 0
    ;;

  ## Office documents
  odt | sxw | doc | docx | xls | xlsx | odp | ods | pptx | odg)
    handle_office_docs
    exit 1
    ;;

  md | mkd | markdown)
    handle_markdown
    exit 1
    ;;

  htm | html | xhtml | shtml | xht)
    handle_html
    exit 1
    ;;

  json)
    handle_json
    exit 1
    ;;

  yaml | yml)
    handle_yaml
    exit 1
    ;;

  toml | xml | xbl | xsd | rng | csv)
    handle_data_format
    exit 1
    ;;

  torrent)
    handle_bittorrent
    exit 1
    ;;

  esac
}

handle_mime() {
  mimetype="${1}"
  case "${mimetype}" in

  application/x-archive | application/x-ace | application/x-alz | \
    application/x-arj | application/x-bzip* | application/vnd.ms-cab-compressed | \
    application/x-cpio* | application/vnd.debian.binary-package | \
    application/gzip | application/java-archive | application/x-lzip | \
    application/x-lha | application/x-lzma | application/x-lzop | \
    application/x-rpm | application/x-tar | application/x-compressed-tar | \
    application/x-lzma-compressed-tar | application/x-xz-compressed-tar | \
    application/x-tzo | application/x-xpinstall | application/x-xz | \
    application/x-compress | application/zip)
    handle_archive
    exit 1
    ;;

  application/x-7z-compressed)
    handle_7z
    exit 1
    ;;

  application/vnd.rar)
    handle_rar
    exit 1
    ;;

  image/vnd.djvu*)
    handle_djvu
    exit 1
    ;;

  image/svg+xml)
    handle_svg
    exit 1
    ;;

  image/*)
    handle_image
    exit 1
    ;;

  application/pdf)
    handle_pdf
    exit 1
    ;;

  application/epub+zip)
    handle_epub
    exit 1
    ;;
  application/oxps | application/xps)
    handle_xps
    exit 1
    ;;

  application/x-cb* | appication/vnd.comicbook*)
    handle_comic_book
    exit 1
    ;;

  application/x-mobipocket-ebook | application/vnd.amazon.mobi8-ebook)
    handle_mobi
    exit 1
    ;;

  application/x-fictionbook+html)
    handle_fictionbook
    exit 1
    ;;

  application/postscript)
    handle_postscript
    exit 1
    ;;

  audio/*)
    handle_audio
    exit 1
    ;;

  ## Video
  video/*)
    handle_video
    exit 1
    ;;

  application/vnd.oasis.opendocument.* | application/vnd.sun.xml.writer | \
    application/vnd.openxmlformats-officedocument.*)
    handle_office_docs
    exit 1
    ;;

  ## Manpages
  text/troff)
    man -l "${FILEPATH}"
    exit 0
    ;;

  text/markdown)
    handle_markdown
    exit 1
    ;;

  text/html | application/xhtml+xml)
    handle_html
    exit 1
    ;;

  application/json*)
    handle_json
    exit 1
    ;;

  application/yaml)
    handle_yaml
    exit 1
    ;;

  application/toml | */xml | text/csv*)
    handle_data_format
    exit 1
    ;;

  ## Text
  text/*)
    "$EDITOR" "${FILEPATH}"
    exit 0
    ;;

  application/x-bittorrent)
    handle_bittorrent
    exit 1
    ;;

  esac
}

handle_fallback() {
  if [ "$GUI" -ne 0 ]; then
    if command -v xdg-open >/dev/null 2>&1; then
      nohup xdg-open "${FILEPATH}"
      exit 0
    elif command -v open >/dev/null 2>&1; then
      nohup open "${FILEPATH}"
      exit 0
    fi
  fi

  echo '----- File details -----' && file --dereference --brief -- "${FILEPATH}"
  exit 1
}

handle_blocked() {
  case "${MIMETYPE}" in
  application/x-sharedlib)
    exit 0
    ;;

  application/x-shared-library-la)
    exit 0
    ;;

  application/x-executable)
    exit 0
    ;;

  application/x-shellscript)
    exit 0
    ;;

  application/octet-stream)
    exit 0
    ;;
  esac
}

handle_bin() {
  case "${MIMETYPE}" in
  application/x-executable | application/x-shellscript)
    clear
    echo '-------- Executable File --------' && file --dereference --brief -- "${FILEPATH}"
    printf "Run executable (y/N/'a'rgs)? "
    read -r answer
    case "$answer" in
    [Yy]*) exec "${FILEPATH}" ;;
    [Aa]*)
      printf "args: "
      read -r args
      exec "${FILEPATH}" "$args"
      ;;
    [Nn]*) exit ;;
    esac
    ;;
  esac
}

handle_extension
MIMETYPE="$(file -bL --mime-type -- "${FILEPATH}")"
handle_mime "${MIMETYPE}"
[ "$BIN" -ne 0 ] && [ -x "${FILEPATH}" ] && handle_bin
handle_blocked "${MIMETYPE}"
handle_fallback

# shellcheck disable=SC2317
exit 1
