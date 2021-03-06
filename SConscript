header_paths = [
    'foundation-lib/jni/foundation/Foundation/Source',
    'foundation-lib/jni/foundation/Foundation/uriparser/include',
    'foundation-lib/jni/foundation/Foundation/Headers/Additions',
    '../CoreFoundation/include',
    '../CFNetwork/include',
]

defines = {
    'BUILD_FOUNDATION_LIB': 1,
    '__POSIX_SOURCE': 1,
    'URI_NO_UNICODE': 1,
    'URI_ENABLE_ANSI': 1,
    'HAVE_GCC_VISIBILITY': 1,
    'USE_ASHMEM': {'value': 1, 'env': {'TARGET_OS': 'android'}},
    'USE_SHALLOW_BUNDLES': 1,
    'USE_MONOTONIC_CLOCK': {'value': 1, 'env': {'TARGET_OS': 'android'}},
    'GNUSTEP_TARGET_OS': {'value': "\"android\"", 'env': {'TARGET_OS': 'android'}},
    'HAVE_SET_UNCAUGHT_EXCEPTION_HANDLER': 1,
}

flags = [
    '-Werror-return-type',
    '-Werror-implicit-function-declaration',
]

libs = [
    'ssl',
    'crypto',
    'z',
    'objc',
    'ffi',
    'dispatch',
    'cxx',
    'v',
    'System'
]

deps = [
    'v',
    'cxx',
    'objc',
    'ffi',
    'dispatch',
    'System'
]

sources = [
    "foundation-lib/jni/foundation/Foundation/Source/NSObject.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSZombie.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSDeprecated.m",
    "foundation-lib/jni/foundation/Foundation/Source/GSObjcRuntimeExtras.m",
    {"source": "foundation-lib/jni/foundation/Foundation/Source/GSString.m", "flags": ['-mno-thumb']},
    "foundation-lib/jni/foundation/Foundation/Source/GSArray.m",
    "foundation-lib/jni/foundation/Foundation/Source/GSSet.m",
    "foundation-lib/jni/foundation/Foundation/Source/GSDictionary.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/GSFunctions.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/GSInsensitiveDictionary.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/GSLock.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/GSMime.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/GSObjCRuntime.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/GSXML.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSArray+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSAttributedString+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSBundle+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSCalendarDate+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSData+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSDebug+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSError+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSFileHandle+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSLock+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSMutableString+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSNumber+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSObject+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSStream+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSString+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSTask+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSThread+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSThread+cocotron.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSURL+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/Unicode.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSDictionary+Blocks.m",
    "foundation-lib/jni/foundation/Foundation/Source/CXXException.m",
    "foundation-lib/jni/foundation/Foundation/Source/GSAttributedString.m",
    "foundation-lib/jni/foundation/Foundation/Source/GSConcreteValue.m",
    "foundation-lib/jni/foundation/Foundation/Source/GSCountedSet.m",
    {"source": "foundation-lib/jni/foundation/Foundation/Source/GSFormat.m", "flags": ['-mno-thumb']},
    "foundation-lib/jni/foundation/Foundation/Source/GSICUString.m",
    "foundation-lib/jni/foundation/Foundation/Source/GSLocale.m",
    "foundation-lib/jni/foundation/Foundation/Source/GSRunLoopWatcher.m",
    "foundation-lib/jni/foundation/Foundation/Source/GSValue.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSArchiver.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSArray.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSAssertionHandler.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSAttributedString.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSAutoreleasePool.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSCachedURLResponse.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSCalendarDate.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSCallBacks.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSCharacterSet.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSClassDescription.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSCoder.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSConcreteHashTable.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSConcreteMapTable.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSConcretePointerFunctions.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSCopyObject.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSCountedSet.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSData.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSDate.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSDateFormatter.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSDecimal.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSDecimalNumber.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSDictionary.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSDictionary+NSFileAttributes.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSDistantObject.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSDistributedLock.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSDistributedNotificationCenter.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSEnumerator.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSError.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSException.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSDebug.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSFileHandle.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSFormatter.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSGarbageCollector.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSHTTPCookie.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSHTTPCookieStorage.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSHashTable.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSIndexPath.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSIndexSet.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSInvocation.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSKeyValueCoding.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSKeyValueObserving.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSKeyedArchiver.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSKeyedUnarchiver.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSLocale.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSLock.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSLog.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSMachPort.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSMapTable.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSMethodSignature.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSNotification.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSNotificationCenter.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSNotificationQueue.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSNull.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSNumber.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSNumberFormatter.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSObjCRuntime.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSObject+NSComparisonMethods.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSPage.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSPipe.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSPointerArray.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSPointerFunctions.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSPort.m",
    # "foundation-lib/jni/foundation/Foundation/Source/NSPortCoder.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSPortMessage.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSPortNameServer.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSPredicate.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSPropertyList.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSProtocolChecker.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSProxy.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSRange.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSRegularExpression.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSRunLoop.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSScanner.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSSerializer.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSSet.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSSortDescriptor.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSSpellServer.m",
    {"source": "foundation-lib/jni/foundation/Foundation/Source/NSString.m", "flags": ['-mno-thumb']},
    "foundation-lib/jni/foundation/Foundation/Source/NSTextCheckingResult.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSThread.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSTimeZone.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSTimer.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSURL.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSURLAuthenticationChallenge.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSURLCache.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSURLConnection.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSURLCredential.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSURLCredentialStorage.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSURLDownload.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSURLHandle.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSURLProtectionSpace.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSURLProtocol.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSURLRequest.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSURLResponse.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSUnarchiver.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSUndoManager.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSUserDefaults.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSValue.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSValueTransformer.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSXMLDTD.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSXMLDTDNode.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSXMLDocument.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSXMLElement.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSXMLNode.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSXMLParser.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSZone.m",
    "foundation-lib/jni/foundation/Foundation/Source/externs.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSHost.m",
    "foundation-lib/jni/foundation/Foundation/Source/GSStream.m",
    # "foundation-lib/jni/foundation/Foundation/Source/msgSendv.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSProcessInfo.m",
    "foundation-lib/jni/foundation/Foundation/Source/Additions/NSProcessInfo+GNUstepBase.m",
    "foundation-lib/jni/foundation/Foundation/stubs/GSFileHandle.m",
    "foundation-lib/jni/foundation/Foundation/stubs/GSFTPURLHandle.m",
    "foundation-lib/jni/foundation/Foundation/stubs/GSHTTPAuthentication.m",
    "foundation-lib/jni/foundation/Foundation/stubs/GSHTTPURLHandle.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSBundle.mm",
    "foundation-lib/jni/foundation/Foundation/stubs/NSConnection.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSFileManager.m",
    "foundation-lib/jni/foundation/Foundation/stubs/NSMessagePort.m",
    "foundation-lib/jni/foundation/Foundation/stubs/NSMessagePortNameServer.m",
    "foundation-lib/jni/foundation/Foundation/stubs/NSSocketPort.m",
    "foundation-lib/jni/foundation/Foundation/stubs/NSSocketPortNameServer.m",
    "foundation-lib/jni/foundation/Foundation/stubs/NSTask.m",
    "foundation-lib/jni/foundation/Foundation/stubs/objc-load.m",
    "foundation-lib/jni/foundation/Foundation/stubs/syscall.c",
    "foundation-lib/jni/foundation/Foundation/stubs/strnstr.c",
    "foundation-lib/jni/foundation/Foundation/stubs/NSPlatform.m",
    "foundation-lib/jni/foundation/Foundation/stubs/gnustep_base_user_main.m",
    "foundation-lib/jni/foundation/Foundation/stubs/NSPathUtilities.m",
    "foundation-lib/jni/foundation/Foundation/Source/unix/NSStream.m",
    "foundation-lib/jni/foundation/Foundation/Source/GSSocketStream.m",
    "foundation-lib/jni/foundation/Foundation/Source/unix/GSRunLoopCtxt.m",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriCommon.c",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriCompare.c",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriEscape.c",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriFile.c",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriIp4Base.c",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriIp4.c",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriNormalize.c",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriNormalizeBase.c",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriParse.c",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriParseBase.c",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriQuery.c",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriRecompose.c",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriResolve.c",
    "foundation-lib/jni/foundation/Foundation/uriparser/src/UriShorten.c",
    "foundation-lib/jni/foundation/Foundation/Source/GSFFIInvocation.m",
    "foundation-lib/jni/foundation/Foundation/Source/cifframe.m",
    "foundation-lib/jni/foundation/Foundation/Source/NSJSONSerialization.m",
]

Import('env')

if 'ICU' in env:
    defines['HAVE_ICU'] = 1
    defines['HAVE_UNICODE_ULOC_H'] = 1
    defines['HAVE_UNICODE_ULOCDATA_H'] = 1
    defines['HAVE_UNICODE_UCURR_H'] = 1
    defines['HAVE_UNICODE_UREGEX_H'] = 1
    defines['GS_USE_ICU'] = 1
    deps.append('icu')
    libs.append('icu')


env.BuildLibrary(sources, header_paths, static=False, flags=flags, defines=defines, deps=deps, libs=libs)
