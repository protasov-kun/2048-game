#!/bin/bash

# Получаем IP-адрес из Terraform output
ip_address=$(terraform output | grep external_ip_address_game01 | cut -d' ' -f3 | sed 's/"//g')

# Заменяем IP-адрес второй строки файла hosts
sed -i "2 s/[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+/$ip_address/" hosts