
#import <vector>
#import <algorithm>
#import <Foundation/Foundation.h>

#import "Zh.h"

#define kStartString "NSLocalizedString(@\""

BOOL g_muteMsg = FALSE;
BOOL g_keyAsValue = FALSE;
BOOL g_keyAsComment = FALSE;
BOOL g_stConvert = FALSE;

int mystrcmp(const char *s, const char *t)
{
	while(*s != '\0'  ||  *t !='\0' )
	{
		char ss = toupper(*s);
		char tt = toupper(*t);
		if (ss > tt)
		{
			return 1;
		}
		else if(ss < tt)
		{
			return -1;
		}
		s++;
		t++;
	}
	return 0;	
}

//
struct String {char *key; char *value;};
inline BOOL operator <(const String& item1, const String& item2)
{
	return mystrcmp(item1.key, item2.key) < 0;
}

//
class GenStrings: private std::vector<String>
{
public:
	//
	void AddFile(const char *path)
	{
		FILE *src = fopen(path, "rb");
		if (src == NULL) return;
		
		fseek(src, 0, SEEK_END);
		size_t size = ftell(src);
		fseek(src, 0, SEEK_SET);
		
		char *strings = (char *)malloc(size + 1);
		fread(strings, size, 1, src);
		strings[size] = 0;
		fclose(src);
		
		for (char *string = strings; string = strstr(string, kStartString); string += sizeof(kStartString))
		{
			char key[10240];
			char value[10240];
			const char *p = string + sizeof(kStartString) - 1;
			p = FetchString(key, p);
			p = FindString(p + 1);
			if (p)
			{
				FetchString(value, p);
			}
			else
			{
				value[0] = 0;
			}
			AddString(key, value);
		}
		
		free(strings);
	}
	
	//
	void SortStrings()
	{
		std::sort(begin(), end());
	}
	
	//
	inline void U16ToU8(wchar_t w, char u[3])
	{
		u[0] = 0xE0 | (w >> 12);
		u[1] = 0x80 | ((w >> 6) & 0x3F);
		u[2] = 0x80 | (w & 0x3F);
	}
	
	//
	inline char *GetValue(String *str, char *buf)
	{
		char *value = (g_keyAsValue || !str->value[0]) ? str->key : str->value;
		if (g_stConvert == NO)
		{
			return value;
		}
		
		char *p = value;
		char *q = buf;
		while (*p)
		{
			if ((*p & 0x11100000) == 0x11100000)
			{
				char u[3];
				char *v = p;
				for (const wchar_t *s = zh_Hans; *s; s++)
				{
					U16ToU8(*s, u);
					if ((u[0] == p[0]) && (u[1] == p[1]) && (u[2] == p[2]))
					{
						U16ToU8(zh_Hant[s - zh_Hans], u);
						v = u;
						break;
					}
				}
				*q++ = *v++;
				*q++ = *v++;
				*q++ = *v++;
				p += 3;
			}
			else
			{
				*q++ = *p++;
			}
		}
		
		*q = 0;
		return buf;
	}
	
	//
	int SaveString(const char *path)
	{
		if (size() == 0)
		{
			return 0;
		}

		FILE *outFile = fopen(path, "wb");
		if (outFile == NULL)
		{
			return -1;
		}
		
		char buf[4096];
		for (iterator it = begin(); it != end(); ++it)
		{
			fprintf(outFile, "/* %s */\n\"%s\" = \"%s\";\n\n",
					g_keyAsComment ? it->key : ((it->value[0] ? it->value : "No comment provided by engineer.")),
					it->key, GetValue(&(*it), buf));
		}

		fclose(outFile);
		return size();
	}

	//
	~GenStrings()
	{
		for (iterator it = begin(); it != end(); ++it)
		{
			free(it->key);
			free(it->value);
		}
	}
	
private:
	//
	bool AddString(const char *key, const char *value)
	{
		for (iterator it = begin(); it != end(); ++it)
		{
			if (strcmp(it->key, key) == 0)
			{
				if (strcmp(it->value, value) != 0)
				{
					printf("WARNING: KEY(%s) is identical but VALUE is different!\n\t%s\n\t%s\n", key, it->value, value);
				}
				return false;
			}
		}

		String str;
		size_t keySize = strlen(key) + 1;
		str.key = (char *)malloc(keySize);
		memcpy(str.key, key, keySize);
		size_t valueSize = strlen(value) + 1;
		str.value = (char *)malloc(valueSize);
		memcpy(str.value, value, valueSize);
		
		push_back(str);
		return true;
	}

	//
	const char *FindString(const char *str, char end = ')')
	{
		while (*str && *str != end)
		{
			if (*str == '"')
			{
				return str + 1;
			}
			str++;
		}
		return NULL;
	}

	//
	const char *FetchString(char *dst, const char *src)
	{
		while (*src && (*src != '"'))
		{
			if (*src == '\\')
			{
				*dst++ = *src++;
				*dst = *src;
				/*switch (*++src)
				{
					case 'r': *dst = '\r'; break;
					case 'n': *dst = '\n'; break;
					case 't': *dst = '\t'; break;
					default: *dst = *src; break;
				}*/
			}
			else 
			{
				*dst = *src;
			}
			src++;
			dst++;
		}
		*dst = 0;
		return src;
	}
	
public:
	GenStrings(NSString *srcDir, NSString *outDir)
	{
		//
		NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:srcDir];
		for (NSString *file in files)
		{
			if ([file hasSuffix:@".mm"] || [file hasSuffix:@".m"] || [file hasSuffix:@".h"])
			{
				if (g_muteMsg == FALSE) printf("Process %s\n", file.UTF8String);
				AddFile([srcDir stringByAppendingPathComponent:file].UTF8String);
			}
		}
		
		//
		SortStrings();
		
		//
		const char *outFile = [outDir stringByAppendingPathComponent:@"Localizable.strings"].UTF8String;
		int ret = SaveString(outFile);
		if (ret < 0)
		{
			printf("Failed to create out file: %s\n", outFile);
		}
		else if (ret)
		{
			printf("Fetched and saved %u strings\n", ret);
		}
		else
		{
			printf("No localized strings found\n");	
		}
	}	
};


//
int main(int argc, const char * argv[])
{
	int ret = 0;
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	printf("GenString - Version 1.0.6\nCopyright (C) Yonsm 2010-2011, All Rights Reserved.\n\n");

	const char *dir = NULL;
	for (int i = 1; i < argc; i++)
	{
		if (argv[i][0] == '-')
		{
			if ((mystrcmp(argv[i], "-V") == 0) ||
				(mystrcmp(argv[i], "-KeyAsValue") == 0))
			{
				g_keyAsValue = TRUE;
			}
			else if ((strcmp(argv[i], "-C") == 0) ||
					 (strcmp(argv[i], "-KeyAsComment") == 0))
			{
				g_keyAsComment = TRUE;
			}
		}
		else
		{
			dir = argv[i];
		}
	}
	
	if (dir)
	{
		NSString *srcDir = [NSString stringWithFormat:@"%s", dir];
		GenStrings gs(srcDir, srcDir);
	}
	else
	{
		char dir[256];
		strcpy(dir, argv[0]);
		char *p = strrchr(dir, '/');
		if (p) *p = 0;
		p = strrchr(dir, '/');
		if (p && !strcmp(p + 1, "Resources")) *p = 0;
		NSString *srcDir = /*@"/Users/Yonsm/Documents/InfoHub";*/[NSString stringWithFormat:@"%s", dir];
		if ([[NSFileManager defaultManager] fileExistsAtPath:[srcDir stringByAppendingPathComponent:@"Resources/English.lproj/Localizable.strings"]])
		{
			g_muteMsg = TRUE;
			g_keyAsValue = TRUE;
			g_keyAsComment = TRUE;
			
			GenStrings enu(srcDir, [srcDir stringByAppendingPathComponent:@"Resources/English.lproj"]);
			g_keyAsValue = FALSE;
			GenStrings zhs(srcDir, [srcDir stringByAppendingPathComponent:@"Resources/zh-Hans.lproj"]);
			g_stConvert = TRUE;
			GenStrings zht(srcDir, [srcDir stringByAppendingPathComponent:@"Resources/zh-Hant.lproj"]);
		}
		else
		{
			printf("Usage: GenStrings [-KeyAsValue|-V] [-KeyAsComment|-C] <dir>\n");
		}
	}

    [pool drain];
    return ret;
}
