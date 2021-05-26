#!/bin/bash
set -e

# Run balena base image entrypoint script
/usr/bin/entry.sh echo "Running balena base image entrypoint..."

function reset_hci_interface () {
  local INTERFACE=$1

  echo "Resetting $i"
  btmgmt --index $i discov off > /dev/null
  btmgmt --index $i pairable off > /dev/null
  btmgmt --index $i connectable off > /dev/null
}

# Bluetooth block environment variables and defaults
DEVICE_NAME=${BLUETOOTH_DEVICE_NAME:-$(printf "balenaOS %s"$(echo "$BALENA_DEVICE_UUID" | cut -c -4))}
HCI_INTERFACE=${BLUETOOTH_HCI_INTERFACE:-"hci0"}
PAIRING_MODE=${BLUETOOTH_PAIRING_MODE:-"SSP"}
PIN_CODE=${BLUETOOTH_PIN_CODE:-"0000"}

echo "--- Bluetooth ---"
echo "Starting bluetooth service with settings:"
echo "- Device name: "$DEVICE_NAME
echo "- HCI interface: "$HCI_INTERFACE
echo "- Pairing mode: "$PAIRING_MODE
echo "- PIN code: "$PIN_CODE

# Get available interfaces
HCI_INTERFACES=$(btmgmt info | awk 'BEGIN { ORS=" " }; /^ *hci/ {gsub(":", ""); print $1}')
FS=' ' read -r -a HCI_INTERFACES <<< "$HCI_INTERFACES"
echo "Available HCI interfaces: "${HCI_INTERFACES[@]}

# Bail out if provided HCI interface is invalid
if [[ ! "${HCI_INTERFACES[@]}" =~ "$HCI_INTERFACE" ]]; then
  echo "Exiting... selected HCI interface is invalid: $HCI_INTERFACE"
  exit 0
fi

# Reset all interfaces. This helps shut off interfaces from previous runs.
for i in "${HCI_INTERFACES[@]}"
do
  reset_hci_interface "$i"
done

# Configure selected interface
echo "Configuring selected interface: $HCI_INTERFACE"
# Set device name
btmgmt --index $HCI_INTERFACE name "$DEVICE_NAME"

# Ensure bluetooth is ready to connect
btmgmt --index $HCI_INTERFACE connectable on
btmgmt --index $HCI_INTERFACE pairable on
btmgmt --index $HCI_INTERFACE discov on

# Set bluetooth pairing mode:
# - SSP (default): Secure Simple Pairing, no PIN code required
# - LEGACY: disable SSP mode, PIN code required
if [[ $PAIRING_MODE == "LEGACY" ]]; then
  AGENT_CAPABILITY="KeyboardDisplay"
  btmgmt --index $HCI_INTERFACE ssp off
  echo "Pairing mode set to 'Legacy Pairing Mode (LPM)'. PIN code is required."
else 
  AGENT_CAPABILITY="NoInputNoOutput"
  btmgmt --index $HCI_INTERFACE ssp on
  echo "Pairing mode set to 'Secure Simple Pairing Mode (SSPM)'. PIN code is NOT required."
fi

# If command starts with an option, prepend bluetooth-agent to it
if [[ "${1#-}" != "$1" ]]; then
  set -- bluetooth-agent "$@"
fi

exec "$@"
