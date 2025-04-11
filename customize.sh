SKIPUNZIP=1

echo "Moving vendor/tee to vendor/tee_asia"
mv -f "$WORK_DIR/vendor/tee" "$WORK_DIR/vendor/tee_asia"
mkdir -p "$WORK_DIR/vendor/tee" 

echo "Moving firmware files to asia directory"
for file in AIE.bin mfc_fw.bin pablo_icpufw.bin calliope_sram.bin os.checked.bin vts.bin; do
  mkdir -p "$WORK_DIR/vendor/firmware/asia"
  mv -f "$WORK_DIR/vendor/firmware/$file" "$WORK_DIR/vendor/firmware/asia"
done

for region in eur sea; do
  echo "Copying files for $region regions"
  cp -a --preserve=all "$SRC_DIR/target/a54x/patches/vendor/vendor/tee_$region" "$WORK_DIR/vendor"
  for file in AIE.bin mfc_fw.bin pablo_icpufw.bin calliope_sram.bin os.checked.bin vts.bin; do
    echo "Copying $region firmware/$file to $WORK_DIR/vendor/firmware/$region"
    mkdir -p "$WORK_DIR/vendor/firmware/$region"
    cp -a --preserve=all "$SRC_DIR/target/a54x/patches/vendor/vendor/firmware/$region/$file" "$WORK_DIR/vendor/firmware/$region"
  done
done

if ! grep -q "tee_blobs" "$WORK_DIR/configs/file_context-vendor"; then
    {
        echo "/vendor/etc/init/tee_blobs\.rc u:object_r:vendor_configs_file:s0"
    } >> "$WORK_DIR/configs/file_context-vendor"
fi

if ! grep -q "tee_blobs" "$WORK_DIR/configs/fs_config-vendor"; then
    {
        echo "vendor/etc/init/tee_blobs.rc 0 0 644 capabilities=0x0"
    } >> "$WORK_DIR/configs/fs_config-vendor"
fi

REGIONS=("asia" "eur" "sea")
FILES=("file_context-vendor" "fs_config-vendor")

for region in "${REGIONS[@]}"; do
    for file in "${FILES[@]}"; do
        target_file="$WORK_DIR/configs/$file"
        source_file="$SRC_DIR/target/a54x/patches/vendor/${file}-${region}"
        echo "Add $region $file to $file"
        tee_tag="tee_${region}"
        firmware_path="vendor/firmware/${region}/"

        if ! grep -q "vendor/$tee_tag" "$target_file"; then
            grep -E "AIE|mfc_fw|pablo_icpufw|calliope_sram|os\.checked|vts|vendor/tee" "$source_file" \
            | sed -e "s/\btee\b/$tee_tag/g" -e "s|vendor/firmware/|$firmware_path|g" \
            >> "$target_file"
        fi
    done
    echo "/vendor/firmware/$region u:object_r:vendor_fw_file:s0" >> "$WORK_DIR/configs/file_context-vendor"
    echo "vendor/firmware/$region 0 2000 755 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-vendor"
    fi
done

if ! grep -q "tee_file (dir (mounton" "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"; then
    echo "(allow init_33_0 tee_file (dir (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow priv_app_33_0 tee_file (dir (getattr)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow init_33_0 vendor_fw_file (file (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow priv_app_33_0 vendor_fw_file (file (getattr)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
fi
