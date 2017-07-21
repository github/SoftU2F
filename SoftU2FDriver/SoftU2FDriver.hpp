//
//  SoftU2FDriver.hpp
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/12/17.
//

#ifndef SoftU2FDriver_hpp
#define SoftU2FDriver_hpp

#include <IOKit/IOService.h>
#include <IOKit/IOWorkLoop.h>

class SoftU2FDriver : public IOService {
  OSDeclareDefaultStructors(SoftU2FDriver)

  IOWorkLoop *_workLoop = nullptr;

public :
  virtual bool start(IOService *provider) override;
  void free() override;
  IOWorkLoop* getWorkLoop() const override;
};

#endif /* SoftU2F_hpp */
