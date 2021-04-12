#import "VonageVideoPlugin.h"
#if __has_include(<vonage_video/vonage_video-Swift.h>)
#import <vonage_video/vonage_video-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "vonage_video-Swift.h"
#endif

@implementation VonageVideoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVonageVideoPlugin registerWithRegistrar:registrar];
}
@end
