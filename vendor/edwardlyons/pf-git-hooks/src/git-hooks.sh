#!/bin/bash

###############################################################################
# This script makes it possible to have multiple hooks for the same git hook.
# It copies all directories in the git-hooks directory to the .git/hooks/
# directory and creates a symlink to the multihook.sh script that takes care of
# running all the hooks inside the *.d directory for that specific hook.
###############################################################################

HOME_DIR=$(pwd)
SCRIPT_DIR=$(dirname $0)

# Loop through all directories in the git-hooks folder
for i in $(ls -d $SCRIPT_DIR/git-hooks/*/); do
    # Copy the folder containing the hooks to the actual git hooks folder
    cp -R ${i%%/} $HOME_DIR/.git/hooks/

    # Create a symlink to the multihook script for the specific hook
    DIR_NAME=$(basename ${i%%/})
    HOOK_NAME=${DIR_NAME/.d/}
    TARGET_PATH="../../setup/git-hooks/multihook.sh"
    LINK_PATH="$HOME_DIR/.git/hooks/$HOOK_NAME"
    CURRENT_LINK_PATH=$(readlink $HOME_DIR/.git/hooks/$HOOK_NAME)

    # Make sure we only create the symlink if there is no existing hook
    if [ -f $LINK_PATH ] && [ ! -h $LINK_PATH ]
    then
        echo "Error: The $HOOK_NAME hook already exists. Can't create symlink."
    elif [ -h $LINK_PATH ] && [ "$TARGET_PATH" != "$CURRENT_LINK_PATH" ]
    then
        echo "Error: A symlink for the $HOOK_NAME hook already exists but points to a different target."
    elif [ ! -f $LINK_PATH ]
    then
        # Create the symlink if it doesn't exist
        ln -s $TARGET_PATH $LINK_PATH
    fi
done

# Make sure the multihook.sh script is executable
chmod +x $SCRIPT_DIR/git-hooks/multihook.sh
