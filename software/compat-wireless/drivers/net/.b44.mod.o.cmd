cmd_/test_ap/software/compat-wireless/drivers/net/b44.mod.o := gcc -Wp,-MD,/test_ap/software/compat-wireless/drivers/net/.b44.mod.o.d -I/test_ap/software/compat-wireless/include/ -include /test_ap/software/compat-wireless/include/net/compat.h  -Iinclude  -I/test_ap/software/linux-2.6.32.16/arch/x86/include -include include/linux/autoconf.h -D__KERNEL__ -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -fno-delete-null-pointer-checks -Os -m32 -msoft-float -mregparm=3 -freg-struct-return -mpreferred-stack-boundary=2 -march=i686 -mtune=generic -Wa,-mtune=generic32 -ffreestanding -fstack-protector -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1 -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -Wframe-larger-than=1024 -fomit-frame-pointer -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fno-dwarf2-cfi-asm -fconserve-stack  -D"KBUILD_STR(s)=\#s" -D"KBUILD_BASENAME=KBUILD_STR(b44.mod)"  -D"KBUILD_MODNAME=KBUILD_STR(b44)"  -DMODULE -c -o /test_ap/software/compat-wireless/drivers/net/b44.mod.o /test_ap/software/compat-wireless/drivers/net/b44.mod.c

deps_/test_ap/software/compat-wireless/drivers/net/b44.mod.o := \
  /test_ap/software/compat-wireless/drivers/net/b44.mod.c \
    $(wildcard include/config/module/unload.h) \
  /test_ap/software/compat-wireless/include/net/compat.h \
  include/linux/version.h \
  /test_ap/software/compat-wireless/include/linux/compat_autoconf.h \
    $(wildcard include/config/wireless/ext.h) \
    $(wildcard include/config/mac80211.h) \
    $(wildcard include/config/mac80211/debugfs.h) \
    $(wildcard include/config/mac80211/rc/default.h) \
    $(wildcard include/config/mac80211/rc/default/minstrel.h) \
    $(wildcard include/config/compat/mac80211/rc/default.h) \
    $(wildcard include/config/mac80211/rc/pid.h) \
    $(wildcard include/config/mac80211/rc/minstrel.h) \
    $(wildcard include/config/mac80211/leds.h) \
    $(wildcard include/config/mac80211/mesh.h) \
    $(wildcard include/config/cfg80211.h) \
    $(wildcard include/config/cfg80211/default/ps.h) \
    $(wildcard include/config/cfg80211/default/ps/value.h) \
    $(wildcard include/config/lib80211.h) \
    $(wildcard include/config/lib80211/crypt/wep.h) \
    $(wildcard include/config/lib80211/crypt/ccmp.h) \
    $(wildcard include/config/lib80211/crypt/tkip.h) \
    $(wildcard include/config/wireless/old/regulatory.h) \
    $(wildcard include/config/mac80211/hwsim.h) \
    $(wildcard include/config/ath5k.h) \
    $(wildcard include/config/ath5k/rfkill.h) \
    $(wildcard include/config/ath9k.h) \
    $(wildcard include/config/iwlwifi.h) \
    $(wildcard include/config/iwlwifi/leds.h) \
    $(wildcard include/config/iwlwifi/rfkill.h) \
    $(wildcard include/config/iwlwifi/spectrum/measurement.h) \
    $(wildcard include/config/iwlagn.h) \
    $(wildcard include/config/compat/iwl4965.h) \
    $(wildcard include/config/iwl5000.h) \
    $(wildcard include/config/iwl3945.h) \
    $(wildcard include/config/iwl3945/spectrum/measurement.h) \
    $(wildcard include/config/b43.h) \
    $(wildcard include/config/b43/hwrng.h) \
    $(wildcard include/config/b43/pci/autoselect.h) \
    $(wildcard include/config/b43/pcicore/autoselect.h) \
    $(wildcard include/config/b43/pcmcia.h) \
    $(wildcard include/config/b43/pio.h) \
    $(wildcard include/config/b43/leds.h) \
    $(wildcard include/config/b43/rfkill.h) \
    $(wildcard include/config/b43/phy/lp.h) \
    $(wildcard include/config/b43/debug.h) \
    $(wildcard include/config/b43legacy.h) \
    $(wildcard include/config/b43legacy/hwrng.h) \
    $(wildcard include/config/b43legacy/pci/autoselect.h) \
    $(wildcard include/config/b43legacy/pcicore/autoselect.h) \
    $(wildcard include/config/b43legacy/leds.h) \
    $(wildcard include/config/b43legacy/rfkill.h) \
    $(wildcard include/config/b43legacy/debug.h) \
    $(wildcard include/config/b43legacy/dma.h) \
    $(wildcard include/config/b43legacy/pio.h) \
    $(wildcard include/config/b43legacy/dma/and/pio/mode.h) \
    $(wildcard include/config/libipw.h) \
    $(wildcard include/config/ipw2100.h) \
    $(wildcard include/config/ipw2100/monitor.h) \
    $(wildcard include/config/ipw2200.h) \
    $(wildcard include/config/ipw2200/monitor.h) \
    $(wildcard include/config/ipw2200/radiotap.h) \
    $(wildcard include/config/ipw2200/promiscuous.h) \
    $(wildcard include/config/ipw2200/qos.h) \
    $(wildcard include/config/ssb/blockio.h) \
    $(wildcard include/config/ssb/pcihost/possible.h) \
    $(wildcard include/config/ssb/pcihost.h) \
    $(wildcard include/config/ssb/b43/pci/bridge.h) \
    $(wildcard include/config/ssb/pcmciahost/possible.h) \
    $(wildcard include/config/ssb/pcmciahost.h) \
    $(wildcard include/config/ssb/driver/pcicore/possible.h) \
    $(wildcard include/config/ssb/driver/pcicore.h) \
    $(wildcard include/config/p54/pci.h) \
    $(wildcard include/config/b44.h) \
    $(wildcard include/config/b44/pci/autoselect.h) \
    $(wildcard include/config/b44/pcicore/autoselect.h) \
    $(wildcard include/config/b44/pci.h) \
    $(wildcard include/config/rtl8180.h) \
    $(wildcard include/config/adm8211.h) \
    $(wildcard include/config/pcmcia/atmel.h) \
    $(wildcard include/config/rt2x00/lib/pci.h) \
    $(wildcard include/config/rt2400pci.h) \
    $(wildcard include/config/rt2500pci.h) \
    $(wildcard include/config/rt2800pci.h) \
    $(wildcard include/config/rt61pci.h) \
    $(wildcard include/config/atmel.h) \
    $(wildcard include/config/pci/atmel.h) \
    $(wildcard include/config/mwl8k.h) \
    $(wildcard include/config/libertas.h) \
    $(wildcard include/config/libertas/cs.h) \
    $(wildcard include/config/eeprom/93cx6.h) \
    $(wildcard include/config/zd1211rw.h) \
    $(wildcard include/config/usb/net/cdcether.h) \
    $(wildcard include/config/usb/net/rndis/host.h) \
    $(wildcard include/config/usb/net/rndis/wlan.h) \
    $(wildcard include/config/p54/usb.h) \
    $(wildcard include/config/rtl8187.h) \
    $(wildcard include/config/at76c50x/usb.h) \
    $(wildcard include/config/ar9170/usb.h) \
    $(wildcard include/config/ar9170/leds.h) \
    $(wildcard include/config/rt2500usb.h) \
    $(wildcard include/config/rt2800usb.h) \
    $(wildcard include/config/rt2x00/lib/usb.h) \
    $(wildcard include/config/rt73usb.h) \
    $(wildcard include/config/libertas/thinfirm/usb.h) \
    $(wildcard include/config/libertas/usb.h) \
    $(wildcard include/config/wl1251.h) \
    $(wildcard include/config/p54/spi.h) \
    $(wildcard include/config/libertas/spi.h) \
    $(wildcard include/config/libertas/sdio.h) \
    $(wildcard include/config/iwm.h) \
    $(wildcard include/config/rt2x00.h) \
    $(wildcard include/config/rt2x00/lib.h) \
    $(wildcard include/config/rt2x00/lib/ht.h) \
    $(wildcard include/config/rt2x00/lib/firmware.h) \
    $(wildcard include/config/rt2x00/lib/crypto.h) \
    $(wildcard include/config/rt2x00/lib/rfkill.h) \
    $(wildcard include/config/rt2x00/lib/leds.h) \
    $(wildcard include/config/p54/common.h) \
    $(wildcard include/config/p54/leds.h) \
    $(wildcard include/config/ath/common.h) \
    $(wildcard include/config/wl12xx.h) \
    $(wildcard include/config/wl1251/spi.h) \
    $(wildcard include/config/wl1251/sdio.h) \
    $(wildcard include/config/wl1271.h) \
    $(wildcard include/config/ssb/possible.h) \
    $(wildcard include/config/ssb.h) \
    $(wildcard include/config/ssb/sprom.h) \
    $(wildcard include/config/libertas/thinfirm.h) \
    $(wildcard include/config/rfkill/backport.h) \
    $(wildcard include/config/rfkill/backport/leds.h) \
    $(wildcard include/config/rfkill/backport/input.h) \
    $(wildcard include/config/net/sched.h) \
    $(wildcard include/config/netdevices/multiqueue.h) \
    $(wildcard include/config/mac80211/qos.h) \
  /test_ap/software/compat-wireless/include/net/compat-2.6.22.h \
    $(wildcard include/config/ax25.h) \
  /test_ap/software/compat-wireless/include/net/compat-2.6.23.h \
    $(wildcard include/config/pm/sleep.h) \
  /test_ap/software/compat-wireless/include/net/compat-2.6.24.h \
    $(wildcard include/config/net.h) \
    $(wildcard include/config/debug/sg.h) \
  /test_ap/software/compat-wireless/include/net/compat-2.6.25.h \
  /test_ap/software/compat-wireless/include/net/compat-2.6.26.h \
    $(wildcard include/config/net/ns.h) \
    $(wildcard include/config/alpha.h) \
    $(wildcard include/config/arm.h) \
    $(wildcard include/config/avr32.h) \
    $(wildcard include/config/blackfin.h) \
    $(wildcard include/config/cris.h) \
    $(wildcard include/config/frv.h) \
    $(wildcard include/config/h8300.h) \
    $(wildcard include/config/ia64.h) \
    $(wildcard include/config/m32r.h) \
    $(wildcard include/config/m68k.h) \
    $(wildcard include/config/coldfire.h) \
    $(wildcard include/config/mips.h) \
    $(wildcard include/config/mn10300.h) \
    $(wildcard include/config/parisc.h) \
    $(wildcard include/config/ppc.h) \
    $(wildcard include/config/s390.h) \
    $(wildcard include/config/superh.h) \
    $(wildcard include/config/sparc.h) \
    $(wildcard include/config/uml.h) \
    $(wildcard include/config/v850.h) \
    $(wildcard include/config/x86.h) \
    $(wildcard include/config/xtensa.h) \
  /test_ap/software/compat-wireless/include/net/compat-2.6.27.h \
    $(wildcard include/config/compat.h) \
  /test_ap/software/compat-wireless/include/net/compat-2.6.28.h \
  /test_ap/software/compat-wireless/include/net/compat-2.6.29.h \
  /test_ap/software/compat-wireless/include/net/compat-2.6.30.h \
  /test_ap/software/compat-wireless/include/net/compat-2.6.31.h \
  /test_ap/software/compat-wireless/include/net/compat-2.6.32.h \
  include/linux/module.h \
    $(wildcard include/config/modules.h) \
    $(wildcard include/config/modversions.h) \
    $(wildcard include/config/unused/symbols.h) \
    $(wildcard include/config/generic/bug.h) \
    $(wildcard include/config/kallsyms.h) \
    $(wildcard include/config/tracepoints.h) \
    $(wildcard include/config/tracing.h) \
    $(wildcard include/config/event/tracing.h) \
    $(wildcard include/config/ftrace/mcount/record.h) \
    $(wildcard include/config/smp.h) \
    $(wildcard include/config/constructors.h) \
    $(wildcard include/config/sysfs.h) \
  include/linux/list.h \
    $(wildcard include/config/debug/list.h) \
  include/linux/stddef.h \
  include/linux/compiler.h \
    $(wildcard include/config/trace/branch/profiling.h) \
    $(wildcard include/config/profile/all/branches.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/enable/warn/deprecated.h) \
  include/linux/compiler-gcc.h \
    $(wildcard include/config/arch/supports/optimized/inlining.h) \
    $(wildcard include/config/optimize/inlining.h) \
  include/linux/compiler-gcc4.h \
  include/linux/poison.h \
    $(wildcard include/config/illegal/pointer/value.h) \
  include/linux/prefetch.h \
  include/linux/types.h \
    $(wildcard include/config/uid16.h) \
    $(wildcard include/config/lbdaf.h) \
    $(wildcard include/config/phys/addr/t/64bit.h) \
    $(wildcard include/config/64bit.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/types.h \
    $(wildcard include/config/x86/64.h) \
    $(wildcard include/config/highmem64g.h) \
  include/asm-generic/types.h \
  include/asm-generic/int-ll64.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/bitsperlong.h \
  include/asm-generic/bitsperlong.h \
  include/linux/posix_types.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/posix_types.h \
    $(wildcard include/config/x86/32.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/posix_types_32.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/processor.h \
    $(wildcard include/config/x86/vsmp.h) \
    $(wildcard include/config/cc/stackprotector.h) \
    $(wildcard include/config/paravirt.h) \
    $(wildcard include/config/m386.h) \
    $(wildcard include/config/m486.h) \
    $(wildcard include/config/x86/debugctlmsr.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/processor-flags.h \
    $(wildcard include/config/vm86.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/vm86.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/ptrace.h \
    $(wildcard include/config/x86/ptrace/bts.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/ptrace-abi.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/segment.h \
  include/linux/init.h \
    $(wildcard include/config/hotplug.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/math_emu.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/sigcontext.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/current.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/percpu.h \
    $(wildcard include/config/x86/64/smp.h) \
  include/linux/kernel.h \
    $(wildcard include/config/preempt/voluntary.h) \
    $(wildcard include/config/debug/spinlock/sleep.h) \
    $(wildcard include/config/prove/locking.h) \
    $(wildcard include/config/printk.h) \
    $(wildcard include/config/dynamic/debug.h) \
    $(wildcard include/config/ring/buffer.h) \
    $(wildcard include/config/numa.h) \
  /usr/lib/gcc/i486-linux-gnu/4.4.5/include/stdarg.h \
  include/linux/linkage.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/linkage.h \
    $(wildcard include/config/x86/alignment/16.h) \
  include/linux/stringify.h \
  /test_ap/software/compat-wireless/include/linux/bitops.h \
    $(wildcard include/config/generic/find/first/bit.h) \
    $(wildcard include/config/generic/find/last/bit.h) \
    $(wildcard include/config/generic/find/next/bit.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/bitops.h \
    $(wildcard include/config/x86/cmov.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/alternative.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/asm.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/cpufeature.h \
    $(wildcard include/config/x86/invlpg.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/required-features.h \
    $(wildcard include/config/x86/minimum/cpu/family.h) \
    $(wildcard include/config/math/emulation.h) \
    $(wildcard include/config/x86/pae.h) \
    $(wildcard include/config/x86/cmpxchg64.h) \
    $(wildcard include/config/x86/use/3dnow.h) \
    $(wildcard include/config/x86/p6/nop.h) \
  include/asm-generic/bitops/sched.h \
  include/asm-generic/bitops/hweight.h \
  include/asm-generic/bitops/fls64.h \
  include/asm-generic/bitops/ext2-non-atomic.h \
  include/asm-generic/bitops/le.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/byteorder.h \
  include/linux/byteorder/little_endian.h \
  include/linux/swab.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/swab.h \
    $(wildcard include/config/x86/bswap.h) \
  include/linux/byteorder/generic.h \
  include/asm-generic/bitops/minix.h \
  include/linux/log2.h \
    $(wildcard include/config/arch/has/ilog2/u32.h) \
    $(wildcard include/config/arch/has/ilog2/u64.h) \
  include/linux/typecheck.h \
  include/linux/ratelimit.h \
  include/linux/param.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/param.h \
  include/asm-generic/param.h \
    $(wildcard include/config/hz.h) \
  include/linux/dynamic_debug.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/bug.h \
    $(wildcard include/config/bug.h) \
    $(wildcard include/config/debug/bugverbose.h) \
  include/asm-generic/bug.h \
    $(wildcard include/config/generic/bug/relative/pointers.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/div64.h \
  include/asm-generic/percpu.h \
    $(wildcard include/config/debug/preempt.h) \
    $(wildcard include/config/have/setup/per/cpu/area.h) \
  include/linux/threads.h \
    $(wildcard include/config/nr/cpus.h) \
    $(wildcard include/config/base/small.h) \
  include/linux/percpu-defs.h \
    $(wildcard include/config/debug/force/weak/per/cpu.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/system.h \
    $(wildcard include/config/ia32/emulation.h) \
    $(wildcard include/config/x86/32/lazy/gs.h) \
    $(wildcard include/config/x86/ppro/fence.h) \
    $(wildcard include/config/x86/oostore.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/cmpxchg.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/cmpxchg_32.h \
    $(wildcard include/config/x86/cmpxchg.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/nops.h \
    $(wildcard include/config/mk7.h) \
  include/linux/irqflags.h \
    $(wildcard include/config/trace/irqflags.h) \
    $(wildcard include/config/irqsoff/tracer.h) \
    $(wildcard include/config/preempt/tracer.h) \
    $(wildcard include/config/trace/irqflags/support.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/irqflags.h \
    $(wildcard include/config/debug/lock/alloc.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/paravirt.h \
    $(wildcard include/config/highpte.h) \
    $(wildcard include/config/paravirt/spinlocks.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/pgtable_types.h \
    $(wildcard include/config/kmemcheck.h) \
    $(wildcard include/config/compat/vdso.h) \
    $(wildcard include/config/proc/fs.h) \
  include/linux/const.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/page_types.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/page_32_types.h \
    $(wildcard include/config/highmem4g.h) \
    $(wildcard include/config/page/offset.h) \
    $(wildcard include/config/4kstacks.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/pgtable_32_types.h \
    $(wildcard include/config/highmem.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/pgtable-2level_types.h \
  include/asm-generic/pgtable-nopud.h \
  include/asm-generic/pgtable-nopmd.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/paravirt_types.h \
    $(wildcard include/config/x86/local/apic.h) \
    $(wildcard include/config/paravirt/debug.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/desc_defs.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/kmap_types.h \
    $(wildcard include/config/debug/highmem.h) \
  include/asm-generic/kmap_types.h \
  include/linux/cpumask.h \
    $(wildcard include/config/cpumask/offstack.h) \
    $(wildcard include/config/hotplug/cpu.h) \
    $(wildcard include/config/debug/per/cpu/maps.h) \
    $(wildcard include/config/disable/obsolete/cpumask/functions.h) \
  include/linux/bitmap.h \
  include/linux/string.h \
    $(wildcard include/config/binary/printf.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/string.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/string_32.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/page.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/page_32.h \
    $(wildcard include/config/hugetlb/page.h) \
    $(wildcard include/config/debug/virtual.h) \
    $(wildcard include/config/flatmem.h) \
    $(wildcard include/config/x86/3dnow.h) \
  include/asm-generic/memory_model.h \
    $(wildcard include/config/discontigmem.h) \
    $(wildcard include/config/sparsemem/vmemmap.h) \
    $(wildcard include/config/sparsemem.h) \
  include/asm-generic/getorder.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/msr.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/msr-index.h \
  include/linux/ioctl.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/ioctl.h \
  include/asm-generic/ioctl.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/errno.h \
  include/asm-generic/errno.h \
  include/asm-generic/errno-base.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/cpumask.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/ds.h \
    $(wildcard include/config/x86/ds.h) \
  include/linux/err.h \
  include/linux/personality.h \
  include/linux/cache.h \
    $(wildcard include/config/arch/has/cache/line/size.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/cache.h \
    $(wildcard include/config/x86/l1/cache/shift.h) \
  include/linux/math64.h \
  include/linux/stat.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/stat.h \
  include/linux/time.h \
    $(wildcard include/config/arch/uses/gettimeoffset.h) \
  include/linux/seqlock.h \
  include/linux/spinlock.h \
    $(wildcard include/config/debug/spinlock.h) \
    $(wildcard include/config/generic/lockbreak.h) \
    $(wildcard include/config/preempt.h) \
  include/linux/preempt.h \
    $(wildcard include/config/preempt/notifiers.h) \
  include/linux/thread_info.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/thread_info.h \
    $(wildcard include/config/debug/stack/usage.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/ftrace.h \
    $(wildcard include/config/function/tracer.h) \
    $(wildcard include/config/dynamic/ftrace.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/atomic.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/atomic_32.h \
  include/asm-generic/atomic-long.h \
  include/linux/bottom_half.h \
  include/linux/spinlock_types.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/spinlock_types.h \
  include/linux/lockdep.h \
    $(wildcard include/config/lockdep.h) \
    $(wildcard include/config/lock/stat.h) \
    $(wildcard include/config/generic/hardirqs.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/spinlock.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/rwlock.h \
  include/linux/spinlock_api_smp.h \
  include/linux/kmod.h \
  include/linux/gfp.h \
    $(wildcard include/config/zone/dma.h) \
    $(wildcard include/config/zone/dma32.h) \
    $(wildcard include/config/debug/vm.h) \
  include/linux/mmzone.h \
    $(wildcard include/config/force/max/zoneorder.h) \
    $(wildcard include/config/memory/hotplug.h) \
    $(wildcard include/config/arch/populates/node/map.h) \
    $(wildcard include/config/flat/node/mem/map.h) \
    $(wildcard include/config/cgroup/mem/res/ctlr.h) \
    $(wildcard include/config/have/memory/present.h) \
    $(wildcard include/config/need/node/memmap/size.h) \
    $(wildcard include/config/need/multiple/nodes.h) \
    $(wildcard include/config/have/arch/early/pfn/to/nid.h) \
    $(wildcard include/config/sparsemem/extreme.h) \
    $(wildcard include/config/nodes/span/other/nodes.h) \
    $(wildcard include/config/holes/in/zone.h) \
    $(wildcard include/config/arch/has/holes/memorymodel.h) \
  include/linux/wait.h \
  include/linux/numa.h \
    $(wildcard include/config/nodes/shift.h) \
  include/linux/nodemask.h \
  include/linux/pageblock-flags.h \
    $(wildcard include/config/hugetlb/page/size/variable.h) \
  include/linux/bounds.h \
  include/linux/memory_hotplug.h \
    $(wildcard include/config/have/arch/nodedata/extension.h) \
    $(wildcard include/config/memory/hotremove.h) \
  include/linux/notifier.h \
  include/linux/errno.h \
  include/linux/mutex.h \
    $(wildcard include/config/debug/mutexes.h) \
  include/linux/rwsem.h \
    $(wildcard include/config/rwsem/generic/spinlock.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/rwsem.h \
  include/linux/srcu.h \
  include/linux/topology.h \
    $(wildcard include/config/sched/smt.h) \
    $(wildcard include/config/sched/mc.h) \
  include/linux/smp.h \
    $(wildcard include/config/use/generic/smp/helpers.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/smp.h \
    $(wildcard include/config/x86/io/apic.h) \
    $(wildcard include/config/x86/32/smp.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/mpspec.h \
    $(wildcard include/config/x86/numaq.h) \
    $(wildcard include/config/mca.h) \
    $(wildcard include/config/eisa.h) \
    $(wildcard include/config/x86/mpparse.h) \
    $(wildcard include/config/acpi.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/mpspec_def.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/x86_init.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/bootparam.h \
  include/linux/screen_info.h \
  include/linux/apm_bios.h \
  include/linux/edd.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/e820.h \
    $(wildcard include/config/efi.h) \
    $(wildcard include/config/hibernation.h) \
    $(wildcard include/config/memtest.h) \
  include/linux/ioport.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/ist.h \
  include/video/edid.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/apic.h \
    $(wildcard include/config/x86/x2apic.h) \
  include/linux/delay.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/delay.h \
  include/linux/pm.h \
    $(wildcard include/config/pm/runtime.h) \
  include/linux/workqueue.h \
  include/linux/timer.h \
    $(wildcard include/config/timer/stats.h) \
    $(wildcard include/config/debug/objects/timers.h) \
  include/linux/ktime.h \
    $(wildcard include/config/ktime/scalar.h) \
  include/linux/jiffies.h \
  include/linux/timex.h \
    $(wildcard include/config/no/hz.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/timex.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/tsc.h \
    $(wildcard include/config/x86/tsc.h) \
  include/linux/debugobjects.h \
    $(wildcard include/config/debug/objects.h) \
    $(wildcard include/config/debug/objects/free.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/apicdef.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/fixmap.h \
    $(wildcard include/config/provide/ohci1394/dma/init.h) \
    $(wildcard include/config/x86/visws/apic.h) \
    $(wildcard include/config/x86/f00f/bug.h) \
    $(wildcard include/config/x86/cyclone/timer.h) \
    $(wildcard include/config/pci/mmconfig.h) \
    $(wildcard include/config/intel/txt.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/acpi.h \
    $(wildcard include/config/acpi/numa.h) \
  include/acpi/pdc_intel.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/numa.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/numa_32.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/mmu.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/io_apic.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/irq_vectors.h \
    $(wildcard include/config/sparse/irq.h) \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/topology.h \
    $(wildcard include/config/x86/ht.h) \
    $(wildcard include/config/x86/64/acpi/numa.h) \
  include/asm-generic/topology.h \
  include/linux/mmdebug.h \
  include/linux/elf.h \
  include/linux/elf-em.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/elf.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/user.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/user_32.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/auxvec.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/vdso.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/desc.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/ldt.h \
  include/linux/kobject.h \
  include/linux/sysfs.h \
  include/linux/kref.h \
  include/linux/moduleparam.h \
    $(wildcard include/config/ppc64.h) \
  include/linux/tracepoint.h \
  include/linux/rcupdate.h \
    $(wildcard include/config/tree/preempt/rcu.h) \
    $(wildcard include/config/tree/rcu.h) \
  include/linux/completion.h \
  include/linux/rcutree.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/local.h \
  include/linux/percpu.h \
    $(wildcard include/config/have/legacy/per/cpu/area.h) \
    $(wildcard include/config/need/per/cpu/embed/first/chunk.h) \
    $(wildcard include/config/need/per/cpu/page/first/chunk.h) \
    $(wildcard include/config/debug/kmemleak.h) \
  include/linux/slab.h \
    $(wildcard include/config/slab/debug.h) \
    $(wildcard include/config/slub.h) \
    $(wildcard include/config/slob.h) \
    $(wildcard include/config/debug/slab.h) \
  include/linux/slub_def.h \
    $(wildcard include/config/slub/stats.h) \
    $(wildcard include/config/slub/debug.h) \
    $(wildcard include/config/kmemtrace.h) \
  include/linux/kmemtrace.h \
  include/trace/events/kmem.h \
  include/trace/define_trace.h \
  include/linux/kmemleak.h \
  include/linux/pfn.h \
  /test_ap/software/linux-2.6.32.16/arch/x86/include/asm/module.h \
    $(wildcard include/config/m586.h) \
    $(wildcard include/config/m586tsc.h) \
    $(wildcard include/config/m586mmx.h) \
    $(wildcard include/config/mcore2.h) \
    $(wildcard include/config/matom.h) \
    $(wildcard include/config/m686.h) \
    $(wildcard include/config/mpentiumii.h) \
    $(wildcard include/config/mpentiumiii.h) \
    $(wildcard include/config/mpentiumm.h) \
    $(wildcard include/config/mpentium4.h) \
    $(wildcard include/config/mk6.h) \
    $(wildcard include/config/mk8.h) \
    $(wildcard include/config/x86/elan.h) \
    $(wildcard include/config/mcrusoe.h) \
    $(wildcard include/config/mefficeon.h) \
    $(wildcard include/config/mwinchipc6.h) \
    $(wildcard include/config/mwinchip3d.h) \
    $(wildcard include/config/mcyrixiii.h) \
    $(wildcard include/config/mviac3/2.h) \
    $(wildcard include/config/mviac7.h) \
    $(wildcard include/config/mgeodegx1.h) \
    $(wildcard include/config/mgeode/lx.h) \
  include/asm-generic/module.h \
  include/trace/events/module.h \
  include/linux/vermagic.h \
  include/linux/utsrelease.h \

/test_ap/software/compat-wireless/drivers/net/b44.mod.o: $(deps_/test_ap/software/compat-wireless/drivers/net/b44.mod.o)

$(deps_/test_ap/software/compat-wireless/drivers/net/b44.mod.o):
