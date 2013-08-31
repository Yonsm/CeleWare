

/**********************************************************************************************************************/
/* Uniform Base Library 3.0.308 iOS */
/* Copyright (C) Yonsm 2006-2011, All Rights Reserved.*/
#pragma once

#ifdef _DEBUG
#define _TRACE
//#define _TRACE_TIME
//#define _TRACE_TO_FILE
//#define _TRACE_TO_CONSOLE
#endif

#if defined(_UNICODE) && !defined(UNICODE)
#define UNICODE
#endif

#import <stdio.h>
#import <stdlib.h>
#import <stdarg.h>
#import <memory.h>
#import <mach/mach_time.h>
#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* Define */
#ifndef CONST
#define CONST						const
#endif

#ifndef STATIC
#define STATIC						static
#endif

#ifndef INLINE
#define INLINE						inline
#endif

#ifndef FINLINE
#define FINLINE						inline
#endif

#ifndef ISTATIC
#define ISTATIC						inline static
#endif

#define UCALL						/**/
#define UCALLBACK					/**/
#define UAPI(x)						INLINE x UCALL

#ifdef __cplusplus
#define UDEF(x)						= x
#else
#define UDEF(x)
#endif

#ifdef _WIN32
#define SEPCHAR						'\\'
#else
#define SEPCHAR						'/'
#endif
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* Type */
#define VOID						void
typedef void						*PVOID;
typedef FILE						*UFILE;
typedef void						*HANDLE;
typedef HANDLE						*PHANDLE;
#ifndef __OBJC__
typedef int							BOOL;
#endif
typedef BOOL						*PBOOL;
typedef float						FLOAT, *PFLOAT;
typedef double						DOUBLE, *PDOUBLE;

typedef int							INT, *PINT;
typedef signed char					INT8, *PINT8;
typedef signed short				INT16, *PINT16;
typedef signed int					INT32, *PINT32;
typedef signed long long			INT64, *PINT64;

typedef unsigned int				UINT, *PUINT;
typedef unsigned char				UINT8, *PUINT8;
typedef unsigned short				UINT16, *PUINT16;
typedef unsigned int				UINT32, *PUINT32;
typedef unsigned long long			UINT64, *PUINT64;


typedef unsigned char				BYTE, *PBYTE;
typedef unsigned short				WORD, *PWORD;
typedef unsigned long				DWORD, *PDWORD;
typedef unsigned long long			QWORD, *PQWORD;

#if defined(_MAC64)
typedef long long					INT_PTR, *PINT_PTR;
typedef unsigned long long			UINT_PTR, *PUINT_PTR;
#else
typedef int							INT_PTR, *PINT_PTR;
typedef unsigned int				UINT_PTR, *PUINT_PTR;
#endif

typedef char						CHAR, *PCHAR;
typedef char						ACHAR, *PACHAR;
typedef UINT16						WCHAR, *PWCHAR;
#ifdef _UNICODE
typedef WCHAR						TCHAR, *PTCHAR;
typedef WORD						UTCHAR, *PUTCHAR;
#else
typedef ACHAR						TCHAR, *PTCHAR;
typedef BYTE						UTCHAR, *PUTCHAR;
#endif

typedef CHAR						*PSTR;
typedef ACHAR						*PASTR;
typedef WCHAR						*PWSTR;
typedef TCHAR						*PTSTR;
typedef CONST ACHAR					*PCSTR;
typedef CONST ACHAR					*PCASTR;
typedef CONST WCHAR					*PCWSTR;
typedef CONST TCHAR					*PCTSTR;

typedef CONST VOID					*PCVOID;
typedef CONST BYTE					*PCBYTE;

#ifndef VALIST
#define VALIST						va_list
#endif

#ifndef TEXT
#ifdef _UNICODE
#define TEXT(t)						L##t
#else
#define TEXT(t)						t
#endif
#endif
#define TSTR(t)						TEXT(t)
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* Const */
#ifndef TRUE
#define TRUE						1
#endif

#ifndef FALSE
#define FALSE						0
#endif

#ifndef NULL
#define NULL						0
#endif

#ifndef MAX_STR
#define MAX_STR						1024
#endif

#ifndef MAX_PATH
#define MAX_PATH					260
#endif

#ifndef MAX_NAME
#define MAX_NAME					80
#endif

#define UFILE_READ					1
#define UFILE_WRITE					2
#define UFILE_READWRITE				3

#define UFILE_BEGIN					SEEK_SET
#define UFILE_CURRENT				SEEK_CUR
#define UFILE_END					SEEK_END
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* Macro */
#define _NumOf(s)					(sizeof(s) / sizeof(s[0]))
#define _Zero(p)					UMemSet(p, 0, sizeof(*p))

#define _SafeFree(p)				if (p) {UMemFree(p); p = NULL;}
#define _SafeDelete(p)				if (p) {delete p; p = NULL;}
#define _SafeRelease(p)				if (p) {CFRelease(p); p = NULL;}

#define _DibStride(w, i)			(((((w) * i) + 31) & ~31) / 8)
#define _DibSize(w, i, h)			(_DibStride((w), i) * (h))
#define _DibBits(p, w, i, x, y)		((p) + _DibStride((w), (i)) * (y) + (x) * 3)
#define _DibStride24(w)				(((w) + (w) + (w) + 3) & 0xFFFFFFFC)
#define _DibSize24(w, h)			(_DibStride24(w) * (h))
#define _DibBits24(p, w, x, y)		((p) + _DibStride24(w) * (y) + (x) * 3)
#define _DibStride32(w)				((w) * 4)
#define _DibSize32(w, h)			(_DibStride32(w) * (h))
#define _DibBits32(p, w, x, y)		((p) + _DibStride32(w) * (y) + (x) * 4)
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* Global */
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* Memory */
UAPI(PVOID) UMemAlloc(UINT nSize)
{
	return malloc(nSize);
}

UAPI(PVOID) UMemRealloc(PVOID pvMem, UINT nSize)
{
	return realloc(pvMem, nSize);
}

UAPI(VOID) UMemFree(PVOID pvMem)
{
	free(pvMem);
}

UAPI(PVOID) UMemAlignAlloc(UINT nSize, UINT16 uAlign UDEF(16))
{
	PVOID pvAlloc = UMemAlloc(nSize + sizeof(UINT16) + uAlign);
	if (pvAlloc)
	{
		UINT_PTR uMem = (UINT_PTR) pvAlloc + sizeof(UINT16);
		uMem = (uMem + (uAlign - 1)) & ~(uAlign - 1);
		((PUINT16) uMem)[-1] = (UINT16) (uMem - (UINT_PTR) pvAlloc);
		return (PVOID) uMem;
	}
	return NULL;
}

UAPI(VOID) UMemAlignFree(PVOID pvMem)
{
	if (pvMem)
	{
		pvMem = (PVOID) ((UINT_PTR) pvMem - ((PUINT16) pvMem)[-1]);
		UMemFree(pvMem);
	}
}

UAPI(PVOID) UMemSet(PVOID pvMem, ACHAR cVal, UINT nSize)
{
	return memset(pvMem, cVal, nSize);
}

UAPI(PVOID) UMemCopy(PVOID pvDst, PCVOID pvSrc, UINT nSize)
{
	return memcpy(pvDst, pvSrc, nSize);
}

UAPI(PVOID) UMemMove(PVOID pvDst, PCVOID pvSrc, UINT nSize)
{
	return memmove(pvDst, pvSrc, nSize);
}

UAPI(INT) UMemCmp(PCVOID pvMem1, PCVOID pvMem2, UINT nSize)
{
	return memcmp(pvMem1, pvMem2, nSize);
}

UAPI(INT) UMemCmpI(PCVOID pvMem1, PCVOID pvMem2, UINT nSize)
{
	return 0;//memicmp(pvMem1, pvMem2, nSize);
}
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* ASCII Char */
UAPI(BOOL) AChrIsNum(ACHAR a)
{
	return (a >= '0') && (a <= '9');
}

UAPI(BOOL) AChrIsAlpha(ACHAR a)
{
	return ((a >= 'A') && (a <= 'Z')) || ((a >= 'a') && (a <= 'z'));
}

UAPI(BOOL) AChrIsSymbol(ACHAR a)
{
	return ((a > ' ') && (a < '0')) || ((a > '9') && (a < 'A')) || ((a > 'Z') && (a < 'a')) || ((a > 'z') && (a < 127));
}

UAPI(BOOL) AChrIsPrintable(ACHAR a)
{
	return ((a >= ' ') && (a <= '~')) || (a == '\r') || (a == '\n') || (a == '\t');
}

UAPI(ACHAR) AChrToLower(ACHAR a)
{
	return ((a >= 'A') && (a <= 'Z')) ? (a - 'A' + 'a') : a;
}

UAPI(ACHAR) AChrToUpper(ACHAR a)
{
	return ((a >= 'a') && (a <= 'z')) ? (a + 'A' - 'a') : a;
}

UAPI(BYTE) AChrToHex(CONST ACHAR a[2])
{
	CONST STATIC BYTE c_bHexVal[128] =
	{
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
	};
	return (c_bHexVal[a[0]] << 4) | c_bHexVal[a[1]];
}

UAPI(VOID) AChrFromHex(ACHAR a[2], BYTE b)
{
	CONST STATIC ACHAR c_azHexChr[] = "0123456789ABCDEF";
	a[0] = c_azHexChr[b >> 4];
	a[1] = c_azHexChr[b & 0x0F];
}

UAPI(BOOL) AChrEqualI(ACHAR a1, ACHAR a2)
{
	return ((a1 == a2) || (AChrToUpper(a1) == AChrToUpper(a2)));
}
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* UNICODE Char */
UAPI(BOOL) WChrIsNum(WCHAR w)
{
	return (w >= '0') && (w <= '9');
}

UAPI(BOOL) WChrIsAlpha(WCHAR w)
{
	return ((w >= 'A') && (w <= 'Z')) || ((w >= 'a') && (w <= 'z'));
}

UAPI(BOOL) WChrIsSymbol(WCHAR w)
{
	return ((w > ' ') && (w < '0')) || ((w > '9') && (w < 'A')) || ((w > 'Z') && (w < 'a')) || ((w > 'z') && (w < 127));
}

UAPI(BOOL) WChrIsPrintable(WCHAR w)
{
	return ((w >= ' ') && (w <= '~')) || (w == '\r') || (w == '\n') || (w == '\t');
}

UAPI(WCHAR) WChrToLower(WCHAR w)
{
	return ((w >= 'A') && (w <= 'Z')) ? (w - 'A' + 'a') : w;
}

UAPI(WCHAR) WChrToUpper(WCHAR w)
{
	return ((w >= 'a') && (w <= 'z')) ? (w + 'A' - 'a') : w;
}

UAPI(BYTE) WChrToHex(CONST WCHAR w[2])
{
	CONST STATIC BYTE c_bHexVal[128] =
	{
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	};
	return (c_bHexVal[w[0]] << 4) | c_bHexVal[w[1]];
}

UAPI(VOID) WChrFromHex(WCHAR w[2], BYTE b)
{
	CONST STATIC CHAR c_wzHexChr[17] = "0123456789ABCDEF";
	w[0] = c_wzHexChr[b >> 4];
	w[1] = c_wzHexChr[b & 0x0F];
}

UAPI(BOOL) WChrEqualI(WCHAR w1, WCHAR w2)
{
	return (w1 == w2) || (WChrToUpper(w1) == WChrToUpper(w2));
}
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* String Conversion */
#if 0
UAPI(UINT) AStrToWStr(PWSTR pwzDst, PCASTR pazSrc, UINT nDstLen UDEF(MAX_STR), UINT nSrcLen UDEF(-1), UINT uCodePage UDEF(UCP_ANSI))
{
	return 0;
}

UAPI(UINT) WStrToAStr(PASTR pazDst, PCWSTR pwzSrc, UINT nDstLen UDEF(MAX_STR), UINT nSrcLen UDEF(-1), UINT uCodePage UDEF(UCP_ANSI))
{
	return 0;
}

UAPI(UINT) UTF8ToWStr(PWSTR pwzDst, PCASTR puzSrc, UINT nDstLen UDEF(MAX_STR), UINT nSrcLen UDEF(-1))
{
	return 0;
}

UAPI(UINT) UTF8ToAStr(PASTR pazDst, PCASTR puzSrc, UINT nDstLen UDEF(MAX_STR), UINT nSrcLen UDEF(-1))
{
	return 0;
}

UAPI(UINT) WStrToUTF8(PASTR puzDst, PCWSTR pwzSrc, UINT nDstLen UDEF(MAX_STR), UINT nSrcLen UDEF(-1))
{
	return 0;
}

UAPI(UINT) AStrToUTF8(PASTR puzDst, PASTR pazSrc, UINT nDstLen UDEF(MAX_STR), UINT nSrcLen UDEF(-1))
{
	return 0;
}
#endif

UAPI(BOOL) AStrIsUTF8XML(PASTR pazStr)
{
	if ((pazStr[0] == '<') && (pazStr[1] == '?') && (pazStr[2] == 'x') && (pazStr[3] == 'm') && (pazStr[4] == 'l'))
	{
		for (pazStr += 5; (*pazStr != 0) && (*pazStr != '\n'); pazStr++)
		{
			if (((pazStr[0] == 'u') || (pazStr[0] == 'U')) && 
				((pazStr[1] == 't') || (pazStr[1] == 'T')) && 
				((pazStr[2] == 'f') || (pazStr[2] == 'F')) && 
				(pazStr[3] == '-') && 
				(pazStr[4] == '8'))
			{
				return TRUE;
			}
		}
	}
	return FALSE;
}
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* ASCII String */
#define AStrFormat sprintf
#define AStrFormatV vsprintf

UAPI(PASTR) AStrEnd(PCASTR pazStr)
{
	while (*pazStr)
	{
		pazStr++;
	}
	return (PASTR) pazStr;
}

UAPI(UINT) AStrLen(PCASTR pazStr)
{
	return (UINT) (AStrEnd(pazStr) - pazStr);
}

UAPI(UINT) AStrCopy(PASTR pazDst, PCASTR pazSrc)
{
	PASTR p = pazDst;
	while ((*p++ = *pazSrc++));
	return (UINT) (p - pazDst);
}

UAPI(UINT) AStrCopyN(PASTR pazDst, PCASTR pazSrc, UINT nDstLen)
{
	PASTR p = pazDst;
	while (*pazSrc && ((INT) (--nDstLen) > 0))
	{
		*p++ = *pazSrc++;
	}
	*p++ = 0;
	return (UINT) (p - pazDst);
}

UAPI(UINT) AStrCat(PASTR pazDst, PCASTR pazSrc)
{
	PASTR p = AStrEnd(pazDst);
	return (UINT) (p - pazDst) + AStrCopy(p, pazSrc);
}

UAPI(INT) AStrCmp(PCASTR pazStr1, PCASTR pazStr2)
{
	return strcmp(pazStr1, pazStr2);
}

UAPI(INT) AStrCmpI(PCASTR pazStr1, PCASTR pazStr2)
{
	while (*pazStr1 && *pazStr2 && AChrEqualI(*pazStr1, *pazStr2))  
	{
		pazStr1++;
		pazStr2++;
	}
	return *pazStr1 - *pazStr2; 
}

UAPI(INT) AStrCmpN(PCASTR pazStr1, PCASTR pazStr2, UINT nLen)
{
	return strncmp(pazStr1, pazStr2, nLen);
}

UAPI(INT) AStrCmpNI(PCASTR pazStr1, PCASTR pazStr2, UINT nLen)
{
	UINT n = 0;
	while ((n < nLen) && *pazStr1 && *pazStr2 && AChrEqualI(*pazStr1, *pazStr2))
	{
		pazStr1++;
		pazStr2++;
		n++;
	}
	return (n < nLen) ? (*pazStr1 - *pazStr2) : TRUE;
}

UAPI(PASTR) AStrChr(PCASTR pazStr, ACHAR cChr)
{
	return (PASTR) strchr(pazStr, cChr);
}

UAPI(PASTR) AStrRChr(PCASTR pazStr, ACHAR cChr)
{
	return (PASTR) strrchr(pazStr, cChr);
}

UAPI(PASTR) AStrStr(PCASTR pazStr1, PCASTR pazStr2)
{
	return (PASTR) strstr(pazStr1, pazStr2);
}

UAPI(PASTR) AStrStrI(PCASTR pazStr1, PCASTR pazStr2)
{
	PASTR p = (PASTR) pazStr1;
	while (*p)
	{
		PASTR s1 = p;
		PASTR s2 = (PASTR) pazStr2;
		
		while (*s1 && *s2 && AChrEqualI(*s1, *s2))
		{
			s1++;
			s2++;
		}
		
		if (*s2 == 0)
		{
			return p;
		}
		
		p++;
	}
	return NULL;
}

UAPI(PASTR) AStrRep(PASTR pazStr, ACHAR cFind UDEF('|'), ACHAR cRep UDEF(0))
{
	PASTR p = pazStr;
	for (; *p; p++)
	{
		if (*p == cFind)
		{
			*p = cRep;
		}
	}
	return pazStr;
}

UAPI(PASTR) AStrTrim(PASTR pazStr, ACHAR cTrim UDEF('"'))
{
	if (*pazStr == cTrim)
	{
		PASTR p = pazStr + AStrLen(pazStr) - 1;
		if (*p == cTrim)
		{
			*p = 0;
		}
		return pazStr + 1;
	}
	return pazStr;
}

UAPI(PASTR) AStrSplit(PASTR pazStr, ACHAR cSplit)
{
	while (*pazStr)
	{
		if (*pazStr == cSplit)
		{
			*pazStr++ = 0;
			break;
		}
		pazStr++;
	}
	return pazStr;
}

UAPI(PASTR) AStrRSplit(PASTR pazStr, ACHAR cSplit)
{
	PASTR p;
	PASTR pazEnd = AStrEnd(pazStr);
	for (p = pazEnd; p >= pazStr; p--)
	{
		if (*p == cSplit)
		{
			*p++ = 0;
			return p;
		}
	}
	return pazEnd;
}

UAPI(UINT) AStrEqual(PCASTR pazStr1, PCASTR pazStr2)
{
	UINT i = 0;
	while (pazStr1[i] && (pazStr1[i] == pazStr2[i]))
	{
		i++;
	}
	return i;
}

UAPI(UINT) AStrEqualI(PCASTR pazStr1, PCASTR pazStr2)
{
	UINT i = 0;
	while (pazStr1[i] && WChrEqualI(pazStr1[i], pazStr2[i]))
	{
		i++;
	}
	return i;
}

UAPI(BOOL) AStrMatch(PCASTR pazStr, PCASTR pazPat)
{
	PCASTR s, p;
	BOOL bStar = FALSE;
	
__LoopStart:
	for (s = pazStr, p = pazPat; *s; s++, p++)
	{
		switch (*p)
		{
			case '?':
				/*if (*s == '.') goto __StartCheck;*/
				break;
				
			case '*':
				bStar = TRUE;
				pazStr = s, pazPat = p;
				if (!*++pazPat) return TRUE;
				goto __LoopStart;
				
			default:
				if (*s != *p)
				{
					/*__StartCheck:*/
					if (!bStar) return FALSE;
					pazStr++;
					goto __LoopStart;
				}
				break;
		}
	}
	if (*p == '*') ++p;
	return (!*p);
}

UAPI(BOOL) AStrMatchI(PCASTR pazStr, PCASTR pazPat)
{
	PCASTR s, p;
	BOOL bStar = FALSE;
	
__LoopStart:
	for (s = pazStr, p = pazPat; *s; s++, p++)
	{
		switch (*p)
		{
			case '?':
				/*if (*s == '.') goto __StartCheck;*/
				break;
				
			case '*':
				bStar = TRUE;
				pazStr = s, pazPat = p;
				if (!*++pazPat) return TRUE;
				goto __LoopStart;
				
			default:
				if (!AChrEqualI(*s, *p))
				{
					/*__StartCheck:*/
					if (!bStar) return FALSE;
					pazStr++;
					goto __LoopStart;
				}
				break;
		}
	}
	if (*p == '*') ++p;
	return (!*p);
}

UAPI(PASTR) AStrToUpper(PASTR pazStr)
{
	for (PASTR p = pazStr; *p; p++)
	{
		if ((*p >= 'a') && (*p <= 'z'))
		{
			*p -= 'a' - 'A';
		}
	}
	return pazStr;
}

UAPI(PASTR) AStrToLower(PASTR pazStr)
{
	for (PASTR p = pazStr; *p; p++)
	{
		if ((*p >= 'a') && (*p <= 'z'))
		{
			*p += 'a' - 'A';
		}
	}
	return pazStr;
}

UAPI(INT) AStrToInt(PCASTR pazStr)
{
	return atoi(pazStr);
}

UAPI(INT64) AStrToInt64(PCASTR pazStr)
{
	return atoll(pazStr);
}

UAPI(DOUBLE) AStrToDouble(PCASTR pazStr)
{
	return atof(pazStr);
}

UAPI(PASTR) AStrFromInt(PASTR pazDst, INT iVal, INT iRadix UDEF(10))
{
	INT power = 1;
	PASTR p = pazDst;
	for (INT j = iVal; j >= 10; j /= iRadix) 
	{
		power *= iRadix;
	}
	for (; power > 0; power /= iRadix)
	{
		*p++ = '0' + iVal / power;
		iVal %= power;
	}
	*p = 0;
	return pazDst;
}

UAPI(UINT) AStrToHex(PBYTE pbDst, PCASTR pazSrc)
{
	PBYTE pbStart = pbDst;
	while (*pazSrc)
	{
		*pbDst++ = AChrToHex(pazSrc);
		pazSrc += 2;
	}
	return (UINT) (pbDst - pbStart);
}

UAPI(UINT) AStrFromHex(PASTR pazDst, PCBYTE pbSrc, UINT nSize)
{
	UINT i;
	for (i = 0; i < nSize; i++)
	{
		AChrFromHex(&pazDst[i * 2], pbSrc[i]);
	}
	pazDst[nSize * 2] = 0;
	return nSize * 2;
}

#ifdef _WIN32
UAPI(UINT) AStrLoad(UINT uID, PASTR pazStr, UINT nMax UDEF(MAX_STR))
{
	return 0;
}

UAPI(PCASTR) AStrGet(UINT uID)
{
	STATIC ACHAR s_azStr[MAX_STR];
	AStrLoad(uID, s_azStr, MAX_STR);
	return s_azStr;
}
#endif
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* UNICODE String */
#define WStrFormat swprintf
#define WStrFormatV vswprintf

UAPI(PWSTR) WStrEnd(PCWSTR pwzStr)
{
	while (*pwzStr)
	{
		pwzStr++;
	}
	return (PWSTR) pwzStr;
}

UAPI(UINT) WStrLen(PCWSTR pwzStr)
{
	return (UINT) (WStrEnd(pwzStr) - pwzStr);
}

UAPI(UINT) WStrCopy(PWSTR pwzDst, PCWSTR pwzSrc)
{
	PWSTR p = pwzDst;
	while ((*p++ = *pwzSrc++));
	return (UINT) (p - pwzDst);
}

UAPI(UINT) WStrCopyN(PWSTR pwzDst, PCWSTR pwzSrc, UINT nDstLen)
{
	PWSTR p = pwzDst;
	while (*pwzSrc && ((INT) (--nDstLen) > 0))
	{
		*p++ = *pwzSrc++;
	}
	*p++ = 0;
	return (UINT) (p - pwzDst);
}

UAPI(UINT) WStrCat(PWSTR pwzDst, PCWSTR pwzSrc)
{
	PWSTR p = WStrEnd(pwzDst);
	return (UINT) (p - pwzDst) + WStrCopy(p, pwzSrc);
}

UAPI(INT) WStrCmp(PCWSTR pwzStr1, PCWSTR pwzStr2)
{
	while (*pwzStr1 && *pwzStr2 && (*pwzStr1 == *pwzStr2))  
	{
		pwzStr1++;
		pwzStr2++;
	}
	return *pwzStr1 - *pwzStr2;
}

UAPI(INT) WStrCmpI(PCWSTR pwzStr1, PCWSTR pwzStr2)
{
	while (*pwzStr1 && *pwzStr2 && WChrEqualI(*pwzStr1, *pwzStr2))
	{
		pwzStr1++;
		pwzStr2++;
	}
	return *pwzStr1 - *pwzStr2;
}

UAPI(INT) WStrCmpN(PCWSTR pwzStr1, PCWSTR pwzStr2, UINT nLen)
{
	UINT n = 0;
	while ((n < nLen) && *pwzStr1 && *pwzStr2 && (*pwzStr1 == *pwzStr2))
	{
		pwzStr1++;
		pwzStr2++;
		n++;
	}
	return (n < nLen) ? (*pwzStr1 - *pwzStr2) : TRUE;
}

UAPI(INT) WStrCmpNI(PCWSTR pwzStr1, PCWSTR pwzStr2, UINT nLen)
{
	UINT n = 0;
	while ((n < nLen) && *pwzStr1 && *pwzStr2 && WChrEqualI(*pwzStr1, *pwzStr2))
	{
		pwzStr1++;
		pwzStr2++;
		n++;
	}
	return (n < nLen) ? (*pwzStr1 - *pwzStr2) : TRUE;
}

UAPI(PWSTR) WStrChr(PCWSTR pwzStr, WCHAR wChr)
{
	for (PCWSTR p = pwzStr; *p; p++)
	{
		if (*p == wChr)
		{
			return (PWSTR) p;
		}
	}
	return NULL;
}

UAPI(PWSTR) WStrRChr(PCWSTR pwzStr, WCHAR wChr)
{
	for (PCWSTR p = WStrEnd(pwzStr) - 1; p > pwzStr; p--)
	{
		if (*p == wChr)
		{
			return (PWSTR) p;
		}
	}
	return NULL;
}

UAPI(PWSTR) WStrStr(PCWSTR pwzStr1, PCWSTR pwzStr2)
{
	PWSTR p = (PWSTR) pwzStr1;
	while (*p)
	{
		PWSTR s1 = p;
		PWSTR s2 = (PWSTR) pwzStr2;
		
		while (*s1 && *s2 && (*s1 == *s2))
		{
			s1++;
			s2++;
		}
		
		if (*s2 == 0)
		{
			return p;
		}
		
		p++;
	}
	return NULL;
}

UAPI(PWSTR) WStrStrI(PCWSTR pwzStr1, PCWSTR pwzStr2)
{
	PWSTR p = (PWSTR) pwzStr1;
	while (*p)
	{
		PWSTR s1 = p;
		PWSTR s2 = (PWSTR) pwzStr2;
		
		while (*s1 && *s2 && WChrEqualI(*s1, *s2))
		{
			s1++;
			s2++;
		}
		
		if (*s2 == 0)
		{
			return p;
		}
		
		p++;
	}
	return NULL;
}

UAPI(PWSTR) WStrRep(PWSTR pwzStr, WCHAR wFind UDEF('|'), WCHAR wRep UDEF(0))
{
	PWSTR p = pwzStr;
	for (; *p; p++)
	{
		if (*p == wFind)
		{
			*p = wRep;
		}
	}
	return pwzStr;
}

UAPI(PWSTR) WStrTrim(PWSTR pwzStr, WCHAR wTrim UDEF('"'))
{
	if (*pwzStr == wTrim)
	{
		PWSTR p = pwzStr + WStrLen(pwzStr) - 1;
		if (*p == wTrim)
		{
			*p = 0;
		}
		return pwzStr + 1;
	}
	return pwzStr;
}

UAPI(PWSTR) WStrSplit(PWSTR pwzStr, WCHAR wSplit)
{
	while (*pwzStr)
	{
		if (*pwzStr == wSplit)
		{
			*pwzStr++ = 0;
			break;
		}
		pwzStr++;
	}
	return pwzStr;
}

UAPI(PWSTR) WStrRSplit(PWSTR pwzStr, WCHAR wSplit)
{
	PWSTR p;
	PWSTR pwzEnd = WStrEnd(pwzStr);
	for (p = pwzEnd; p >= pwzStr; p--)
	{
		if (*p == wSplit)
		{
			*p++ = 0;
			return p;
		}
	}
	return pwzEnd;
}

UAPI(UINT) WStrEqual(PCWSTR pwzStr1, PCWSTR pwzStr2)
{
	UINT i = 0;
	while (pwzStr1[i] && (pwzStr1[i] == pwzStr2[i]))
	{
		i++;
	}
	return i;
}

UAPI(UINT) WStrEqualI(PCWSTR pwzStr1, PCWSTR pwzStr2)
{
	UINT i = 0;
	while (pwzStr1[i] && WChrEqualI(pwzStr1[i], pwzStr2[i]))
	{
		i++;
	}
	return i;
}

UAPI(BOOL) WStrMatch(PCWSTR pwzStr, PCWSTR pwzPat)
{
	PCWSTR s, p;
	BOOL bStar = FALSE;
	
__LoopStart:
	for (s = pwzStr, p = pwzPat; *s; s++, p++)
	{
		switch (*p)
		{
			case '?':
				/*if (*s == '.') goto __StartCheck;*/
				break;
				
			case '*':
				bStar = TRUE;
				pwzStr = s, pwzPat = p;
				if (!*++pwzPat) return TRUE;
				goto __LoopStart;
				
			default:
				if (*s != *p)
				{
					/*__StartCheck:*/
					if (!bStar) return FALSE;
					pwzStr++;
					goto __LoopStart;
				}
				break;
		}
	}
	if (*p == '*') ++p;
	return (!*p);
}

UAPI(BOOL) WStrMatchI(PCWSTR pwzStr, PCWSTR pwzPat)
{
	PCWSTR s, p;
	BOOL bStar = FALSE;
	
__LoopStart:
	for (s = pwzStr, p = pwzPat; *s; s++, p++)
	{
		switch (*p)
		{
			case '?':
				/*if (*s == '.') goto __StartCheck;*/
				break;
				
			case '*':
				bStar = TRUE;
				pwzStr = s, pwzPat = p;
				if (!*++pwzPat) return TRUE;
				goto __LoopStart;
				
			default:
				if (!WChrEqualI(*s, *p))
				{
					/*__StartCheck:*/
					if (!bStar) return FALSE;
					pwzStr++;
					goto __LoopStart;
				}
				break;
		}
	}
	if (*p == '*') ++p;
	return (!*p);
}

UAPI(PWSTR) WStrToUpper(PWSTR pwzStr)
{
	for (PWSTR p = pwzStr; *p; p++)
	{
		if ((*p >= 'a') && (*p <= 'z'))
		{
			*p -= 'a' - 'A';
		}
	}
	return pwzStr;
}

UAPI(PWSTR) WStrToLower(PWSTR pwzStr)
{
	for (PWSTR p = pwzStr; *p; p++)
	{
		if ((*p >= 'a') && (*p <= 'z'))
		{
			*p += 'a' - 'A';
		}
	}
	return pwzStr;
}

UAPI(INT) WStrToInt(PCWSTR pwzStr)
{
	INT sign;
	INT num = 0;
	if (*pwzStr == '-')
	{
		sign = -1;
		pwzStr++;
	}
	else
	{
		sign = 1;
		if (*pwzStr == '+')
		{
			pwzStr++;
		}
	}
	while (*pwzStr)
	{
        num = num * 10 + (*pwzStr++ - '0');
	}
	return num * sign;
}

UAPI(INT64) WStrToInt64(PCWSTR pwzStr)
{
	INT64 sign;
	INT64 num = 0;
	if (*pwzStr == '-')
	{
		sign = -1;
		pwzStr++;
	}
	else
	{
		sign = 1;
	}
	
	while (*pwzStr)
	{
        num = num * 10 + (*pwzStr++ - '0');
	}
	return num * sign;
}

UAPI(DOUBLE) WStrToDouble(PCWSTR pwzStr)
{
	DOUBLE a = 0.1;  
	PCWSTR p = pwzStr;
	DOUBLE value = 0.L;
	INT sign = (*p == '-') ? -1 : 1;  
	if ((*p=='-') || (*p=='+'))  
	{
		p++;  
	}
	while (WChrIsNum(*p))
	{  
        value = (*p - '0' ) + value * 10;
        p++;  
	}
	if (*p == '.')
	{
        p++;
	}
	while (WChrIsNum(*p))
	{  
        value += a * (*p - '0');  
        a = a * 0.1;  
        p++;  
	}  
	return sign * value;  
}

UAPI(PWSTR) WStrFromInt(PWSTR pwzDst, INT iVal, INT iRadix UDEF(10))
{
	INT power = 1;
	PWSTR p = pwzDst;
	for (INT j = iVal; j >= 10; j /= iRadix) 
	{
		power *= iRadix;
	}
	for (; power > 0; power /= iRadix)
	{
		*p++ = '0' + iVal / power;
		iVal %= power;
	}
	*p = 0;
	return pwzDst;
}

UAPI(UINT) WStrToHex(PBYTE pbDst, PCWSTR pwzSrc)
{
	PBYTE pbStart = pbDst;
	while (*pwzSrc)
	{
		*pbDst++ = WChrToHex(pwzSrc);
		pwzSrc += 2;
	}
	return (UINT) (pbDst - pbStart);
}

UAPI(UINT) WStrFromHex(PWSTR pwzDst, PCBYTE pbSrc, UINT nSize)
{
	UINT i;
	for (i = 0; i < nSize; i++)
	{
		WChrFromHex(&pwzDst[i * 2], pbSrc[i]);
	}
	pwzDst[nSize * 2] = 0;
	return nSize * 2;
}

/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* Transformable String */

#ifdef _UNICODE

#define TChrIsNum					WChrIsNum
#define TChrIsAlpha					WChrIsAlpha
#define TChrIsSymbol				WChrIsSymbol
#define TChrIsPrintable				WChrIsPrintable
#define TChrToLower					WChrToLower
#define TChrToUpper					WChrToUpper
#define TChrToHex					WChrToHex
#define TChrFromHex					WChrFromHex
#define TChrEqualI					WChrEqualI

#define TStrEnd						WStrEnd
#define TStrLen						WStrLen
#define TStrCopy					WStrCopy
#define TStrCopyN					WStrCopyN
#define TStrCat						WStrCat
#define TStrCmp						WStrCmp
#define TStrCmpI					WStrCmpI
#define TStrCmpN					WStrCmpN
#define TStrCmpNI					WStrCmpNI

#define TStrChr						WStrChr
#define TStrRChr					WStrRChr
#define TStrStr						WStrStr
#define TStrStrI					WStrStrI

#define TStrRep						WStrRep
#define TStrTrim					WStrTrim
#define TStrEqual					WStrEqual
#define TStrEqualI					WStrEqualI
#define TStrSplit					WStrSplit
#define TStrRSplit					WStrRSplit
#define TStrMatch					WStrMatch
#define TStrMatchI					WStrMatchI
#define TStrToUpper					WStrToUpper
#define TStrToLower					WStrToLower
#define TStrToInt					WStrToInt
#define TStrToInt64					WStrToInt64
#define TStrToDouble				WStrToDouble
#define TStrFromInt					WStrFromInt
#define TStrFromDouble				WStrFromDouble
#define TStrToHex					WStrToHex
#define TStrFromHex					WStrFromHex
#define TStrFormat					WStrFormat
#define TStrFormatV					WStrFormatV

#define TStrLoad					WStrLoad
#define TStrGet						WStrGet

#define TStrToAStr					WStrToAStr
#define TStrToWStr					WStrCopyN
#define AStrToTStr					AStrToWStr
#define WStrToTStr					WStrCopyN

#define TStrToUTF8					WStrToUTF8
#define UTF8ToTStr					UTF8ToWStr

#else

#define TChrIsNum					AChrIsNum
#define TChrIsAlpha					AChrIsAlpha
#define TChrIsSymbol				AChrIsSymbol
#define TChrIsPrintable				AChrIsPrintable
#define TChrToLower					AChrToLower
#define TChrToUpper					AChrToUpper
#define TChrToHex					AChrToHex
#define TChrFromHex					AChrFromHex
#define TChrEqualI					AChrEqualI

#define TStrEnd						AStrEnd
#define TStrLen						AStrLen
#define TStrCopy					AStrCopy
#define TStrCopyN					AStrCopyN
#define TStrCat						AStrCat
#define TStrCmp						AStrCmp
#define TStrCmpI					AStrCmpI
#define TStrCmpN					AStrCmpN
#define TStrCmpNI					AStrCmpNI

#define TStrChr						AStrChr
#define TStrRChr					AStrRChr
#define TStrStr						AStrStr
#define TStrStrI					AStrStrI

#define TStrRep						AStrRep
#define TStrTrim					AStrTrim
#define TStrEqual					AStrEqual
#define TStrEqualI					AStrEqualI
#define TStrSplit					AStrSplit
#define TStrRSplit					AStrRSplit
#define TStrMatch					AStrMatch
#define TStrMatchI					AStrMatchI
#define TStrToUpper					AStrToUpper
#define TStrToLower					AStrToLower
#define TStrToInt					AStrToInt
#define TStrToInt64					AStrToInt64
#define TStrToDouble				AStrToDouble
#define TStrFromInt					AStrFromInt
#define TStrFromDouble				AStrFromDouble
#define TStrToHex					AStrToHex
#define TStrFromHex					AStrFromHex
#define TStrFormat					AStrFormat
#define TStrFormatV					AStrFormatV

#define TStrLoad					AStrLoad
#define TStrGet						AStrGet

#define TStrToAStr					AStrCopyN
#define TStrToWStr					AStrToWStr
#define AStrToTStr					AStrCopyN
#define WStrToTStr					WStrToAStr

#define TStrToUTF8					AStrToUTF8
#define UTF8ToTStr					UTF8ToAStr

#endif
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* File */
UAPI(UFILE) UFileOpen(PCTSTR ptzPath, DWORD dwAccess UDEF(UFILE_READ))
{
	if (dwAccess == UFILE_READ)
	{
		return fopen(ptzPath, "rb");
	}
	else if (dwAccess == UFILE_WRITE)
	{
		return fopen(ptzPath, "wb");
	}
	return fopen(ptzPath, "b");
}

UAPI(BOOL) UFileClose(UFILE uFile)
{
	return fclose(uFile);
}

UAPI(UINT) UFileRead(UFILE uFile, PVOID pvData, UINT nSize)
{
	return fread(pvData, 1, nSize, uFile);
}

UAPI(UINT) UFileWrite(UFILE uFile, PCVOID pvData, UINT nSize)
{
	return fwrite(pvData, 1, nSize, uFile);
}

UAPI(UINT) UFileSeek(UFILE uFile, INT iOffset, DWORD dwOrigin UDEF(UFILE_BEGIN))
{
	return fseek(uFile, iOffset, dwOrigin);
}

UAPI(UINT) UFileTell(UFILE uFile)
{
	return UFileSeek(uFile, 0, UFILE_CURRENT);
}

UAPI(UINT) UFileGetSize(UFILE uFile)
{
	UINT cur = fseek(uFile, 0, SEEK_END);
	UINT size = ftell(uFile);
	fseek(uFile, cur, SEEK_SET);
	return size;
}

#ifdef WIN32
UAPI(BOOL) UFileSetSize(UFILE uFile, UINT nSize UDEF(0))
{
	UFileSeek(uFile, nSize, UFILE_BEGIN);
	return SetEndOfFile(uFile);
}
#endif

#ifdef WIN32
UAPI(PTSTR) UFileToTStr(PCTSTR ptzPath, PUINT puSize UDEF(NULL))
{
	UINT nSize;
	PTSTR ptzData;
	UFILE uFile = UFileOpen(ptzPath, UFILE_READ);
	if (uFile == NULL)
	{
		return NULL;
	}
	
	nSize = UFileGetSize(uFile);
	if (puSize && (nSize > *puSize))
	{
		nSize = *puSize;
	}
	ptzData = (PTSTR) UMemAlloc(nSize + 16);
	if (ptzData)
	{
		UINT nRead = UFileRead(uFile, ptzData, 2);
		if (nRead == 2)
		{
			WORD wBom = *((PWORD) ptzData);
			if (wBom == 0xFEFF)
			{
				nRead = 0;
			}
			else if (wBom == 0xBBEF)
			{
				nRead = 0;
				UFileRead(uFile, ptzData, 1);
			}
			
			nRead += UFileRead(uFile, (PBYTE) ptzData + nRead, nSize - 2);
		
#ifdef _UNICODE
			if ((nRead >= 2) && (wBom != 0xFEFF) && (((PBYTE) ptzData)[1] != 0))
			{
				PASTR pazTemp = (PASTR) ptzData;
				ptzData = (PTSTR) UMemAlloc((nRead + 16) * sizeof(WCHAR));
				if (ptzData)
				{
					UINT uCodePage = ((wBom == 0xBBEF) || AStrIsUTF8XML(pazTemp)) ? UCP_UTF8 : UCP_ANSI;
					nRead = sizeof(WCHAR) * AStrToWStr(ptzData, pazTemp, nRead + 16, nRead, uCodePage);
				}
				UMemFree(pazTemp);
			}
#else
			if ((nRead >= 2) && ((wBom == 0xFEFF) || (wBom == 0xBBEF) || ((PBYTE) ptzData)[1] == 0))
			{
				PWSTR pwzTemp = (PWSTR) ptzData;
				ptzData = (PTSTR) UMemAlloc((nRead + 16) * sizeof(WCHAR));
				if (ptzData)
				{
					if ((wBom == 0xBBEF) || AStrIsUTF8XML((PASTR) pwzTemp))
					{
						PASTR pazUTF8 = (PASTR) pwzTemp;
						pwzTemp = (PWSTR) ptzData;
						ptzData = (PTSTR) pazUTF8;
						nRead = sizeof(WCHAR) * AStrToWStr(pwzTemp, pazUTF8, nRead, nRead, UCP_UTF8);
					}
					nRead = sizeof(ACHAR) * WStrToAStr(ptzData, pwzTemp, nSize, nRead / sizeof(WCHAR), UCP_ANSI);
				}
				UMemFree(pwzTemp);
			}
#endif
		}
		
		if (ptzData)
		{
			if (puSize)
			{
				*puSize = nRead;
			}
			((PBYTE) ptzData)[nRead] = 0;
			((PBYTE) ptzData)[nRead + 1] = 0;
			((PBYTE) ptzData)[nRead + 2] = 0;
		}
	}
	UFileClose(uFile);
	return ptzData;
}
#endif

UAPI(PVOID) UFileLoad(PCTSTR ptzPath, PUINT puSize UDEF(NULL), PVOID pvData UDEF(NULL))
{
	UINT nSize;
	UFILE uFile = UFileOpen(ptzPath, UFILE_READ);
	if (uFile == NULL)
	{
		return NULL;
	}
	
	nSize = UFileGetSize(uFile);
	if (puSize && (nSize > *puSize))
	{
		nSize = *puSize;
	}
	
	if (pvData == NULL)
	{
		pvData = (PBYTE) UMemAlloc(nSize + 16);
	}
	
	if (pvData)
	{
		nSize = UFileRead(uFile, pvData, nSize);
		((PBYTE) pvData)[nSize] = 0;
		((PBYTE) pvData)[nSize + 1] = 0;
		if (puSize)
		{
			*puSize = nSize;
		}
	}
	
	UFileClose(uFile);
	return pvData;
}

UAPI(UINT) UFileSave(PCTSTR ptzPath, PCVOID pvData, UINT nSize, BOOL bAppend UDEF(FALSE))
{
	UINT nWrite;
	UFILE uFile = UFileOpen(ptzPath, bAppend ? UFILE_READWRITE : UFILE_WRITE);
	if (uFile == NULL)
	{
		return 0;
	}
	
	if (bAppend)
	{
		UFileSeek(uFile, 0, UFILE_END);
	}
	nWrite = UFileWrite(uFile, pvData, nSize);
	UFileClose(uFile);
	return nWrite;
}
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* File Management */
UAPI(UINT) UPathMake(PTSTR ptzDir, PCTSTR ptzSub)
{
	PTSTR p = TStrEnd(ptzDir);
	if (p[-1] != SEPCHAR)
	{
		*p++ = SEPCHAR;
	}
	return (UINT) (p - ptzDir) + TStrCopy(p, ptzSub);
}

UAPI(PTSTR) UPathSplit(PTSTR* pptzPath)
{
	PTSTR p;
	PTSTR ptzEnd = TStrEnd(*pptzPath);
	for (p = ptzEnd; p >= *pptzPath; p--)
	{
		if (*p == SEPCHAR)
		{
			*p++ = 0;
			return p;
		}
	}
	p = *pptzPath;
	*pptzPath = ptzEnd;
	return p;
}

UAPI(BOOL) UFileNameValid(PCTSTR ptzName)
{
	UINT i;
	PCTSTR p;
	CONST STATIC TCHAR c_tzInvalidChar[] = TEXT("\\/:*?\"<>|");
	for (p = ptzName; *p; p++)
	{
		for (i = 0; i < _NumOf(c_tzInvalidChar) - 1; i++)
		{
			if (*p == c_tzInvalidChar[i])
			{
				return FALSE;
			}
		}
	}
	return (*ptzName != 0);
}

#ifdef __OBJC__
UAPI(BOOL) UFileDelete(PCTSTR ptzPath)
{
	return [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithUTF8String:ptzPath] error:nil];
}

UAPI(BOOL) UFileCopy(PCTSTR ptzPath, PCTSTR ptzNewPath)
{
	return [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithUTF8String:ptzPath] toPath:[NSString stringWithUTF8String:ptzNewPath] error:nil];
}

UAPI(BOOL) UFileMove(PCTSTR ptzPath, PCTSTR ptzNewPath)
{
	return [[NSFileManager defaultManager] moveItemAtPath:[NSString stringWithUTF8String:ptzPath] toPath:[NSString stringWithUTF8String:ptzNewPath] error:nil];
}

UAPI(BOOL) UFileExist(PCTSTR ptzPath)
{
	BOOL isDirectory;
	return [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:ptzPath] isDirectory:&isDirectory] && !isDirectory;
}

UAPI(BOOL) UDirExist(PCTSTR ptzDir)
{
	BOOL isDirectory;
	return [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:ptzDir] isDirectory:&isDirectory] && isDirectory;
}

UAPI(BOOL) UDirCreate(PCTSTR ptzDir)
{
	return [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithUTF8String:ptzDir] withIntermediateDirectories:YES attributes:nil error:nil];
}

UAPI(BOOL) UDirDelete(PCTSTR ptzDir)
{
	return [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithUTF8String:ptzDir] error:nil];
}

UAPI(UINT) UDirGetAppPath(PTSTR ptzPath)
{
	NSString *dir = [[NSBundle mainBundle] bundlePath];
	return TStrCopy(ptzPath, dir.UTF8String) - 1;
}

UAPI(UINT) UDirGetAppFile(PTSTR ptzPath, PCTSTR ptzFile)
{
	PTSTR p = ptzPath + UDirGetAppPath(ptzPath);
	for (; p >= ptzPath; p--)
	{
		if (*p == SEPCHAR)
		{
			p++;
			break;
		}
	}
	return (UINT) (p - ptzPath) + TStrCopy(p, ptzFile) - 1;
}

UAPI(UINT) UDirGetAppExt(PTSTR ptzPath, PCTSTR ptzExt)
{
	PTSTR p;
	PTSTR ptzEnd = ptzPath + UDirGetAppPath(ptzPath);
	for (p = ptzEnd; p >= ptzPath; p--)
	{
		if (*p == '.')
		{
			p++;
			break;
		}
	}
	if (p == ptzPath)
	{
		p = ptzEnd;
		*p++ = '.';
	}
	return (UINT) (p - ptzPath) + TStrCopy(p, ptzExt) - 1;
}

UAPI(UINT) UDirGetCurrent(PTSTR ptzDir)
{
#ifdef GetCurrentDirectory
	return GetCurrentDirectory(MAX_PATH, ptzDir);
#else
	UDirGetAppPath(ptzDir);
	return (UINT) (UPathSplit(&ptzDir) - ptzDir - 1);
#endif
}

UAPI(UINT) UDirGetTemp(PTSTR ptzDir)
{
	NSString *dir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	return TStrCopy(ptzDir, dir.UTF8String) - 1;
}

UAPI(UINT) UFileGetTemp(PTSTR ptzPath)
{
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	
	NSString *dir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *path = [dir stringByAppendingPathComponent:(NSString *)string];
	[(NSString *)string autorelease];
	return TStrCopy(ptzPath, path.UTF8String) - 1;
}
#endif
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* Thread */
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* Misc */
UAPI(UINT) UGetRandom()
{
	srand(mach_absolute_time());
	return rand();
}

UAPI(UINT64) UGetTimeStamp()
{
	return mach_absolute_time();
}

UAPI(VOID) UTrace(PCTSTR ptzFormat, ...)
{
	DWORD i;
	va_list va;
	TCHAR tz[MAX_STR];
	
#ifdef _TRACE_TIME
	UTIME ut;
	UGetTime(&ut);
	i = TStrFormat(tz, TEXT("%02u:%02u:%02u\t"), (UINT) ut.wHour, (UINT) ut.wMinute, (UINT) ut.wSecond);
#else
	i = 0;
#endif
	
	va_start(va, ptzFormat);
	i += TStrFormatV(tz + i, ptzFormat, va);
	va_end(va);
	
	tz[i++] = '\r';
	tz[i++] = '\n';
	tz[i] = 0;
	
#if defined(_TRACE_TO_FILE)
	UFileSave(_TRACE_TO_FILE, tz, i * sizeof(TCHAR), TRUE);
#elif defined(_TRACE_TO_CONSOLE)
	puts(tz);
#else
	puts(tz);
#endif
}

UAPI(VOID) UAssert(PCTSTR ptzExp, PCTSTR ptzFile, UINT uLine)
{
	printf(TEXT("Assertion failed!\n\n")
		   TEXT("File: %s\n")
		   TEXT("Line: %d\n\n")
		   TEXT("Expression: %s\n\n"),
		   ptzFile, uLine, ptzExp);
}
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* UAutoTrace */
#ifdef __cplusplus
class UAutoTrace
{
private:
	UINT m_uLine;
	PCTSTR m_ptzName;
	UINT64 m_uStartTime;
	
public:
	UAutoTrace(PCTSTR ptzName, UINT uLine): m_uLine(uLine), m_ptzName(ptzName)
	{
		m_uStartTime = UGetTimeStamp();
		UTrace(TEXT("Enter %s:%u"), ptzName, uLine);
	}
	
	~UAutoTrace()
	{
		UTrace(TEXT("Leave %s:%u Elapsed %qu"), m_ptzName, m_uLine, UGetTimeStamp() - m_uStartTime);
	}
};
#endif
/**********************************************************************************************************************/



/**********************************************************************************************************************/
/* Debug */
#ifdef __FUNCTION__
#define __FUNCFILE__				TEXT(__FUNCTION__)
#else
#define __FUNCFILE__				TEXT(__FILE__)
#endif

#ifdef _TRACE
#define _Trace						UTrace
#define _LineTrace()				UTrace(TEXT("Trace %s:%u"), __FUNCFILE__, __LINE__)
#ifdef __cplusplus
#define _AutoTrace()				UAutoTrace at(__FUNCFILE__, __LINE__)
#else
#define _AutoTrace()				_LineTrace()
#endif
#else
#define _Trace
#define _LineTrace()
#define _AutoTrace()
#endif

#ifdef _DEBUG
#define _Assert(e)					(VOID) ((e) || (UAssert(TEXT(#e), TEXT(__FILE__), __LINE__), 0))
#define _Verify(e)					_Assert(e)
#else
#define _Assert(e)					((VOID) 0)
#define _Verify(e)					((VOID) (e))
#endif

#ifdef _CHECK
#ifdef _DEBUG
FINLINE BOOL __Check(BOOL e)		{BOOL b = (e); _Assert(b); return b;}
#define _Check(e)					__Check(e)
#else
#define _Check(e)					(e)
#endif
#else
#ifdef _DEBUG
#define _Check(e)					(_Assert(e), TRUE)
#else
#define _Check(e)					(TRUE)
#endif
#endif
/**********************************************************************************************************************/
