//
//  SoftU2FUserClient.cpp
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/12/17.
//

#include "SoftU2FUserClient.hpp"
#include "SoftU2FDevice.hpp"
#include "SoftU2FDriver.hpp"
#include <IOKit/IOKitKeys.h>
#include <IOKit/IOLib.h>

#define super IOUserClient

OSDefineMetaClassAndStructors(SoftU2FUserClient, IOUserClient)

/**
 * A dispatch table for this User Client interface, used by
 * 'SoftU2FUserClient::externalMethod()'.
 * The fields of the IOExternalMethodDispatch type follows:
 *
 *  struct IOExternalMethodDispatch
 *  {
 *      IOExternalMethodAction function;
 *      uint32_t		   checkScalarInputCount;
 *      uint32_t		   checkStructureInputSize;
 *      uint32_t		   checkScalarOutputCount;
 *      uint32_t		   checkStructureOutputSize;
 *  };
 */
const IOExternalMethodDispatch SoftU2FUserClient::sMethods[kNumberOfMethods] = {
    {(IOExternalMethodAction)&SoftU2FUserClient::sSendFrame, 0, sizeof(U2FHID_FRAME), 0, 0},
    {(IOExternalMethodAction)&SoftU2FUserClient::sNotifyFrame, 0, 0, 0, 0},
};

IOReturn SoftU2FUserClient::externalMethod(uint32_t selector, IOExternalMethodArguments *arguments, IOExternalMethodDispatch *dispatch, OSObject *target, void *reference) {
  if (isInactive())
    return kIOReturnOffline;

  ExternalMethodGatedArguments gatedArguments = {selector, arguments, dispatch, target, reference};

  return _commandGate->runAction(OSMemberFunctionCast(IOCommandGate::Action, this, &SoftU2FUserClient::externalMethodGated), &gatedArguments);
}

IOReturn SoftU2FUserClient::externalMethodGated(ExternalMethodGatedArguments *arguments) {
  if (isInactive())
    return kIOReturnOffline;

  if (arguments->selector >= (uint32_t)kNumberOfMethods)
    return kIOReturnBadArgument;

  arguments->dispatch = (IOExternalMethodDispatch *)&sMethods[arguments->selector];

  if (!arguments->target)
    arguments->target = this;

  return super::externalMethod(arguments->selector, arguments->arguments, arguments->dispatch, arguments->target, arguments->reference);
}

void SoftU2FUserClient::free() {
  IOLog("%s[%p]::%s()\n", getName(), this, __FUNCTION__);

  if (_notifyRef)
    IOFree(_notifyRef, sizeof(OSAsyncReference64));

  if (_commandGate)
    _commandGate->release();

  return super::free();
}

// start is called after initWithTask as a result of the user process calling
// IOServiceOpen.
bool SoftU2FUserClient::start(IOService *provider) {
  IOLog("%s[%p]::%s(%p)\n", getName(), this, __FUNCTION__, provider);

  SoftU2FDevice *device = nullptr;
  IOWorkLoop *workLoop = nullptr;

  if (!OSDynamicCast(SoftU2FDriver, provider))
    goto fail_bad_provider;

  if (!super::start(provider))
    goto fail_super_start;

  device = SoftU2FDevice::newDevice();
  if (!device)
    goto fail_new_device;

  if (!device->attach(this))
    goto fail_device_attach;

  if (!device->start(this))
    goto fail_device_start;

  workLoop = getWorkLoop();
  if (!workLoop)
    goto fail_no_workloop;

  _commandGate = IOCommandGate::commandGate(this);
  if (!_commandGate)
    goto fail_new_cgate;

  if (workLoop->addEventSource(_commandGate) != kIOReturnSuccess)
    goto fail_add_event_source;

  // Our call to device->attach took a retain on the device when it was added to the registry.
  // That will be released when the device is detached from the registry.
  device->release();

  return true;

fail_add_event_source:
fail_new_cgate:
fail_no_workloop:
fail_device_start:
  device->detach(this);

fail_device_attach:
  device->release();

fail_new_device:
  stop(provider);

fail_super_start:
fail_bad_provider:
  return false;
}

void SoftU2FUserClient::stop(IOService *provider) {
  IOLog("%s[%p]::%s(%p)\n", getName(), this, __FUNCTION__, provider);

  IOWorkLoop *workLoop = getWorkLoop();
  if (workLoop && _commandGate)
    workLoop->removeEventSource(_commandGate);

  super::stop(provider);
}

// clientClose is called as a result of the user process calling IOServiceClose.
IOReturn SoftU2FUserClient::clientClose(void) {
  IOLog("%s[%p]::%s()\n", getName(), this, __FUNCTION__);

  terminate();
  return kIOReturnSuccess;
}

void SoftU2FUserClient::frameReceived(IOMemoryDescriptor *report) {
  if (isInactive())
    return;

  _commandGate->runAction(OSMemberFunctionCast(IOCommandGate::Action, this, &SoftU2FUserClient::frameReceivedGated), report);
}

void SoftU2FUserClient::frameReceivedGated(IOMemoryDescriptor *report) {
  IOLog("%s[%p]::%s(%p)\n", getName(), this, __FUNCTION__, report);

  IOMemoryMap *reportMap;
  io_user_reference_t *args;

  if (isInactive() || !_notifyRef)
    return;

  if (report->getLength() != sizeof(U2FHID_FRAME) || report->prepare() != kIOReturnSuccess)
    return;

  // Map report into kernel space.
  reportMap = report->map();

  // Notify userland that we got a report.
  args = (io_user_reference_t *)reportMap->getAddress();
  sendAsyncResult64(*_notifyRef, kIOReturnSuccess, args, sizeof(U2FHID_FRAME) / sizeof(io_user_reference_t));

  reportMap->release();
  report->complete();
}

IOReturn SoftU2FUserClient::sSendFrame(SoftU2FUserClient *target, void *reference, IOExternalMethodArguments *arguments) {
  return target->sendFrame((U2FHID_FRAME *)arguments->structureInput, arguments->structureInputSize);
}

IOReturn SoftU2FUserClient::sendFrame(U2FHID_FRAME *frame, size_t frameSize) {
  SoftU2FDevice *device = nullptr;
  IOMemoryDescriptor *report = nullptr;

  if (isInactive())
    return kIOReturnOffline;

  if (frameSize != HID_RPT_SIZE)
    return kIOReturnBadArgument;

  device = OSDynamicCast(SoftU2FDevice, getClient());
  if (!device)
    return kIOReturnNotAttached;

  report = IOBufferMemoryDescriptor::inTaskWithOptions(kernel_task, 0, HID_RPT_SIZE);
  if (!report)
    return kIOReturnNoResources;

  report->writeBytes(0, frame, frameSize);

  if (device->handleReport(report) != kIOReturnSuccess) {
    report->release();
    return kIOReturnError;
  }

  report->release();

  return kIOReturnSuccess;
}

IOReturn SoftU2FUserClient::sNotifyFrame(SoftU2FUserClient *target, void *reference, IOExternalMethodArguments *arguments) {
  return target->notifyFrame(arguments->asyncReference, arguments->asyncReferenceCount);
}

IOReturn SoftU2FUserClient::notifyFrame(io_user_reference_t *ref, uint32_t refCount) {
  if (isInactive())
    return kIOReturnOffline;

  if (_notifyRef) {
    IOFree(_notifyRef, sizeof(OSAsyncReference64));
    _notifyRef = nullptr;
  }

  _notifyRef = (OSAsyncReference64 *)IOMalloc(sizeof(OSAsyncReference64));
  if (!_notifyRef)
    return kIOReturnNoMemory;

  bzero(_notifyRef, sizeof(OSAsyncReference64));

  memcpy(_notifyRef, ref, sizeof(io_user_reference_t) * refCount);

  return kIOReturnSuccess;
}
