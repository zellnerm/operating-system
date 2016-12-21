PROJECT		?= dom0-HW

# options: x86 arm
TOOLCHAIN_TARGET    ?= arm

# options: see tool/create_builddir
GENODE_TARGET       ?= focnados_panda

VAGRANT_BUILD_DIR           ?= build
VAGRANT_TOOLCHAIN_BUILD_DIR ?= $(VAGRANT_BUILD_DIR)/toolchain-$(TOOLCHAIN_TARGET)
VAGRANT_GENODE_BUILD_DIR    ?= $(VAGRANT_BUILD_DIR)/genode-$(GENODE_TARGET)
VAGRANT_BUILD_CONF           = $(VAGRANT_GENODE_BUILD_DIR)/etc/build.conf

JENKINS_BUILD_DIR           ?= build
JENKINS_TOOLCHAIN_BUILD_DIR ?= $(JENKINS_BUILD_DIR)/toolchain-$(TOOLCHAIN_TARGET)
JENKINS_GENODE_BUILD_DIR    ?= $(JENKINS_BUILD_DIR)/genode-$(GENODE_TARGET)
JENKINS_BUILD_CONF           = $(JENKINS_GENODE_BUILD_DIR)/etc/build.conf

vagrant: ports vagrant_build_dir

jenkins: foc jenkins_build_dir

# ================================================================
# Genode toolchain. Only needs to be done once per target (x86/arm).
toolchain:
	mkdir -p $(VAGRANT_TOOLCHAIN_BUILD_DIR)
	cd $(VAGRANT_TOOLCHAIN_BUILD_DIR);\
	genode/tool/tool_chain $(TOOLCHAIN_TARGET)
#
# ================================================================


# ================================================================
# Download Genode external sources. Only needs to be done once per system.
ports: foc libports dde_linux

foc:
	$(MAKE) -C genode/repos/base-focnados prepare

libports:
	$(MAKE) -C genode/repos/libports prepare

dde_linux:
	$(MAKE) -C genode/repos/dde_linux prepare
#
# ================================================================


# ================================================================
# Genode build process. Rebuild subtargets as needed.

vagrant_build_dir:
	genode/tool/create_builddir $(GENODE_TARGET) BUILD_DIR=$(VAGRANT_GENODE_BUILD_DIR)
	printf 'REPOSITORIES += $$(GENODE_DIR)/repos/libports\n' >> $(VAGRANT_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-dom0-HW\n' >> $(VAGRANT_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Taskloader\n' >> $(VAGRANT_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Parser\n' >> $(VAGRANT_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Monitoring\n' >> $(VAGRANT_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-schedulerTest\n' >> $(VAGRANT_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-AdmCtrl\n' >> $(VAGRANT_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Synchronization\n' >> $(VAGRANT_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/repos/dde_linux\n' >> $(VAGRANT_BUILD_CONF)
	printf 'MAKE += -j4' >> $(VAGRANT_BUILD_CONF)

jenkins_build_dir:
	genode/tool/create_builddir $(GENODE_TARGET) BUILD_DIR=$(JENKINS_GENODE_BUILD_DIR)
	printf 'REPOSITORIES += $$(GENODE_DIR)/repos/libports\n' >> $(JENKINS_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-dom0-HW\n' >> $(JENKINS_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Taskloader\n' >> $(JENKINS_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Parser\n' >> $(JENKINS_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Monitoring\n' >> $(JENKINS_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-schedulerTest\n' >> $(JENKINS_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-AdmCtrl\n' >> $(JENKINS_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Synchronization\n' >> $(JENKINS_BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/repos/dde_linux\n' >> $(JENKINS_BUILD_CONF)
	printf 'MAKE += -j4' >> $(JENKINS_BUILD_CONF)

# Delete build directory for all target systems. In some cases, subfolders in the contrib directory might be corrupted. Remove manually and re-prepare if necessary.
vagrant_clean:
	rm -rf $(VAGRANT_BUILD_DIR)

jenkins_clean:
	rm -rf $(JENKINS_BUILD_DIR)
#
# ================================================================


# ================================================================
# Run Genode with an active dom0 server.
vagrant_run:
	$(MAKE) -C $(VAGRANT_GENODE_BUILD_DIR) run/$(PROJECT) #declare which run file to run
	rm -f /var/lib/tftpboot/image.elf
	rm -f /var/lib/tftpboot/modules.list
	rm -rf /var/lib/tftpboot/genode
	cp $(VAGRANT_BUILD_DIR)/genode-focnados_panda/var/run/$(PROJECT)/image.elf /var/lib/tftpboot/
	cp $(VAGRANT_BUILD_DIR)/genode-focnados_panda/var/run/$(PROJECT)/modules.list /var/lib/tftpboot/
	cp -R $(VAGRANT_BUILD_DIR)/genode-focnados_panda/var/run/$(PROJECT)/genode /var/lib/tftpboot/

jenkins_run:
	$(MAKE) -C $(JENKINS_GENODE_BUILD_DIR) run/$(PROJECT) #declare which run file to run
	rm -f /var/lib/tftpboot/image.elf
	rm -f /var/lib/tftpboot/modules.list
	rm -rf /var/lib/tftpboot/genode
	cp $(JENKINS_BUILD_DIR)/genode-focnados_panda/var/run/$(PROJECT)/image.elf /var/lib/tftpboot/
	cp $(JENKINS_BUILD_DIR)/genode-focnados_panda/var/run/$(PROJECT)/modules.list /var/lib/tftpboot/
	cp -R $(JENKINS_BUILD_DIR)/genode-focnados_panda/var/run/$(PROJECT)/genode /var/lib/tftpboot/
	
#
# ================================================================

# ================================================================
# Requiered packages for relaunched systems
packages:
	sudo apt-get update
	sudo apt-get install libncurses5-dev texinfo autogen autoconf2.64 g++ libexpat1-dev flex bison gperf cmake libxml2-dev libtool zlib1g-dev libglib2.0-dev make pkg-config gawk subversion expect git libxml2-utils syslinux xsltproc yasm iasl lynx unzip qemu
#
# ================================================================
