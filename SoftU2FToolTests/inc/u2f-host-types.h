/*
  Copyright (C) 2013-2015 Yubico AB

  This program is free software; you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License as published by
  the Free Software Foundation; either version 2.1, or (at your option) any
  later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

#ifndef U2F_HOST_TYPES_H
#define U2F_HOST_TYPES_H

/**
 * u2fh_rc:
 * @U2FH_OK: Success.
 * @U2FH_MEMORY_ERROR: Memory error.
 * @U2FH_TRANSPORT_ERROR: Transport (e.g., USB) error.
 * @U2FH_JSON_ERROR: Json error.
 * @U2FH_BASE64_ERROR: Base64 error.
 * @U2FH_NO_U2F_DEVICE: Missing U2F device.
 * @U2FH_AUTHENTICATOR_ERROR: Authenticator error.
 * @U2FH_TIMEOUT_ERROR: Timeout error.
 *
 * Error codes.
 */
typedef enum
{
  U2FH_OK = 0,
  U2FH_MEMORY_ERROR = -1,
  U2FH_TRANSPORT_ERROR = -2,
  U2FH_JSON_ERROR = -3,
  U2FH_BASE64_ERROR = -4,
  U2FH_NO_U2F_DEVICE = -5,
  U2FH_AUTHENTICATOR_ERROR = -6,
  U2FH_TIMEOUT_ERROR = -7,
  U2FH_SIZE_ERROR = -8,
} u2fh_rc;

/**
 * u2fh_initflags:
 * @U2FH_DEBUG: Print debug messages.
 *
 * Flags passed to u2fh_global_init().
 */
typedef enum
{
  U2FH_DEBUG = 1
} u2fh_initflags;

/**
 * u2fh_cmdflags:
 * @U2FH_REQUEST_USER_PRESENCE: Request user presence.
 *
 * Flags passed to u2fh_register() and u2fh_authenticate().
 */
typedef enum
{
  U2FH_REQUEST_USER_PRESENCE = 1
} u2fh_cmdflags;

typedef struct u2fh_devs u2fh_devs;

#endif
