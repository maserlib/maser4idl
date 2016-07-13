#!/bin/bash

# Set READ/WRITE privileges to users for maser4idl Git repos.
# X.Bonnin (LESIA, Obs.Paris, CNRS), 13-JUL-2016

ssh git@git.obspm.fr perms projets/Plasma/maser4idl + WRITERS xbonnin
ssh git@git.obspm.fr perms projets/Plasma/maser4idl + WRITERS qnnguyen
ssh git@git.obspm.fr perms projets/Plasma/maser4idl + WRITERS cecconi
ssh git@git.obspm.fr perms projets/Plasma/maser4idl + READERS anonymous
