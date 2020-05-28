################################################################################
#
# hifiberry-shairport
#
################################################################################

#HIFIBERRY_SHAIRPORT_VERSION = 3.3.5
# Bugfix for incorrect artist names
HIFIBERRY_SHAIRPORT_VERSION = 4fc161cf0c4d0bbf500b5887da5704a600d7ab5e
HIFIBERRY_SHAIRPORT_SITE = $(call github,mikebrady,shairport-sync,$(HIFIBERRY_SHAIRPORT_VERSION))

HIFIBERRY_SHAIRPORT_LICENSE = MIT, BSD-3-Clause
HIFIBERRY_SHAIRPORT_LICENSE_FILES = LICENSES
HIFIBERRY_SHAIRPORT_DEPENDENCIES = alsa-lib libconfig libdaemon popt host-pkgconf avahi

# git clone, no configure
HIFIBERRY_SHAIRPORT_AUTORECONF = YES

HIFIBERRY_SHAIRPORT_CONF_OPTS = --with-alsa \
        --with-metadata \
        --with-pipe \
        --with-stdout \
        --with-avahi \
        --with-mpris-interface \
        --with-mpris-test-client 

HIFIBERRY_SHAIRPORT_CONF_ENV += LIBS="$(HIFIBERRY_SHAIRPORT_CONF_LIBS)"

# OpenSSL or mbedTLS
ifeq ($(BR2_PACKAGE_OPENSSL),y)
HIFIBERRY_SHAIRPORT_DEPENDENCIES += openssl
HIFIBERRY_SHAIRPORT_CONF_OPTS += --with-ssl=openssl
else
HIFIBERRY_SHAIRPORT_DEPENDENCIES += mbedtls
HIFIBERRY_SHAIRPORT_CONF_OPTS += --with-ssl=mbedtls
HIFIBERRY_SHAIRPORT_CONF_LIBS += -lmbedx509 -lmbedcrypto
ifeq ($(BR2_PACKAGE_MBEDTLS_COMPRESSION),y)
HIFIBERRY_SHAIRPORT_CONF_LIBS += -lz
endif
endif

ifeq ($(BR2_PACKAGE_HIFIBERRY_SHAIRPORT_LIBSOXR),y)
HIFIBERRY_SHAIRPORT_DEPENDENCIES += libsoxr
HIFIBERRY_SHAIRPORT_CONF_OPTS += --with-soxr
endif

define HIFIBERRY_SHAIRPORT_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/shairport-sync \
                $(TARGET_DIR)/usr/bin/shairport-sync
        $(INSTALL) -D -m 0755 $(@D)/shairport-sync-mpris-test-client \
                $(TARGET_DIR)/usr/bin/shairport-sync-mpris-test-client
        $(INSTALL) -D -m 0644 $(BR2_EXTERNAL_HIFIBERRY_PATH)/package/hifiberry-shairport/shairport-sync.conf \
                $(TARGET_DIR)/etc/shairport-sync.conf
        $(INSTALL) -D -m 0644 $(BR2_EXTERNAL_HIFIBERRY_PATH)/package/hifiberry-shairport/dbus.conf \
                $(TARGET_DIR)/etc/dbus-1/system.d/shairport-sync.conf
endef

define HIFIBERRY_SHAIRPORT_INSTALL_INIT_SYSV
        $(INSTALL) -D -m 0755 package/shairport-sync/S99shairport-sync \
                $(TARGET_DIR)/etc/init.d/S99shairport-sync
endef

define HIFIBERRY_SHAIRPORT_INSTALL_INIT_SYSTEMD
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
        $(INSTALL) -D -m 0644 $(BR2_EXTERNAL_HIFIBERRY_PATH)/package/hifiberry-shairport/shairport-sync.service \
                $(TARGET_DIR)/usr/lib/systemd/system/shairport-sync.service
        ln -fs ../../../../usr/lib/systemd/system/shairport-sync.service \
                $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/shairport-sync.service
endef

$(eval $(autotools-package))
