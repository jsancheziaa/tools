#!/bin/bash

# Check whether the script is running as sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please, wait run this script as root or with sudo."
  exit 1
fi

# Path resolv.conf
RESOLV_CONF="/etc/resolv.conf"

# Add nameserver 8.8.8.8.8 to the beginning of the file
echo "Adding nameserver 8.8.8.8 a $RESOLV_CONF"
sed -i '1inameserver 8.8.8.8' $RESOLV_CONF

# Check if the line has been added correctly
if grep -q "nameserver 8.8.8.8" $RESOLV_CONF; then
  echo "Líne added correctly."
else
  echo "Error to add line."
  exit 1
fi

# Renew certificate with Let's Encrypt
echo "Renewing el certificado con Let's Encrypt"
/usr/bin/certbot renew

# check if the renovation was successful
if [ $? -eq 0 ]; then
  echo "Certificate renewed correctly."
else
  echo "Error to renew certificate."
  exit 1
fi

# Remove the line added at start
echo "Removing nameserver 8.8.8.8 de $RESOLV_CONF"
sed -i '/^nameserver 8.8.8.8/d' $RESOLV_CONF

# check if the line was removed correctly
if grep -q "nameserver 8.8.8.8" $RESOLV_CONF; then
  echo "Error to remove line."
  exit 1
else
  echo "Line removed."
fi

echo "Script was executed correctly."
exit 0
