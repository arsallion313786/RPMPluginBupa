// AFNetworking.h
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

//! Project version number for AFNetworking.
FOUNDATION_EXPORT double AFNetworkingVersionNumber;

//! Project version string for AFNetworking.
FOUNDATION_EXPORT const unsigned char AFNetworkingVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import "PublicHeader.h"

#import "Availability.h"
#import "TargetConditionals.h"

#ifndef _AFNETWORKING_
#define _AFNETWORKING_

#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "AFSecurityPolicy.h"
#import "AFCompatibilityMacros.h"

#if !TARGET_OS_WATCH
#import "AFNetworkReachabilityManager.h"
#endif

#import "AFURLSessionManager.h"
#import "AFHTTPSessionManager.h"

#if TARGET_OS_IOS || TARGET_OS_TV
#import "AFAutoPurgingImageCache.h"
#import "AFImageDownloader.h"
#import "UIActivityIndicatorView+AFNetworking.h"
#import "UIButton+AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "UIProgressView+AFNetworking.h"
#endif

#if TARGET_OS_IOS
#import "AFNetworkActivityIndicatorManager.h"
#import "UIRefreshControl+AFNetworking.h"
#import "WKWebView+AFNetworking.h"
#endif


#endif /* _AFNETWORKING_ */
