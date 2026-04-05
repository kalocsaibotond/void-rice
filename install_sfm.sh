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

printf "\nFetch local patches:\n\n"
sudo mkdir patches
cd patches
sudo cp ../../local_patches/sfm/autojump/sfm-autojump-20250104-db66dd0.diff .
sudo cp ../../local_patches/sfm/smartmoves/sfm-smartmoves-20250726-f1f1197.diff .
cd ..

printf "\nApplying patches\n\n"
printf "\nApplying local smartmoves patch:\n\n"
sudo git apply patches/sfm-smartmoves-20250726-f1f1197.diff
printf "\nApplying local autojump patch:\n\n"
sudo patch -p1 <patches/sfm-autojump-20250104-db66dd0.diff

printf "\nConfiguring sfm\n\n"
sudo cp config.def.h config.h

echo 'set number
/software
+
.,/extensions/- change
static const char *archive_viewer[] =    {
	"sh", "-c",
	"tar --list --file $0 | $PAGER"
};
static const char *seven_zip_viewer[] =  {
	"sh", "-c",
	"7z l -p -- $0  | $PAGER"
};
static const char *rar_viewer[] =        {
	"sh", "-c",
	"7z l -p -- $0   | $PAGER"
};
static const char *image_viewer[] =      {
	"sh", "-c",
	"if [ -n \\"$DISPLAY\\" ]; then\\n"
	"  devour sxiv $0\\n"
	"else\\n"
	"  fim $0\\n"
	"fi"
};
static const char *gimp[] =              { "devour", "gimp" };
static const char *svg_viewer[] =        {
	"sh", "-c",
	"if [ -n \\"$DISPLAY\\" ]; then\\n"
	"  devour sxiv $0\\n"
	"else\\n"
	"  fbpdf $0\\n"
	"fi"
};
static const char *djvu_viewer[] =       {
	"sh", "-c",
	"if [ -n \\"$DISPLAY\\" ]; then\\n"
	"  devour zathura $0\\n"
	"else\\n"
	"  fbdjvu $0\\n"
	"fi"
};
static const char *document_viewer[] =   {
	"sh", "-c",
	"if [ -n \\"$DISPLAY\\" ]; then\\n"
	"  devour mupdf $0\\n"
	"else\\n"
	"  fbpdf $0\\n"
	"fi"
};
static const char *postscript_viewer[] = { "devour", "zathura" };
static const char *video_viewer[] = {
	"sh", "-c",
	"if [ -n \\"$DISPLAY\\" ]; then\\n"
	"  devour mpv $0\\n"
	"else\\n"
	"  mpv --vo=drm $0\\n"
	"fi"
};
static const char *libreoffice[] =       { "devour", "soffice" };
static const char *webpage_viewer[] =    {
	"sh", "-c",
	"if [ -n \\"$DISPLAY\\" ]; then\\n"
	"  devour surf $0\\n"
	"else\\n"
	"  fbpdf $0\\n"
	"fi"
};

.
/extensions
+
.,/rules\[\] =/- change
static const char *archives[] =         {
	"a", "ar", "ace", "alz", "arc", "arj", "bz", "bz2", "bz3", "cab", "cpio",
  "deb", "udeb", "xbps", "gz", "jar", "tha", "lz", "lzh", "lha", "lzma", "lzo",
	"rpm", "rz", "t7z", "tar", "tbz", "tbz2", "tbz3", "tgz", "tlz", "txz", "tZ",
	"tzo", "war", "xpi", "xz", "Z", "zip", "zipx"
};
static const char *seven_zip[] =        { "7z" };
static const char *rar[] =              { "rar" };
static const char *images[] =           {
	"bmp", "jpg", "jpeg", "png", "tif", "tiff", "gif", "webp", "xpm"
};
static const char *gimp_files[] =       { "xcf" };
static const char *svg[] =              { "svg" };
static const char *djvu[] =             { "djvu", "djv" };
static const char *documents[] =        {
	"pdf", "epub", "oxps", "xps", "cbt", "cbz", "cbr", "cb7", "mobi", "azw3",
	"kfx", "fb2"
};
static const char *postscript[] =       { "ps" };
static const char *videos[] =           {
	"avi", "flv", "webm", "wma", "wmw", "m2v", "m4a", "m4v", "mkv",
	"mov", "mp4", "mpeg", "mpg", "ogv",
	"wav", "mp3", "flac", "aac", "ogg", "aiff", "wma", "alac", "pcm"
};
static const char *office_documents[] = {
	"odt", "sxw", "doc", "docx", "xls", "xlsx", "odp", "ods", "pptx", "odg"
};
static const char *webpages[] =         {
	"htm", "html", "xhtml", "shtml", "xht"
};

.
/rules\[\] =
+
.,/};/- change
	RULE(archives,         archive_viewer,    Wait),
	RULE(seven_zip,        seven_zip_viewer,  Wait),
	RULE(rar,              rar_viewer,        Wait),
	RULE(images,           image_viewer,      Wait),
	RULE(gimp_files,       gimp,              Wait),
	RULE(svg,              svg_viewer,        Wait),
	RULE(djvu,             djvu_viewer,       Wait),
	RULE(documents,        document_viewer,   Wait),
	RULE(postscript,       postscript_viewer, Wait),
	RULE(videos,           video_viewer,      Wait),
	RULE(office_documents, libreoffice,       Wait),
	RULE(webpages,         webpage_viewer,    Wait),
.
xit' | sudo ex config.h

sudo git add -A
sudo git commit -m "feat: setup my base sfm version"
sudo make
sudo make install
