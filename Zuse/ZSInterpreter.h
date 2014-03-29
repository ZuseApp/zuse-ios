//
//  ZSInterpreter.h
//  Interpreter
//
//  Created by Parker Wightman on 9/16/13.
//  Copyright (c) 2013 Alora Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZSInterpreter;

@protocol ZSInterpreterDelegate <NSObject>

- (void) interpreter:(ZSInterpreter *)interpreter
objectWithIdentifier:(NSString *)identifier
 didUpdateProperties:(NSDictionary *)properties;


- (BOOL) interpreter:(ZSInterpreter *)interpreter shouldDelegateProperty:(NSString *)property objectIdentifier:(NSString *)identifier;
- (id)interpreter:(ZSInterpreter *)interpreter valueForProperty:(NSString *)property objectIdentifier:(NSString *)identifier;

@end

@interface ZSInterpreter : NSObject

@property (strong, nonatomic) id<ZSInterpreterDelegate> delegate;

/**
 *  Convenience constructor
 *
 *  @return ZSInterepter object
 */
+ (instancetype)interpreter;

/**
 *  Evaluates given JSON code in the context of this interpreter
 *
 *  @param JSON JSON expected to be a valid Zuse IR
 *
 *  @return The result of the last expression run (either a boolean, number, or string)
 */
- (id)runJSON:(NSDictionary *)JSON;

/**
 *  Loads a method with a given name and implementation block into this interpretation
 *  context, which any object is allowed to call from anywhere in their code. The dictionary
 *  should be structured like so:
 *
 *  [_interpreter loadMethod: @{
 *      @"method":  @"method name",
 *      @"block": ^id(NSString *identifier, NSArray *args) { ... } 
 *  }];
 *
 *  @param method Dictionary with a method name and implementation block
 */
- (void)loadMethod:(NSDictionary *)method;

/**
 *  Runs event handlers associated with `event` for all objects loaded into the interpreter.
 *
 *  @param event Identifier for event
 */
- (void)triggerEvent:(NSString *)event;

/**
 *  Run event handlers for `event` for a single object, identified by objectID.
 *
 *  @param event    Identifier for event
 *  @param objectID Identifier for object for which the event should be run
 */
- (void)triggerEvent:(NSString *)event onObjectWithIdentifier:(NSString *)objectID;

/**
 *  Run event handlers, passing `parameters`, for all objects registered in the interpreter.
 *
 *  @param event      Identifier for event
 *  @param parameters Dictionary of parameters to be in scope during the event
 */
- (void)triggerEvent:(NSString *)event
          parameters:(NSDictionary *)parameters;

/**
 *  Run event handlers, passing `parameters`, for the object identified by `objectID`.
 *
 *  @param event      Identifier for event
 *  @param objectID   Identifier for object for which the event should be run
 *  @param parameters Dictionary of parameters to be in scope during the event
 */
- (void)  triggerEvent:(NSString *)event
onObjectWithIdentifier:(NSString *)objectID
            parameters:(NSDictionary *)parameters;

/**
 *  Returns a dictionary of all objects and their properties. Example:
 *
 *   {
 *     "paddle1": {
 *       "x": 1,
 *       "y": 2",
 *       "width": 10,
 *       "height": 100
 *     }
 *   }
 *
 *
 *  @return Dictionary of objects
 */
- (NSDictionary *)objects;

/**
 *  Removes object registered with `identifier` from the context of the interpreter.
 *
 *  @param identifier Indentifier for object
 */
- (void)removeObjectWithIdentifier:(NSString *)identifier;

@end
