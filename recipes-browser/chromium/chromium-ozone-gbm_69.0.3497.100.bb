require chromium-upstream-tarball.inc
require chromium-gn.inc

SRC_URI += " \
 file://0001-Allow-DisplayManager-and-DisplayConfigurator-to-be-b.patch \
 file://0002-Make-content_shell-works-with-ozone-gbm.patch \
 file://0003-Add-support-for-mouse-cursor.patch \
 file://0004-Enable-zero-copy-texture-uplad-using-dmabuf.patch \
 file://0005-Add-support-for-video-acceleration.patch \
 file://0006-Allow-to-build-content_shell-with-Yocto.patch \
 file://0007-Make-content-full-screen.patch \
 file://0008-Build-fix.patch \
 file://0009-RELAND-vaapi-decode-on-client-NativePixmaps.patch \
 file://0010-add-mojo-layouttest-test.patch \
 file://init \
 file://content_shell.service \
"
DEPENDS += "\
        virtual/egl \
        libva \
"

GN_ARGS += "\
        use_ozone=true \
        ozone_auto_platforms=false \
        ozone_platform_headless=false \
        ozone_platform_wayland=false \
        ozone_platform_x11=false \
        ozone_platform_gbm=true \
        enable_gtk=false \
        toolkit_views = false \
        enable_nacl = false \
        build_display_configuration = true \
        use_intel_minigbm = true \
        use_vaapi = true \
"

# VA support
GN_ARGS += 'ffmpeg_branding="Chrome"'
GN_ARGS += "proprietary_codecs=true"
GN_ARGS += "use_v4l2_codec = false"
GN_ARGS += "enable_media_codec_video_decoder = true"

# The chromium binary must always be started with those arguments.
CHROMIUM_EXTRA_ARGS_append = " --ozone-platform=gbm"
BB_STRICT_CHECKSUM = "0"
