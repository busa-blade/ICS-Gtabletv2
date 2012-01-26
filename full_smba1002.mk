# Copyright (C) 2011 The Android Open Source Project
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

# Camera
PRODUCT_PACKAGES := \
    Camera \
    SpareParts \
    Development \
    Superuser

$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# Inherit from SMBA1002 device
$(call inherit-product, device/viewsonic/smba1002/device.mk)

# The gps config appropriate for this device
$(call inherit-product, device/common/gps/gps_us_supl.mk)

$(call inherit-product-if-exists, vendor/viewsonic/smba1002/device-vendor.mk)


PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0
PRODUCT_NAME := full_smba1002
PRODUCT_DEVICE := smba1002
PRODUCT_BRAND := Viewsonic
PRODUCT_MODEL := Viewsonic Gtablet
