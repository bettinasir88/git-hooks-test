#!/bin/bash

SCRIPT_DIR=$(dirname $0)
HOOK_NAME=$(basename $0)
HOOK_DIR="$SCRIPT_DIR/$HOOK_NAME.d"

for hook in $HOOK_DIR/*; do
    test -x "$hook" || continue
    echo "$data" | "$hook"
    exitcodes+=($?)
done

for i in "${exitcodes[@]}"; do
    # If any exit code isn't 0, bail.
    if [ "$i" != 0 ]; then
        echo -e "\n\nThe $HOOK_NAME hook failed. Please fix the errors before continuing.\n"
        exit $i
    fi
done
