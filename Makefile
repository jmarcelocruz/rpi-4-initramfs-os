TOPDIR = ${PWD}
BUILDDIR = build
SCRIPTSDIR = scripts

ARCH = arm64
CROSS_COMPILE = aarch64-none-linux-gnu-

all: ${BUILDDIR}/vmlinuz-6.8.8-arm64 ${BUILDDIR}/bcm2711-rpi-4-b.dtb ${BUILDDIR}/initramfs.cpio.gz

${BUILDDIR}/vmlinuz-6.8.8-arm64: ${BUILDDIR}/linux/arch/${ARCH}/boot/Image.gz
	ln -f $^ $@

${BUILDDIR}/bcm2711-rpi-4-b.dtb: ${BUILDDIR}/linux/arch/${ARCH}/boot/dts/broadcom/bcm2711-rpi-4-b.dtb
	ln -f $^ $@

${BUILDDIR}/initramfs.cpio.gz: ${BUILDDIR}/busybox/busybox ${BUILDDIR}/linux/arch/${ARCH}/boot/dts/broadcom/bcm2711-rpi-4-b.dtb init
	@mkdir -p ${BUILDDIR}/initramfs
	./${SCRIPTSDIR}/make-fhs-layout.sh ${BUILDDIR}/initramfs
	${MAKE} -C external/busybox CROSS_COMPILE=${CROSS_COMPILE} O=${TOPDIR}/${BUILDDIR}/busybox CONFIG_PREFIX=${TOPDIR}/${BUILDDIR}/initramfs install
	cp -a init ${BUILDDIR}/initramfs
	fakeroot /bin/bash -c "(cd ${BUILDDIR}/initramfs; find . | cpio -o -H newc | gzip) > $@"

${BUILDDIR}/busybox/busybox: ${BUILDDIR}/busybox/.config
	${MAKE} -C external/busybox CROSS_COMPILE=${CROSS_COMPILE} O=${TOPDIR}/${BUILDDIR}/busybox oldconfig
	${MAKE} -C external/busybox CROSS_COMPILE=${CROSS_COMPILE} O=${TOPDIR}/${BUILDDIR}/busybox

${BUILDDIR}/linux/arch/${ARCH}/boot/Image.gz ${BUILDDIR}/linux/arch/${ARCH}/boot/dts/broadcom/bcm2711-rpi-4-b.dtb &: ${BUILDDIR}/linux/.config
	${MAKE} -C external/linux ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} O=${TOPDIR}/${BUILDDIR}/linux oldconfig
	${MAKE} -C external/linux ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} O=${TOPDIR}/${BUILDDIR}/linux Image.gz dtbs

${BUILDDIR}/busybox/.config: busybox.config
	@mkdir -p $$(dirname $@)
	ln -f $^ $@

${BUILDDIR}/linux/.config: linux.config
	@mkdir -p $$(dirname $@)
	ln -f $^ $@

.PHONY: clean
clean:
	rm -rf ${BUILDDIR}
