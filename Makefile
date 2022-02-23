ks=https://raw.githubusercontent.com/JosiahKerley/homelab-kickstarts/main/centos/7/base.cfg
iso_url=http://mirror.den01.meanservers.net/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-NetInstall-2009.iso

isos/autoinstall.iso: isos/orig.iso
	@cd isos; \
	  [[ -d tmp/mnt ]] || mkdir -p tmp/mnt; \
	  [[ -d tmp/new ]] || mkdir -p tmp/new; \
	  sudo mount -o loop orig.iso tmp/mnt; \
	  sudo cp -r tmp/mnt/* tmp/new/; \
	  sudo umount tmp/mnt; \
	  sudo chmod -R u+w tmp/new; \
	  cd tmp/new; \
	  sudo bash -c 'echo -e "default vesamenu.c32\ntimeout 600\nmenu title Autoinstall\nlabel install\nmenu default\nmenu label $(shell echo $(ks) | rev | cut -c -50 | rev)\nkernel vmlinuz\nappend initrd=initrd.img quiet ks=$(ks)" > isolinux/isolinux.cfg'; \
	  sudo mkisofs \
	    -o ../../autoinstall.iso \
	    -b isolinux.bin \
	    -c boot.cat \
	    -no-emul-boot \
	    -boot-load-size 4 \
	    -boot-info-table \
	    -V "CentOS 7 x86_64" \
	    -R -J -v -T isolinux/. .; \
	  sudo isohybrid ../../autoinstall.iso; \
	  cd ../; sudo rm -rf new; sudo chown -R `whoami`:`whoami` ./

isos/orig.iso: isos
	@cd isos; [[ -f orig.iso ]] || (wget $(iso_url) -O orig.iso_in-progress && mv orig.iso_in-progress orig.iso)

isos:
	@mkdir isos

iso-test: isos/autoinstall.iso
	@qemu-system-x86_64 -boot d -cdrom isos/autoinstall.iso -m 1024

clean:
	@sudo rm -rf isos/tmp isos/autoinstall.iso
