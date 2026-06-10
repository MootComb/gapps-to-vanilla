#!/bin/bash
# gapps-to-vanilla.sh - Convert GAPPS to Vanilla AOSP

cd "$(dirname "$0")/.."

WORK_DIR="gapps-to-vanilla-build"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

echo "========================================="
echo "  gapps-to-vanilla"
echo "  Convert GAPPS to Vanilla AOSP"
echo "========================================="
echo ""

copy_item() {
    local src="$1"
    local dst="$2"
    local name="$3"
    
    if [ ! -e "$src" ]; then
        echo "  ✗ $name - SOURCE NOT FOUND!"
        return 1
    fi
    
    mkdir -p "$(dirname "$dst")"
    
    if [ -f "$src" ]; then
        cp "$src" "$dst"
        echo "  ✓ $name (file)"
    elif [ -d "$src" ]; then
        rm -rf "$dst"
        mkdir -p "$dst"
        
        if [ -d "$src/$name" ]; then
            cp -r "$src/$name"/* "$dst/" 2>/dev/null
            if [ -f "$dst/$name.apk" ]; then
                echo "  ✓ $name (good)"
            else
                echo "  ✗ $name - ERROR!"
                return 1
            fi
        else
            cp -r "$src"/* "$dst/" 2>/dev/null
            if [ -f "$dst/$name.apk" ] || [ -d "$dst/$name" ]; then
                echo "  ✓ $name"
            else
                if [ -f "$dst/$name/$name.apk" ]; then
                    echo "  ✗ $name - DOUBLE NESTING!"
                    return 1
                fi
            fi
        fi
    fi
    return 0
}

echo "Copying AOSP components from vanilla to package..."
echo ""

echo "1. Apps in /system_ext/priv-app:"
copy_item "vanilla/system_ext/priv-app/Provision"           "$WORK_DIR/system_ext/priv-app/Provision"           "Provision"
copy_item "vanilla/system_ext/priv-app/StatementService"    "$WORK_DIR/system_ext/priv-app/StatementService"    "StatementService"
copy_item "vanilla/system_ext/priv-app/ThemePicker"         "$WORK_DIR/system_ext/priv-app/ThemePicker"         "ThemePicker"
copy_item "vanilla/system_ext/priv-app/Updater"             "$WORK_DIR/system_ext/priv-app/Updater"             "Updater"
echo ""

echo "2. Apps in /product/app:"
copy_item "vanilla/product/app/DeskClock"        "$WORK_DIR/product/app/DeskClock"        "DeskClock"
copy_item "vanilla/product/app/ExactCalculator"  "$WORK_DIR/product/app/ExactCalculator"  "ExactCalculator"
copy_item "vanilla/product/app/LatinIME"         "$WORK_DIR/product/app/LatinIME"         "LatinIME"
copy_item "vanilla/product/app/webview"          "$WORK_DIR/product/app/webview"          "webview"
echo ""

echo "3. Apps in /product/priv-app:"
copy_item "vanilla/product/priv-app/Contacts"    "$WORK_DIR/product/priv-app/Contacts"    "Contacts"
echo ""

echo "4. Libraries:"
copy_item "vanilla/product/lib64/libjni_latinime.so" "$WORK_DIR/product/lib64/libjni_latinime.so" "libjni_latinime.so"
echo ""

echo "5. AOSP config files:"
copy_item "vanilla/product/etc/default-permissions/com.android.deskclock_default-permissions.xml" \
          "$WORK_DIR/product/etc/default-permissions/com.android.deskclock_default-permissions.xml" \
          "deskclock permissions"
copy_item "vanilla/product/etc/permissions/com.android.contacts.xml" \
          "$WORK_DIR/product/etc/permissions/com.android.contacts.xml" \
          "contacts permissions"
copy_item "vanilla/product/etc/sysconfig/com.android.deskclock_allowlist.xml" \
          "$WORK_DIR/product/etc/sysconfig/com.android.deskclock_allowlist.xml" \
          "deskclock allowlist"
echo ""

echo "6. System apps:"
copy_item "vanilla/system/app/ExtShared"  "$WORK_DIR/system/app/ExtShared"  "ExtShared"
copy_item "vanilla/system/app/PrintRecommendationService" "$WORK_DIR/system/app/PrintRecommendationService" "PrintRecommendationService"
copy_item "vanilla/system/app/ViaBrowser" "$WORK_DIR/system/app/ViaBrowser" "ViaBrowser"
copy_item "vanilla/system/priv-app/PackageInstaller" "$WORK_DIR/system/priv-app/PackageInstaller" "PackageInstaller"
copy_item "vanilla/system/priv-app/SoundPicker" "$WORK_DIR/system/priv-app/SoundPicker" "SoundPicker"
echo ""

echo "7. AOSP permissions:"
copy_item "vanilla/system_ext/etc/permissions/android.software.theme_picker.xml" \
          "$WORK_DIR/system_ext/etc/permissions/android.software.theme_picker.xml" \
          "theme_picker"
copy_item "vanilla/system_ext/etc/permissions/com.android.provision.xml" \
          "$WORK_DIR/system_ext/etc/permissions/com.android.provision.xml" \
          "provision"
copy_item "vanilla/system_ext/etc/permissions/com.android.statementservice.xml" \
          "$WORK_DIR/system_ext/etc/permissions/com.android.statementservice.xml" \
          "statementservice"
echo ""

echo "8. NOTICE.xml.gz files:"
if [ -f "vanilla/product/etc/NOTICE.xml.gz" ]; then
    cp "vanilla/product/etc/NOTICE.xml.gz" "$WORK_DIR/product/etc/NOTICE.xml.gz"
    echo "  ✓ product/etc/NOTICE.xml.gz"
fi
if [ -f "vanilla/system/etc/NOTICE.xml.gz" ]; then
    cp "vanilla/system/etc/NOTICE.xml.gz" "$WORK_DIR/system/etc/NOTICE.xml.gz"
    echo "  ✓ system/etc/NOTICE.xml.gz"
fi
if [ -f "vanilla/system_ext/etc/NOTICE.xml.gz" ]; then
    cp "vanilla/system_ext/etc/NOTICE.xml.gz" "$WORK_DIR/system_ext/etc/NOTICE.xml.gz"
    echo "  ✓ system_ext/etc/NOTICE.xml.gz"
fi
echo ""

echo "9. Aconfig files:"
mkdir -p "$WORK_DIR/system_ext/etc/aconfig"
for file in flag.info flag.map flag.val package.map; do
    if [ -f "vanilla/system_ext/etc/aconfig/$file" ]; then
        cp "vanilla/system_ext/etc/aconfig/$file" "$WORK_DIR/system_ext/etc/aconfig/$file"
        echo "  ✓ system_ext/etc/aconfig/$file"
    fi
done
if [ -f "vanilla/system_ext/etc/aconfig_flags.pb" ]; then
    cp "vanilla/system_ext/etc/aconfig_flags.pb" "$WORK_DIR/system_ext/etc/aconfig_flags.pb"
    echo "  ✓ system_ext/etc/aconfig_flags.pb"
fi
echo ""

echo "========================================="
echo "  Copy completed!"
echo "========================================="
echo ""

echo "========================================="
echo "  DETAILED STRUCTURE CHECK"
echo "========================================="
echo ""

errors=0

check_apk() {
    local path="$1"
    local name="$2"
    
    echo -n "  $name: "
    
    if [ ! -d "$WORK_DIR/$path" ]; then
        echo "❌ Folder not exist!"
        errors=$((errors + 1))
        return
    fi
    
    if [ -d "$WORK_DIR/$path/$name" ]; then
        echo "❌ DOUBLE NESTING!"
        errors=$((errors + 1))
        return
    fi
    
    if [ -f "$WORK_DIR/$path/$name.apk" ]; then
        echo "✅ $name.apk"
    else
        echo "❌ APK not found!"
        errors=$((errors + 1))
    fi
}

check_file() {
    local path="$1"
    local name="$2"
    
    echo -n "  $name: "
    if [ -f "$WORK_DIR/$path" ]; then
        echo "✅"
    else
        echo "❌ not found!"
        errors=$((errors + 1))
    fi
}

echo "1. Check system_ext/priv-app:"
check_apk "system_ext/priv-app/Provision" "Provision"
check_apk "system_ext/priv-app/StatementService" "StatementService"
check_apk "system_ext/priv-app/ThemePicker" "ThemePicker"
check_apk "system_ext/priv-app/Updater" "Updater"
echo ""

echo "2. Check product/app:"
check_apk "product/app/DeskClock" "DeskClock"
check_apk "product/app/ExactCalculator" "ExactCalculator"
check_apk "product/app/LatinIME" "LatinIME"
check_apk "product/app/webview" "webview"
echo ""

echo "3. Check product/priv-app:"
check_apk "product/priv-app/Contacts" "Contacts"
echo ""

echo "4. Check system/priv-app:"
check_apk "system/priv-app/PackageInstaller" "PackageInstaller"
check_apk "system/priv-app/SoundPicker" "SoundPicker"
echo ""

echo "5. Check system/app:"
check_apk "system/app/ExtShared" "ExtShared"
check_apk "system/app/PrintRecommendationService" "PrintRecommendationService"
check_apk "system/app/ViaBrowser" "ViaBrowser"
echo ""

echo "6. Check config files:"
check_file "product/etc/default-permissions/com.android.deskclock_default-permissions.xml" "deskclock permissions"
check_file "product/etc/permissions/com.android.contacts.xml" "contacts permissions"
check_file "product/etc/sysconfig/com.android.deskclock_allowlist.xml" "deskclock allowlist"
check_file "product/lib64/libjni_latinime.so" "libjni_latinime.so"
echo ""

echo "7. Check system_ext/etc/permissions:"
check_file "system_ext/etc/permissions/android.software.theme_picker.xml" "theme_picker"
check_file "system_ext/etc/permissions/com.android.provision.xml" "provision"
check_file "system_ext/etc/permissions/com.android.statementservice.xml" "statementservice"
echo ""

echo "8. Check NOTICE.xml.gz:"
check_file "product/etc/NOTICE.xml.gz" "product NOTICE"
check_file "system/etc/NOTICE.xml.gz" "system NOTICE"
check_file "system_ext/etc/NOTICE.xml.gz" "system_ext NOTICE"
echo ""

echo "9. Check Aconfig files:"
check_file "system_ext/etc/aconfig/flag.info" "flag.info"
check_file "system_ext/etc/aconfig/flag.map" "flag.map"
check_file "system_ext/etc/aconfig/flag.val" "flag.val"
check_file "system_ext/etc/aconfig/package.map" "package.map"
check_file "system_ext/etc/aconfig_flags.pb" "aconfig_flags.pb"
echo ""

if [ $errors -eq 0 ]; then
    echo "========================================="
    echo "  ✅ ALL CHECKS PASSED SUCCESSFULLY!"
    echo "========================================="
else
    echo "========================================="
    echo "  ❌ $errors ERRORS FOUND! ZIP NOT CREATED!"
    echo "========================================="
    exit 1
fi

echo ""

mkdir -p "$WORK_DIR/META-INF/com/google/android"

cat > "$WORK_DIR/META-INF/com/google/android/update-binary" << 'EOF'
#!/sbin/sh

SCREEN=/proc/self/fd/$2
ZIPFILE="$3"
EX_DIR=/tmp/gapps-to-vanilla

ui_print() {
    echo -e "ui_print $1\nui_print" >> $SCREEN
}

abort() {
    ui_print "❌ ERROR: $1"
    ui_print "❌ Installation aborted"
    exit 1
}

ui_print "========================================="
ui_print "   gapps-to-vanilla"
ui_print "   Remove GAPPS and restore AOSP"
ui_print "========================================="

SYSTEM_MOUNT="/system"
PRODUCT_MOUNT="/product"
SYSTEM_EXT_MOUNT="/system_ext"

ui_print ""
ui_print "Step 1/9: Mounting partitions"

for point in $SYSTEM_MOUNT $PRODUCT_MOUNT $SYSTEM_EXT_MOUNT; do
    ui_print "  → $point"
    mount -o remount,rw $point 2>/dev/null
    if ! touch $point/.test 2>/dev/null; then
        mount -o rw $point 2>/dev/null
        if ! touch $point/.test 2>/dev/null; then
            abort "Failed to mount $point as RW"
        fi
    fi
    rm -f $point/.test
    ui_print "    ✓ $point mounted"
done

ui_print ""
ui_print "Step 2/9: Extracting files"

rm -rf "$EX_DIR"
mkdir -p "$EX_DIR"
cd "$EX_DIR"
unzip -o "$ZIPFILE" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    abort "Failed to extract ZIP archive"
fi

ui_print "  ✓ Files extracted"

ui_print ""
ui_print "Step 3/9: Removing all GAPPS"

ui_print "  → Removing Google apps from /product/app"

for app in CalculatorGoogle Chrome64 GoogleContacts GoogleLocationHistory LatinImeGoogle \
           MarkupGoogle_v2 PixelThemesStub2025_and_newer SoundPickerPrebuilt SpeechServicesByGoogle \
           talkback TrichromeLibrary64 WallpaperEmojiPrebuilt-foldable-wallpaper WebViewGoogle64 \
           CalculatorGooglePrebuilt Chrome GoogleCamera GoogleDialer GoogleMessages \
           Gmail GoogleCalendar GoogleDrive GoogleMaps YouTube YouTubeMusic GooglePhotos \
           GoogleKeep GoogleNews GoogleWeather GoogleHome GoogleWallet GoogleFit \
           GoogleAssistant GooglePay DevicePolicy Assistant GoogleOne DataTransferTool \
           LocationHistoryPrebuilt AndroidAuto GoogleTTS GoogleFeedback AndroidMigratePrebuilt \
           CarrierServices CarrierSetup GooglePrintRecommendationService GoogleExtShared; do
    if [ -e "$PRODUCT_MOUNT/app/$app" ]; then
        rm -rf "$PRODUCT_MOUNT/app/$app" 2>/dev/null
        ui_print "    ✓ $app removed"
    fi
done

ui_print "  → Removing Google services from /product/priv-app"

for app in AndroidAutoStub ConfigUpdater DeskClockGoogle GmsCore GoogleOneTimeInitializer \
           GooglePartnerSetup GoogleRestore GoogleServicesFramework Phonesky Velvet Wellbeing \
           GmsCoreMG GoogleServicesFrameworkMG PhoneskyMG PlayAutoInstallConfig \
           PixelLiveWallpaper GoogleFeedback GoogleBackupTransport GoogleContactsSyncAdapter \
           GoogleCalendarSyncAdapter SetupWizard GoogleLoginService \
           PrebuiltGmsCore Velvet GoogleDialer GoogleMessages SettingsIntelligenceGoogle \
           DevicePersonalizationServices PrivateComputeServices ConnectivityService \
           NetworkLocationBackup PlatformNetworkSecurityBackup SecurityHub Turbo \
           TurboPrebuilt DeviceSetup GoogleRestorePrebuilt CarrierMetrics; do
    if [ -e "$PRODUCT_MOUNT/priv-app/$app" ]; then
        rm -rf "$PRODUCT_MOUNT/priv-app/$app" 2>/dev/null
        ui_print "    ✓ $app removed"
    fi
done

ui_print "  → Removing Google components from /system/priv-app"

for app in GooglePackageInstaller GoogleFeedback GoogleBackupTransport \
           GoogleServicesFramework GoogleLoginService SetupWizard; do
    if [ -e "$SYSTEM_MOUNT/priv-app/$app" ]; then
        rm -rf "$SYSTEM_MOUNT/priv-app/$app" 2>/dev/null
        ui_print "    ✓ $app removed"
    fi
done

ui_print "  → Removing Google components from /system/app"

for app in GoogleExtShared GooglePrintRecommendationService PartnerBookmarksProvider \
           GoogleCalendarSyncAdapter GoogleContactsSyncAdapter GoogleTTS \
           Chrome GoogleCamera GoogleDialer GoogleMessages Gmail GoogleCalendar \
           GoogleDrive GoogleMaps YouTube YouTubeMusic GooglePhotos; do
    if [ -e "$SYSTEM_MOUNT/app/$app" ]; then
        rm -rf "$SYSTEM_MOUNT/app/$app" 2>/dev/null
        ui_print "    ✓ $app removed"
    fi
done

ui_print "  → Removing Google components from /system_ext/priv-app"

for app in GoogleServicesFramework MagicPortraitWallpapers SetupWizard \
           WallpaperPickerGoogleRelease GoogleFeedback GoogleOneTimeInitializer; do
    if [ -e "$SYSTEM_EXT_MOUNT/priv-app/$app" ]; then
        rm -rf "$SYSTEM_EXT_MOUNT/priv-app/$app" 2>/dev/null
        ui_print "    ✓ $app removed"
    fi
done

ui_print "  → Removing Google Overlay"

for overlay in GmsConfigOverlayASI GmsConfigOverlayCommon GmsConfigOverlayComms \
               GmsConfigOverlayGeotz GmsConfigOverlayGSA GmsContactsProviderOverlay \
               GmsFrameworksOverlay GmsSettingsOverlay GmsSettingsProviderOverlay \
               GmsSystemUIOverlay PixelWallpaperOverlay; do
    if [ -e "$PRODUCT_MOUNT/overlay/$overlay.apk" ]; then
        rm -rf "$PRODUCT_MOUNT/overlay/$overlay.apk" 2>/dev/null
        ui_print "    ✓ $overlay removed"
    fi
done
rm -rf "$PRODUCT_MOUNT/overlay" 2>/dev/null

ui_print "  → Removing additional Google configs"

rm -rf "$PRODUCT_MOUNT/etc/permissions/com.google.android.apps.dialer."* 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/permissions/privapp-permissions-google-comms-suite.xml" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/permissions/privapp-permissions-google-product.xml" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/permissions/privapp-permissions-google-p.xml" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/sysconfig/google-initial-package-stopped-states.xml" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/sysconfig/google_wifi_provisioner.xml" 2>/dev/null
rm -rf "$SYSTEM_MOUNT/etc/permissions/privapp-permissions-google-system.xml" 2>/dev/null
rm -rf "$SYSTEM_MOUNT/etc/sysconfig/google-hiddenapi-package-allowlist.xml" 2>/dev/null
rm -rf "$SYSTEM_EXT_MOUNT/etc/permissions/privapp-permissions-google-se.xml" 2>/dev/null
rm -rf "$SYSTEM_EXT_MOUNT/etc/permissions/privapp-permissions-google-system_ext.xml" 2>/dev/null

ui_print "  → Removing Google speech data"
if [ -d "$PRODUCT_MOUNT/usr/srec" ]; then
    rm -rf "$PRODUCT_MOUNT/usr/srec" 2>/dev/null
    ui_print "    ✓ Google speech data removed"
fi

ui_print "  → Removing Google preferences"
rm -rf "$PRODUCT_MOUNT/etc/preferred-apps" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/security" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/gms"* 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/google"* 2>/dev/null

ui_print "  → Removing basic Google configs"

rm -rf "$PRODUCT_MOUNT/etc/default-permissions/default-permissions-google.xml" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/default-permissions/opengapps-permissions.xml" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/permissions/com.google.android."* 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/permissions/privapp-permissions-google-"* 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/permissions/split-permissions-google.xml" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/permissions/com.google."* 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/sysconfig/d2d_cable_migration_feature.xml" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/sysconfig/google"* 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/sysconfig/personal_safety.xml" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/sysconfig/wellbeing.xml" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/sysconfig/gms"* 2>/dev/null
rm -rf "$PRODUCT_MOUNT/etc/sysconfig/play"* 2>/dev/null

ui_print "  → Removing Google media files"

rm -rf "$PRODUCT_MOUNT/media/audio/alarms/Fresh_start.ogg" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/media/audio/notifications/Eureka.ogg" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/media/audio/ringtones/Your_new_adventure.ogg" 2>/dev/null
rm -rf "$PRODUCT_MOUNT/media/audio/alarms/Google"* 2>/dev/null
rm -rf "$PRODUCT_MOUNT/media/audio/notifications/Google"* 2>/dev/null
rm -rf "$PRODUCT_MOUNT/media/audio/ringtones/Google"* 2>/dev/null

ui_print "  → Removing Google libraries"

rm -rf "$SYSTEM_MOUNT/lib/libtensorflowlite_jni.so" 2>/dev/null
rm -rf "$SYSTEM_MOUNT/lib64/libtensorflowlite_jni.so" 2>/dev/null
rm -rf "$SYSTEM_MOUNT/lib/libgoogle"* 2>/dev/null
rm -rf "$SYSTEM_MOUNT/lib64/libgoogle"* 2>/dev/null
rm -rf "$PRODUCT_MOUNT/lib/libgoogle"* 2>/dev/null
rm -rf "$PRODUCT_MOUNT/lib64/libgoogle"* 2>/dev/null

ui_print "  → Removing Google framework files"

rm -rf "$PRODUCT_MOUNT/framework/com.google."* 2>/dev/null
rm -rf "$SYSTEM_MOUNT/framework/com.google."* 2>/dev/null
rm -rf "$SYSTEM_EXT_MOUNT/framework/com.google."* 2>/dev/null

ui_print "  → Removing Google addon.d scripts"

rm -rf "/system/addon.d/90-gapps.sh" 2>/dev/null
rm -rf "/system/addon.d/69-gapps.sh" 2>/dev/null
rm -rf "/system/addon.d/70-gapps.sh" 2>/dev/null
rm -rf "/system/addon.d/80-gapps.sh" 2>/dev/null
rm -rf "/system/addon.d/90-gapps-"* 2>/dev/null

ui_print "    ✓ All Google components removed"

ui_print ""
ui_print "Step 4/9: Cleaning target directories"

ui_print "  → Cleaning system_ext/priv-app:"
for dir in Provision StatementService ThemePicker Updater; do
    if [ -d "$SYSTEM_EXT_MOUNT/priv-app/$dir" ]; then
        rm -rf "$SYSTEM_EXT_MOUNT/priv-app/$dir"
        ui_print "    ✓ $dir removed"
    fi
done

ui_print "  → Cleaning product/app:"
for dir in DeskClock ExactCalculator LatinIME webview; do
    if [ -d "$PRODUCT_MOUNT/app/$dir" ]; then
        rm -rf "$PRODUCT_MOUNT/app/$dir"
        ui_print "    ✓ $dir removed"
    fi
done

ui_print "  → Cleaning product/priv-app:"
if [ -d "$PRODUCT_MOUNT/priv-app/Contacts" ]; then
    rm -rf "$PRODUCT_MOUNT/priv-app/Contacts"
    ui_print "    ✓ Contacts removed"
fi

ui_print "  → Cleaning system/priv-app:"
for dir in PackageInstaller SoundPicker; do
    if [ -d "$SYSTEM_MOUNT/priv-app/$dir" ]; then
        rm -rf "$SYSTEM_MOUNT/priv-app/$dir"
        ui_print "    ✓ $dir removed"
    fi
done

ui_print "  → Cleaning system/app:"
for dir in ExtShared PrintRecommendationService ViaBrowser; do
    if [ -d "$SYSTEM_MOUNT/app/$dir" ]; then
        rm -rf "$SYSTEM_MOUNT/app/$dir"
        ui_print "    ✓ $dir removed"
    fi
done

ui_print "  → Cleaning config files:"
rm -f "$PRODUCT_MOUNT/etc/default-permissions/com.android.deskclock_default-permissions.xml" 2>/dev/null
rm -f "$PRODUCT_MOUNT/etc/permissions/com.android.contacts.xml" 2>/dev/null
rm -f "$PRODUCT_MOUNT/etc/sysconfig/com.android.deskclock_allowlist.xml" 2>/dev/null
rm -f "$PRODUCT_MOUNT/lib64/libjni_latinime.so" 2>/dev/null
rm -f "$SYSTEM_EXT_MOUNT/etc/permissions/android.software.theme_picker.xml" 2>/dev/null
rm -f "$SYSTEM_EXT_MOUNT/etc/permissions/com.android.provision.xml" 2>/dev/null
rm -f "$SYSTEM_EXT_MOUNT/etc/permissions/com.android.statementservice.xml" 2>/dev/null

ui_print "  → Cleaning NOTICE.xml.gz and aconfig files"
rm -f "$PRODUCT_MOUNT/etc/NOTICE.xml.gz" 2>/dev/null
rm -f "$SYSTEM_MOUNT/etc/NOTICE.xml.gz" 2>/dev/null
rm -f "$SYSTEM_EXT_MOUNT/etc/NOTICE.xml.gz" 2>/dev/null
rm -rf "$SYSTEM_EXT_MOUNT/etc/aconfig" 2>/dev/null
rm -f "$SYSTEM_EXT_MOUNT/etc/aconfig_flags.pb" 2>/dev/null

ui_print "    ✓ All target directories cleaned"

ui_print ""
ui_print "Step 5/9: Restoring AOSP"

restore_item() {
    local src="$EX_DIR/$1"
    local dst="$2"
    local name="$3"
    local check_apk="$4"
    
    if [ -d "$src" ]; then
        mkdir -p "$dst"
        cp -rf "$src"/* "$dst/" 2>/dev/null
        
        if [ -d "$dst/$name" ]; then
            cp -rf "$dst/$name"/* "$dst/" 2>/dev/null
            rm -rf "$dst/$name"
        fi
        
        if [ -n "$check_apk" ]; then
            if [ -f "$dst/$check_apk" ]; then
                ui_print "    ✓ $name"
            else
                ui_print "    ⚠️ $name - APK not found, but folder copied"
            fi
        else
            ui_print "    ✓ $name"
        fi
    elif [ -f "$src" ]; then
        mkdir -p "$(dirname "$dst")"
        cp -f "$src" "$dst"
        ui_print "    ✓ $name"
    fi
}

ui_print "  → Restoring to /system_ext/priv-app"
restore_item "system_ext/priv-app/Provision" "$SYSTEM_EXT_MOUNT/priv-app/Provision" "Provision" "Provision.apk"
restore_item "system_ext/priv-app/StatementService" "$SYSTEM_EXT_MOUNT/priv-app/StatementService" "StatementService" "StatementService.apk"
restore_item "system_ext/priv-app/ThemePicker" "$SYSTEM_EXT_MOUNT/priv-app/ThemePicker" "ThemePicker" "ThemePicker.apk"
restore_item "system_ext/priv-app/Updater" "$SYSTEM_EXT_MOUNT/priv-app/Updater" "Updater" "Updater.apk"

ui_print "  → Restoring to /system/priv-app"
restore_item "system/priv-app/PackageInstaller" "$SYSTEM_MOUNT/priv-app/PackageInstaller" "PackageInstaller" "PackageInstaller.apk"
restore_item "system/priv-app/SoundPicker" "$SYSTEM_MOUNT/priv-app/SoundPicker" "SoundPicker" "SoundPicker.apk"

ui_print "  → Restoring to /system/app"
restore_item "system/app/ExtShared" "$SYSTEM_MOUNT/app/ExtShared" "ExtShared" "ExtShared.apk"
restore_item "system/app/PrintRecommendationService" "$SYSTEM_MOUNT/app/PrintRecommendationService" "PrintRecommendationService" "PrintRecommendationService.apk"
restore_item "system/app/ViaBrowser" "$SYSTEM_MOUNT/app/ViaBrowser" "ViaBrowser" "ViaBrowser.apk"

ui_print "  → Restoring to /product/app"
restore_item "product/app/DeskClock" "$PRODUCT_MOUNT/app/DeskClock" "DeskClock" "DeskClock.apk"
restore_item "product/app/ExactCalculator" "$PRODUCT_MOUNT/app/ExactCalculator" "ExactCalculator" "ExactCalculator.apk"
restore_item "product/app/LatinIME" "$PRODUCT_MOUNT/app/LatinIME" "LatinIME" "LatinIME.apk"
restore_item "product/app/webview" "$PRODUCT_MOUNT/app/webview" "webview" "webview.apk"

ui_print "  → Restoring to /product/priv-app"
restore_item "product/priv-app/Contacts" "$PRODUCT_MOUNT/priv-app/Contacts" "Contacts" "Contacts.apk"

ui_print "  → Restoring configs"
restore_item "product/etc/default-permissions/com.android.deskclock_default-permissions.xml" \
            "$PRODUCT_MOUNT/etc/default-permissions/com.android.deskclock_default-permissions.xml" \
            "deskclock permissions"
restore_item "product/etc/permissions/com.android.contacts.xml" \
            "$PRODUCT_MOUNT/etc/permissions/com.android.contacts.xml" \
            "contacts permissions"
restore_item "product/etc/sysconfig/com.android.deskclock_allowlist.xml" \
            "$PRODUCT_MOUNT/etc/sysconfig/com.android.deskclock_allowlist.xml" \
            "deskclock allowlist"
restore_item "product/lib64/libjni_latinime.so" \
            "$PRODUCT_MOUNT/lib64/libjni_latinime.so" \
            "libjni_latinime.so"

ui_print "  → Restoring system_ext permissions"
restore_item "system_ext/etc/permissions/android.software.theme_picker.xml" \
            "$SYSTEM_EXT_MOUNT/etc/permissions/android.software.theme_picker.xml" \
            "theme_picker"
restore_item "system_ext/etc/permissions/com.android.provision.xml" \
            "$SYSTEM_EXT_MOUNT/etc/permissions/com.android.provision.xml" \
            "provision"
restore_item "system_ext/etc/permissions/com.android.statementservice.xml" \
            "$SYSTEM_EXT_MOUNT/etc/permissions/com.android.statementservice.xml" \
            "statementservice"

ui_print "  → Restoring NOTICE.xml.gz"
restore_item "product/etc/NOTICE.xml.gz" "$PRODUCT_MOUNT/etc/NOTICE.xml.gz" "product NOTICE"
restore_item "system/etc/NOTICE.xml.gz" "$SYSTEM_MOUNT/etc/NOTICE.xml.gz" "system NOTICE"
restore_item "system_ext/etc/NOTICE.xml.gz" "$SYSTEM_EXT_MOUNT/etc/NOTICE.xml.gz" "system_ext NOTICE"

ui_print "  → Restoring aconfig files"
restore_item "system_ext/etc/aconfig/flag.info" "$SYSTEM_EXT_MOUNT/etc/aconfig/flag.info" "flag.info"
restore_item "system_ext/etc/aconfig/flag.map" "$SYSTEM_EXT_MOUNT/etc/aconfig/flag.map" "flag.map"
restore_item "system_ext/etc/aconfig/flag.val" "$SYSTEM_EXT_MOUNT/etc/aconfig/flag.val" "flag.val"
restore_item "system_ext/etc/aconfig/package.map" "$SYSTEM_EXT_MOUNT/etc/aconfig/package.map" "package.map"
restore_item "system_ext/etc/aconfig_flags.pb" "$SYSTEM_EXT_MOUNT/etc/aconfig_flags.pb" "aconfig_flags.pb"

ui_print ""
ui_print "Step 6/9: Setting permissions"

ui_print "  → Setting directory permissions (755):"

for dir in \
    "$SYSTEM_EXT_MOUNT/priv-app/Provision" \
    "$SYSTEM_EXT_MOUNT/priv-app/StatementService" \
    "$SYSTEM_EXT_MOUNT/priv-app/ThemePicker" \
    "$SYSTEM_EXT_MOUNT/priv-app/Updater" \
    "$SYSTEM_MOUNT/priv-app/PackageInstaller" \
    "$SYSTEM_MOUNT/priv-app/SoundPicker" \
    "$SYSTEM_MOUNT/app/ExtShared" \
    "$SYSTEM_MOUNT/app/PrintRecommendationService" \
    "$SYSTEM_MOUNT/app/ViaBrowser" \
    "$PRODUCT_MOUNT/app/DeskClock" \
    "$PRODUCT_MOUNT/app/ExactCalculator" \
    "$PRODUCT_MOUNT/app/LatinIME" \
    "$PRODUCT_MOUNT/app/webview" \
    "$PRODUCT_MOUNT/priv-app/Contacts"; do
    if [ -d "$dir" ]; then
        chmod -R 755 "$dir" 2>/dev/null
        chown -R 0:0 "$dir" 2>/dev/null
    fi
done

ui_print "    ✓ Directory permissions set"

ui_print "  → Setting config file permissions (644):"

for file in \
    "$PRODUCT_MOUNT/etc/default-permissions/com.android.deskclock_default-permissions.xml" \
    "$PRODUCT_MOUNT/etc/permissions/com.android.contacts.xml" \
    "$PRODUCT_MOUNT/etc/sysconfig/com.android.deskclock_allowlist.xml" \
    "$PRODUCT_MOUNT/lib64/libjni_latinime.so" \
    "$SYSTEM_EXT_MOUNT/etc/permissions/android.software.theme_picker.xml" \
    "$SYSTEM_EXT_MOUNT/etc/permissions/com.android.provision.xml" \
    "$SYSTEM_EXT_MOUNT/etc/permissions/com.android.statementservice.xml" \
    "$PRODUCT_MOUNT/etc/NOTICE.xml.gz" \
    "$SYSTEM_MOUNT/etc/NOTICE.xml.gz" \
    "$SYSTEM_EXT_MOUNT/etc/NOTICE.xml.gz" \
    "$SYSTEM_EXT_MOUNT/etc/aconfig_flags.pb"; do
    if [ -f "$file" ]; then
        chmod 644 "$file" 2>/dev/null
        chown 0:0 "$file" 2>/dev/null
    fi
done

for file in \
    "$SYSTEM_EXT_MOUNT/etc/aconfig/flag.info" \
    "$SYSTEM_EXT_MOUNT/etc/aconfig/flag.map" \
    "$SYSTEM_EXT_MOUNT/etc/aconfig/flag.val" \
    "$SYSTEM_EXT_MOUNT/etc/aconfig/package.map"; do
    if [ -f "$file" ]; then
        chmod 644 "$file" 2>/dev/null
        chown 0:0 "$file" 2>/dev/null
    fi
done

ui_print "    ✓ Config file permissions set"

ui_print ""
ui_print "Step 7/9: Final double nesting check"

check_double_nesting() {
    local dir="$1"
    local name="$2"
    if [ -d "$dir/$name" ]; then
        cp -rf "$dir/$name"/* "$dir/" 2>/dev/null
        rm -rf "$dir/$name"
        return 0
    fi
    return 1
}

check_double_nesting "$SYSTEM_EXT_MOUNT/priv-app/Provision" "Provision"
check_double_nesting "$SYSTEM_EXT_MOUNT/priv-app/StatementService" "StatementService"
check_double_nesting "$SYSTEM_EXT_MOUNT/priv-app/ThemePicker" "ThemePicker"
check_double_nesting "$SYSTEM_EXT_MOUNT/priv-app/Updater" "Updater"
check_double_nesting "$SYSTEM_MOUNT/priv-app/PackageInstaller" "PackageInstaller"
check_double_nesting "$SYSTEM_MOUNT/priv-app/SoundPicker" "SoundPicker"
check_double_nesting "$SYSTEM_MOUNT/app/ExtShared" "ExtShared"
check_double_nesting "$SYSTEM_MOUNT/app/PrintRecommendationService" "PrintRecommendationService"
check_double_nesting "$SYSTEM_MOUNT/app/ViaBrowser" "ViaBrowser"
check_double_nesting "$PRODUCT_MOUNT/app/DeskClock" "DeskClock"
check_double_nesting "$PRODUCT_MOUNT/app/ExactCalculator" "ExactCalculator"
check_double_nesting "$PRODUCT_MOUNT/app/LatinIME" "LatinIME"
check_double_nesting "$PRODUCT_MOUNT/app/webview" "webview"
check_double_nesting "$PRODUCT_MOUNT/priv-app/Contacts" "Contacts"

ui_print "    ✓ Check completed"

ui_print ""
ui_print "Step 8/9: Cleaning cache"

rm -rf /data/dalvik-cache/* 2>/dev/null
ui_print "  ✓ Dalvik-cache cleaned"

rm -rf /cache/* 2>/dev/null
ui_print "  ✓ /cache cleaned"

rm -rf /data/system/package_cache/* 2>/dev/null
ui_print "  ✓ Package cache cleaned"

ui_print ""
ui_print "Step 9/9: Final cleanup"

rm -rf "$EX_DIR"
ui_print "  ✓ Temporary files removed"

sync
ui_print "  ✓ Data synced"

ui_print ""
ui_print "========================================="
ui_print "   ✅ gapps-to-vanilla COMPLETED!"
ui_print "========================================="
ui_print ""
ui_print "  ❌ ALL GAPPS REMOVED:"
ui_print "     - Google apps and services"
ui_print "     - Overlay and configs"
ui_print "     - Speech data and media files"
ui_print "     - addon.d survival scripts"
ui_print ""
ui_print "  ✅ AOSP COMPONENTS RESTORED:"
ui_print "     - All AOSP apps"
ui_print "     - NOTICE.xml.gz licenses"
ui_print "     - Aconfig flag files"
ui_print "     - Configs and permissions"
ui_print ""
ui_print "  ✅ Permissions set"
ui_print "  ✅ Cache cleaned"
ui_print ""
ui_print "  Reboot your device!"

exit 0
EOF

cat > "$WORK_DIR/META-INF/com/google/android/updater-script" << 'EOF'
ui_print("Installing gapps-to-vanilla package...");
run_program("/sbin/sh", "/META-INF/com/google/android/update-binary", "", "/tmp/update.zip");
EOF

echo ""
echo "========================================="
echo "  Creating ZIP archive..."
echo "========================================="

cd "$WORK_DIR"
zip -r ../gapps-to-vanilla.zip . -x "*.DS_Store" > /dev/null
cd ..

if [ -f "gapps-to-vanilla.zip" ]; then
    echo ""
    echo "========================================="
    echo "  ✅ Archive created: gapps-to-vanilla.zip"
    echo "  Size: $(du -h gapps-to-vanilla.zip | cut -f1)"
    echo "========================================="
    echo ""
    echo "✅ REMOVED (present in gapps, absent in vanilla):"
    echo "  ✓ All Google apps and services"
    echo "  ✓ GoogleServicesFramework, SetupWizard"
    echo "  ✓ WallpaperPickerGoogleRelease"
    echo "  ✓ Overlay (11 items)"
    echo "  ✓ Speech data srec"
    echo "  ✓ preferred-apps, security"
    echo "  ✓ Additional configs"
    echo ""
    echo "✅ RESTORED (present in vanilla, absent in gapps):"
    echo "  ✓ All AOSP apps"
    echo "  ✓ NOTICE.xml.gz (3 files)"
    echo "  ✓ Aconfig files (5 files)"
    echo "  ✓ All permissions and configs"
    echo ""
    echo "⚠️ NOT TOUCHED (binary differences):"
    echo "  ✗ build.prop (different versions)"
    echo "  ✗ vendor files (device firmware)"
    echo "  ✗ bin/linker* (system libraries)"
    echo ""
    echo "INSTALLATION:"
    echo "1. Copy gapps-to-vanilla.zip to device"
    echo "2. Boot to recovery (TWRP / OrangeFox)"
    echo "3. Install → select gapps-to-vanilla.zip"
    echo "4. Wait for 9 installation steps"
    echo "5. Reboot System"
    echo "========================================="
else
    echo "❌ Failed to create archive!"
    exit 1
fi
