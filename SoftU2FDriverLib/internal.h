//
//  internal.h
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/25/17.
//

#ifndef internal_h
#define internal_h

#include "UserKernelShared.h"
#include "u2f_hid.h"
#include <IOKit/IOKitLib.h>
#include <pthread.h>

// Context includes cid counter, connection.
struct softu2f_ctx {
  io_connect_t con;
  uint32_t next_cid;
  pthread_mutex_t mutex;
  CFRunLoopRef run_loop;

  // Incomming messages.
  softu2f_hid_message *msg_list;

  // Verbose logging.
  bool debug;

  // Handlers registered for HID msg types.
  softu2f_hid_message_handler ping_handler;
  softu2f_hid_message_handler msg_handler;
  softu2f_hid_message_handler init_handler;
  softu2f_hid_message_handler wink_handler;
  softu2f_hid_message_handler sync_handler;
};

struct timespec softu2f_poll_interval = {0, 1000000L}; // 1ms. Spec says 5ms...

// Read an individual HID frame from the device into a HID message.
void softu2f_hid_frame_read(softu2f_ctx *ctx, U2FHID_FRAME *frame);

// Handle complete messages. Abort messages that timed out.
void softu2f_hid_handle_messages(softu2f_ctx *ctx);

// Find a message handler for a message.
softu2f_hid_message_handler softu2f_hid_msg_handler(softu2f_ctx *ctx, softu2f_hid_message *msg);

// Send an INIT response for a given request.
bool softu2f_hid_msg_handle_init(softu2f_ctx *ctx, softu2f_hid_message *req);

// Send a PING response for a given request.
bool softu2f_hid_msg_handle_ping(softu2f_ctx *ctx, softu2f_hid_message *req);

// Send a WINK response for a given request.
bool softu2f_hid_msg_handle_wink(softu2f_ctx *ctx, softu2f_hid_message *req);

// Send a SYNC response for a given request.
bool softu2f_hid_msg_handle_sync(softu2f_ctx *ctx, softu2f_hid_message *req);

// Create a new message and add it to the list.
softu2f_hid_message *softu2f_hid_msg_list_create(softu2f_ctx *ctx);

// Find a message with the given cid.
softu2f_hid_message *softu2f_hid_msg_list_find(softu2f_ctx *ctx, uint32_t cid);

// Get size of message list.
unsigned int softu2f_hid_msg_list_count(softu2f_ctx *ctx);

// Remove a message from the list and free it.
void softu2f_hid_msg_list_remove(softu2f_ctx *ctx, softu2f_hid_message *msg);

// Allocate memory for a new message.
softu2f_hid_message *softu2f_hid_msg_alloc(softu2f_ctx *ctx);

// Check if the message has timed out.
bool softu2f_hid_msg_is_timed_out(softu2f_ctx *ctx, softu2f_hid_message *msg);

// Check if we've read the whole message.
bool softu2f_hid_msg_is_complete(softu2f_ctx *ctx, softu2f_hid_message *msg);

// Initialize the message's data with the contents of its read buffer.
void softu2f_hid_msg_finalize(softu2f_ctx *ctx, softu2f_hid_message *msg);

// Free a HID message and associated data.
void softu2f_hid_msg_free(softu2f_hid_message *msg);

// Log a message if logging is enabled.
void softu2f_log(softu2f_ctx *ctx, char *fmt, ...);

// Log a U2FHID_FRAME if logging is enabled.
void softu2f_debug_frame(softu2f_ctx *ctx, U2FHID_FRAME *frame, bool recv);

// Called by the kernel when setReport is called on our device.
void softu2f_async_callback(void *refcon, IOReturn result, io_user_reference_t* args, uint32_t numArgs);

// Called periodically in our runloop.
void softu2f_async_timer_callback(CFRunLoopTimerRef timer, void* info);

#endif /* internal_h */
