//
//  SKXMLDictionaryParser.m
//  MusicXMLDemo
//
//  Created by shikaiming on 2020/4/8.
//  Copyright © 2020 shikaiming. All rights reserved.
//

//===========================================================//
/**
 *  这里的解析是在 NSDictionary+YYAdd 的基础上进行修改的,如果直接使用YYCategories也是可以的。
 *  <https://github.com/ibireme/YYCategories>
 */
//===========================================================//

#import "SKXMLDictionaryParser.h"

@interface SKXMLDictionaryParser ()<NSXMLParserDelegate>


@end
@implementation SKXMLDictionaryParser{
    NSMutableDictionary *_root;
    NSMutableArray *_stack;
    NSMutableString *_text;
}

- (instancetype)initWithData:(NSData *)data {
    self = super.init;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
    return self;
}

- (instancetype)initWithString:(NSString *)xml {
    NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
    return [self initWithData:data];
}

- (NSDictionary *)result {
    return _root;
}

#define XMLText @"_text"
#define XMLName @"_name"
#define XMLPref @"_"

- (void)textEnd {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *str = [_text stringByTrimmingCharactersInSet:set];
    _text = str.mutableCopy;
    
    if (_text.length) {
        NSMutableDictionary *top = _stack.lastObject;
        id existing = top[XMLText];
        if ([existing isKindOfClass:[NSArray class]]) {
            [existing addObject:_text];
        } else if (existing) {
            top[XMLText] = [@[existing, _text] mutableCopy];
        } else {
            top[XMLText] = _text;
        }
    }
    _text = nil;
}

- (void)parser:(__unused NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(__unused NSString *)namespaceURI qualifiedName:(__unused NSString *)qName attributes:(NSDictionary *)attributeDict {
    [self textEnd];
    

    NSMutableDictionary *node = [NSMutableDictionary new];
    if (!_root) node[XMLName] = elementName;
    if (attributeDict.count) [node addEntriesFromDictionary:attributeDict];
    
    if (_root) {
        NSMutableDictionary *top = _stack.lastObject;
        id existing = top[elementName];
        if ([existing isKindOfClass:[NSArray class]]) {
            [existing addObject:node];
        } else if (existing) {
            top[elementName] = [@[existing, node] mutableCopy];
        } else {
            

            if ([elementName isEqualToString:@"harmony"] ||
                [elementName isEqualToString:@"part"] ||
                [elementName isEqualToString:@"measure"] ||
                [elementName isEqualToString:@"note"] ||
                [elementName isEqualToString:@"attributes"] ||
                [elementName isEqualToString:@"frame-note"] ||
                [elementName isEqualToString:@"score-part"] ||
                [elementName isEqualToString:@"staff-tuning"] ||
                [elementName isEqualToString:@"hammer-on"] ||
                [elementName isEqualToString:@"tie"] ||
                [elementName isEqualToString:@"tied"] ||
                [elementName isEqualToString:@"direction"] ||
                [elementName isEqualToString:@"beam"] ||
                [elementName isEqualToString:@"bend"]) {
                top[elementName] = [@[node] mutableCopy];
            }else{
                top[elementName] = node;
            }
            
            //休止符
            if ([elementName isEqualToString:@"rest"]) {
                [node setObject:@"1" forKey:@"isRest"];
            }
            
            //和弦
            if ([elementName isEqualToString:@"chord"]) {
                [node setObject:@"1" forKey:@"isChord"];
            }
            
            //backup
            if ([elementName isEqualToString:@"backup"]) {
                [node setObject:@"1" forKey:@"isBackup"];
            }
            
            //forward
            if ([elementName isEqualToString:@"forward"]) {
                [node setObject:@"1" forKey:@"isForward"];
            }
            
            //附点
            if ([elementName isEqualToString:@"dot"]) {
                [node setObject:@"1" forKey:@"isDot"];
            }
            
            //===========================================================//
            //泛音
            if ([elementName isEqualToString:@"natural"]) {
                [node setObject:@"1" forKey:@"isNatural"];
            }
            
            if ([elementName isEqualToString:@"base-pitch"]) {
                [node setObject:@"1" forKey:@"isBase-pitch"];
            }
            //===========================================================//
            
            //推弦回原位标识
            if ([elementName isEqualToString:@"release"]) {
                [node setObject:@"1" forKey:@"isRelease"];
            }
            
            
            
        }
        
        
        //如果是扫弦也会有和弦图,还是丢到note下
        if ([elementName isEqualToString:@"note"]) {
            NSMutableArray *arrayM = _stack[1][@"measure"];
            NSMutableDictionary *dict = arrayM.lastObject;
            NSArray *harmonyArray = dict[@"harmony"];
            if (harmonyArray.count > 0) {
                NSMutableDictionary *harmonyDict = [[harmonyArray mutableCopy] lastObject];
                node[@"noteHarmony"] = harmonyDict;
                node[@"noteHarmonyIndex"] = [NSString stringWithFormat:@"%ld",harmonyArray.count - 1];
            }

        }
        
        [_stack addObject:node];

        
    } else {

        _root = node;
        _stack = [NSMutableArray arrayWithObject:node];
    }
}

- (void)parser:(__unused NSXMLParser *)parser didEndElement:(__unused NSString *)elementName namespaceURI:(__unused NSString *)namespaceURI qualifiedName:(__unused NSString *)qName {
    [self textEnd];
    
    NSMutableDictionary *top = _stack.lastObject;
    [_stack removeLastObject];
    
    NSMutableDictionary *left = top.mutableCopy;
    [left removeObjectsForKeys:@[XMLText, XMLName]];
    for (NSString *key in left.allKeys) {
        [left removeObjectForKey:key];
        if ([key hasPrefix:XMLPref]) {
            left[[key substringFromIndex:XMLPref.length]] = top[key];
        }
    }
    if (left.count) return;
    
    NSMutableDictionary *children = top.mutableCopy;
    [children removeObjectsForKeys:@[XMLText, XMLName]];
    for (NSString *key in children.allKeys) {
        if ([key hasPrefix:XMLPref]) {
            [children removeObjectForKey:key];
        }
    }
    if (children.count) return;
    
    NSMutableDictionary *topNew = _stack.lastObject;
    NSString *nodeName = top[XMLName];
    if (!nodeName) {
        for (NSString *name in topNew) {
            id object = topNew[name];
            if (object == top) {
                nodeName = name; break;
            } else if ([object isKindOfClass:[NSArray class]] && [object containsObject:top]) {
                nodeName = name; break;
            }
        }
    }
    if (!nodeName) return;
    
    id inner = top[XMLText];
    if ([inner isKindOfClass:[NSArray class]]) {
        inner = [inner componentsJoinedByString:@"\n"];
    }
    if (!inner) return;
    
    id parent = topNew[nodeName];
    if ([parent isKindOfClass:[NSArray class]]) {
        parent[[parent count] - 1] = inner;
    } else {
        topNew[nodeName] = inner;
    }
    

}

- (void)parser:(__unused NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (_text) [_text appendString:string];
    else _text = [NSMutableString stringWithString:string];
}

- (void)parser:(__unused NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    NSString *string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    if (_text) [_text appendString:string];
    else _text = [NSMutableString stringWithString:string];
}

#undef XMLText
#undef XMLName
#undef XMLPref
@end
