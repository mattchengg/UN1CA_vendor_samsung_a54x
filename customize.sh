SKIPUNZIP=1

mv -f "$WORK_DIR/vendor/tee" "$WORK_DIR/vendor/tee_asia" || true

for file in AIE.bin mfc_fw.bin pablo_icpufw.bin calliope_sram.bin os.checked.bin vts.bin; do
  mkdir -p "$WORK_DIR/vendor/firmware/asia"
  mv -f "$WORK_DIR/vendor/firmware/$file" "$WORK_DIR/vendor/firmware/asia" || true
done
for region in eur sea; do
  cp -a --preserve=all "$SDR_DIR/target/a54x/patches/vendor/vendor/tee_$region/*" "$WORK_DIR/vendor/tee_$region" || true
  for file in AIE.bin mfc_fw.bin pablo_icpufw.bin calliope_sram.bin os.checked.bin vts.bin; do
    mkdir -p "$WORK_DIR/vendor/firmware/$region"
    mkdir -p "$WORK_DIR/vendor/tee_$region"
    cp -a --preserve=all "$SDR_DIR/target/a54x/patches/vendor/vendor/firmware/$file" "$WORK_DIR/vendor/firmware/$region" || true
  done
done

if ! grep -q "tee_blobs" "$WORK_DIR/configs/file_context-vendor"; then
    {
        echo "/vendor/etc/init/tee_blobs\.rc u:object_r:vendor_configs_file:s0"
        echo "/vendor/tee u:object_r:tee_file:s0"
    } >> "$WORK_DIR/configs/file_context-vendor"
fi

if ! grep -q "tee_blobs" "$WORK_DIR/configs/fs_config-vendor"; then
    {
        echo "vendor/etc/init/tee_blobs.rc 0 0 644 capabilities=0x0"
        echo "vendor/tee 0 2000 755 capabilities=0x0"
    } >> "$WORK_DIR/configs/fs_config-vendor"
fi

REGIONS=("asia" "eur" "sea")
FILES=("file_context-vendor" "fs_config-vendor")

for region in "${REGIONS[@]}"; do
    for file in "${FILES[@]}"; do
        target_file="$WORK_DIR/configs/$file"
        source_file="$SRC_DIR/target/a54x/patches/vendor/${file}-${region}"
        echo "$REGIONS"
        echo "$SRC_DIR"
        ls $SRC_DIR

        tee_tag="tee_${region}"
        firmware_path="/vendor/firmware/${region}/"

        if ! grep -q "vendor/$tee_tag" "$target_file"; then
            grep -E "AIE|mfc_fw|pablo_icpufw|calliope_sram|os\.checked|vts|vendor/tee" "$source_file" \
            | sed -e "s/\btee\b/$tee_tag/g" -e "s|/vendor/firmware/|$firmware_path|g" \
            >> "$target_file"
        fi
    done
done

if ! grep -q "tee_file (dir (mounton" "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"; then
    echo "(allow init_33_0 tee_file (dir (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow priv_app_33_0 tee_file (dir (getattr)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow init_33_0 vendor_fw_file (file (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow priv_app_33_0 vendor_fw_file (file (getattr)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
fi
