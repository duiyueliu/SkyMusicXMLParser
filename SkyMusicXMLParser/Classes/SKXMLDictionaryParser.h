//
//  SKXMLDictionaryParser.h
//  MusicXMLDemo
//
//  Created by shikaiming on 2020/4/8.
//  Copyright © 2020 shikaiming. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKXMLDictionaryParser : NSObject

- (instancetype)initWithData:(NSData *)data;

- (instancetype)initWithString:(NSString *)xml;

- (NSDictionary *)result;

@end

NS_ASSUME_NONNULL_END
