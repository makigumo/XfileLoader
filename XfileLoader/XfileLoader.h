//
//  XfileLoaderLoader.h
//  XfileLoader
//
//  Created by Dan on 2021/12/21.
//  
//

#import <Foundation/Foundation.h>
#import <Hopper/Hopper.h>

#ifdef __linux__

@interface NSData (NSData)

- (NSRange)rangeOfData:(NSData *)aData
               options:(NSUInteger)mask
                 range:(NSRange)aRange;

@end

#endif

typedef struct dos_call {
    const uint16_t val;
    const char* const name;
} DOS_CALL;


// DOS calls
/// https://www.chibiakumas.com/68000/x68000.php
/// https://gamesx.com/wiki/doku.php?id=x68000:doscall
/// https://datacrystal.romhacking.net/wiki/X68k:DOSCALL
const struct dos_call dos_calls[] = {
    {0xff00, "_EXIT"},
    {0xff01, "_GETCHAR"},
    {0xff02, "_PUTCHAR"},
    {0xff03, "_COMINP"},
    {0xff04, "_COMOUT"},
    {0xff05, "_PRNOUT"},
    {0xff06, "_INPOUT"},
    {0xff07, "_INKEY"},
    {0xff08, "_GETC"},
    {0xff09, "_PRINT"},
    {0xff0a, "_GETS"},
    {0xff0b, "_KEYSNS"},
    {0xff0c, "_KFLUSH"},
    {0xff0d, "_FFLUSH"},
    {0xff0e, "_CHGDRV"},
    {0xff0f, "_DRVCTRL"},
    {0xff10, "_CONSNS"},
    {0xff11, "_PRNSNS"},
    {0xff12, "_CINSNS"},
    {0xff13, "_COUTSNS"},
    //{0xff14, ""},
    //{0xff15, ""},
    //{0xff16, ""},
    {0xff17, "_FATCHK"},
    {0xff18, "_HENDSP"},
    {0xff19, "_CURDRV"},
    {0xff1a, "_GETSS"},
    {0xff1b, "_FGETC"},
    {0xff1c, "_FGETS"},
    {0xff1d, "_FPUTC"},
    {0xff1e, "_FPUTS"},
    {0xff1f, "_ALLCLOSE"},
    {0xff20, "_SUPER"},
    {0xff21, "_FNCKEY"},
    {0xff22, "_KNJCTRL"},
    {0xff23, "_CONCTRL"},
    {0xff24, "_KEYCTRL"},
    {0xff25, "_INTVCS"},
    {0xff26, "_PSPSET"},
    {0xff27, "_GETTIM2"},
    {0xff28, "_SETTIM2"},
    {0xff29, "_NAMESTS"},
    {0xff2a, "_GETDATE"},
    {0xff2b, "_SETDATE"},
    {0xff2c, "_GETTIME"},
    {0xff2d, "_SETTIME"},
    {0xff2e, "_VERIFY"},
    {0xff2f, "_DUP0"},
    {0xff30, "_VERNUM"},
    {0xff31, "_KEEPPR"},
    {0xff32, "_GETDPB"},
    {0xff33, "_BREAKCK"},
    {0xff34, "_DRVXCHG"},
    {0xff35, "_INTVCG"},
    {0xff36, "_DSKFRE"},
    {0xff37, "_NAMECK"},
    //{0xff38, ""},
    {0xff39, "_MKDIR"},
    {0xff3a, "_RMDIR"},
    {0xff3b, "_CHDIR"},
    {0xff3c, "_CREATE"},
    {0xff3d, "_OPEN"},
    {0xff3e, "_CLOSE"},
    {0xff3f, "_READ"},
    {0xff40, "_WRITE"},
    {0xff41, "_DELETE"},
    {0xff42, "_SEEK"},
    {0xff43, "_CHMOD"},
    {0xff44, "_IOCTRL"},
    {0xff45, "_DUP"},
    {0xff46, "_DUP2"},
    {0xff47, "_CURDIR"},
    {0xff48, "_MALLOC"},
    {0xff49, "_MFREE"},
    {0xff4a, "_SETBLOCK"},
    {0xff4b, "_EXEC"},
    {0xff4c, "_EXIT2"},
    {0xff4d, "_WAIT"},
    {0xff4e, "_FILES"},
    {0xff4f, "_NFILES"},

    {0xff80, "_SETPDB"},
    {0xff81, "_GETPDB"},
    {0xff82, "_SETENV"},
    {0xff83, "_GETENV"},
    {0xff84, "_VERIFYG"},
    {0xff85, "_COMMON"},
    {0xff86, "_RENAME"},
    {0xff87, "_FILEDATE"},
    {0xff88, "_MALLOC2"},
    //{0xff89, ""},
    {0xff8a, "_MAKETMP"},
    {0xff8b, "_NEWFILE"},
    {0xff8c, "_LOCK"},
    //{0xff8d, ""},
    //{0xff8e, ""},
    {0xff8f, "_ASSIGN"},

    {0xffaa, "FFLUSH"},
    {0xffab, "_OS_PATCH"},
    {0xffac, "_GETFCB"},
    {0xffad, "_S_MALLOC"},
    {0xffae, "_S_MFREE"},
    {0xffaf, "_S_PROCESS"},

    {0xfff0, "_EXITVC"},
    {0xfff1, "_CTRLVC"},
    {0xfff2, "_ERRJVC"},
    {0xfff3, "_DISKRED"},
    {0xfff4, "_DISKWRT"},
    {0xfff5, "_INDOSFLG"},
    {0xfff6, "_SUPER_JSR"},
    {0xfff7, "_BUS_ERR"},
    {0xfff8, "_OPEN_PR"},
    {0xfff9, "_KILL_PR"},
    {0xfffa, "_GET_PR"},
    {0xfffb, "_SUSPEND_PR"},
    {0xfffc, "_SLEEP_PR"},
    {0xfffd, "_SEND_PR"},
    {0xfffe, "_TIME_PR"},
    {0xffff, "_CHANGE_PR"},
};

@interface XfileLoader : NSObject<FileLoader>

@end
