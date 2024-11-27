#!/bin/bash

# Usage: ./add_layers_from_gitmodules.sh <bblayers-location> <excluded-submodules>

# Input Arguments
BBLAYERS_LOCATION=$1
EXCLUDED_SUBMODULES="yocto/poky"

# Validate Inputs
if [ -z "$BBLAYERS_LOCATION" ]; then
    echo "Usage: $0 <bblayers-location> <excluded-submodules (comma-separated)>"
    exit 1
fi

# Parse excluded submodules into an array
IFS=',' read -r -a EXCLUDE_LIST <<< "$EXCLUDED_SUBMODULES"

# Check if .gitmodules exists
if [ ! -f .gitmodules ]; then
    echo "Error: .gitmodules file not found in the current directory."
    exit 1
fi

# Ensure bblayers.conf exists
BBLAYERS_CONF="$BBLAYERS_LOCATION/conf/bblayers.conf"
if [ ! -f "$BBLAYERS_CONF" ]; then
    echo "Error: bblayers.conf not found at $BBLAYERS_LOCATION."
    exit 1
fi

# Function to check if a submodule is excluded
is_excluded() {
    local submodule=$1
    for exclude in "${EXCLUDE_LIST[@]}"; do
        if [[ "$submodule" == "$exclude" ]]; then
            return 0
        fi
    done
    return 1
}

# Parse .gitmodules for submodule paths and URLs
echo "Processing submodules from .gitmodules..."
SUBMODULES=()
while IFS= read -r line; do
    if [[ "$line" =~ ^\[submodule ]]; then
        SUBMODULE=$(echo "$line" | sed -e 's/\[submodule "\(.*\)"\]/\1/')
    elif [[ "$line" =~ ^path ]]; then
        PATH=$(echo "$line" | sed -e 's/path = //')
    elif [[ "$line" =~ ^url ]]; then
        URL=$(echo "$line" | sed -e 's/url = //')
        
        # Check if submodule is excluded
        if is_excluded "$SUBMODULE"; then
            echo "Skipping excluded submodule: $SUBMODULE"
            continue
        fi

        # Clone the submodule if it doesn't exist
        if [ ! -d "$PATH" ]; then
            echo "Cloning submodule '$SUBMODULE' from $URL..."
            git clone "$URL" "$PATH"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to clone $SUBMODULE."
                continue
            fi
        else
            echo "Submodule '$SUBMODULE' already exists. Skipping clone."
        fi

        # Add the layer to bblayers.conf if not already present
        LAYER_PATH="$(pwd)/$PATH"
        if grep -q "$LAYER_PATH" "$BBLAYERS_CONF"; then
            echo "Layer '$LAYER_PATH' is already in bblayers.conf."
        else
            echo "Adding layer '$LAYER_PATH' to bblayers.conf..."
            sed -i "/^BBLAYERS/s/]/  \"$LAYER_PATH\",]/" "$BBLAYERS_CONF"
            if [ $? -eq 0 ]; then
                echo "Layer added successfully."
            else
                echo "Error: Failed to add the layer to bblayers.conf."
            fi
        fi
    fi
done < <(grep -E '^\[submodule|path =|url =' .gitmodules)

echo "Submodule processing complete."