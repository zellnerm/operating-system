PROJECT		?= dom0-HW

# options: x86 arm
TOOLCHAIN_TARGET    ?= arm

# options: see tool/create_builddir
GENODE_TARGET       ?= focnados_panda

BUILD_DIR           ?= build
TOOLCHAIN_BUILD_DIR ?= $(BUILD_DIR)/toolchain-$(TOOLCHAIN_TARGET)
GENODE_BUILD_DIR    ?= $(BUILD_DIR)/genode-$(GENODE_TARGET)
BUILD_CONF           = $(GENODE_BUILD_DIR)/etc/build.conf

all: ports platform

# ================================================================
# Genode toolchain. Only needs to be done once per target (x86/arm).
toolchain:
	mkdir -p $(TOOLCHAIN_BUILD_DIR)
	cd $(TOOLCHAIN_BUILD_DIR);\
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
platform: genode_build_dir

genode_build_dir:
	genode/tool/create_builddir $(GENODE_TARGET) BUILD_DIR=$(GENODE_BUILD_DIR)
	printf 'REPOSITORIES += $$(GENODE_DIR)/repos/libports\n' >> $(BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-dom0-HW\n' >> $(BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Taskloader\n' >> $(BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Parser\n' >> $(BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Monitoring\n' >> $(BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-schedulerTest\n' >> $(BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-AdmCtrl\n' >> $(BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Synchronization\n' >> $(BUILD_CONF)
	printf 'REPOSITORIES += $$(GENODE_DIR)/repos/dde_linux\n' >> $(BUILD_CONF)

# Delete build directory for all target systems. In some cases, subfolders in the contrib directory might be corrupted. Remove manually and re-prepare if necessary.
clean:
	rm -rf $(BUILD_DIR)
#
# ================================================================


# ================================================================
# Run Genode with an active dom0 server.
run:
	$(MAKE) -C $(GENODE_BUILD_DIR) run/$(PROJECT) #declare which run file to run
	rm -f /var/lib/tftpboot/image.elf
	rm -f /var/lib/tftpboot/modules.list
	rm -rf /var/lib/tftpboot/genode
	cp $(BUILD_DIR)/genode-focnados_panda/var/run/$(PROJECT)/image.elf /var/lib/tftpboot/
	cp $(BUILD_DIR)/genode-focnados_panda/var/run/$(PROJECT)/modules.list /var/lib/tftpboot/
	cp -R $(BUILD_DIR)/genode-focnados_panda/var/run/$(PROJECT)/genode /var/lib/tftpboot/
	
#
# ================================================================

# ================================================================
# Requiered packages for relaunched systems
packages:
	sudo apt-get update
	sudo apt-get install libncurses5-dev texinfo autogen autoconf2.64 g++ libexpat1-dev flex bison gperf cmake libxml2-dev libtool zlib1g-dev libglib2.0-dev make pkg-config gawk subversion expect git libxml2-utils syslinux xsltproc yasm iasl lynx unzip qemu
#
# ================================================================
