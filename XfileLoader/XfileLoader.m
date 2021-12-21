//
//  XfileLoaderLoader.m
//  XfileLoader
//
//  Created by Dan on 2021/12/21.
//  
//

#import "XfileLoader.h"

#ifdef LINUX
#include <endian.h>

int16_t OSReadBigInt16(const void *address, uintptr_t offset) {
    return be16toh(*(int16_t *) ((uintptr_t) address + offset));
}

int32_t OSReadBigInt32(const void *address, uintptr_t offset) {
    return be32toh(*(int32_t *) ((uintptr_t) address + offset));
}

void OSWriteBigInt32(void *address, uintptr_t offset, int32_t data) {
    *(int32_t *) ((uintptr_t) address + offset) = htobe32(data);
}

#endif

const uint16_t XFILE_MAGIC = 0x4855;


@implementation XfileLoader {
    NSObject<HPHopperServices> *_services;
}

+ (int)sdkVersion {
    return HOPPER_CURRENT_SDK_VERSION;
}

- (instancetype)initWithHopperServices:(NSObject<HPHopperServices> *)services {
    if (self = [super init]) {
        _services = services;
    }
    return self;
}

- (nonnull NSObject<HPHopperUUID> *)pluginUUID {
    return [_services UUIDWithString:@"FD5AE629-4E93-453E-AB34-6CAA1E545FE1"];
}

- (HopperPluginType)pluginType {
    return Plugin_Loader;
}

- (nonnull NSString *)pluginName {
    return @"XfileLoader";
}

- (nonnull NSString *)pluginDescription {
    return @"Xfile Loader for Sharp X68000";
}

- (nonnull NSString *)pluginAuthor {
    return @"Makigumo";
}

- (nonnull NSString *)pluginCopyright {
    return @"©2021 - Makigumo";
}

- (NSString *)pluginVersion {
    return @"0.0.1";
}

- (nonnull NSArray<NSString *> *)commandLineIdentifiers {
    return @[@"xfile"];
}

- (BOOL)canLoadDebugFiles {
    return NO;
}

// Returns an array of DetectedFileType objects.
- (nullable NSArray<NSObject<HPDetectedFileType> *> *)detectedTypesForData:(nonnull const void *)bytes
                                                                    length:(size_t)length
                                                               ofFileNamed:(nullable NSString *)filename
                                                                    atPath:(nullable NSString *)fileFullPath {
    if (length < 4) return @[];
    
    if (OSReadBigInt16(bytes, 0) == XFILE_MAGIC) {
        NSObject<HPDetectedFileType> *type = [_services detectedType];
        [type setFileDescription:@"Xfile Executable"];
        [type setAddressWidth:AW_32bits];
        [type setCpuFamily:@"motorola"];
        [type setCpuSubFamily:@"68000"];
        [type setShortDescriptionString:@"xfile"];
        [type setAdditionalParameters:@[[_services checkboxComponentWithLabel:@"Mark DOS Calls"]]];
        return @[type];
    }
    
    return @[];
}

#define INCREMENT_PTR(P,V) P = (const void *) ((uintptr_t) P + (V))

- (FileLoaderLoadingStatus)loadData:(nonnull const void *)bytes
                             length:(size_t)length
                       originalPath:(nullable NSString *)fileFullPath
              usingDetectedFileType:(nonnull NSObject<HPDetectedFileType> *)fileType
                            options:(FileLoaderOptions)options
                            forFile:(nonnull NSObject<HPDisassembledFile> *)file
                      usingCallback:(nullable FileLoadingCallbackInfo)callback {
    const void *firstByte = (const void *)bytes;
    
    if (OSReadBigInt16(bytes, 0) != XFILE_MAGIC) return DIS_BadFormat;
    
    INCREMENT_PTR(bytes, 4);
    
    uint32_t base_addr = OSReadBigInt32(bytes, 0); INCREMENT_PTR(bytes, 4);
    uint32_t start_addr = OSReadBigInt32(bytes, 0); INCREMENT_PTR(bytes, 4);
    uint32_t text_size = OSReadBigInt32(bytes, 0); INCREMENT_PTR(bytes, 4);
    uint32_t data_size = OSReadBigInt32(bytes, 0); INCREMENT_PTR(bytes, 4);
    uint32_t heap_size = OSReadBigInt32(bytes, 0); INCREMENT_PTR(bytes, 4);
    uint32_t reloc_table_size = OSReadBigInt32(bytes, 0); INCREMENT_PTR(bytes, 4);
    uint32_t symbol_table_size = OSReadBigInt32(bytes, 0); INCREMENT_PTR(bytes, 4);
    
    //
    // Header segment
    //
    //NSObject <HPSegment> *headerSegment = [file addSegmentAt:0 size:0x40];
    //NSObject <HPSection> *headerSection = [headerSegment addSectionAt:0 size:0x40];
    
    //headerSegment.segmentName = @"HEADER";
    //headerSection.sectionName = @"header";
    //headerSection.containsCode = NO;
    
    // data starts at 0x00
    //NSData *headerSegmentData = [NSData dataWithBytes:firstByte length:0x40];
    //headerSegment.mappedData = headerSegmentData;
    //headerSection.fileOffset = 0;
    //headerSection.fileLength = 0x40;
    
    //
    // TEXT segment
    //
    NSObject <HPSegment> *textSegment = [file addSegmentAt:base_addr size:text_size];
    NSObject <HPSection> *textSection = [textSegment addSectionAt:base_addr size:text_size];
    
    textSegment.segmentName = @"TEXT";
    textSection.sectionName = @"text";
    textSection.containsCode = YES;
    
    // data starts at 0x40
    NSData *textSegmentData = [NSData dataWithBytes:firstByte + 0x40 length:text_size];
    textSegment.mappedData = textSegmentData;
    textSection.fileOffset = 0x40;
    textSection.fileLength = text_size;
    
    [file addEntryPoint:start_addr];
    
    // mark dos calls
    if (((NSObject <HPLoaderOptionComponents> *) fileType.additionalParameters[0]).isChecked) {
        [_services logMessage:@"Marking DOS calls."];
        
        uint64_t dos_calls_found = 0;
        for (int i = 0; i < sizeof(dos_calls) / sizeof(struct dos_call); i++) {
            struct dos_call dc = dos_calls[i];
            uint16_t val = CFSwapInt16BigToHost(dc.val);
            NSData *dataToFind = [NSData dataWithBytes:&val length:2];
            NSRange range = [textSegmentData rangeOfData:dataToFind
                                                 options:0
                                                   range:NSMakeRange(0, [textSegmentData length])];
            while (range.location != NSNotFound) {
                Address address = textSegment.startAddress + range.location;
                [file setInlineComment:@(dc.name) atVirtualAddress:address reason:CCReason_Automatic];
                dos_calls_found++;
                range = [textSegmentData rangeOfData:dataToFind
                                             options:0
                                               range:NSMakeRange(range.location + sizeof(dc.val), [textSegmentData length] - range.location - sizeof(dc.val))];
            }
        }
        [_services logMessage:[NSString stringWithFormat:@"%llu PSX bios calls found", dos_calls_found]];

    }
    
    //
    // DATA segment
    //
    NSObject <HPSegment> *dataSegment = [file addSegmentAt:base_addr + text_size size:data_size];
    NSObject <HPSection> *dataSection = [dataSegment addSectionAt:base_addr + text_size size:data_size];
    
    dataSegment.segmentName = @"DATA";
    dataSection.sectionName = @"data";
    dataSection.containsCode = NO;
    
    // data starts after text_segment
    NSData *dataSegmentData = [NSData dataWithBytes:firstByte + 0x40 + text_size length:data_size];
    dataSegment.mappedData = dataSegmentData;
    dataSection.fileOffset = 0x40 + text_size;
    dataSection.fileLength = data_size;
    
    //
    // Relocation table segment
    //
    if (reloc_table_size > 0) {
        NSObject <HPSegment> *relTblSegment = [file addSegmentAt:base_addr + text_size + data_size size:reloc_table_size];
        NSObject <HPSection> *relTblSection = [relTblSegment addSectionAt:base_addr + text_size + data_size size:reloc_table_size];
        
        relTblSegment.segmentName = @"REL_TABLE";
        relTblSection.sectionName = @"rel_table";
        relTblSection.containsCode = NO;
        
        // data starts after text_segment
        NSData *relTablSegmentData = [NSData dataWithBytes:firstByte + 0x40 + text_size + data_size length:reloc_table_size];
        relTblSegment.mappedData = relTablSegmentData;
        relTblSection.fileOffset = 0x40 + text_size + data_size;
        relTblSection.fileLength = reloc_table_size;
        
        // TODO relocation
    }
    
    //
    // Symbol table segment
    //
    if (symbol_table_size > 0) {
        NSObject <HPSegment> *symTblSegment = [file addSegmentAt:base_addr + text_size + data_size + reloc_table_size size:symbol_table_size];
        NSObject <HPSection> *symTblSection = [symTblSegment addSectionAt:base_addr + text_size + data_size + reloc_table_size size:symbol_table_size];
        
        symTblSegment.segmentName = @"SYM_TABLE";
        symTblSection.sectionName = @"sym_table";
        symTblSection.containsCode = NO;
        
        // data starts after text_segment
        NSData *symTablSegmentData = [NSData dataWithBytes:firstByte + 0x40 + text_size + data_size + reloc_table_size length:symbol_table_size];
        symTblSegment.mappedData = symTablSegmentData;
        symTblSection.fileOffset = 0x40 + text_size + data_size + reloc_table_size;
        symTblSection.fileLength = symbol_table_size;
    }
    
    //
    // Memory Map
    //
    // TODO
    
    
    file.cpuFamily = @"motorola";
    file.cpuSubFamily = @"68000";
    file.addressSpaceWidthInBits = 32;
    file.integerWidthInBits = 32;
    
    
    
    return DIS_OK;
}

- (FileLoaderLoadingStatus)loadDebugData:(nonnull const void *)bytes
                                  length:(size_t)length
                            originalPath:(nullable NSString *)fileFullPath
                                 forFile:(nonnull NSObject<HPDisassembledFile> *)file
                           usingCallback:(nullable FileLoadingCallbackInfo)callback {
    return DIS_NotSupported;
}

- (void)fixupRebasedFile:(nonnull NSObject<HPDisassembledFile> *)file
               withSlide:(int64_t)slide
        originalFileData:(nonnull const void *)fileBytes
                  length:(size_t)length
            originalPath:(nullable NSString *)fileFullPath {
}

- (nullable NSData *)extractFromData:(nonnull const void *)bytes
                              length:(size_t)length
               usingDetectedFileType:(nonnull NSObject<HPDetectedFileType> *)fileType
                    originalFileName:(nullable NSString *)filename
                        originalPath:(nullable NSString *)fileFullPath
                  returnAdjustOffset:(nullable uint64_t *)adjustOffset
                returnAdjustFilename:(NSString * _Nullable __autoreleasing * _Nullable)newFilename {
    return nil;
}

- (void)setupFile:(nonnull NSObject<HPDisassembledFile> *)file
afterExtractionOf:(nonnull NSString *)filename
     originalPath:(nullable NSString *)fileFullPath
             type:(nonnull NSObject<HPDetectedFileType> *)fileType {
    
}
@end

#ifdef __linux__

@implementation NSData (NSData)

- (NSRange)rangeOfData:(NSData *)aData
               options:(NSUInteger)mask
                 range:(NSRange)aRange {

    NSRange range = NSMakeRange(NSNotFound, 0);
    if (aData) {
        const NSUInteger aDataLength = [aData length];
        const NSUInteger selfLength = [self length];
        if (aRange.location + aRange.length > selfLength) {
            [NSException raise:NSInvalidArgumentException
                        format:@"Bad Range (%"PRIuPTR",%"PRIuPTR") for length %lu",
                               aRange.location, aRange.length, selfLength];
        } else if (aDataLength > 0) {
            const BOOL reverse = ((mask & NSBackwardsSearch) == NSBackwardsSearch);
            const BOOL anchored = ((mask & NSAnchoredSearch) == NSAnchoredSearch);
            const void *selfBytes = [self bytes];
            const void *aDataBytes = [aData bytes];
            if (anchored) {
                if (aDataLength <= aRange.length) {
                    if (reverse) {
                        if (memcmp(selfBytes + aRange.location - aDataLength, aDataBytes, aDataLength) == 0) {
                            range = NSMakeRange(selfLength - aDataLength, aDataLength);
                        };
                    } else {
                        if (memcmp(selfBytes + aRange.location, aDataBytes, aDataLength)) {
                            range = NSMakeRange(0, aDataLength);
                        };
                    };
                };
            } else {
                if (reverse) {
                    const NSUInteger first = (aRange.location + aDataLength);
                    for (NSUInteger i = aRange.location + aRange.length - 1; i >= first && range.length == 0; i--) {
                        if (((unsigned char *) selfBytes)[i] == ((unsigned char *) aDataBytes)[aDataLength - 1]) {
                            if (memcmp(selfBytes + i - aDataLength, aDataBytes, aDataLength) == 0) {
                                range = NSMakeRange(i - aDataLength, aDataLength);
                            };
                        };
                    };
                } else {
                    const NSUInteger last = aRange.location + aRange.length - aDataLength;
                    for (NSUInteger i = aRange.location; i <= last && range.length == 0; i++) {
                        if (((unsigned char *) selfBytes)[i] == ((unsigned char *) aDataBytes)[0]) {
                            if (memcmp(selfBytes + i, aDataBytes, aDataLength) == 0) {
                                range = NSMakeRange(i, aDataLength);
                            };
                        };
                    };
                };
            };
        };
    } else {
        [NSException raise:NSInvalidArgumentException
                    format:@"nil data"];
    }
    return range;
}

@end

#endif
