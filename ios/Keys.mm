#import "Keys.h"
#import <React/RCTBridge+Private.h>
#import <React/RCTUtils.h>
#import <jsi/jsi.h>
#import <sys/utsname.h>
#import "YeetJSIUtils.h"
#import <React/RCTBridge+Private.h>

#import "crypto.h"
#import "GeneratedDotEnv.m"
#import "privateKey.m"

using namespace facebook::jsi;
using namespace std;

@implementation Keys

@synthesize bridge = _bridge;
@synthesize methodQueue = _methodQueue;

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

// Installing JSI Bindings
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(install)
{
    RCTBridge* bridge = [RCTBridge currentBridge];
    RCTCxxBridge* cxxBridge = (RCTCxxBridge*)bridge;
    if (cxxBridge == nil) {
        return @false;
    }

    auto jsiRuntime = (jsi::Runtime*) cxxBridge.runtime;
    if (jsiRuntime == nil) {
        return @false;
    }
    
    auto& runtime = *jsiRuntime;

    auto secureFor = Function::createFromHostFunction(runtime,
                                                    PropNameID::forAscii(runtime,
                                                                         "secureFor"),
                                                    1,
                                                      [](Runtime &runtime,
                                                             const Value &thisValue,
                                                             const Value *arguments,
                                                             size_t count) -> Value {
        NSString *key = convertJSIStringToNSString(runtime, arguments[0].getString(runtime));
        NSString *value = [Keys secureFor:key];
        return Value(runtime, convertNSStringToJSIString(runtime, value));
    });
    
    runtime.global().setProperty(runtime, "secureFor", std::move(secureFor));
    
    
    auto publicKeys = Function::createFromHostFunction(runtime,
                                                    PropNameID::forAscii(runtime,
                                                                         "publicKeys"),
                                                    0,
                                                      [](Runtime &runtime,
                                                             const Value &thisValue,
                                                             const Value *arguments,
                                                             size_t count) -> Value {
        NSDictionary *s = [Keys public_keys];
        return Value(runtime, convertNSDictionaryToJSIObject(runtime, s));
        
    });
    
    runtime.global().setProperty(runtime, "publicKeys", std::move(publicKeys));
    
    
  
   
    return @true;
}


+ (NSString *)secureFor: (NSString *)key {
      @try {
          NSDictionary *privatesKeyEnv = PRIVATE_KEY;
          NSString *privateKey = [privatesKeyEnv objectForKey:@"privateKey"];
           NSString* stringfyData = [NSString stringWithCString:Crypto().getJniJsonStringifyData([privateKey cStringUsingEncoding:NSUTF8StringEncoding]).c_str() encoding:[NSString defaultCStringEncoding]];
           NSData *data = [stringfyData dataUsingEncoding:NSUTF8StringEncoding];
           NSMutableDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
           NSString *value =[s objectForKey:key];
          return value;
      }
      @catch (NSException *exception) {
          return @"";
      }
  }

  + (NSDictionary *)public_keys {
    return (NSDictionary *)DOT_ENV;
  }

  + (NSString *)publicFor: (NSString *)key {
      NSString *value = (NSString *)[self.public_keys objectForKey:key];
      return value;
  }

// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeKeysSpecJSI>(params);
}
#endif
@end
