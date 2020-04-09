//
//  ViewController.m
//  MusicXMLDemo
//
//  Created by shikaiming on 2020/4/8.
//  Copyright © 2020 shikaiming. All rights reserved.
//

#import "ViewController.h"
#import "SKXMLDictionaryParser.h"

@interface ViewController ()

@property (nonatomic, strong) NSDictionary *xmlDict;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSData *xmlData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"测试曲谱" ofType:@"xml"]];
    self.xmlDict = [self dictionaryWithXML:xmlData];
    
    NSLog(@"%@",self.xmlDict);
}

- (NSDictionary *)dictionaryWithXML:(id)xml {
    SKXMLDictionaryParser *parser = nil;
    if ([xml isKindOfClass:[NSString class]]) {
        parser = [[SKXMLDictionaryParser alloc] initWithString:xml];
    } else if ([xml isKindOfClass:[NSData class]]) {
        parser = [[SKXMLDictionaryParser alloc] initWithData:xml];
    }
    return [parser result];
}



@end
