mkdir -p "$WORK_DIR/vendor/tee_asia"
mkdir -p "$WORK_DIR/vendor/tee_eur"
mkdir -p "$WORK_DIR/vendor/tee_sea"
mkdir -p "$WORK_DIR/vendor/firmware/asia"
mkdir -p "$WORK_DIR/vendor/firmware/eur"
mkdir -p "$WORK_DIR/vendor/firmware/sea"
mkdir -p "$WORK_DIR/vendor/tee"
rm -rf "$WORK_DIR/vendor/tee/*"
cp -a --preserve=all "$SRC_DIR/target/a54x/patches/vendor/vendor/etc/"* "$WORK_DIR/vendor/etc"
cp -a --preserve=all "$SRC_DIR/target/a54x/patches/vendor/vendor/firmware/"* "$WORK_DIR/vendor/firmware"
cp -a --preserve=all "$SRC_DIR/target/a54x/patches/vendor/vendor/tee_*" "$WORK_DIR/vendor"




if ! grep -q "tee_file (dir (mounton" "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"; then
    echo "(allow init_33_0 tee_file (dir (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow priv_app_33_0 tee_file (dir (getattr)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow init_33_0 vendor_fw_file (file (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow priv_app_33_0 vendor_fw_file (file (getattr)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
fi
