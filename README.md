# balena bluetooth primitive

balenaOS optimized bluetooth agent. Easiest way to add bluetooth to your projects!

## Features

The bluetooth primitive is a Docker image that runs a pre-configured bluetooth agent, some of it's features are:

- Handle bluetooth pairing and connection with other devices
- Support for any bluetooth interface (built-in or USB)
- Uses DBus to communicate with balenaOS bluetooth daemon

## Usage

#### docker-compose file
To use this image, create a container in your `docker-compose.yml` file as shown below:

```yaml
version: '2'

services:

  bluetooth:
    image: balenaplayground/balenalabs-audio:raspberrypi4-64  # See supported devices for other archs
    network_mode: host
    cap_add:
      - NET_ADMIN
    restart: on-failure
    labels:
      io.balena.features.dbus: 1

  my-bluetooth-app:
    build: ./my-bluetooth-app
```


## Customization
### Environment variables

The following environment variables allow some degree of configuration:

| Environment variable | Description | Default | Options | 
| --- | --- | --- | --- |
| `BLUETOOTH_DEVICE_NAME` | The bluetooth device name that will be advertised. | `balenaSound <SHORT_UUID>` | - |
| `BLUETOOTH_HCI_INTERFACE` | The bluetooth interface to be used. | `hci0` | - |
| `BLUETOOTH_PAIRING_MODE` | The bluetooth paring mode:<br>- Secure Simple Pairing (SSP): Secure pinless pairing method<br>- Legacy Pairing: PIN code based authentication. Less secure but older devices might only support this mode. Note that this mode is no longer allowed on [iOS](https://developer.apple.com/accessories/Accessory-Design-Guidelines.pdf) devices. | `SSP` | `SSP`, `LEGACY` |
| `BLUETOOTH_PIN_CODE` | PIN code used for Legacy Pairing. Must be numeric and up to six digits (1 - 999999). | `0000` | - |

## Supported devices
The audio primitive has been tested to work on the following devices:

| Device Type  | Status |
| ------------- | ------------- |
| Raspberry Pi 1 / Zero | |
| Raspberry Pi Zero W | ✔ |
| Raspberry Pi 2 | ✔ <sup>*</sup> |
| Raspberry Pi 3 | ✔ |
| Raspberry Pi 4 | ✔ |
| Jetson Nano | ✔ <sup>*</sup> |
| BeagleBone Black | ✔ <sup>*</sup> |
| Intel NUC | ✔ <sup>*</sup> |

*: Requires external USB bluetooth dongle
