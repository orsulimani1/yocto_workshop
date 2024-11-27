# !/bin/bash

# Define the directory path
DIR="yocto/poky"

# Check if the directory exists
if [ -d "$DIR" ]; then
    # Navigate to the poky directory
    cd "$DIR" || { echo "Failed to change directory to $DIR"; exit 1; }

    # Source the oe-init-build-env script with the specified build directory
    source oe-init-build-env ../../build/

else
    echo "The directory '$DIR' run 'git submodule update --init --recursive"
fi

ln -s ../../meta-ti yocto/poky/meta-ti
