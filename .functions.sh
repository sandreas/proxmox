#!/bin/bash

install_package() {
  dpkg -s "$1" &> /dev/null || /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install "$1"
}
