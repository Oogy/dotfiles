#!/usr/bin/env bash

pushd ${HOME}
git clone https://github.com/oogy/dotfiles.git && pushd dotfiles && ./setup.sh
