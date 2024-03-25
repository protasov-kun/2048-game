#!/bin/bash

# Получаем IP-адрес из Terraform output
ip_address=$(terraform output | grep external_ip_address_game01 | cut -d' ' -f3 | sed 's/"//g')

# Создаем временный файл для обновленных данных
temp_file=$(mktemp)

# Заменяем IP-адрес в файле hosts
awk -v ip="$ip_address" '/game01/ {sub(/ansible_host=[0-9.]*/, "ansible_host=" ip)} 1' hosts > "$temp_file"

# Перемещаем временный файл на место исходного
mv "$temp_file" hosts
