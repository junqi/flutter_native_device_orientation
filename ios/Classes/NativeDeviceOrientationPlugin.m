#import "NativeDeviceOrientationPlugin.h"

NSString* const METHOD_CHANEL = @"com.github.rmtmckenzie/flutter_native_device_orientation/orientation";
NSString* const EVENT_CHANNEL = @"com.github.rmtmckenzie/flutter_native_device_orientation/orientationevent";


NSString* const PORTRAIT_UP = @"PortraitUp";
NSString* const PORTRAIT_DOWN = @"PortraitDown";
NSString* const LANDSCAPE_LEFT = @"LandscapeLeft";
NSString* const LANDSCAPE_RIGHT = @"LandscapeRight";
NSString* const UNKNOWN = @"Unknown";

@interface NativeDeviceOrientationPlugin ()
@property id observer;
@end

@implementation NativeDeviceOrientationPlugin


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:METHOD_CHANEL
                                     binaryMessenger:[registrar messenger]];
    FlutterEventChannel* eventChannel = [FlutterEventChannel eventChannelWithName:EVENT_CHANNEL binaryMessenger:[registrar messenger]];
    
    NativeDeviceOrientationPlugin* instance = [[NativeDeviceOrientationPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [eventChannel setStreamHandler:instance];
}

- (NSString*)getOrientation {
    switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationPortrait:
            return PORTRAIT_UP;
            break;
            case UIInterfaceOrientationPortraitUpsideDown:
            return PORTRAIT_DOWN;
            break;
            case UIInterfaceOrientationLandscapeLeft:
            return LANDSCAPE_LEFT;
            break;
            case UIInterfaceOrientationLandscapeRight:
            return LANDSCAPE_RIGHT;
            break;
            case UIInterfaceOrientationUnknown:
        default:
            return UNKNOWN;
            break;
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([@"getOrientation" isEqualToString:call.method]) {
        result([self getOrientation]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    self.observer = [nc addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        events([self getOrientation]);
    }];
    events([self getOrientation]);
    return NULL;
}


- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    if (self.observer != NULL) {
        UIDevice *device = [UIDevice currentDevice];
        [device endGeneratingDeviceOrientationNotifications];
        [nc removeObserver:self.observer];
        self.observer = NULL;
    }
    
    return NULL;
}

@end
