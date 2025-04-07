
DELETE_FROM_WORK_DIR "vendor" "tee/*"

WORK_VENDOR_DIR="$WORK_DIR/vendor"
SRC_PATCH_DIR="$SRC_DIR/target/$TARGET_CODENAME/patches/vendor"

FILES="file_context-vendor fs_config-vendor"

for FILE in $FILES; do
    WORK_FILE="$WORK_VENDOR_DIR/$FILE"
    SRC_FILE="$SRC_PATCH_DIR/$FILE"

    echo "$FILE："

    if [ ! -f "$WORK_FILE" ]; then
        echo "$WORK_FILE not found"
        continue
    fi

    if [ ! -f "$SRC_FILE" ]; then
        echo "$SRC_FILE not found"
        continue
    fi

    TMP_WORK="$WORK_DIR/.tmp_diff_work.txt"
    TMP_SRC="$WORK_DIR/.tmp_diff_src.txt"

    sort "$WORK_FILE" | uniq > "$TMP_WORK"
    sort "$SRC_FILE" | uniq > "$TMP_SRC"

    NEW_LINES=$(comm -13 "$TMP_WORK" "$TMP_SRC")

    if [ -n "$NEW_LINES" ]; then
        echo "$NEW_LINES" >> "$WORK_FILE"
        echo " add SRC_DIR $FILES to WORK_DIR $FILES"
    fi

    rm -f "$TMP_WORK" "$TMP_SRC"
done


if ! grep -q "tee_file (dir (mounton" "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"; then
    echo "(allow init_33_0 tee_file (dir (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow priv_app_33_0 tee_file (dir (getattr)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow init_33_0 vendor_fw_file (file (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow priv_app_33_0 vendor_fw_file (file (getattr)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
fi
