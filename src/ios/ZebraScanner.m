/* ZebraScanner.m */

#import "ZebraScanner.h"
#import <Cordova/CDV.h>
#import "SbtSdkFactory.h"
#import "RMDAttributes.h"

@implementation ZebraScanner

/**
 * Initialise the plugin when the application first loads
 *
 * @return  void
 */
- (void) pluginInitialize
{
    // Initialise the API
    self.api = [SbtSdkFactory createSbtSdkApiInstance];
    
    // Enable delegates
    [self.api sbtSetDelegate:(id)self];
    
    int notifications_mask = 0;
    notifications_mask |= (SBT_EVENT_SCANNER_APPEARANCE | SBT_EVENT_SCANNER_DISAPPEARANCE);
    notifications_mask |= (SBT_EVENT_SESSION_ESTABLISHMENT | SBT_EVENT_SESSION_TERMINATION);
    notifications_mask |= (SBT_EVENT_BARCODE);
    notifications_mask |= (SBT_EVENT_IMAGE);
    notifications_mask |= (SBT_EVENT_VIDEO);
    notifications_mask |= (SBT_EVENT_RAW_DATA);
    
    [self.api sbtSetOperationalMode:SBT_OPMODE_ALL];
    [self.api sbtSubsribeForEvents:notifications_mask];
    
    // Allocate an array for storage of a list of available scanners
    self.availableScanners = [[NSMutableArray alloc] init];
    // Allocate an array for storage of a list of active scanners
    self.activeScanners = [[NSMutableArray alloc] init];
    
    // Get the SDK version string and send it to the logs
    NSString *version = [self.api sbtGetVersion];
    NSLog(@"Zebra SDK version: %@\n", version);
}

/**
 * Returns version of the SDK.
 *
 * @return void
 */
- (void) getVersion:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    
    // Get the SDK version string
    NSString *version = [self.api sbtGetVersion];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:version];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Configures operating mode of the SDK.
 *
 * @return int
 */
- (void) setOperationalMode:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSNumber *mode = [command.arguments objectAtIndex:0];
    
    // pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    // [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    if (mode == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    } else {
        SBT_RESULT result = [self.api sbtSetOperationalMode:mode.intValue];
        
        // Check the result code
        if (result == 0) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:result];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
        }
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Enable or disable scanner detection.
 *
 * @return int
 */
- (void) enableAvailableScannersDetection:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    BOOL enable = [command.arguments objectAtIndex:0];
    
    SBT_RESULT result = [self.api sbtEnableAvailableScannersDetection:enable];
    
    // Check the result code
    if (result == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:result];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Get available scanners
 *
 * @return array
 */
- (void) getAvailableScanners:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    
    NSMutableArray *available = [[NSMutableArray alloc] init];
    NSMutableArray *scanners = [[NSMutableArray alloc] init];
    SBT_RESULT result = [self.api sbtGetAvailableScannersList:&available];
    self.availableScanners = available;
    
    // Check the result code
    if (result == 0) {
        
        // return an array of dictionaries with some of the parameters of SbtScannerInfo
        for (SbtScannerInfo *scannerObj in available) {
            NSMutableDictionary *scanner = [NSMutableDictionary dictionary];
            [scanner setObject:[NSNumber numberWithInt:[scannerObj getScannerID]] forKey:@"scannerID"];
            [scanner setObject:[NSNumber numberWithInt:[scannerObj getConnectionType]] forKey:@"connectionType"];
            [scanner setObject:[NSNumber numberWithInt:[scannerObj getAutoCommunicationSessionReestablishment]] forKey:@"autoCommunicationSessionReestablishment"];
            [scanner setObject:[NSNumber numberWithInt:[scannerObj isActive]] forKey:@"active"];
            [scanner setObject:[NSNumber numberWithInt:[scannerObj isAvailable]] forKey:@"available"];
            [scanner setObject:[NSNumber numberWithInt:[scannerObj getScannerModel]] forKey:@"model"];
            [scanners addObject:scanner];
        }
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:scanners];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Get active scanners
 *
 * @return array
 */
- (void) getActiveScanners:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    
    NSMutableArray *active = [[NSMutableArray alloc] init];
    NSMutableArray *scanners = [[NSMutableArray alloc] init];
    SBT_RESULT result = [self.api sbtGetActiveScannersList:&active];
    self.activeScanners = active;
    
    // Check the result code
    if (result == 0) {
        
        // return an array of dictionaries with some of the parameters of SbtScannerInfo
        for (SbtScannerInfo *scannerObj in active) {
            NSMutableDictionary *scanner = [NSMutableDictionary dictionary];
            [scanner setObject:[NSNumber numberWithInt:[scannerObj getScannerID]] forKey:@"scannerID"];
            [scanner setObject:[NSNumber numberWithInt:[scannerObj getConnectionType]] forKey:@"connectionType"];
            [scanner setObject:[NSNumber numberWithInt:[scannerObj getAutoCommunicationSessionReestablishment]] forKey:@"autoCommunicationSessionReestablishment"];
            [scanner setObject:[NSNumber numberWithInt:[scannerObj isActive]] forKey:@"active"];
            [scanner setObject:[NSNumber numberWithInt:[scannerObj isAvailable]] forKey:@"available"];
            [scanner setObject:[NSNumber numberWithInt:[scannerObj getScannerModel]] forKey:@"model"];
            [scanners addObject:scanner];
        }
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:scanners];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Configures operating mode of the SDK.
 *
 * @return int
 */
- (void) establishCommunicationSession:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSNumber *scanner = [command.arguments objectAtIndex:0];
    
    if (scanner == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    } else {
        SBT_RESULT result = [self.api sbtEstablishCommunicationSession:scanner.intValue];
        
        // Check the result code
        if (result == 0) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:result];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
        }
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Configures operating mode of the SDK.
 *
 * @return int
 */
- (void) terminateCommunicationSession:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSNumber *scanner = [command.arguments objectAtIndex:0];
    
    if (scanner == nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    } else {
        SBT_RESULT result = [self.api sbtTerminateCommunicationSession:scanner.intValue];
        
        // Check the result code
        if (result == 0) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:result];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsInt:result];
        }
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) sbtEventScannerAppeared:(SbtScannerInfo*)availableScanner
{
    NSLog(@"sbtEventScannerAppeared - : %d\n", [availableScanner getScannerID]);
    [CDVPluginResult writeJavascript:[NSString stringWithFormat:@"setTimeout( function() { cordova.fireDocumentEvent('%@_%@', {data:'%@'} ) }, 0);", ID, event, data]];
}

- (void) sbtEventScannerDisappeared:(int)scannerID;
{
    NSLog(@"sbtEventScannerDisappeared - : %d\n", scannerID);
}

- (void) sbtEventCommunicationSessionEstablished:(SbtScannerInfo*)activeScanner;
{
    NSLog(@"sbtEventCommunicationSessionEstablished - : %d\n", activeScanner.getScannerID);
}

- (void) sbtEventCommunicationSessionTerminated:(int)scannerID;
{
    NSLog(@"sbtEventCommunicationSessionTerminated - : %d\n", scannerID);
}

- (void) sbtEventBarcodeData:(NSData *)barcodeData barcodeType:(int)barcodeType fromScanner:(int)scannerID;
{
    NSLog(@"sbtEventBarcodeData - : %d %@\n", scannerID, barcodeData);
}

- (void) sbtEventImage:(NSData*)imageData fromScanner:(int)scannerID;
{
    NSLog(@"sbtEventImage - : %d\n", scannerID);
}

- (void) sbtEventVideo:(NSData*)videoFrame fromScanner:(int)scannerID;
{
    NSLog(@"sbtEventVideo - : %@\n", scannerID);
}

- (void) sbtEventFirmwareUpdate:(FirmwareUpdateEvent*)event;
{
    NSLog(@"sbtEventFirmwareUpdate - : %@\n", event);
}

/**
 * Registers a specific object which conforms to ISbtSdkApiDelegate Objective C protocol as a receiver
 * of SDK notifications. Registration of a specific object which conforms to ISbtSdkApiDelegate protocol
 * is required to receive notifications from the SDK.
 *
 * @return void
 */
// - (void) setDelegate:(CDVInvokedUrlCommand*)command
// {
//     CDVPluginResult* pluginResult = nil;
//     id delegate = [command.arguments objectAtIndex:0];

//     if (delegate == nil || [delegate length] == 0) {
//         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
//     } else {
//         // Set the Delegate
//         int result = [self.api sbtSetDelegate: delegate];
//         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt result];
//     }

//     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
// }

@end
