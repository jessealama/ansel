#!/bin/bash

APPLICATIONS=/Applications
WOW=$APPLICATIONS/World\ of\ Warcraft
ADDON_DIR=$WOW/Interface/AddOns
ANSEL_DIR=$ADDON_DIR/Ansel
ANSEL_FILES='Ansel.lua Ansel.xml Ansel.toc Bindings.xml'

if [[ ! -d $ANSEL_DIR ]]; then
    echo Making Ansel directory in $ADDON_DIR;
    mkdir "$ANSEL_DIR";
fi

echo -n Installing ansel...;

for i in $ANSEL_FILES; do
    cp $i "$ANSEL_DIR";
done

echo done
