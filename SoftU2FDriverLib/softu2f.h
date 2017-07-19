//
//  libsoftu2f.h
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/12/17.
//

#ifndef SoftU2FClientInterface_h
#define SoftU2FClientInterface_h

#include <CoreFoundation/CoreFoundation.h>

typedef struct softu2f_ctx softu2f_ctx;
typedef struct softu2f_hid_message softu2f_hid_message;

// Handler function for HID message.
typedef bool (*softu2f_hid_message_handler)(softu2f_ctx *ctx, softu2f_hid_message *req);

// U2FHID message.
struct softu2f_hid_message {
  uint8_t cmd;
  uint16_t bcnt;
  uint32_t cid;
  CFDataRef data;
  CFMutableDataRef buf;
  uint8_t lastSeq;
  struct timeval start;
  softu2f_hid_message *next;
};

typedef enum softu2f_init_flags {
  SOFTU2F_DEBUG = 1 << 0
} softu2f_init_flags;

// Initialization
softu2f_ctx *softu2f_init(softu2f_init_flags flags);

// Deinitialization
void softu2f_deinit(softu2f_ctx *ctx);

// Read HID messages from the device.
void softu2f_run(softu2f_ctx *ctx);

// Shutdown the run loop.
void softu2f_shutdown(softu2f_ctx *ctx);

// Send a HID message to the device.
bool softu2f_hid_msg_send(softu2f_ctx *ctx, softu2f_hid_message *msg);

// Send a HID error to the device.
bool softu2f_hid_err_send(softu2f_ctx *ctx, uint32_t cid, uint8_t code);

// Register a handler for a message type.
void softu2f_hid_msg_handler_register(softu2f_ctx *ctx, uint8_t type, softu2f_hid_message_handler handler);

// Find a message handler for a message.
softu2f_hid_message_handler softu2f_hid_msg_handler_default(softu2f_ctx *ctx, softu2f_hid_message *msg);

#endif /* SoftU2FClientInterface_h */
