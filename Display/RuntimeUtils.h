#import <Foundation/Foundation.h>

typedef enum {
    NSObjectAssociationPolicyRetain = 0,
    NSObjectAssociationPolicyCopy = 1
} NSObjectAssociationPolicy;

@interface RuntimeUtils : NSObject

+ (void)swizzleInstanceMethodOfClass:(Class)targetClass currentSelector:(SEL)currentSelector newSelector:(SEL)newSelector;

@end

@interface NSObject (AssociatedObject)

- (void)setAssociatedObject:(id)object forKey:(void const *)key;
- (void)setAssociatedObject:(id)object forKey:(void const *)key associationPolicy:(NSObjectAssociationPolicy)associationPolicy;
- (id)associatedObjectForKey:(void const *)key;

@end
