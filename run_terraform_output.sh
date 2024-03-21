#!/bin/bash

terraform output | grep external_ip_address_game01 | cut -d' ' -f3 | sed 's/"//g' > game01_ipv4_address.txt
awk '/^ *game01:/ {print; getline new_ip < "game01_ipv4_address.txt"; print "      ansible_host:", new_ip; f=1; next} f && /^ *ansible_host:/ {f=0; next} 1' inventory.yaml > temp && mv temp inventory.yaml
rm game01_ipv4_address.txt