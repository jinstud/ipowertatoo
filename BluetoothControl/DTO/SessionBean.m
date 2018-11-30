#import "SessionBean.h"

@interface SessionBean ()

@end

@implementation SessionBean

/* Method for class instance */
+ (id) sharedSessionBean
{
    static SessionBean *instance;
    @synchronized(self)
    {
        if (instance == nil)
        {
            instance = [SessionBean new];
        }
    }
    return instance;
}

+ (int)unsignedByte:(Byte)a {
    int v = (int)a;
    if(v < 0) {
        v = 256+v;
    }
    return v;
}

@end