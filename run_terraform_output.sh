#!/bin/bash

# Получаем IP-адрес из Terraform output
ip_address=$(terraform output | grep external_ip_address_game01 | cut -d' ' -f3 | sed 's/"//g')

# Создаем временный файл для обновленных данных
temp_file=$(mktemp)

# Заменяем IP-адрес второй строки файла hosts
awk -v ip="$ip_address" 'NR==2 {sub(/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/, ip)} 1' hosts > "$temp_file"

# Перемещаем временный файл на место исходного
mv "$temp_file" hosts