const Bluez = require('bluez');

const bluetooth = new Bluez();

class BluezAgent extends Bluez.Agent {
  constructor (bluez, DbusObject, pin) {
    super(bluez, DbusObject);
    this.pin = pin;
  }

  DisplayPasskey(device, passkey, entered, callback) {
    console.log('disp pass')
    callback();
}
DisplayPinCode(device, pincode, callback) {
  console.log('disp pin')
  callback();
}
  Release (callback) {
    console.log("Agent Disconnected");
    callback();
  }

  RequestPinCode (device, callback) {
    console.log("Send pass");
    callback(null, this.pin);
  }

  RequestPasskey (device, callback) {
    console.log("Send pin");
    callback(null, parseInt(this.pin));
  }
  RequestConfirmation(device, passkey, callback) {
    console.log('req conf')
    console.log(device)
    console.log(passkey)
    callback();
}
  RequestAuthorization(device, callback) {
    console.log('req auth')
    callback();
}
  AuthorizeService(device, uuid, callback) {
    console.log('auth service')
    callback();
}
  Cancel(callback) {
    console.log('cancel')
    callback();
}
}



// Register callback for new devices
bluetooth.on('device', async (address, props) => {
  console.log("Found new Device " + address + " " + props.Name);
  console.log(props)
});

// Initialize bluetooth interface
bluetooth.init().then(async () => {

  await bluetooth.registerAgent(new BluezAgent(bluetooth, bluetooth.getUserServiceObject(), "1234"), "KeyboardDisplay", true)
  console.log("Agent registered")

  bluetooth.objectManager.on('InterfacesAdded', async (path, interfaces) => {
    console.log('interface added')
    console.log(path)
    console.log(interfaces)

    // if ('org.bluez.MediaTransport1' in interfaces) {
    //   const props = interfaces['org.bluez.MediaTransport1'];
    //   const device = await bluetooth.getDevice(props.Device)
    //   console.log(device)
    // }
  })
  bluetooth.objectManager.on('InterfacesRemoved', (path, interfaces) => {
    console.log('interface removed')
    console.log(path)
    console.log(interfaces)
  })

  bluetooth.objectManager.GetManagedObjects((err, objs) => {
    console.log(objs)
    // Object.keys(objs).forEach((k)=>this.onInterfacesAdded(k, objs[k]))
});

  // listen on first bluetooth adapter
  // const adapter = await bluetooth.getAdapter('hci0');
  // await adapter.StartDiscovery();
  // console.log("Discovering");
});