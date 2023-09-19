#!/usr/bin/env bash

set -euxo pipefail

moreutils_url='http://deb.debian.org/debian/pool/main/m/moreutils/moreutils_0.67.orig.tar.gz'
pkgbase="moreutils-0.67"
tarball="$pkgbase.tar.gz"

curl -#fSL -o "$tarball" "$moreutils_url"
tar xzvf "$tarball"
pushd "$pkgbase"
make pee
sudo make install
popd
