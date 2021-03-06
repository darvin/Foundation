/** NSURL.m - Class NSURL
   Copyright (C) 1999 Free Software Foundation, Inc.

   Written by:  Manuel Guesdon <mguesdon@sbuilders.com>
   Date:        Jan 1999

   Rewrite by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:        Jun 2002

   This file is part of the GNUstep Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.

   <title>NSURL class reference</title>
   $Date: 2010-10-19 05:56:30 -0700 (Tue, 19 Oct 2010) $ $Revision: 31532 $
 */

/*
   Note from Manuel Guesdon:
 * I've made some test to compare apple NSURL results
   and GNUstep NSURL results but as there this class is not very documented,
    *some
   function may be incorrect
 * I've put 2 functions to make tests. You can add your own tests
 * Some functions are not implemented
 */
#import "common.h"
#define EXPOSE_NSURL_IVARS  1
#import "Foundation/NSArray.h"
#import "Foundation/NSCoder.h"
#import "Foundation/NSData.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSException.h"
#import "Foundation/NSFileManager.h"
#import "Foundation/NSLock.h"
#import "Foundation/NSMapTable.h"
#import "Foundation/NSPortCoder.h"
#import "Foundation/NSRunLoop.h"
#import "Foundation/NSURL.h"
#import "Foundation/NSURLHandle.h"
#import "Foundation/NSValue.h"
#import "Foundation/NSURLConnection.h"
#import "Foundation/NSURLRequest.h"
#import "GSPrivate.h"

#include <uriparser/Uri.h>

NSString * const NSURLNameKey = @"NSURLNameKey";
NSString * const NSURLLocalizedNameKey = @"NSURLLocalizedNameKey";
NSString * const NSURLIsRegularFileKey = @"NSURLIsRegularFileKey";
NSString * const NSURLIsDirectoryKey = @"NSURLIsDirectoryKey";
NSString * const NSURLIsSymbolicLinkKey = @"NSURLIsSymbolicLinkKey";
NSString * const NSURLIsVolumeKey = @"NSURLIsVolumeKey";
NSString * const NSURLIsPackageKey = @"NSURLIsPackageKey";
NSString * const NSURLIsSystemImmutableKey = @"NSURLIsSystemImmutableKey";
NSString * const NSURLIsUserImmutableKey = @"NSURLIsUserImmutableKey";
NSString * const NSURLIsHiddenKey = @"NSURLIsHiddenKey";
NSString * const NSURLHasHiddenExtensionKey = @"NSURLHasHiddenExtensionKey";
NSString * const NSURLCreationDateKey = @"NSURLCreationDateKey";
NSString * const NSURLContentAccessDateKey = @"NSURLContentAccessDateKey";
NSString * const NSURLContentModificationDateKey = @"NSURLContentModificationDateKey";
NSString * const NSURLAttributeModificationDateKey = @"NSURLAttributeModificationDateKey";
NSString * const NSURLLinkCountKey = @"NSURLLinkCountKey";
NSString * const NSURLParentDirectoryURLKey = @"NSURLParentDirectoryURLKey";
NSString * const NSURLVolumeURLKey = @"NSURLVolumeURLKey";
NSString * const NSURLTypeIdentifierKey = @"NSURLTypeIdentifierKey";
NSString * const NSURLLocalizedTypeDescriptionKey = @"NSURLLocalizedTypeDescriptionKey";
NSString * const NSURLLabelNumberKey = @"NSURLLabelNumberKey";
NSString * const NSURLLabelColorKey = @"NSURLLabelColorKey";
NSString * const NSURLLocalizedLabelKey = @"NSURLLocalizedLabelKey";
NSString * const NSURLEffectiveIconKey = @"NSURLEffectiveIconKey";
NSString * const NSURLCustomIconKey = @"NSURLCustomIconKey";
NSString * const NSURLFileResourceIdentifierKey = @"NSURLFileResourceIdentifierKey";
NSString * const NSURLVolumeIdentifierKey = @"NSURLVolumeIdentifierKey";
NSString * const NSURLPreferredIOBlockSizeKey = @"NSURLPreferredIOBlockSizeKey";
NSString * const NSURLIsReadableKey = @"NSURLIsReadableKey";
NSString * const NSURLIsWritableKey = @"NSURLIsWritableKey";
NSString * const NSURLIsExecutableKey = @"NSURLIsExecutableKey";
NSString * const NSURLIsMountTriggerKey = @"NSURLIsMountTriggerKey";
NSString * const NSURLFileSecurityKey = @"NSURLFileSecurityKey";
NSString * const NSURLIsExcludedFromBackupKey = @"NSURLIsExcludedFromBackupKey";
NSString * const NSURLFileResourceTypeKey = @"NSURLFileResourceTypeKey";
NSString * const NSURLFileResourceTypeNamedPipe = @"NSURLFileResourceTypeNamedPipe";
NSString * const NSURLFileResourceTypeCharacterSpecial = @"NSURLFileResourceTypeCharacterSpecial";
NSString * const NSURLFileResourceTypeDirectory = @"NSURLFileResourceTypeDirectory";
NSString * const NSURLFileResourceTypeBlockSpecial = @"NSURLFileResourceTypeBlockSpecial";
NSString * const NSURLFileResourceTypeRegular = @"NSURLFileResourceTypeRegular";
NSString * const NSURLFileResourceTypeSymbolicLink = @"NSURLFileResourceTypeSymbolicLink";
NSString * const NSURLFileResourceTypeSocket = @"NSURLFileResourceTypeSocket";
NSString * const NSURLFileResourceTypeUnknown = @"NSURLFileResourceTypeUnknown";
NSString * const NSURLFileSizeKey = @"NSURLFileSizeKey";
NSString * const NSURLFileAllocatedSizeKey = @"NSURLFileAllocatedSizeKey";
NSString * const NSURLTotalFileSizeKey = @"NSURLTotalFileSizeKey";
NSString * const NSURLTotalFileAllocatedSizeKey = @"NSURLTotalFileAllocatedSizeKey";
NSString * const NSURLIsAliasFileKey = @"NSURLIsAliasFileKey";
NSString * const NSURLVolumeLocalizedFormatDescriptionKey = @"NSURLVolumeLocalizedFormatDescriptionKey";
NSString * const NSURLVolumeTotalCapacityKey = @"NSURLVolumeTotalCapacityKey";
NSString * const NSURLVolumeAvailableCapacityKey = @"NSURLVolumeAvailableCapacityKey";
NSString * const NSURLVolumeResourceCountKey = @"NSURLVolumeResourceCountKey";
NSString * const NSURLVolumeSupportsPersistentIDsKey = @"NSURLVolumeSupportsPersistentIDsKey";
NSString * const NSURLVolumeSupportsSymbolicLinksKey = @"NSURLVolumeSupportsSymbolicLinksKey";
NSString * const NSURLVolumeSupportsHardLinksKey = @"NSURLVolumeSupportsHardLinksKey";
NSString * const NSURLVolumeSupportsJournalingKey = @"NSURLVolumeSupportsJournalingKey";
NSString * const NSURLVolumeIsJournalingKey = @"NSURLVolumeIsJournalingKey";
NSString * const NSURLVolumeSupportsSparseFilesKey = @"NSURLVolumeSupportsSparseFilesKey";
NSString * const NSURLVolumeSupportsZeroRunsKey = @"NSURLVolumeSupportsZeroRunsKey";
NSString * const NSURLVolumeSupportsCaseSensitiveNamesKey = @"NSURLVolumeSupportsCaseSensitiveNamesKey";
NSString * const NSURLVolumeSupportsCasePreservedNamesKey = @"NSURLVolumeSupportsCasePreservedNamesKey";
NSString * const NSURLVolumeSupportsRootDirectoryDatesKey = @"NSURLVolumeSupportsRootDirectoryDatesKey";
NSString * const NSURLVolumeSupportsVolumeSizesKey = @"NSURLVolumeSupportsVolumeSizesKey";
NSString * const NSURLVolumeSupportsRenamingKey = @"NSURLVolumeSupportsRenamingKey";
NSString * const NSURLVolumeSupportsAdvisoryFileLockingKey = @"NSURLVolumeSupportsAdvisoryFileLockingKey";
NSString * const NSURLVolumeSupportsExtendedSecurityKey = @"NSURLVolumeSupportsExtendedSecurityKey";
NSString * const NSURLVolumeIsBrowsableKey = @"NSURLVolumeIsBrowsableKey";
NSString * const NSURLVolumeMaximumFileSizeKey = @"NSURLVolumeMaximumFileSizeKey";
NSString * const NSURLVolumeIsEjectableKey = @"NSURLVolumeIsEjectableKey";
NSString * const NSURLVolumeIsRemovableKey = @"NSURLVolumeIsRemovableKey";
NSString * const NSURLVolumeIsInternalKey = @"NSURLVolumeIsInternalKey";
NSString * const NSURLVolumeIsAutomountedKey = @"NSURLVolumeIsAutomountedKey";
NSString * const NSURLVolumeIsLocalKey = @"NSURLVolumeIsLocalKey";
NSString * const NSURLVolumeIsReadOnlyKey = @"NSURLVolumeIsReadOnlyKey";
NSString * const NSURLVolumeCreationDateKey = @"NSURLVolumeCreationDateKey";
NSString * const NSURLVolumeURLForRemountingKey = @"NSURLVolumeURLForRemountingKey";
NSString * const NSURLVolumeUUIDStringKey = @"NSURLVolumeUUIDStringKey";
NSString * const NSURLVolumeNameKey = @"NSURLVolumeNameKey";
NSString * const NSURLVolumeLocalizedNameKey = @"NSURLVolumeLocalizedNameKey";
NSString * const NSURLIsUbiquitousItemKey = @"NSURLIsUbiquitousItemKey";
NSString * const NSURLUbiquitousItemHasUnresolvedConflictsKey = @"NSURLUbiquitousItemHasUnresolvedConflictsKey";
NSString * const NSURLUbiquitousItemIsDownloadedKey = @"NSURLUbiquitousItemIsDownloadedKey";
NSString * const NSURLUbiquitousItemIsDownloadingKey = @"NSURLUbiquitousItemIsDownloadingKey";
NSString * const NSURLUbiquitousItemIsUploadedKey = @"NSURLUbiquitousItemIsUploadedKey";
NSString * const NSURLUbiquitousItemIsUploadingKey = @"NSURLUbiquitousItemIsUploadingKey";
NSString * const NSURLUbiquitousItemPercentDownloadedKey = @"NSURLUbiquitousItemPercentDownloadedKey";
NSString * const NSURLUbiquitousItemPercentUploadedKey = @"NSURLUbiquitousItemPercentUploadedKey";

NSString * const NSURLErrorDomain = @"NSURLErrorDomain";
NSString * const NSErrorFailingURLStringKey = @"NSErrorFailingURLStringKey";
NSString * const NSURLErrorFailingURLErrorKey = @"NSErrorFailingURLStringKey"; //
                                                                               // Intentionally
                                                                               // duplicated
NSString * const NSURLErrorFailingURLStringErrorKey = @"NSURLErrorFailingURLStringErrorKey";

@interface  NSString (NSURLPrivate)
- (NSString*)_stringByAddingPercentEscapes;
@end

@implementation NSString (NSURLPrivate)
/* Like the normal percent escape method, but with additional characters
 * escaped.
 */
- (NSString*)_stringByAddingPercentEscapes
{
    NSData    *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString  *s = nil;

    if (data != nil)
    {
        unsigned char *src = (unsigned char*)[data bytes];
        unsigned int slen = [data length];
        unsigned char *dst;
        unsigned int spos = 0;
        unsigned int dpos = 0;

        dst = (unsigned char*)NSZoneMalloc(NSDefaultMallocZone(), slen * 3);
        while (spos < slen)
        {
            unsigned char c = src[spos++];
            unsigned int hi;
            unsigned int lo;

            if (c <= 32
                || c > 126
                || c == 34
                || c == 35
                || c == 37
                || c == 59
                || c == 60
                || c == 62
                || c == 63
                || c == 91
                || c == 92
                || c == 93
                || c == 94
                || c == 96
                || c == 123
                || c == 124
                || c == 125)
            {
                dst[dpos++] = '%';
                hi = (c & 0xf0) >> 4;
                dst[dpos++] = (hi > 9) ? 'A' + hi - 10 : '0' + hi;
                lo = (c & 0x0f);
                dst[dpos++] = (lo > 9) ? 'A' + lo - 10 : '0' + lo;
            }
            else
            {
                dst[dpos++] = c;
            }
        }
        s = [[NSString alloc] initWithBytes:dst
             length:dpos
             encoding:NSASCIIStringEncoding];
        NSZoneFree(NSDefaultMallocZone(), dst);
        IF_NO_GC([s autorelease]; )
    }
    return s;
}
@end

/*
 * Structure describing a URL.
 * All the char* fields may be NULL pointers, except path, which
 * is *always* non-null (though it may be an empty string).
 */
typedef struct {
    id absolute;        // Cache absolute string or nil
    char  *scheme;
    char  *user;
    char  *password;
    char  *host;
    char  *port;
    char  *path;        // May never be NULL
    char  *parameters;
    char  *query;
    char  *fragment;
    BOOL pathIsAbsolute;
    BOOL hasNoPath;
    BOOL isGeneric;
    BOOL isFile;
} parsedURL;

#define myData ((parsedURL*)(self->_data))
#define baseData ((self->_baseURL == 0) ? 0 : ((parsedURL*)(self->_baseURL->_data)))

static NSLock   *clientsLock = nil;

/*
 * Local utility functions.
 */
static char *buildURL(parsedURL *base, parsedURL *rel, BOOL standardize);
static id clientForHandle(void *data, NSURLHandle *hdl);
static char *findUp(char *str);
static char *unescape(const char *from, char * to);

/**
 * Build an absolute URL as a C string
 */
static char *buildURL(parsedURL *base, parsedURL *rel, BOOL standardize)
{
    char      *buf;
    char      *ptr;
    char      *tmp;
    unsigned int len = 1;

    if (rel->scheme != 0)
    {
        len += strlen(rel->scheme) + 3; // scheme://
    }
    if (rel->user != 0)
    {
        len += strlen(rel->user) + 1; // user...@
    }
    if (rel->password != 0)
    {
        len += strlen(rel->password) + 1; // :password
    }
    if (rel->host != 0)
    {
        len += strlen(rel->host) + 1; // host.../
    }
    else if(base != 0 && base->host != 0) /* rel host takes precedence even
                                            though the behaviour is technically
                                            undefined */
    {
        len += strlen(base->host) + 1;
    }
    if (rel->port != 0)
    {
        len += strlen(rel->port) + 1; // :port
    }
    if (rel->path != 0)
    {
        len += strlen(rel->path) + 1; // path
    }
    if (base != 0 && base->path != 0)
    {
        len += strlen(base->path) + 1;  // path
    }
    if (rel->parameters != 0)
    {
        len += strlen(rel->parameters) + 1; // ;parameters
    }
    if (rel->query != 0)
    {
        len += strlen(rel->query) + 1;      // ?query
    }
    if (rel->fragment != 0)
    {
        len += strlen(rel->fragment) + 1;   // #fragment
    }

    ptr = buf = (char*)NSZoneMalloc(NSDefaultMallocZone(), len);

    memset(ptr, 0, len);

    if (rel->scheme != 0)
    {
        strcpy(ptr, rel->scheme);
        ptr = &ptr[strlen(ptr)];
        *ptr++ = ':';
    }
    if (rel->isGeneric == YES
        || rel->user != 0 || rel->password != 0 || rel->host != 0 || (base != 0 && base->host != 0) || rel->port != 0)
    {
        *ptr++ = '/';
        *ptr++ = '/';
        if (rel->user != 0 || rel->password != 0)
        {
            if (rel->user != 0)
            {
                strcpy(ptr, rel->user);
                ptr = &ptr[strlen(ptr)];
            }
            if (rel->password != 0)
            {
                *ptr++ = ':';
                strcpy(ptr, rel->password);
                ptr = &ptr[strlen(ptr)];
            }
            if (rel->host != 0 || (base != 0 && base->host != 0) || rel->port != 0)
            {
                *ptr++ = '@';
            }
        }
        if (rel->host != 0)
        {
            strcpy(ptr, rel->host);
            ptr = &ptr[strlen(ptr)];
        }
        else if(base != 0 && base->host != 0)
        {
            strcpy(ptr, base->host);
            ptr = &ptr[strlen(ptr)];
        }
        if (rel->port != 0)
        {
            *ptr++ = ':';
            strcpy(ptr, rel->port);
            ptr = &ptr[strlen(ptr)];
        }
    }

    /*
     * Now build path.
     */

    tmp = ptr;
    if (rel->pathIsAbsolute == YES)
    {
        if (rel->hasNoPath == NO)
        {
            *tmp++ = '/';
        }
        if (rel->path) {
            strcpy(tmp, rel->path);
        }
        else if(base && base->path) {
            strcpy(tmp, base->path);
        }
    }
    else if (base == 0)
    {
        if (rel->path) {
            strcpy(tmp, rel->path);
        }
    }
    else if (rel->path[0] == 0)
    {
        if (base->hasNoPath == NO)
        {
            *tmp++ = '/';
        }
        strcpy(tmp, base->path);
    }
    else
    {
        char  *start = base->path;
        char  *end = strrchr(start, '/');

        if (end != 0)
        {
            *tmp++ = '/';
            strncpy(tmp, start, end - start);
            tmp += (end - start);
        }
        *tmp++ = '/';
        strcpy(tmp, rel->path);
    }

    if (standardize == YES)
    {
        /*
         * Compact '/./'  to '/' and strip any trailing '/.'
         */
        tmp = ptr;
        while (*tmp != '\0')
        {
            if (tmp[0] == '/' && tmp[1] == '.'
                && (tmp[2] == '/' || tmp[2] == '\0'))
            {
                /*
                 * Ensure we don't remove the leading '/'
                 */
                if (tmp == ptr && tmp[2] == '\0')
                {
                    tmp[1] = '\0';
                }
                else
                {
                    strcpy(tmp, &tmp[2]);
                }
            }
            else
            {
                tmp++;
            }
        }
        /*
         * Reduce any sequence of '/' characters to a single '/'
         */
        tmp = ptr;
        while (*tmp != '\0')
        {
            if (tmp[0] == '/' && tmp[1] == '/')
            {
                strcpy(tmp, &tmp[1]);
            }
            else
            {
                tmp++;
            }
        }
        /*
         * Reduce any '/something/../' sequence to '/' and a trailing
         * "/something/.." to ""
         */
        tmp = ptr;
        while ((tmp = findUp(tmp)) != 0)
        {
            char  *next = &tmp[3];

            while (tmp > ptr)
            {
                if (*--tmp == '/')
                {
                    break;
                }
            }
            /*
             * Ensure we don't remove the leading '/'
             */
            if (tmp == ptr && *next == '\0')
            {
                tmp[1] = '\0';
            }
            else
            {
                strcpy(tmp, next);
            }
        }
        /*
         * if we have an empty path, we standardize to a single slash.
         */
        tmp = ptr;
        if (*tmp == '\0')
        {
            strcpy(tmp, "/");
        }
    }
    ptr = &ptr[strlen(ptr)];

    if (rel->parameters != 0)
    {
        *ptr++ = ';';
        strcpy(ptr, rel->parameters);
        ptr = &ptr[strlen(ptr)];
    }
    if (rel->query != 0)
    {
        *ptr++ = '?';
        strcpy(ptr, rel->query);
        ptr = &ptr[strlen(ptr)];
    }
    if (rel->fragment != 0)
    {
        *ptr++ = '#';
        strcpy(ptr, rel->fragment);
        ptr = &ptr[strlen(ptr)];
    }

    return buf;
}

static id clientForHandle(void *data, NSURLHandle *hdl)
{
    id client = nil;

    if (data != 0)
    {
        [clientsLock lock];
        client = (id)NSMapGet((NSMapTable*)data, hdl);
        [clientsLock unlock];
    }
    return client;
}

/**
 * Locate a '/../ or trailing '/..'
 */
static char *findUp(char *str)
{
    while (*str != '\0')
    {
        if (str[0] == '/' && str[1] == '.' && str[2] == '.'
            && (str[3] == '/' || str[3] == '\0'))
        {
            return str;
        }
        str++;
    }
    return 0;
}

/*
 * Check a string to see if it contains only legal data characters
 * or percent escape sequences.
 */
static BOOL legal(const char *str, const char *extras)
{
    const char    *mark = "-_.!~*'()";

    if (str != 0)
    {
        while (*str != 0)
        {
            if (*str == '%' && isxdigit(str[1]) && isxdigit(str[2]))
            {
                str += 3;
            }
            else if (isalnum(*str))
            {
                str++;
            }
            else if (strchr(mark, *str) != 0)
            {
                str++;
            }
            else if (strchr(extras, *str) != 0)
            {
                str++;
            }
            else
            {
                return NO;
            }
        }
    }
    return YES;
}

/*
 * Convert percent escape sequences to individual characters.
 */
static char *unescape(const char *from, char * to)
{
    while (*from != '\0')
    {
        if (*from == '%')
        {
            unsigned char c;

            from++;
            if (isxdigit(*from))
            {
                if (*from <= '9')
                {
                    c = *from - '0';
                }
                else if (*from <= 'F')
                {
                    c = *from - 'A' + 10;
                }
                else
                {
                    c = *from - 'a' + 10;
                }
                from++;
            }
            else
            {
                c = 0; // Avoid compiler warning
                [NSException raise:NSGenericException
                 format:@"Bad percent escape sequence in URL string"];
            }
            c <<= 4;
            if (isxdigit(*from))
            {
                if (*from <= '9')
                {
                    c |= *from - '0';
                }
                else if (*from <= 'F')
                {
                    c |= *from - 'A' + 10;
                }
                else
                {
                    c |= *from - 'a' + 10;
                }
                from++;
                *to++ = c;
            }
            else
            {
                [NSException raise:NSGenericException
                 format:@"Bad percent escape sequence in URL string"];
            }
        }
        else
        {
            *to++ = *from++;
        }
    }
    *to = '\0';
    return to;
}


/**
 * This class permits manipulation of URLs and the resources to which they
 * refer.  They can be used to represent absolute URLs or relative URLs
 * which are based upon an absolute URL.  The relevant RFCs describing
 * how a URL is formatted, and what is legal in a URL are -
 * 1808, 1738, and 2396.<br />
 * Handling of the underlying resources is carried out by NSURLHandle
 * objects, but NSURL provides a simplified API wrapping these objects.
 */
@implementation NSURL

static unsigned urlAlign;

/**
 * Create and return a file URL with the supplied path.<br />
 * The value of aPath must be a valid filesystem path.<br />
 * Calls -initFileURLWithPath: which escapes characters in the
 * path where necessary.
 */
+ (id)fileURLWithPath:(NSString*)aPath
{
    return AUTORELEASE([[NSURL alloc] initFileURLWithPath:aPath]);
}

+ (id)fileURLWithPath:(NSString *)aPath isDirectory:(BOOL)isDir
{
    if (isDir)
    {
        return [self fileURLWithPath:[aPath stringByAppendingString:@"/"]];
    }
    else
    {
        return [self fileURLWithPath:aPath];
    }
}

+ (void)initialize
{
    if (clientsLock == nil)
    {
        urlAlign = objc_alignof_type(@encode(parsedURL));
        clientsLock = [NSLock new];
    }
}

/**
 * Create and return a URL with the supplied string, which should
 * be a string (containing percent escape codes where necessary)
 * conforming to the description (in RFC2396) of an absolute URL.<br />
 * Calls -initWithString:
 */
+ (id)URLWithString:(NSString*)aUrlString
{
    return AUTORELEASE([[NSURL alloc] initWithString:aUrlString]);
}

/**
 * Create and return a URL with the supplied string, which should
 * be a string (containing percent escape codes where necessary)
 * conforming to the description (in RFC2396) of a relative URL.<br />
 * Calls -initWithString:relativeToURL:
 */
+ (id)URLWithString:(NSString*)aUrlString
    relativeToURL:(NSURL*)aBaseUrl
{
    return AUTORELEASE([[NSURL alloc] initWithString:aUrlString
                        relativeToURL:aBaseUrl]);
}

/**
 * Initialise by building a URL string from the supplied parameters
 * and calling -initWithString:relativeToURL:<br />
 * This method adds percent escapes to aPath if it contains characters
 * which need escaping.<br />
 * Accepts RFC2732 style IPv6 host addresses either with or without the
 * enclosing square brackets (MacOS-X at least up to version 10.5 does
 * not handle these correctly, but GNUstep does).<br />
 * Permits the 'aHost' part to contain 'username:password@host:port' or
 * 'host:port' in addition to a simple host name or address.
 */
- (id)initWithScheme:(NSString*)aScheme
    host:(NSString*)aHost
    path:(NSString*)aPath
{
    NSString  *aUrlString = [NSString alloc];

    aPath = [aPath _stringByAddingPercentEscapes];
    if ([aHost length] > 0)
    {
        NSRange r = [aHost rangeOfString:@"@"];
        NSString  *auth = nil;

        /* Allow for authentication (username:password) before actual host.
         */
        if (r.length > 0)
        {
            auth = [aHost substringToIndex:r.location];
            aHost = [aHost substringFromIndex:NSMaxRange(r)];
        }

        /* Add square brackets around ipv6 address if necessary
         */
        if ([[aHost componentsSeparatedByString:@":"] count] > 2
            && [aHost hasPrefix:@"["] == NO)
        {
            aHost = [NSString stringWithFormat:@"[%@]", aHost];
        }

        if (auth != nil)
        {
            aHost = [NSString stringWithFormat:@"%@@%@", auth, aHost];
        }

        if ([aPath length] > 0)
        {
            /*
             * For MacOS-X compatibility, assume a path component with
             * a leading slash is intended to have that slash separating
             * the host from the path as specified in the RFC1738
             */
            if ([aPath hasPrefix:@"/"] == YES)
            {
                aUrlString = [aUrlString initWithFormat:@"%@://%@%@",
                              aScheme, aHost, aPath];
            }
            else
            {
                aUrlString = [aUrlString initWithFormat:@"%@://%@/%@",
                              aScheme, aHost, aPath];
            }
        }
        else
        {
            aUrlString = [aUrlString initWithFormat:@"%@://%@/",
                          aScheme, aHost];
        }
    }
    else
    {
        if ([aPath length] > 0)
        {
            aUrlString = [aUrlString initWithFormat:@"%@:%@",
                          aScheme, aPath];
        }
        else
        {
            aUrlString = [aUrlString initWithFormat:@"%@:",
                          aScheme];
        }
    }
    self = [self initWithString:aUrlString relativeToURL:nil];
    RELEASE(aUrlString);
    return self;
}

- (id)initFileURLWithPath:(NSString*)aPath isDirectory:(BOOL)isDirectory
{
    // TODO (aultman): do I need to do something with the isDirectory flag?
    return [self initFileURLWithPath:aPath];
}


/**
 * Initialise as a file URL with the specified path (which must
 * be a valid path on the local filesystem).<br />
 * Converts relative paths to absolute ones.<br />
 * Appends a trailing slash to the path when necessary if it
 * specifies a directory.<br />
 * Calls -initWithScheme:host:path:
 */
- (id)initFileURLWithPath:(NSString*)aPath
{
    NSFileManager *mgr = [NSFileManager defaultManager];
    BOOL flag = NO;

    if ([aPath isAbsolutePath] == NO)
    {
        aPath = [[mgr currentDirectoryPath]
                 stringByAppendingPathComponent:aPath];
    }
// TODO(jackson): Support path standardization
    self = [self initWithScheme:NSURLFileScheme
            host:@"localhost"
            path:aPath];
    return self;
}

/**
 * Initialise as an absolute URL.<br />
 * Calls -initWithString:relativeToURL:
 */
- (id)initWithString:(NSString*)aUrlString
{
    self = [self initWithString:aUrlString relativeToURL:nil];
    return self;
}

/** <init />
 * Initialised using aUrlString and aBaseUrl.  The value of aBaseUrl
 * may be nil, but aUrlString must be non-nil.<br />
 * Accepts RFC2732 style IPv6 host addresses.<br />
 * Parses a string wihthout a scheme as a simple path.<br />
 * Parses an empty string as an empty path.<br />
 * If the string cannot be parsed the method returns nil.
 */
- (id)initWithString:(NSString*)aUrlString
    relativeToURL:(NSURL*)aBaseUrl
{
    if (aUrlString == NULL || [aUrlString length] == 0)
    {
        [self release];
        return [aBaseUrl copy];
    }

    if(aBaseUrl != NULL)
    {
        // For cases when aUrlString and aBaseURL contain common paths
        aUrlString = [aUrlString stringByReplacingOccurrencesOfString:[aBaseUrl path]
                      withString:@""
                      options:NSAnchoredSearch
                      range:NSMakeRange(0, aUrlString.length)];
    }
    /* RFC 2396 'reserved' characters ...
     * as modified by RFC2732
     * static const char *reserved = ";/?:@&=+$,[]";
     */
    /* Same as reserved set but allow the hash character in a path too.
     */
    static const char *filepath = ";/?:@&=+$,[]#";

    if ([aUrlString isKindOfClass:[NSString class]] == NO)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"[%@ %@] nil string parameter",
         NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
    }
    if (aBaseUrl != nil
        && [aBaseUrl isKindOfClass:[NSURL class]] == NO)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"[%@ %@] bad base URL parameter",
         NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
    }
    ASSIGNCOPY(_urlString, aUrlString);
    ASSIGN(_baseURL, [aBaseUrl absoluteURL]);
    NS_DURING
    {
        parsedURL *buf;
        parsedURL *base = baseData;
        unsigned size = [_urlString length];
        char  *end;
        char  *start;
        char  *ptr;
        BOOL usesFragments = YES;
        BOOL usesParameters = YES;
        BOOL usesQueries = YES;
        BOOL canBeGeneric = YES;

        size += sizeof(parsedURL) + urlAlign + 1;
        buf = _data = (parsedURL*)NSZoneMalloc(NSDefaultMallocZone(), size);

        if (buf == NULL)
        {
            [NSException raise:NSMallocException
             format:@"parsedURL for URL %@ coult not be allocated", aUrlString];
        }

        memset(buf, '\0', size);
        start = end = ptr = (char*)&buf[1];
        [_urlString getCString:start
         maxLength:size
         encoding:NSASCIIStringEncoding];


        UriParserStateA state;
        UriUriA uri;

        state.uri = &uri;
        if (uriParseUriA(&state, start) != URI_SUCCESS) {
            [NSException raise:NSInvalidArgumentException
             format:@"[%@] URL could not be parsed", aUrlString];
            uriFreeUriMembersA(&uri);
        }
        else
        {
            if (uri.portText.first != NULL)
            {
                size = uri.portText.afterLast-uri.portText.first;
                buf->port = NSZoneMalloc(NSDefaultMallocZone(),size+1);
                memset(buf->port, '\0', size+1);
                memcpy(buf->port, uri.portText.first, size);
            }
            if (uri.scheme.first != NULL)
            {
                size = uri.scheme.afterLast-uri.scheme.first;
                buf->scheme = NSZoneMalloc(NSDefaultMallocZone(),size+1);
                memset(buf->scheme, '\0', size+1);
                memcpy(buf->scheme, uri.scheme.first, size);
            }

            if (uri.hostText.first != NULL)
            {
                size = uri.hostText.afterLast-uri.hostText.first;
                buf->host = NSZoneMalloc(NSDefaultMallocZone(),size+1);
                memset(buf->host, '\0', size+1);
                memcpy(buf->host, uri.hostText.first, size);
            }

            if (uri.userInfo.first != NULL)
            {
                size = uri.userInfo.afterLast-uri.hostText.first;
                char* userInfo = NSZoneMalloc(NSDefaultMallocZone(),size+1);
                memset(userInfo, '\0', size+1);
                memcpy(userInfo, uri.userInfo.first, size);
                char* pass = strchr(userInfo, ':');
                int userSize = userInfo+size-pass;
                int passSize = size-userSize-1;
                buf->user = malloc(userSize+1);
                memset(buf->user, '\0', userSize+1);
                memcpy(buf->user, userInfo, userSize);
                buf->password = NSZoneMalloc(NSDefaultMallocZone(),passSize+1);
                memset(buf->password, '\0', passSize+1);
                memcpy(buf->password, pass, passSize);
                NSZoneFree([self zone], userInfo);
            }

            if (uri.absolutePath)
            {
                buf->pathIsAbsolute = YES;
                base = 0;
            }

            if (uri.pathHead != NULL)
            {
                UriPathSegmentA* node = uri.pathHead;
                char* path = NSZoneMalloc(NSDefaultMallocZone(),2);
                if (buf->scheme == NULL)
                {
                    if (aBaseUrl != NULL)
                    {
                        Class cls = [self class];
                        DESTROY(self);
                        return [[cls alloc] initWithString: [[aBaseUrl absoluteString] stringByAppendingString: aUrlString]];
                    }
                    else
                    {
                        buf->path = strdup(aUrlString.UTF8String);
                        buf->pathIsAbsolute = NO;
                        buf->hasNoPath = NO;
                        return self;
                    }
                }
                else if (strcmp(buf->scheme,"mailto") == 0)
                {
                    path[0] = '\0';
                }
                else
                {
                    path[0] = '/';
                    path[1] = '\0';
                }

                if (strcmp(buf->scheme,"file") == 0)
                {
                    buf->isFile = YES;
                }

                while (node != NULL)
                {
                    int nodeSize = node->text.afterLast - node->text.first;
                    if (nodeSize != 0) {
                        char* newPath = NSZoneMalloc(NSDefaultMallocZone(),strlen(path)+nodeSize+2);
                        strcpy(newPath,path);
                        memcpy(newPath+(strlen(path)),node->text.first, nodeSize);
                        if ((strcmp(buf->scheme,"mailto") == 0) || node->next == NULL )
                        {
                            //If this is a mailto, or this is the end of the
                            // path section
                            //then do not add any /
                            newPath[strlen(path)+nodeSize] = '\0';
                        }
                        else
                        {
                            newPath[strlen(path)+nodeSize] = '/';
                            newPath[strlen(path)+nodeSize+1] = '\0';
                        }
                        free(path);
                        path = newPath;
                    }
                    node = node->next;
                }
                buf->path = path;
            }
            else {
                buf->pathIsAbsolute = YES;
                buf->hasNoPath = YES;
            }

            if (uri.query.first != NULL)
            {
                size = uri.query.afterLast - uri.query.first;
                buf->query = NSZoneMalloc(NSDefaultMallocZone(),size+1);
                memset(buf->query, '\0', size+1);
                memcpy(buf->query, uri.query.first, size);
            }

            if (uri.fragment.first != NULL)
            {
                size = uri.fragment.afterLast - uri.fragment.first;
                buf->fragment = NSZoneMalloc(NSDefaultMallocZone(),size+1);
                memset(buf->fragment, '\0', size+1);
                memcpy(buf->fragment, uri.fragment.first, size);
            }


            uriFreeUriMembersA(&uri);

            if (base != 0 && base->scheme != 0 && buf->scheme != 0 && strcmp(base->scheme, buf->scheme) != 0)
            {
                [NSException raise:NSInvalidArgumentException
                 format:@"[%@ %@](%@, %@) "
                        @"scheme of base and relative parts does not match",
                 NSStringFromClass([self class]),
                 NSStringFromSelector(_cmd),
                 aUrlString, aBaseUrl];
            }

            if (buf->scheme == 0 && base != 0)
            {
                buf->scheme = base->scheme;
            }

            if (buf->fragment == 0 && base != 0)
            {
                buf->fragment = base->fragment;
            }

            if (buf->query == 0 && base != 0)
            {
                buf->query = base->query;
            }

            if (buf->parameters == 0 && base != 0)
            {
                buf->parameters = base->parameters;
            }
        }
    }

    NS_HANDLER
    {
        NSDebugLog(@"%@", localException);
        DESTROY(self);
    }
    NS_ENDHANDLER
    return self;
}

- (void)dealloc
{
    if (_clients != 0)
    {
        NSFreeMapTable(_clients);
        _clients = 0;
    }
    if (_data != 0)
    {
        DESTROY(myData->absolute);
        parsedURL *buf = _data;
        if (buf->scheme) {
            NSZoneFree([self zone], buf->scheme);
            buf->scheme = 0;
        }
        if (buf->host) {
            NSZoneFree([self zone], buf->host);
            buf->host = 0;
        }
        if (buf->path) {
            NSZoneFree([self zone], buf->path);
            buf->path = 0;
        }
        if (buf->user) {
            NSZoneFree([self zone], buf->user);
            buf->user = 0;
        }
        if (buf->password) {
            NSZoneFree([self zone], buf->password);
            buf->password = 0;
        }
        if (buf->query) {
            NSZoneFree([self zone], buf->query);
            buf->query = 0;
        }
        if (buf->parameters) {
            NSZoneFree([self zone], buf->parameters);
            buf->parameters = 0;
        }
        if (buf->fragment) {
            NSZoneFree([self zone], buf->fragment);
            buf->fragment = 0;
        }

        NSZoneFree([self zone], _data);
        _data = 0;
    }
    DESTROY(_urlString);
    DESTROY(_baseURL);
    [super dealloc];
}

- (id)copyWithZone:(NSZone*)zone
{
    if (NSShouldRetainWithZone(self, zone) == NO)
    {
        return [[object_getClass(self) allocWithZone:zone] initWithString:_urlString
                relativeToURL:_baseURL];
    }
    else
    {
        return RETAIN(self);
    }
}

- (NSString*)description
{
    NSString  *dscr = _urlString;

    if (_baseURL != nil)
    {
        dscr = [dscr stringByAppendingFormat:@" -- %@", _baseURL];
    }
    return dscr;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    if ([aCoder allowsKeyedCoding])
    {
        [aCoder encodeObject:_baseURL forKey:@"NS.base"];
        [aCoder encodeObject:_urlString forKey:@"NS.relative"];
    }
    else
    {
        [aCoder encodeObject:_urlString];
        [aCoder encodeObject:_baseURL];
    }
}

- (NSUInteger)hash
{
    return [[self absoluteString] hash];
}

- (id)initWithCoder:(NSCoder*)aCoder
{
    NSURL     *base;
    NSString  *rel;

    if ([aCoder allowsKeyedCoding])
    {
        base = [aCoder decodeObjectForKey:@"NS.base"];
        rel = [aCoder decodeObjectForKey:@"NS.relative"];
    }
    else
    {
        rel = [aCoder decodeObject];
        base = [aCoder decodeObject];
    }
    if (nil == rel)
    {
        rel = @"";
    }
    self = [self initWithString:rel relativeToURL:base];
    return self;
}

- (BOOL)isEqual:(id)other
{
    if (other == nil || [other isKindOfClass:[NSURL class]] == NO)
    {
        return NO;
    }
    return [[self absoluteString] isEqualToString:[other absoluteString]];
}

/**
 * Returns the full string describing the receiver resolved against its base.
 */
- (NSString*)absoluteString
{
    NSString  *absString = myData->absolute;

    if (absString == nil)
    {
        char  *url = buildURL(baseData, myData, NO);
        unsigned len = strlen(url);

        if (len)
        {
            absString = [[NSString alloc] initWithCStringNoCopy:url
                         length:len
                         freeWhenDone:YES];
        }
        else
        {
            free(url);
            absString = [_urlString copy];
        }
        myData->absolute = absString;
    }
    return absString;
}

/**
 * If the receiver is an absolute URL, returns self.  Otherwise returns an
 * absolute URL referring to the same resource as the receiver.
 */
- (NSURL*)absoluteURL
{
    if (_baseURL == nil)
    {
        return self;
    }
    else
    {
        return [NSURL URLWithString:[self absoluteString]];
    }
}

/**
 * If the receiver is a relative URL, returns its base URL.<br />
 * Otherwise, returns nil.
 */
- (NSURL*)baseURL
{
    return _baseURL;
}

/**
 * Returns the fragment portion of the receiver or nil if there is no
 * fragment supplied in the URL.<br />
 * The fragment is everything in the original URL string after a '#'<br />
 * File URLs do not have fragments.
 */
- (NSString*)fragment
{
    NSString  *fragment = nil;

    if (myData->fragment != 0)
    {
        fragment = [NSString stringWithUTF8String:myData->fragment];
    }
    return fragment;
}

- (char*)_path:(char*)buf
{
    char      *ptr = buf;
    char      *tmp = buf;

    if (myData->pathIsAbsolute == YES)
    {
        if (myData->hasNoPath == NO)
        {
            *tmp++ = '/';
        }
        if (myData->path != 0)
        {
            strcpy(tmp, myData->path);
        }
    }
    else if (_baseURL == nil)
    {
        if (myData->path != 0)
        {
            strcpy(tmp, myData->path);
        }
    }
    else if (*myData->path == 0)
    {
        if (baseData->hasNoPath == NO)
        {
            *tmp++ = '/';
        }
        if (baseData->path != 0)
        {
            strcpy(tmp, baseData->path);
        }
    }
    else
    {
        char  *start = baseData->path;
        char  *end = (start == 0) ? 0 : strrchr(start, '/');

        if (end != 0)
        {
            *tmp++ = '/';
            strncpy(tmp, start, end - start);
            tmp += end - start;
        }
        *tmp++ = '/';
        if (myData->path != 0)
        {
            strcpy(tmp, myData->path);
        }
    }

    return ptr;
}

- (NSString*)fullPath
{
    NSString  *path = nil;
    unsigned int len = 3;

    if (_baseURL != nil)
    {
        if (baseData->path && *baseData->path)
        {
            len += strlen(baseData->path);
        }
        else if (baseData->hasNoPath == NO)
        {
            len++;
        }
    }
    if (myData->path && *myData->path)
    {
        len += strlen(myData->path);
    }
    else if (myData->hasNoPath == NO)
    {
        len++;
    }
    if (len > 3)
    {
        char buf[len];
        char      *ptr;

        ptr = [self _path:buf];
        path = [NSString stringWithUTF8String:ptr];
    }
    return path;
}

/**
 * Returns the host portion of the receiver or nil if there is no
 * host supplied in the URL.<br />
 * Percent escape sequences in the user string are translated and the string
 * treated as UTF8.<br />
 * Returns IPv6 addresses <em>without</em> the enclosing square brackets
 * required (by RFC2732) in URL strings.
 */
- (NSString*)host
{
    NSString  *host = nil;
    char *currentHost = myData->host;
    if(currentHost == NULL && baseData != NULL)
    {
        currentHost = baseData->host;
    }
    if (currentHost != 0)
    {
        char buf[strlen(currentHost)+1];

        if (*currentHost == '[')
        {
            char  *end = unescape(currentHost + 1, buf);

            if (end[-1] == ']')
            {
                end[-1] = '\0';
            }
        }
        else
        {
            unescape(currentHost, buf);
        }
        host = [NSString stringWithUTF8String:buf];
    }
    return host;
}

/**
 * Returns YES if the receiver is a file URL, NO otherwise.
 */
- (BOOL)isFileURL
{
    return myData->isFile;
}

/**
 * Loads resource data for the specified client.
 * <p>
 *   If shouldUseCache is YES then an attempt
 *   will be made to locate a cached NSURLHandle to provide the
 *   resource data, otherwise a new handle will be created and
 *   cached.
 * </p>
 * <p>
 *   If the handle does not have the data available, it will be
 *   asked to load the data in the background by calling its
 *   loadInBackground  method.
 * </p>
 * <p>
 *   The specified client (if non-nil) will be set up to receive
 *   notifications of the progress of the background load process.
 * </p>
 * <p>
 *   The processes current run loop must be run in order for the
 *   background load operation to operate!
 * </p>
 */
- (void)loadResourceDataNotifyingClient:(id)client
    usingCache:(BOOL)shouldUseCache
{
    NSURLHandle   *handle = [self URLHandleUsingCache:YES];
    NSData    *d;

    if (shouldUseCache == YES && (d = [handle availableResourceData]) != nil)
    {
        /*
         * We already have cached data we should use.
         */
        if ([client respondsToSelector:
             @selector(URL:resourceDataDidBecomeAvailable:)])
        {
            [client URL:self resourceDataDidBecomeAvailable:d];
        }
        if ([client respondsToSelector:@selector(URLResourceDidFinishLoading:)])
        {
            [client URLResourceDidFinishLoading:self];
        }
    }
    else
    {
        if (client != nil)
        {
            [clientsLock lock];
            if (_clients == 0)
            {
                _clients = NSCreateMapTable (NSObjectMapKeyCallBacks,
                                             NSNonRetainedObjectMapValueCallBacks, 0);
            }
            NSMapInsert((NSMapTable*)_clients, (void*)handle, (void*)client);
            [clientsLock unlock];
            [handle addClient:self];
        }

        /*
         * Kick off the load process.
         */
        [handle loadInBackground];
    }
}

/**
 * Returns the parameter portion of the receiver or nil if there is no
 * parameter supplied in the URL.<br />
 * The parameters are everything in the original URL string after a ';'
 * but before the query.<br />
 * File URLs do not have parameters.
 */
- (NSString*)parameterString
{
    NSString  *parameters = nil;

    if (myData->parameters != 0)
    {
        parameters = [NSString stringWithUTF8String:myData->parameters];
    }
    return parameters;
}

/**
 * Returns the password portion of the receiver or nil if there is no
 * password supplied in the URL.<br />
 * Percent escape sequences in the user string are translated and the string
 * treated as UTF8 in GNUstep but this appears to be broken in MacOS-X.<br />
 * NB. because of its security implications it is recommended that you
 * do not use URLs with users and passwords unless necessary.
 */
- (NSString*)password
{
    NSString  *password = nil;

    if (myData->password != 0)
    {
        char buf[strlen(myData->password)+1];

        unescape(myData->password, buf);
        password = [NSString stringWithUTF8String:buf];
    }
    return password;
}

/**
 * Returns the path portion of the receiver.<br />
 * Replaces percent escapes with unescaped values, interpreting non-ascii
 * character sequences as UTF8.<br />
 * NB. This does not conform strictly to the RFCs, in that it includes a
 * leading slash ('/') character (whereas the path part of a URL strictly
 * should not) and the interpretation of non-ascii character is (strictly
 * speaking) undefined.<br />
 * Also, this breaks strict conformance in that a URL of file scheme is
 * treated as having a path (contrary to RFCs)
 */
- (NSString*)path
{
    NSString  *path = nil;
    unsigned int len = 3;

    if (_baseURL != nil)
    {
        if (baseData->path && *baseData->path)
        {
            len += strlen(baseData->path);
        }
        else if (baseData->hasNoPath == NO)
        {
            len++;
        }
    }
    if (myData->path && *myData->path)
    {
        len += strlen(myData->path);
    }
    else if (myData->hasNoPath == NO)
    {
        len++;
    }
    if (len > 3)
    {
        char buf[len];
        char      *ptr;
        char      *tmp;

        ptr = [self _path:buf];

        /* Remove any trailing '/' from the path for MacOS-X compatibility.
         */
        tmp = ptr + strlen(ptr) - 1;
        if (tmp > ptr && *tmp == '/')
        {
            *tmp = '\0';
        }

        path = [NSString stringWithUTF8String:ptr];
    }
    return path;
}

/**
 * Returns the port portion of the receiver or nil if there is no
 * port supplied in the URL.<br />
 * Percent escape sequences in the user string are translated in GNUstep
 * but this appears to be broken in MacOS-X.
 */
- (NSNumber*)port
{
    NSNumber  *port = nil;

    if (myData->port != 0)
    {
        char buf[strlen(myData->port)+1];

        unescape(myData->port, buf);
        port = [NSNumber numberWithUnsignedShort:atol(buf)];
    }
    return port;
}

/**
 * Asks a URL handle to return the property for the specified key and
 * returns the result.
 */
- (id)propertyForKey:(NSString*)propertyKey
{
    NSURLHandle   *handle = [self URLHandleUsingCache:YES];

    return [handle propertyForKey:propertyKey];
}

/**
 * Returns the query portion of the receiver or nil if there is no
 * query supplied in the URL.<br />
 * The query is everything in the original URL string after a '?'
 * but before the fragment.<br />
 * File URLs do not have queries.
 */
- (NSString*)query
{
    NSString  *query = nil;

    if (myData->query != 0)
    {
        query = [NSString stringWithUTF8String:myData->query];
    }
    return query;
}

/**
 * Returns the path of the receiver, without taking any base URL into account.
 * If the receiver is an absolute URL, -relativePath is the same as -path.<br />
 * Returns nil if there is no path specified for the URL.
 */
- (NSString*)relativePath
{
    if (nil == _baseURL)
    {
        return [self path];
    }
    else
    {
        NSString  *path = nil;

        if (myData->path != 0)
        {
            path = [NSString stringWithUTF8String:myData->path];
        }
        return path;
    }
}

/**
 * Returns the relative portion of the URL string.  If the receiver is not
 * a relative URL, this returns the same as absoluteString.
 */
- (NSString*)relativeString
{
    return _urlString;
}

/* Encode bycopy unless explicitly requested otherwise.
 */
- (id)replacementObjectForPortCoder:(NSPortCoder*)aCoder
{
    if ([aCoder isByref] == NO) {
        return self;
    }
    return [super replacementObjectForPortCoder:aCoder];
}

/**
 * Loads the resource data for the represented URL and returns the result.
 * The shouldUseCache flag determines whether data previously retrieved by
 * an existing NSURLHandle can be used to provide the data, or if it should
 * be refetched.
 */

- (NSData*)resourceDataUsingCache:(BOOL)shouldUseCache error:(NSError **)error
{
    if ([self isFileURL]) {
        return [NSData dataWithContentsOfFile:[self path]];
    }
    else {
        NSURLResponse *response = NULL;
        return [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:self] returningResponse:&response error:error];
    }
}

- (NSData*)resourceDataUsingCache:(BOOL)shouldUseCache
{
    return [self resourceDataUsingCache:shouldUseCache error:nil];
}

/**
 * Returns the resource specifier of the URL ... the part which lies
 * after the scheme.
 */
- (NSString*)resourceSpecifier
{
    NSRange range = [_urlString rangeOfString:@"://"];

    if (range.length > 0)
    {
        /*
           This is incorrect according to the documentation in Foundation.
           "Any URL is composed of these two basic pieces.  The full URL would
              be the concatenation of [myURL scheme], ':', [myURL
              resourceSpecifier]"
         */
        //return [_urlString substringFromIndex: NSMaxRange(range)];
        return [_urlString substringFromIndex:range.location + 1];  //start
                                                                    // after the
                                                                    // :
    }
    else
    {
        /*
         * Cope with URLs missing net_path info -  <scheme>:/<path>...
         */
        range = [_urlString rangeOfString:@":"];
        if (range.length > 0)
        {
            return [_urlString substringFromIndex:range.location + 1];
        }
        else
        {
            return _urlString;
        }
    }
}

/**
 * Returns the scheme of the receiver.
 */
- (NSString*)scheme
{
    NSString  *scheme = nil;

    if (myData->scheme != 0)
    {
        scheme = [NSString stringWithUTF8String:myData->scheme];
    }
    return scheme;
}

/**
 * Calls [NSURLHandle-writeProperty:forKey:] to set the named property.
 */
- (BOOL)setProperty:(id)property
    forKey:(NSString*)propertyKey
{
    NSURLHandle   *handle = [self URLHandleUsingCache:YES];

    return [handle writeProperty:property forKey:propertyKey];
}

/**
 * Calls [NSURLHandle-writeData:] to write the specified data object
 * to the resource identified by the receiver URL.<br />
 * Returns the result.
 */
- (BOOL)setResourceData:(NSData*)data
{
    NSURLHandle   *handle = [self URLHandleUsingCache:YES];

    if (handle == nil)
    {
        return NO;
    }
    if ([handle writeData:data] == NO)
    {
        return NO;
    }
    if ([handle loadInForeground] == nil)
    {
        return NO;
    }
    return YES;
}

/**
 * Returns a URL with '/./' and '/../' sequences resolved etc.
 */
- (NSURL*)standardizedURL
{
    char      *url = buildURL(baseData, myData, YES);
    unsigned len = strlen(url);
    NSString  *str;
    NSURL     *tmp;

    str = [[NSString alloc] initWithCStringNoCopy:url
           length:len
           freeWhenDone:YES];
    tmp = [NSURL URLWithString:str];
    RELEASE(str);
    return tmp;
}

/**
 * Returns an NSURLHandle instance which may be used to write data to the
 * resource represented by the receiver URL, or read data from it.<br />
 * The shouldUseCache flag indicates whether a cached handle may be returned
 * or a new one should be created.
 */
- (NSURLHandle*)URLHandleUsingCache:(BOOL)shouldUseCache
{
    NSURLHandle   *handle = nil;

    if (shouldUseCache)
    {
        handle = [NSURLHandle cachedHandleForURL:self];
    }
    if (handle == nil)
    {
        Class c = [NSURLHandle URLHandleClassForURL:self];

        if (c != 0)
        {
            handle = [[c alloc] initWithURL:self cached:shouldUseCache];
            IF_NO_GC([handle autorelease]; )
        }
    }
    return handle;
}

/**
 * Returns the user portion of the receiver or nil if there is no
 * user supplied in the URL.<br />
 * Percent escape sequences in the user string are translated and
 * the whole is treated as UTF8 data.<br />
 * NB. because of its security implications it is recommended that you
 * do not use URLs with users and passwords unless necessary.
 */
- (NSString*)user
{
    NSString  *user = nil;

    if (myData->user != 0)
    {
        char buf[strlen(myData->user)+1];

        unescape(myData->user, buf);
        user = [NSString stringWithUTF8String:buf];
    }
    return user;
}

- (void)URLHandle:(NSURLHandle*)sender
    resourceDataDidBecomeAvailable:(NSData*)newData
{
    id c = clientForHandle(_clients, sender);

    if ([c respondsToSelector:@selector(URL:resourceDataDidBecomeAvailable:)])
    {
        [c URL:self resourceDataDidBecomeAvailable:newData];
    }
}

- (void)URLHandle:(NSURLHandle*)sender
    resourceDidFailLoadingWithReason:(NSString*)reason
{
    id c = clientForHandle(_clients, sender);

    if (c != nil)
    {
        if ([c respondsToSelector:
             @selector(URL:resourceDidFailLoadingWithReason:)])
        {
            [c URL:self resourceDidFailLoadingWithReason:reason];
        }
        [clientsLock lock];
        NSMapRemove((NSMapTable*)_clients, (void*)sender);
        [clientsLock unlock];
    }
    [sender removeClient:self];
}

- (void)URLHandleResourceDidBeginLoading:(NSURLHandle*)sender
{
}

- (void)URLHandleResourceDidCancelLoading:(NSURLHandle*)sender
{
    id c = clientForHandle(_clients, sender);

    if (c != nil)
    {
        if ([c respondsToSelector:@selector(URLResourceDidCancelLoading:)])
        {
            [c URLResourceDidCancelLoading:self];
        }
        [clientsLock lock];
        NSMapRemove((NSMapTable*)_clients, (void*)sender);
        [clientsLock unlock];
    }
    [sender removeClient:self];
}

- (void)URLHandleResourceDidFinishLoading:(NSURLHandle*)sender
{
    id c = clientForHandle(_clients, sender);

    IF_NO_GC([self retain]; )
    [sender removeClient : self];
    if (c != nil)
    {
        if ([c respondsToSelector:@selector(URLResourceDidFinishLoading:)])
        {
            [c URLResourceDidFinishLoading:self];
        }
        [clientsLock lock];
        NSMapRemove((NSMapTable*)_clients, (void*)sender);
        [clientsLock unlock];
    }
    RELEASE(self);
}

- (NSURL *)URLByDeletingLastPathComponent
{
    if ([self isFileURL])
    {
        return [NSURL fileURLWithPath:[[self path] stringByDeletingLastPathComponent]];
    }
    else
    {
        return [[[NSURL alloc] initWithScheme:[self scheme] host:[self host] path:[[self path] stringByDeletingLastPathComponent]] autorelease];
    }
}

- (NSString *)pathExtension
{
    return [[self path] pathExtension];
}

- (NSString *)lastPathComponent
{
    return [[self path] lastPathComponent];
}

- (NSURL *)URLByDeletingPathExtension
{
    if ([self isFileURL])
    {
        return [NSURL fileURLWithPath:[[self path] stringByDeletingPathExtension]];
    }
    else
    {
        return [[[NSURL alloc] initWithScheme:[self scheme] host:[self host] path:[[self path] stringByDeletingPathExtension]] autorelease];
    }
}

- (NSURL *)URLByAppendingPathComponent:(NSString *)comp isDirectory:(BOOL)isDir
{
    if ([self isFileURL])
    {
        if (isDir)
        {
            return [NSURL fileURLWithPath:[[[self path] stringByAppendingPathComponent:comp] stringByAppendingString:@"/"]];
        }
        else
        {
            return [NSURL fileURLWithPath:[[self path] stringByAppendingPathComponent:comp]];
        }
    }
    else
    {
        if (isDir)
        {
            return [[[NSURL alloc] initWithScheme:[self scheme] host:[self host] path:[[[self path] stringByAppendingPathComponent:comp] stringByAppendingString:@"/"]] autorelease];
        }
        else
        {
            return [[[NSURL alloc] initWithScheme:[self scheme] host:[self host] path:[[self path] stringByAppendingPathComponent:comp]] autorelease];
        }
    }
}

- (NSURL *)URLByAppendingPathComponent:(NSString *)comp  {
    return [self URLByAppendingPathComponent:comp isDirectory:NO];
}

- (NSURL *)URLByAppendingPathExtension:(NSString *)comp {
    if ([self isFileURL])
    {
        return [NSURL fileURLWithPath:[[self path] stringByAppendingPathExtension:comp]];
    }
    else {
        return [[[NSURL alloc] initWithScheme:[self scheme] host:[self host] path:[[self path] stringByAppendingPathExtension:comp]] autorelease];
    }
}

- (BOOL)getResourceValue:(id *)value forKey:(NSString *)key error:(NSError **)error
{
    VERDE_NOT_IMPLEMENTED();
    if (error)
    {
        *error = [NSError _unimplementedError];
    }
    return NO;
}

@end


/**
 * An informal protocol to which clients may conform if they wish to be
 * notified of the progress in loading a URL for them.  NSURL conforms to
 * this protocol but all methods are implemented as no-ops.  See also
 * the [(NSURLHandleClient)] protocol.
 */
@implementation NSObject (NSURLClient)

- (void)URL:(NSURL*)sender
    resourceDataDidBecomeAvailable:(NSData*)newBytes
{
}

- (void)URL:(NSURL*)sender
    resourceDidFailLoadingWithReason:(NSString*)reason
{
}

- (void)URLResourceDidCancelLoading:(NSURL*)sender
{
}

- (void)URLResourceDidFinishLoading:(NSURL*)sender
{
}

@end
