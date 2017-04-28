PROJECT		?= dom0-HW

# options: x86 arm
TOOLCHAIN_TARGET    ?= arm

# options: see tool/create_builddir
GENODE_TARGET       ?= focnados_panda

VAGRANT_BUILD_DIR           ?= /build
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
	/vagrant/genode/tool/tool_chain $(TOOLCHAIN_TARGET)
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

dom0_tasks:
	$(MAKE) -C genode/repos/dom0_tasks prepare
#
# ================================================================


# ================================================================
# Genode build process. Rebuild subtargets as needed.

vagrant_build_dir:
	@echo "Create build directory "$(VAGRANT_BUILD_DIR)"and set permissions"
	sudo mkdir -p $(VAGRANT_BUILD_DIR)
	sudo chown -R ubuntu $(VAGRANT_BUILD_DIR)
	sudo chgrp -R ubuntu $(VAGRANT_BUILD_DIR)
	sudo chmod 777 $(VAGRANT_BUILD_DIR)
	@echo "DONE!"
	@echo ""
	@echo "Call genode/tool/create_builddir for target "$(GENODE_TARGET)
	@echo ""
	@genode/tool/create_builddir $(GENODE_TARGET) BUILD_DIR=$(VAGRANT_GENODE_BUILD_DIR)
	@echo "DONE!"
	@echo ""
	@echo "Add repositories to genode"
	@echo ""
	@printf 'REPOSITORIES += $$(GENODE_DIR)/repos/libports\n' >> $(VAGRANT_BUILD_CONF)
	@printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-dom0-HW\n' >> $(VAGRANT_BUILD_CONF)
	@printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Taskloader\n' >> $(VAGRANT_BUILD_CONF)
	@printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Parser\n' >> $(VAGRANT_BUILD_CONF)
	@printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Monitoring\n' >> $(VAGRANT_BUILD_CONF)
	@printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-schedulerTest\n' >> $(VAGRANT_BUILD_CONF)
	@printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-AdmCtrl\n' >> $(VAGRANT_BUILD_CONF)
	@printf 'REPOSITORIES += $$(GENODE_DIR)/../genode-Synchronization\n' >> $(VAGRANT_BUILD_CONF)
	@printf 'REPOSITORIES += $$(GENODE_DIR)/repos/dde_linux\n' >> $(VAGRANT_BUILD_CONF)
	@printf 'REPOSITORIES += $$(GENODE_DIR)/repos/dom0_tasks\n' >> $(VAGRANT_BUILD_CONF)
	@printf 'MAKE += -j16' >> $(VAGRANT_BUILD_CONF)
	@echo ""
	@echo "FINISHED!"

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
	@echo "Execute genode makefile in build directory" $(VAGRANT_GENODE_BUILD_DIR)
	@echo ""
	$(MAKE) -C $(VAGRANT_GENODE_BUILD_DIR) run/$(PROJECT) #declare which run file to run
	@echo "Delete old images"
	@rm -rf /var/lib/tftpboot/image.elf /var/lib/tftpboot/modules.list /var/lib/tftpboot/genode
	@echo "Copy images to tftpboot directory"
	cp -R $(VAGRANT_GENODE_BUILD_DIR)/var/run/$(PROJECT)/image.elf \
	$(VAGRANT_GENODE_BUILD_DIR)/var/run/$(PROJECT)/modules.list \
	$(VAGRANT_GENODE_BUILD_DIR)/var/run/$(PROJECT)/genode /var/lib/tftpboot/

jenkins_run:
	$(MAKE) -C $(JENKINS_GENODE_BUILD_DIR) run/$(PROJECT) #declare which run file to run
	rm -rf /var/lib/tftpboot/image.elf \
	/var/lib/tftpboot/modules.list \
	/var/lib/tftpboot/genode
	cp $(JENKINS_BUILD_DIR)/genode-focnados_panda/var/run/$(PROJECT)/image.elf \
	$(JENKINS_BUILD_DIR)/genode-focnados_panda/var/run/$(PROJECT)/modules.list \
	$(JENKINS_BUILD_DIR)/genode-focnados_panda/var/run/$(PROJECT)/genode /var/lib/tftpboot/
	
#
# ================================================================

# ================================================================
# Requiered packages for relaunched systems
packages:
	sudo apt-get update
	sudo apt-get install libncurses5-dev texinfo autogen autoconf2.64 g++ libexpat1-dev flex bison gperf cmake libxml2-dev libtool zlib1g-dev libglib2.0-dev make pkg-config gawk subversion expect git libxml2-utils syslinux xsltproc yasm iasl lynx unzip qemu
#
# ================================================================


again:
	@echo "Performing make again for " $(VAGRANT_GENODE_BUILD_DIR)
	@echo ""
	$(MAKE) -C $(VAGRANT_GENODE_BUILD_DIR) again
	@rm -rf /var/lib/tftpboot/image.elf /var/lib/tftpboot/modules.list /var/lib/tftpboot/genode
	@echo "Copy images to tftpboot directory"
	cp -R $(VAGRANT_GENODE_BUILD_DIR)/var/run/$(PROJECT)/image.elf \
	$(VAGRANT_GENODE_BUILD_DIR)/var/run/$(PROJECT)/modules.list \
	$(VAGRANT_GENODE_BUILD_DIR)/var/run/$(PROJECT)/genode /var/lib/tftpboot/

