#!/home/brian/.pyenv/versions/wacom/bin/python

import time
import subprocess
import pyudev


def main():
    print("Initializing udev listener")
    context = pyudev.Context()
    print("initializing udev monitor")
    monitor = pyudev.Monitor.from_netlink(context)
    monitor.filter_by(subsystem="usb")
    print("starting udev monitor")
    monitor.start()

    for device in iter(monitor.poll, None):
        print(f"action on device {device}")
        vendor_id = device.attributes.get('idVendor')
        print(f"device vendor id: {vendor_id}")
        product_id = device.attributes.get('idProduct')
        print(f"device product id: {product_id}")
        if vendor_id == b'056a' and product_id == b'0374':
            print("Device is my wacom")
            time.sleep(2)
            print("Running wacom setup")
            subprocess.call("/home/brian/.shellrc/wacom/xsetwacom.sh")
            print("Setup wacom")


if __name__ == "__main__":
    main()
