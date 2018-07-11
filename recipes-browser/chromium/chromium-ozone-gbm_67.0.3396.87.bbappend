PACKAGECONFIG[proprietary-codecs] = ' \
        ffmpeg_branding="Chrome" proprietary_codecs=true, \
'


# Run content_shell after booting up.
inherit update-rc.d systemd

INITSCRIPT_NAME = "content_shell-service"
INITSCRIPT_PARAMS = "start 06 5 2 3 . stop 22 0 1 6 ."

SYSTEMD_SERVICE_${PN} = "content_shell.service"

do_compile() {
    echo "build content_shell"
    ninja -v ${PARALLEL_MAKE} content_shell ozone_demo
}

do_install() {
	install -d ${D}${bindir}
	install -d ${D}${libdir}/chromium
	install -d ${D}${libdir}/chromium/locales

	install -m 0755 content_shell ${D}${libdir}/chromium/
	install -m 0755 ozone_demo ${D}${libdir}/chromium/
	install -m 0644 libminigbm.so ${D}${libdir}/chromium/
	install -m 0644 *.bin ${D}${libdir}/chromium/
	install -m 0644 icudtl.dat ${D}${libdir}/chromium/

	# content_shell *.pak files
	install -m 0644 content_shell.pak ${D}${libdir}/chromium/
	install -m 0644 shell_resources.pak ${D}${libdir}/chromium/

	if [ -n "${@bb.utils.contains('PACKAGECONFIG', 'component-build', 'component-build', '', d)}" ]; then
		install -m 0755 *.so ${D}${libdir}/chromium/
	fi

	# Swiftshader is only built for x86 and x86-64.
	if [ -d "swiftshader" ]; then
		install -d ${D}${libdir}/chromium/swiftshader
		install -m 0644 swiftshader/libEGL.so ${D}${libdir}/chromium/swiftshader/
		install -m 0644 swiftshader/libGLESv2.so ${D}${libdir}/chromium/swiftshader/
	fi

    # Create a shell script to run content_shell with runtime flags.
    echo "#!/bin/bash" > content_shell.sh 
    echo "EGL_PLATFORM=surfaceless ${libdir}/chromium/content_shell --no-sandbox --ozone-platform=gbm --enable-accelerated-video --proxy-auto-detect $1" >> content_shell.sh
	install -m 0755 content_shell.sh ${D}${bindir}/

    # run content_shell after booting up.
    if ${@bb.utils.contains('DISTRO_FEATURES','sysvinit','true','false',d)}; then
        install -d ${D}${sysconfdir}/init.d
        install -m 0755 ${WORKDIR}/init ${D}${sysconfdir}/init.d/content_shell-service
    else
        install -d ${D}${systemd_unitdir}/system
        install -m 0644 ${WORKDIR}/content_shell.service ${D}${systemd_unitdir}/system
    fi
}

FILES_${PN} = " \
        ${bindir}/chromium \
        ${libdir}/chromium/* \
        ${bindir} \
        ${bindir}/content_shell.sh \
        ${sysconfdir}/init.d/content_shell-service \
"

PACKAGE_DEBUG_SPLIT_STYLE = "debug-without-src"

# There is no need to ship empty -dev packages.
ALLOW_EMPTY_${PN}-dev = "0"

