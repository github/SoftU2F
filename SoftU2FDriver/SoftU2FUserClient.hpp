//
//  SoftU2FUserClient.hpp
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/12/17.
//

#ifndef SoftU2FUserClient_hpp
#define SoftU2FUserClient_hpp

#include "u2f_hid.h"
#include "UserKernelShared.h"
#include <IOKit/IOService.h>
#include <IOKit/IOUserClient.h>
#include <IOKit/IOCommandGate.h>

class SoftU2FUserClient : public IOUserClient {
  OSDeclareDefaultStructors(SoftU2FUserClient)

private:
  static const IOExternalMethodDispatch sMethods[kNumberOfMethods];
  OSAsyncReference64 *_notifyRef = nullptr;
  IOCommandGate *_commandGate = nullptr;

  typedef struct {
    uint32_t                    selector;
    IOExternalMethodArguments * arguments;
    IOExternalMethodDispatch *  dispatch;
    OSObject *                  target;
    void *                      reference;
  } ExternalMethodGatedArguments;

  IOReturn externalMethodGated(ExternalMethodGatedArguments * arguments);
  virtual void frameReceivedGated(IOMemoryDescriptor *report);

public:
  virtual void free() override;

  virtual bool start(IOService *provider) override;
  virtual void stop(IOService *provider) override;

  virtual IOReturn clientClose(void) override;

  virtual void frameReceived(IOMemoryDescriptor *report);

protected:
  virtual IOReturn externalMethod(uint32_t selector, IOExternalMethodArguments *arguments, IOExternalMethodDispatch *dispatch, OSObject *target, void *reference) override;

  // User client methods
  static IOReturn sSendFrame(SoftU2FUserClient *target, void *reference, IOExternalMethodArguments *arguments);
  virtual IOReturn sendFrame(U2FHID_FRAME *frame, size_t frameSize);

  static IOReturn sNotifyFrame(SoftU2FUserClient *target, void *reference, IOExternalMethodArguments *arguments);
  virtual IOReturn notifyFrame(io_user_reference_t *ref, uint32_t refCount);
};

#endif /* SoftU2FUserClient_hpp */
