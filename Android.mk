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

# WARNING: Everything listed here will be built on ALL platforms,
# including x86, the emulator, and the SDK.  Modules must be uniquely
# named (liblights.tuna), and must build everywhere, or limit themselves
# to only building on ARM if they include assembly. Individual makefiles
# are responsible for having their own logic, for fine-grained control.

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

include $(call all-makefiles-under,$(LOCAL_PATH))

DIR_STRUCTURE := viewsonic/smba1002

#PRODUCT_COPY_FILES :=  \
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

