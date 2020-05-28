#!/home/brian/.pyenv/versions/wacom/bin/python

import time
import argparse
import subprocess
import pyudev


def main():
    parser = argparse.ArgumentParser(description="Listen to udev for the wacom tablet.")
    parser.add_argument('--vendor_id', '--vendor-id', default=b"056a", type=lambda x: x.encode("utf-8"))
    parser.add_argument('--product_id', '--product-id', default=b"0374", type=lambda x: x.encode("utf-8"))
    args = parser.parse_args()

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
        if vendor_id == args.vendor_id and product_id == args.product_id:
            print("Device is my wacom")
            time.sleep(2)
            print("Running wacom setup")
            subprocess.call("/home/brian/.shellrc/wacom/xsetwacom.sh")
            print("Setup wacom")


if __name__ == "__main__":
    main()
