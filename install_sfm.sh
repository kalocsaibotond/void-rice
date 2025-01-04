#!/bin/sh

if [ "$1" ]; then
  export GIT_SSL_NO_VERIFY=true
  env_vars='--preserve-env=GIT_SSL_NO_VERIFY'
else
  env_vars=''
fi

printf "\nInstalling sfm\n\n"
sudo $env_vars git clone https://github.com/afify/sfm.git
cd sfm || return 1
sudo git checkout -b my_sfm || return 1

printf "\nFetch local autojump patch:\n\n"
sudo mkdir patches
cd patches
sudo cp ../../local_patches/sfm/autojump/sfm-autojump-20250104-db66dd0.diff .
cd ..

printf "\nApplying local autojump patch:\n\n"
sudo git apply patches/sfm-autojump-20250104-db66dd0.diff

printf "\nConfiguring sfm\n\n"
sudo cp config.def.h config.h

echo 'set number
/software
+
.,/extensions/- change
static const char *image_viewer[] = {
	"sh", "-c",
	"if [ -n \\"$DISPLAY\\" ]; then\\n"
	"  devour sxiv $0\\n"
	"else\\n"
	"  fim $0\\n"
	"fi"
};
static const char *document_viewer[] = {
	"sh", "-c",
	"if [ -n \\"$DISPLAY\\" ]; then\\n"
	"  devour mupdf $0\\n"
	"else\\n"
	"  fbpdf $0\\n"
	"fi"
};
static const char *video_viewer[] = {
	"sh", "-c",
	"if [ -n \\"$DISPLAY\\" ]; then\\n"
	"  devour mpv $0\\n"
	"else\\n"
	"  mpv --vo=drm $0\\n"
	"fi"
};
static const char *libreoffice[] = { "devour", "libreoffice" };
static const char *gimp[] = { "devour", "gimp" };

.
/extensions
+
.,/rules\[\] =/- change
static const char *images[] =           {
	"bmp", "jpg", "jpeg", "png", "tif", "tiff", "gif", "webp", "xpm"
};
static const char *documents[] =        {
	"pdf", "epub", "xps", "cbz", "mobi", "fb2", "svg"
};
static const char *videos[] =           {
	"avi", "flv", "webm", "wma", "wmw", "m2v", "m4a", "m4v", "mkv",
	"mov", "mp4", "mpeg", "mpg", "ogv",
	"wav", "mp3", "flac", "aac", "ogg", "aiff", "wma", "alac", "pcm"
};
static const char *office_documents[] = {
	"odt", "doc", "docx", "xls", "xlsx", "odp", "ods", "pptx", "odg"
};
static const char *gimp_files[] =       { "xcf" };

.
/rules\[\] =
+
.,/};/- change
	RULE(images,           image_viewer,    Wait),
	RULE(documents,        document_viewer, Wait),
	RULE(videos,           video_viewer,    Wait),
	RULE(office_documents, libreoffice,     Wait),
	RULE(gimp_files,       gimp,            Wait),
.
xit' | sudo ex config.h

sudo git add -A
sudo git commit -m "feat: setup my base sfm version"
sudo make
sudo make install
