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

#ifndef U2F_HOST_H
#define U2F_HOST_H

// Visual studio 2008 and earlier are missing stdint.h
#if defined _MSC_VER && _MSC_VER <= 1500 && !defined HAVE_STDINT_H
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long int uint64_t;
#else
#include <stdint.h>
#endif

#include <string.h>

#include <u2f-host-version.h>
#include <u2f-host-types.h>

#if defined _MSC_VER
#define U2FH_EXPORT __declspec(dllexport)
#else
#define U2FH_EXPORT extern
#endif

#ifdef __cplusplus
extern "C"
{
#endif

/* Must be called successfully before using any other functions. */
  U2FH_EXPORT u2fh_rc u2fh_global_init (u2fh_initflags flags);
  U2FH_EXPORT void u2fh_global_done (void);

  U2FH_EXPORT const char *u2fh_strerror (int err);
  U2FH_EXPORT const char *u2fh_strerror_name (int err);

  U2FH_EXPORT u2fh_rc u2fh_devs_init (u2fh_devs ** devs);
  U2FH_EXPORT u2fh_rc u2fh_devs_discover (u2fh_devs * devs, unsigned *max_index);
  U2FH_EXPORT void u2fh_devs_done (u2fh_devs * devs);

  U2FH_EXPORT u2fh_rc u2fh_register (u2fh_devs * devs,
				const char *challenge,
				const char *origin,
				char **response, u2fh_cmdflags flags);

  U2FH_EXPORT u2fh_rc u2fh_register2 (u2fh_devs * devs,
				 const char *challenge,
				 const char *origin,
				 char *response, size_t * response_len,
				 u2fh_cmdflags flags);

  U2FH_EXPORT u2fh_rc u2fh_authenticate (u2fh_devs * devs,
				    const char *challenge,
				    const char *origin,
				    char **response, u2fh_cmdflags flags);

  U2FH_EXPORT u2fh_rc u2fh_authenticate2 (u2fh_devs * devs,
				     const char *challenge,
				     const char *origin,
				     char *response, size_t * response_len,
				     u2fh_cmdflags flags);

  U2FH_EXPORT u2fh_rc u2fh_sendrecv (u2fh_devs * devs,
				unsigned index,
				uint8_t cmd,
				const unsigned char *send,
				uint16_t sendlen,
				unsigned char *recv, size_t * recvlen);

  U2FH_EXPORT u2fh_rc u2fh_get_device_description (u2fh_devs * devs,
					      unsigned index, char *out,
					      size_t * len);

  U2FH_EXPORT int u2fh_is_alive (u2fh_devs * devs, unsigned index);

#ifdef __cplusplus
}
#endif
#endif
