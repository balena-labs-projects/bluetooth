# balena bluetooth block

balenaOS optimized bluetooth agent. Easiest way to add bluetooth pairing to your projects!

## Features

The bluetooth block is a Docker image that runs a pre-configured bluetooth pairing agent, some of it's features are:

- Handle bluetooth pairing and connection with other devices
- Support for any bluetooth interface (built-in or USB)
- Uses DBus to communicate with balenaOS bluetooth daemon
- Reconnect on boot to known and trusted devices

Note that this block *does not* deal with the bluetooth "data layer". Your application will need to handle the data stream corresponding to the desired bluetooth profile. For example, the [`audio` block](https://github.com/balenablocks/audio) takes an already paired and connected bluetooth device and sets it up as an A2DP audio source.

## Usage

#### docker-compose file
To use this image, create a container in your `docker-compose.yml` file as shown below:

```yaml
version: '2'

services:

  bluetooth:
    image: balenablocks/bluetooth:raspberrypi4-64  # See supported devices for other archs
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
### Extend image configuration

You can extend the `bluetooth` block to include custom configuration as you would with any other `Dockerfile`. Just make sure you don't override the `ENTRYPOINT` as it contains important system configuration.

Here are some of the most common extension cases: 

- Start the bluetooth daemon from your own bash script:

```Dockerfile
FROM balenablocks/bluetooth:%%BALENA_MACHINE_NAME%%

# Be sure to run exec /usr/src/bluetooth-agent in your script
COPY start.sh /usr/src/start.sh
CMD [ "/bin/bash", "/usr/src/start.sh" ]
```

### Environment variables

The following environment variables allow some degree of configuration:

| Environment variable | Description | Default | Options | 
| --- | --- | --- | --- |
| `BLUETOOTH_DEVICE_NAME` | The bluetooth device name that will be advertised. | `balenaSound <SHORT_UUID>` | - |
| `BLUETOOTH_HCI_INTERFACE` | The bluetooth interface to be used. | `hci0` | - |
| `BLUETOOTH_PAIRING_MODE` | The bluetooth paring mode:<br>- Secure Simple Pairing (SSP): Secure pinless pairing method<br>- Legacy Pairing: PIN code based authentication. Less secure but older devices might only support this mode. Note that this mode is no longer allowed on [iOS](https://developer.apple.com/accessories/Accessory-Design-Guidelines.pdf) devices. | `SSP` | `SSP`, `LEGACY` |
| `BLUETOOTH_PIN_CODE` | PIN code used for Legacy Pairing. Must be numeric and up to six digits (1 - 999999). | `0000` | - |

## Supported devices
The bluetooth block has been tested to work on the following devices:

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
