#!/bin/bash

# Define the paths to the necessary files
VENDOR_BLOBS_RC="etc/init/vendor_blobs.rc"
FILE_CONTEXT_VENDOR="vendor/file_context-vendor"
FS_CONFIG_VENDOR="vendor/fs_config-vendor"

# Create or clear the output files
> $FILE_CONTEXT_VENDOR
> $FS_CONFIG_VENDOR

# Read the vendor_blobs.rc file and generate entries for file_context-vendor and fs_config-vendor
while IFS= read -r line; do
    if [[ $line == mount* ]]; then
        src=$(echo $line | awk '{print $4}')
        dest=$(echo $line | awk '{print $5}')
        
        # Add entries to file_context-vendor
        echo "$dest u:object_r:vendor_fw_file:s0" >> $FILE_CONTEXT_VENDOR
        
        # Add entries to fs_config-vendor
        echo "${dest#/} 0 0 644 capabilities=0x0" >> $FS_CONFIG_VENDOR
    fi
done < $VENDOR_BLOBS_RC

# Ensure the generated files are consistent with the existing files
sort -u $FILE_CONTEXT_VENDOR -o $FILE_CONTEXT_VENDOR
sort -u $FS_CONFIG_VENDOR -o $FS_CONFIG_VENDOR
