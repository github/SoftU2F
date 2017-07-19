//
//  SoftU2FDevice.cpp
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/12/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

#include "SoftU2FDevice.hpp"
#include "SoftU2FUserClient.hpp"
#include <IOKit/IOLib.h>

#define super IOHIDDevice
OSDefineMetaClassAndStructors(SoftU2FDevice, IOHIDDevice)

SoftU2FDevice* SoftU2FDevice::newDevice() {
  SoftU2FDevice *device = new SoftU2FDevice;
  if (!device)
    goto fail;

  if (!device->init(nullptr))
    goto fail;

  return device;

fail:
  if (device)
    device->release();

  return nullptr;
}

IOReturn SoftU2FDevice::newReportDescriptor(IOMemoryDescriptor **descriptor) const {
  IOBufferMemoryDescriptor *buffer = IOBufferMemoryDescriptor::withBytes(u2fhid_report_descriptor, sizeof(u2fhid_report_descriptor), kIODirectionNone);
  if (!buffer)
    return kIOReturnNoResources;

  *descriptor = buffer;

  return kIOReturnSuccess;
}

IOReturn SoftU2FDevice::setReport(IOMemoryDescriptor *report, IOHIDReportType reportType, IOOptionBits options) {
  SoftU2FUserClient *userClient = OSDynamicCast(SoftU2FUserClient, getProvider());
  if (userClient)
    userClient->frameReceived(report);

  // Sleep for a bit to make the HID conformance tests happy.
  IOSleep(1); // 1ms

  return kIOReturnSuccess;
}

OSString *SoftU2FDevice::newProductString() const {
  return OSString::withCString("SoftU2F");
}

OSString *SoftU2FDevice::newSerialNumberString() const {
  return OSString::withCString("123");
}

OSNumber *SoftU2FDevice::newVendorIDNumber() const {
  return OSNumber::withNumber(123, 32);
}

OSNumber *SoftU2FDevice::newProductIDNumber() const {
  return OSNumber::withNumber(123, 32);
}

OSNumber* SoftU2FDevice::newPrimaryUsageNumber() const {
  return OSNumber::withNumber(kHIDUsage_PID_TriggerButton, 32);
}
