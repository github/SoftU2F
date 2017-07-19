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

#ifndef U2F_HOST_VERSION_H
#define U2F_HOST_VERSION_H

#ifdef __cplusplus
extern "C"
{
#endif

/**
 * U2FH_VERSION_STRING
 *
 * Pre-processor symbol with a string that describe the header file
 * version number.  Used together with u2fh_check_version() to verify
 * header file and run-time library consistency.
 */
#define U2FH_VERSION_STRING "1.1.3"

/**
 * U2FH_VERSION_NUMBER
 *
 * Pre-processor symbol with a hexadecimal value describing the header
 * file version number.  For example, when the header version is 1.2.3
 * this symbol will have the value 0x01020300.  The last two digits
 * are only used between public releases, and will otherwise be 00.
 */
#define U2FH_VERSION_NUMBER 0x010103

/**
 * U2FH_VERSION_MAJOR
 *
 * Pre-processor symbol with a decimal value that describe the major
 * level of the header file version number.  For example, when the
 * header version is 1.2.3 this symbol will be 1.
 */
#define U2FH_VERSION_MAJOR 1

/**
 * U2FH_VERSION_MINOR
 *
 * Pre-processor symbol with a decimal value that describe the minor
 * level of the header file version number.  For example, when the
 * header version is 1.2.3 this symbol will be 2.
 */
#define U2FH_VERSION_MINOR 1

/**
 * U2FH_VERSION_PATCH
 *
 * Pre-processor symbol with a decimal value that describe the patch
 * level of the header file version number.  For example, when the
 * header version is 1.2.3 this symbol will be 3.
 */
#define U2FH_VERSION_PATCH 3

  const char *u2fh_check_version (const char *req_version);

#ifdef __cplusplus
}
#endif
#endif
