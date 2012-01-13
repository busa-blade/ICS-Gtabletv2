#
# Copyright (C) 2011 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This file includes all definitions that apply to ALL tuna devices, and
# are also specific to tuna devices
#
# Everything in this directory will become public

DEVICE := smba1002
MANUFACTURER := viewsonic

#ifeq ($(TARGET_PREBUILT_KERNEL),)
#LOCAL_KERNEL := device/viewsonic/smba1002/kernel
#LOCAL_KERNEL := ../android-tegra-nv-2.6.39/arch/arm/boot/zImage
#else
#LOCAL_KERNEL := $(TARGET_PREBUILT_KERNEL)
#endif

DEVICE_PACKAGE_OVERLAYS := device/viewsonic/smba1002/overlay

# This device is xhdpi.  However the platform doesn't
# currently contain all of the bitmaps at xhdpi density so
# we do this little trick to fall back to the hdpi version
# if the xhdpi doesn't exist.
PRODUCT_AAPT_CONFIG := normal mdpi
PRODUCT_AAPT_PREF_CONFIG := mdpi

# uses mdpi artwork where available
PRODUCT_LOCALES += mdpi

PRODUCT_COPY_FILES := \
    $(LOCAL_KERNEL):kernel \
    device/viewsonic/smba1002/files/init.harmony.rc:root/init.harmony.rc \
    device/viewsonic/smba1002/files/ueventd.harmony.rc:root/ueventd.harmony.rc \
    device/viewsonic/smba1002/files/nvram.txt:system/etc/wifi/nvram.txt

# APK
#BUILD_PREBUILT := \
#    app/Quadrant.apk:system/app/Quadrant.apk \
#    app/.root_browser:system/etc/.root_browser \
#    app/RootBrowserFree.apk:system/app/RootBrowserFree.apk \
#    app/CalendarGoogle.apk:system/app/CalendarGoogle.apk \
#    app/CalendarProvider.apk:system/app/CalendarProvider.apk \
#    app/ChromeBookmarksSyncAdapter.apk:system/app/ChromeBookmarksSyncAdapter.apk \
#    app/Elixir.apk:system/app/Elixir.apk \
#    app/GalleryGoogle.apk:system/app/GalleryGoogle.apk \
#    app/GenieWidget.apk:system/app/GenieWidget.apk \
#    app/Gmail.apk:system/app/Gmail.apk \
#    app/GoogleBackupTransport.apk:system/app/GoogleBackupTransport.apk \
#    app/GoogleContactsSyncAdapter.apk:system/app/GoogleContactsSyncAdapter.apk \
#    app/GoogleFeedback.apk:system/app/GoogleFeedback.apk \
#    app/GoogleLoginService.apk:system/app/GoogleLoginService.apk \
#    app/GooglePartnerSetup.apk:system/app/GooglePartnerSetup.apk \
#    app/GoogleQuickSearchBox.apk:system/app/GoogleQuickSearchBox.apk \
#    app/GoogleServicesFramework.apk:system/app/GoogleServicesFramework.apk \
#    app/GoogleTTS.apk:system/app/GoogleTTS.apk \
#    app/MarketUpdater.apk:system/app/MarketUpdater.apk \
#    app/MediaUploader.apk:system/app/MediaUploader.apk \
#    app/NetworkLocation.apk:system/app/NetworkLocation.apk \
#    app/OneTimeInitializer.apk:system/app/OneTimeInitializer.apk \
#    app/SetupWizard.apk:system/app/SetupWizard.apk \
#    app/Talk.apk:system/app/Talk.apk \
#    app/Vending.apk:system/app/Vending.apk \
#    app/VoiceSearch.apk:system/app/VoiceSearch.apk \
#    app/YouTube.apk:system/app/YouTube.apk

# Modules
PRODUCT_COPY_FILES += \
     ../android-tegra-nv-2.6.39/arch/arm/mach-tegra/baseband-xmm-power2.ko:system/lib/modules/baseband-xmm-power2.ko \
     ../android-tegra-nv-2.6.39/drivers/scsi/scsi_wait_scan.ko:system/lib/modules/scsi_wait_scan.ko \
     ../android-tegra-nv-2.6.39/drivers/net/wireless/bcm4329/bcm4329.ko:system/lib/modules/bcm4329.ko \
     ../android-tegra-nv-2.6.39/drivers/media/video/videobuf2-memops.ko:system/lib/modules/videobuf2-memops.ko \
     ../android-tegra-nv-2.6.39/drivers/media/video/videobuf2-vmalloc.ko:system/lib/modules/videobuf2-vmalloc.ko \
     ../android-tegra-nv-2.6.39/drivers/media/video/vivi.ko:system/lib/modules/vivi.ko \
     ../android-tegra-nv-2.6.39/sound/soc/tegra/snd-soc-tegra20-spdif.ko:system/lib/modules/snd-soc-tegra20-spdif.ko

#    ../../../../device/viewsonic/smba1002/modules/scsi_wait_scan.ko:system/lib/modules/scsi_wait_scan.ko \
#    device/viewsonic/smba1002/modules/bcm4329.ko:system/lib/modules/bcm4329.ko

# Bluetooth
PRODUCT_COPY_FILES += \
    device/viewsonic/smba1002/files/bcm4329.hcd:system/etc/firmware/bcm4329.hcd
	
# Touchscreen
PRODUCT_COPY_FILES += \
    device/viewsonic/smba1002/files/at168_touch.idc:system/usr/idc/at168_touch.idc 

# Graphics
PRODUCT_COPY_FILES += \
    device/viewsonic/smba1002/files/media_profiles.xml:system/etc/media_profiles.xml

# Generic
PRODUCT_COPY_FILES += \
   device/viewsonic/smba1002/files/vold.fstab:system/etc/vold.fstab

PRODUCT_PROPERTY_OVERRIDES := \
    wifi.interface=wlan0 \
    ro.sf.lcd_density=120 \
    wifi.supplicant_scan_interval=15

# Live Wallpapers
PRODUCT_PACKAGES += \
	HoloSpiralWallpaper \
        LiveWallpapersPicker \
        VisualizationWallpapers

PRODUCT_PACKAGES += \
        audio.a2dp.default \
        libaudioutils

PRODUCT_PACKAGES += \
	sensors.harmony \
	lights.harmony \
	gps.harmony \
	libmbm-ril
        
# These are the hardware-specific features
PRODUCT_COPY_FILES += \
    frameworks/base/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml \
    frameworks/base/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
    frameworks/base/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
    frameworks/base/data/etc/android.hardware.location.xml:system/etc/permissions/android.hardware.location.xml \
    frameworks/base/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
    frameworks/base/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/base/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/base/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/base/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/base/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/base/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/base/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
    frameworks/base/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/base/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
    packages/wallpapers/LivePicker/android.software.live_wallpaper.xml:system/etc/permissions/android.software.live_wallpaper.xml 

PRODUCT_PROPERTY_OVERRIDES += \
	ro.opengles.version=131072

#Set default.prop properties for root + adb
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
	ro.secure=0 \
	persist.service.adb.enable=1 \
        persist.sys.usb.config=mass_storage,adb

ADDITIONAL_DEFAULT_PROPERTIES += \
	ro.secure=0 \
	persist.service.adb.enable=1 \
        persist.sys.usb.config=mass_storage,adb

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_TAGS += dalvik.gc.type-precise

PRODUCT_PACKAGES += \
	librs_jni \
	com.android.future.usb.accessory

# Filesystem management tools
PRODUCT_PACKAGES += \
	setup_fs

# for bugmailer
ifneq ($(TARGET_BUILD_VARIANT),user)
	PRODUCT_PACKAGES += send_bug
	PRODUCT_COPY_FILES += \
            system/extras/bugmailer/bugmailer.sh:system/bin/bugmailer.sh \
            system/extras/bugmailer/send_bug:system/bin/send_bug
endif

$(call inherit-product, frameworks/base/build/tablet-dalvik-heap.mk)

# Make it optional to include vendor stuff..Just to be nice ;)
ifneq ($(TARGET_IGNORE_VENDOR),yes)
$(call inherit-product, vendor/viewsonic/smba1002/device-vendor.mk)
endif
