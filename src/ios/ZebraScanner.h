/* 
The MIT License (MIT)

Copyright (c) 2018 Blank Canvas Limited

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#import <Cordova/CDV.h>
#import "SbtSdkFactory.h"


@interface ZebraScanner : CDVPlugin

// Reference to the initialised instance
@property id <ISbtSdkApi> api;
// The operation mode to run in on initialisation
@property int mode;
// Allocate an array for storage of a list of available scanners
@property NSMutableArray *availableScanners;
// Allocate an array for storage of a list of active scanners
@property NSMutableArray *activeScanners;
// Allocate a string to contain the event callback id
@property NSString *eventCallbackId;

// Override the initialisation plugin from CDVPlugin
- (void) pluginInitialize;

// - (void) setDelegate:(CDVInvokedUrlCommand*)command;
- (void) getVersion:(CDVInvokedUrlCommand*)command;
- (void) setOperationalMode:(CDVInvokedUrlCommand*)command;
- (void) enableAvailableScannersDetection:(CDVInvokedUrlCommand*)command;
- (void) getAvailableScanners:(CDVInvokedUrlCommand*)command;
- (void) getActiveScanners:(CDVInvokedUrlCommand*)command;
- (void) establishCommunicationSession:(CDVInvokedUrlCommand*)command;
- (void) terminateCommunicationSession:(CDVInvokedUrlCommand*)command;
- (void) enableAutomaticSessionReestablishment:(CDVInvokedUrlCommand*)command;

- (void) sbtEventScannerAppeared:(SbtScannerInfo*)availableScanner;
- (void) sbtEventScannerDisappeared:(int)scannerID;
- (void) sbtEventCommunicationSessionEstablished:(SbtScannerInfo*)activeScanner;
- (void) sbtEventCommunicationSessionTerminated:(int)scannerID;
- (void) sbtEventBarcodeData:(NSData *)barcodeData barcodeType:(int)barcodeType fromScanner:(int)scannerID;
- (void) sbtEventImage:(NSData*)imageData fromScanner:(int)scannerID;
- (void) sbtEventVideo:(NSData*)videoFrame fromScanner:(int)scannerID;
- (void) sbtEventFirmwareUpdate:(FirmwareUpdateEvent*)event;

@end
