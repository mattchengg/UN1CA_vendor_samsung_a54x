#!/bin/bash

# Generate fs_config-vendor
find vendor -type d -exec echo "{} 0 2000 755 capabilities=0x0" \; > fs_config-vendor
find vendor -type f -exec echo "{} 0 0 644 capabilities=0x0" \; >> fs_config-vendor

# Generate file_context-vendor
find vendor -type d -exec echo "{} u:object_r:tee_file:s0" \; > file_context-vendor
find vendor -type f -exec echo "{} u:object_r:tee_file:s0" \; >> file_context-vendor
