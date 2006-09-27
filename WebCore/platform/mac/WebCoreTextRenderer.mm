/*
 * Copyright (C) 2006 Apple Computer, Inc.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

#import "config.h"
#import "WebCoreTextRenderer.h"

#import "Font.h"
#import "FontData.h"
#import "GraphicsContext.h"
#import "IntPoint.h"
#import "TextStyle.h"
#import "WebFontCache.h"

using namespace WebCore;

void WebCoreDrawTextAtPoint(const UniChar* buffer, unsigned length, NSPoint point, NSFont* font, NSColor* textColor)
{
    NSGraphicsContext *nsContext = [NSGraphicsContext currentContext];
    CGContextRef cgContext = (CGContextRef)[nsContext graphicsPort];
    GraphicsContext graphicsContext(cgContext);    
    // Safari doesn't flip the NSGraphicsContext before calling WebKit, yet WebCore requires a flipped graphics context.
    BOOL flipped = [nsContext isFlipped];
    if (!flipped)
        CGContextScaleCTM(cgContext, 1.0, -1.0);
    
    FontPlatformData f(font);
    Font renderer(f, ![[NSGraphicsContext currentContext] isDrawingToScreen]);
    TextRun run(buffer, length);
    TextStyle style;
    style.disableRoundingHacks();
    CGFloat red, green, blue, alpha;
    [[textColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] getRed:&red green:&green blue:&blue alpha:&alpha];
    graphicsContext.setPen(makeRGBA((int)(red * 255), (int)(green * 255), (int)(blue * 255), (int)(alpha * 255)));
    renderer.drawText(&graphicsContext, run, style, FloatPoint(point.x, (flipped ? point.y : (-1.0f * point.y))));
    if (!flipped)
        CGContextScaleCTM(cgContext, 1.0, -1.0);
}

float WebCoreTextFloatWidth(const UniChar* buffer, unsigned length , NSFont* font)
{
    FontPlatformData f(font);
    Font renderer(f, ![[NSGraphicsContext currentContext] isDrawingToScreen]);
    TextRun run(buffer, length);
    TextStyle style;
    style.disableRoundingHacks();
    return renderer.floatWidth(run, style);
}

static bool gShouldUseFontSmoothing = true;

void WebCoreSetShouldUseFontSmoothing(bool smooth)
{
    gShouldUseFontSmoothing = smooth;
}

bool WebCoreShouldUseFontSmoothing()
{
    return gShouldUseFontSmoothing;
}

void WebCoreSetAlwaysUseATSU(bool useATSU)
{
    Font::setCodePath(useATSU ? Font::Complex : Font::Auto);
}

NSFont* WebCoreFindFont(NSString* familyName, NSFontTraitMask traits, int size)
{
    return [WebFontCache fontWithFamily:familyName traits:traits size:size];
}
