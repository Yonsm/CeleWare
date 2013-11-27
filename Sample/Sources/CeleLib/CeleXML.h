


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CeleXml 2.1.126
// Copyright (C) Yonsm 2010, All Rights Reserved.
#pragma once
#include "UniBase.h"
#include <vector>

//#define _DO_ESCAPE		// Not supported yet
#define _PARSE_COMMENT
#define _KEEP_COMMENT
#define _CASE_SENSITIVE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CeleXmlAttr class
class CeleXmlAttr
{
public:
	PCTSTR m_ptzName;	// Name
	PCTSTR m_ptzVal;	// Value
	bool m_bAllocName;	//
	bool m_bAllocVal;	//

public:
	// Constructor
	FINLINE CeleXmlAttr(PCTSTR name = TEXT(""), PCTSTR val = TEXT(""))
	{
		m_ptzName = name;
		m_ptzVal = val;
		m_bAllocName = false;
		m_bAllocVal = false;
	}

	// Destructor
	//FINLINE ~CeleXmlAttr()
	//{
	//	Free();
	//}

public:
	// Free
	FINLINE VOID Free()
	{
		FreeName();
		FreeVal();
	}

	// Free name
	FINLINE VOID FreeName()
	{
		if (m_bAllocName)
		{
			UMemFree(PVOID(m_ptzName));
			m_bAllocName = false;
		}
		m_ptzName = TEXT("");
	}

	// Free val
	FINLINE VOID FreeVal()
	{
		if (m_bAllocVal)
		{
			UMemFree(PVOID(m_ptzVal));
			m_bAllocVal = false;
		}
		m_ptzVal = TEXT("");
	}

	// Set attribute name
	FINLINE VOID SetName(PCTSTR name = TEXT(""), bool bAlloc = false)
	{
		FreeName();
		_Assert(name);
		if (m_bAllocName = bAlloc)
		{
			UINT nSize = (TStrLen(name) + 1) * sizeof(TCHAR);
			m_ptzName = PTSTR(UMemAlloc(nSize));
			_Assert(m_ptzName);
			UMemCopy(PVOID(m_ptzName), name, nSize);
		}
		else
		{
			m_ptzName = name;
		}
	}

	// Set attribute value
	FINLINE VOID SetVal(PCTSTR val = TEXT(""), bool bAlloc = false)
	{
		FreeVal();
		_Assert(val);
		if (m_bAllocVal = bAlloc)
		{
			UINT nSize = (TStrLen(val) + 1) * sizeof(TCHAR);
			m_ptzVal = PTSTR(UMemAlloc(nSize));
			_Assert(m_ptzVal);
			UMemCopy(PVOID(m_ptzVal), val, nSize);
		}
		else
		{
			m_ptzVal = val;
		}
	}

public:
	// Get attribute name
	FINLINE PCTSTR GetName()
	{
		return m_ptzName;
	}

	// Get string value
	FINLINE PCTSTR GetStr()
	{
		return m_ptzVal;
	}

	// Get integer value
	FINLINE INT GetInt()
	{
		return TStrToInt(m_ptzVal);
	}

	// Get integer value
	FINLINE INT64 GetInt64()
	{
		return TStrToInt64(m_ptzVal);
	}

	// Get double value
	FINLINE DOUBLE GetDouble()
	{
		return TStrToDouble(m_ptzVal);
	}

public:
	// Get point value
	FINLINE POINT GetPoint()
	{
		POINT pt;
		UINT n = GetArray(PINT(&pt), 2);
		_Assert(n == 2);
		return pt;
	}

	// Get rectangle value
	FINLINE RECT GetRect()
	{
		RECT rt;
		UINT n = GetArray(PINT(&rt), 4);
		_Assert(n == 4);
		return rt;
	}

	// Get color value
	FINLINE COLORREF GetColor()
	{
		COLORREF cr;
		UINT n = GetArray(PBYTE(&cr), 4);
		//_Assert((n == 3) || (n == 4));
		return cr;
	}

public:
	FINLINE operator PCTSTR() {return GetStr();}
	FINLINE operator INT() {return GetInt();}
	FINLINE operator UINT() {return GetInt();}
	FINLINE operator INT64() {return GetInt64();}
	FINLINE operator UINT64() {return GetInt64();}
	FINLINE operator FLOAT() {return FLOAT(GetDouble());}
	FINLINE operator DOUBLE() {return GetDouble();}

	FINLINE operator POINT() {return GetPoint();}
	FINLINE operator RECT() {return GetRect();}
	FINLINE operator COLORREF() {return GetColor();}

public:
	// Get integer array with separated char
	// The lacking elements will be filled with 0
	template<TCHAR SEP, typename TYPE> UINT GetArray(TYPE* ptOut, UINT nCount)
	{
		UINT n = 1;
		PCTSTR p = m_ptzVal;
		StrToVal(p, ptOut);
		for (TYPE* ptEnd = ptOut++ + nCount; ptOut < ptEnd; )
		{
			if (*p == 0)
			{
				*ptOut++ = 0;
			}
			else if (*p++ == SEP)
			{
				n++;
				StrToVal(p, ptOut++);
			}
		}
		return n;
	}

	// Get array with separated space
	template<typename TYPE> UINT GetArray(TYPE* ptOut, UINT nCount)
	{
		return GetArray<' '>(ptOut, nCount);
	}

public:
	// Get enum value with separated char
	template<TCHAR SEP> UINT GetEnum(PCTSTR ptzEnum, UINT nDefault = -1)
	{
		if (*m_ptzVal)
		{
			if (StrEqual<SEP>(ptzEnum, m_ptzVal))
			{
				return 0;
			}
			for (UINT i = 1; *ptzEnum; ptzEnum++)
			{
				if (*ptzEnum++ == SEP)
				{
					if (StrEqual<SEP>(ptzEnum, m_ptzVal))
					{
						return i;
					}
					i++;
				}
			}
		}
		return nDefault;
	}

	// Get enum value with separated space
	UINT GetEnum(PCTSTR ptzEnum, UINT nDefault = -1)
	{
		return GetEnum<' '>(ptzEnum, nDefault);
	}

protected:
#ifndef _CASE_SENSITIVE
	// Support case insensitive XML
	ISTATIC INT TStrCmp(PCTSTR ptzStr1, PCTSTR ptzStr2) {return ::TStrCmpI(ptzStr1, ptzStr2);}
	ISTATIC UINT TStrEqual(PCTSTR ptzStr1, PCTSTR ptzStr2) {return ::TStrEqualI(ptzStr1, ptzStr2);}
#endif

private:
	// For GetArray
	template<typename TYPE>
	ISTATIC VOID StrToVal(PCTSTR ptzVal, TYPE* pOut) {*pOut = TStrToInt(ptzVal);}
	ISTATIC VOID StrToVal(PCTSTR ptzVal, INT64* pOut) {*pOut = TStrToInt64(ptzVal);}
	ISTATIC VOID StrToVal(PCTSTR ptzVal, FLOAT* pOut) {*pOut = FLOAT(TStrToDouble(ptzVal));}
	ISTATIC VOID StrToVal(PCTSTR ptzVal, DOUBLE* pOut) {*pOut = TStrToDouble(ptzVal);}

private:
	// Compare string with extra separated char
	template<TCHAR SEP1, TCHAR SEP2> ISTATIC BOOL StrEqual(PCTSTR ptzStr1, PCTSTR ptzStr2)
	{
		UINT n = TStrEqual(ptzStr1, ptzStr2);
		return (((ptzStr1[n] == 0) || (ptzStr1[n] == SEP1)) && ((ptzStr2[n] == 0) || (ptzStr2[n] == SEP2)));
	}

	// Compare string with extra separated char
	template<TCHAR SEP1> ISTATIC BOOL StrEqual(PCTSTR ptzStr1, PCTSTR ptzStr2)
	{
		UINT n = TStrEqual(ptzStr1, ptzStr2);
		return (((ptzStr1[n] == 0) || (ptzStr1[n] == SEP1)) && (ptzStr2[n] == 0));
	}

public:
	// Set string value
	FINLINE VOID SetStr(PCTSTR val, bool bAlloc = true)
	{
		SetVal(val, bAlloc);
	}

	// Set integer value
	FINLINE VOID SetInt(INT val)
	{
		TCHAR str[MAX_PATH];
		ValToStr(str, val);
		SetVal(str, true);
	}

	// Set integer value
	FINLINE VOID SetInt64(INT64 val)
	{
		TCHAR str[MAX_PATH];
		ValToStr(str, val);
		SetVal(str, true);
	}

	// Set double value
	FINLINE VOID SetDouble(DOUBLE val)
	{
		TCHAR str[MAX_PATH];
		ValToStr(str, val);
		SetVal(str, true);
	}

public:
	// Set point value
	FINLINE VOID SetPoint(POINT& val)
	{
		SetArray(PINT(&val), 2);
	}

	// Set rectangle value
	FINLINE VOID SetRect(RECT& val)
	{
		SetArray(PINT(&val), 4);
	}

	// Set color value
	FINLINE VOID SetColor(COLORREF val)
	{
		SetArray(PBYTE(&val), 4);
	}

public:
	FINLINE VOID operator=(PCTSTR val) {SetStr(val);}
	FINLINE VOID operator=(INT val) {SetInt(val);}
	FINLINE VOID operator=(UINT val) {SetInt(val);}
	FINLINE VOID operator=(FLOAT val) {SetDouble(val);}
	FINLINE VOID operator=(DOUBLE val) {SetDouble(val);}

	FINLINE VOID operator=(POINT& val) {SetPoint(val);}
	FINLINE VOID operator=(RECT& val) {SetRect(val);}
	FINLINE VOID operator=(COLORREF val) {SetColor(val);}

public:
	// Set array with separated char
	template<TCHAR SEP, typename TYPE> VOID SetArray(TYPE* ptVals, UINT nCount)
	{
		TCHAR str[10240];
		PTSTR p = str + ValToStr(str, ptVals[0]);
		for (UINT i = 1; i < nCount; i++)
		{
			*p++ = SEP;
			p += ValToStr(p, ptVals[i]);
		}
		SetStr(str, true);
	}

	// Get integer array with separated space
	template<typename TYPE> VOID SetArray(TYPE* ptOut, UINT nCount)
	{
		return SetArray<' '>(ptOut, nCount);
	}

private:
	// For SetArray
	template<typename TYPE>
	FINLINE UINT ValToStr(PTSTR str, TYPE val) {return TStrFormat(str, TEXT("%d"), INT(val));}
	FINLINE UINT ValToStr(PTSTR str, INT64 val) {return TStrFormat(str, TEXT("%I64d"), val);}
	FINLINE UINT ValToStr(PTSTR str, FLOAT val) {return TStrFormat(str, TEXT("%f"), val);}
	FINLINE UINT ValToStr(PTSTR str, DOUBLE val) {return TStrFormat(str, TEXT("%lf"), val);}
};
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CeleXmlNode class
class CeleXmlNode;
typedef std::vector<CeleXmlAttr> CeleXmlAttrs;
typedef std::vector<CeleXmlNode> CeleXmlNodes;
class CeleXmlNode: public CeleXmlAttr
{
protected:
	CeleXmlAttrs m_Attrs;
	CeleXmlNodes m_Nodes;

public:
	// Constructor
	CeleXmlNode(PCTSTR name = TEXT(""), PCTSTR val = TEXT("")): CeleXmlAttr(name, val)
	{
	}

	// Destructor
	VOID Free()
	{
		for (CeleXmlAttrs::iterator attr = m_Attrs.begin(); attr != m_Attrs.end(); ++attr)
		{
			attr->Free();
		}
		for (CeleXmlNodes::iterator node = m_Nodes.begin(); node != m_Nodes.end(); ++node)
		{
			node->Free();
		}
		m_Attrs.clear();
		m_Nodes.clear();
		CeleXmlAttr::Free();
	}

public:
	// Get sub node set
	CeleXmlNodes& GetNodes()
	{
		return m_Nodes;
	}

	// Get sub node by name
	CeleXmlNode* GetNode(PCTSTR ptzNodeName)
	{
		for (CeleXmlNodes::iterator node = m_Nodes.begin(); node != m_Nodes.end(); ++node)
		{
			if (TStrCmp(node->m_ptzName, ptzNodeName) == 0)
			{
				return &(*node);
			}
		}
		return NULL;
	}

	// Get sub node by name, return a empty node if not exist
	CeleXmlNode& GetOrDefNode(PCTSTR ptzNodeName)
	{
		static CeleXmlNode nullNode;
		CeleXmlNode* node = GetNode(ptzNodeName);
		return node ? *node : nullNode;
	}

	// Get sub node by name, add a node if not exist
	CeleXmlNode& GetOrAddNode(PCTSTR ptzNodeName, bool bAlloc = false)
	{
		CeleXmlNode* node = GetNode(ptzNodeName);
		if (node == NULL)
		{
			m_Nodes.push_back(CeleXmlNode());
			node = &m_Nodes.back();
			node->SetName(ptzNodeName, bAlloc);
		}
		return *node;
	}

	// Get next sub node by name
	CeleXmlNode* GetNext(CeleXmlNode* pNode)
	{
		_Assert(pNode);
		for (CeleXmlNodes::iterator node = m_Nodes.begin(); node != m_Nodes.end(); ++node)
		{
			if (pNode == &(*node))
			{
				for (++node; node != m_Nodes.end(); ++node)
				{
					if (TStrCmp(node->m_ptzName, pNode->m_ptzName) == 0)
					{
						return &(*node);
					}
				}
				break;
			}
		}
		return NULL;
	}

	// Get node by path
	CeleXmlNode* GetNodeByPath(PCTSTR ptzNodePath)
	{
		// Lookup node
		for (CeleXmlNodes::iterator node = m_Nodes.begin(); node != m_Nodes.end(); ++node)
		{
			// Is node name equal?
			UINT n = TStrEqual(ptzNodePath, node->m_ptzName);
			if (node->m_ptzName[n] == 0)
			{
				if (ptzNodePath[n] == '?')
				{
					// Check attribute condition
					PCTSTR ptzName = &ptzNodePath[n + 1];
					PCTSTR ptzVal = ptzName;
					while (*ptzVal++ != '=');

					// Lookup attribute
					for (CeleXmlAttrs::iterator attr = node->m_Attrs.begin(); attr != node->m_Attrs.end(); ++attr)
					{
						// Is attribute name equal?
						n = TStrEqual(ptzName, attr->m_ptzName);
						if ((attr->m_ptzName[n] == 0) && (ptzName[n] == '='))
						{
							// Is attribute value equal?
							n = TStrEqual(ptzVal, attr->m_ptzVal);
							if (attr->m_ptzVal[n] == 0)
							{
								// Yes, continue check
								ptzNodePath = ptzVal;
								goto _Check;
							}
							break;
						}
					}
					continue;
				}

_Check:
				if (ptzNodePath[n] == 0)
				{
					return &(*node);
				}
				else if (ptzNodePath[n] == '/')
				{
					return ptzNodePath[n + 1] ? node->GetNodeByPath(&ptzNodePath[n + 1]) : &(*node);
				}
			}			
		}
		return NULL;
	}

public:
	// Get attribute set
	CeleXmlAttrs& GetAttrs()
	{
		return m_Attrs;
	}

	// Get attribute by name
	CeleXmlAttr* GetAttr(PCTSTR ptzAttrName)
	{
		for (CeleXmlAttrs::iterator attr = m_Attrs.begin(); attr != m_Attrs.end(); ++attr)
		{
			if (TStrCmp(attr->m_ptzName, ptzAttrName) == 0)
			{
				return &(*attr);
			}
		}
		return NULL;
	}

	// Get attribute by name, return a empty attr if not exist
	CeleXmlAttr& GetOrDefAttr(PCTSTR ptzAttrName)
	{
		static CeleXmlAttr nullAttr;
		CeleXmlAttr* attr = GetAttr(ptzAttrName);
		return attr ? *attr : nullAttr; 
	}

	// Get attribute by name, add a attr if not exist
	CeleXmlAttr& GetOrAddAttr(PCTSTR ptzAttrName, bool bAlloc = false)
	{
		CeleXmlAttr* attr = GetAttr(ptzAttrName);
		if (attr == NULL)
		{
			m_Attrs.push_back(CeleXmlAttr());
			attr = &m_Attrs.back();
			attr->SetName(ptzAttrName, bAlloc);
		}
		return *attr;
	}

	// Get attribute by path
	CeleXmlAttr* GetAttrByPath(PCTSTR ptzNodePath, PCTSTR ptzAttrName)
	{
		CeleXmlNode* node = GetNodeByPath(ptzNodePath);
		return node ? node->GetAttr(ptzAttrName) : NULL;
	}

public:
	// Parse node
	PTSTR Parse(PTSTR ptzNode)
	{
		CeleXmlAttr attr;
		m_ptzName = ptzNode + 1;	// Set node name
		//attr.m_ptzName = m_ptzName;
		for (PTSTR p = PTSTR(m_ptzName); ; p++)
		{
			// TODO: Unescape
			switch (*p)
			{
			case '\0':
				m_ptzVal = p;
				return p;

			case '>':
				*p++ = 0;
				if (p[-2] == '/')
				{
					// Closed node
					p[-2] = 0;
					m_ptzVal = p - 2;
				}
				else
				{
					// Parse sub nodes
					for (m_ptzVal = p; *p; )
					{
						if (*p == '<')
						{
							if (p[1] == '/')
							{
								*p++ = 0;	// End of node
								break;
							}
#ifdef _PARSE_COMMENT
							else if ((p[1] == '!') && (p[2] == '-') && (p[3] == '-'))
							{
#ifdef _KEEP_COMMENT
								p[3] = 0;
								CeleXmlNode node(p + 1, p + 4);
								m_Nodes.push_back(node);
#endif
								for (p += 4; *p; p++)
								{
									if ((p[0] == '-') && (p[1] == '-') && (p[2] == '>'))
									{
#ifdef _KEEP_COMMENT
										*p = 0;
#endif
										p += 3;
										break;
									}
								}
							}
#endif
							else
							{
								CeleXmlNode node;
								p = node.Parse(p);
								m_Nodes.push_back(node);
							}
						}
						else
						{
							p++;
						}
					}
				}
				return p;

			case ' ':
			case '\t':
			case '\r':
			case '\n':
				*p = 0;	// End of attribute name
				attr.m_ptzName = p + 1;	// End of attribute name
				break;

			case '=':
				*p++ = 0;	// End of attribute name
				while (*p && (*p++ != '"' && *(p-1) != '\''));
				attr.m_ptzVal = p;	// Set attribute value
				while (*p && (*p != '"' && *p != '\'')) p++;
				*p = 0;
				m_Attrs.push_back(attr);

				break;
			}
		}
	}

public:
	// Indent
	VOID Indent(UFILE hFile, UINT nIndent = 0)
	{
		UFileWrite(hFile, TEXT("\r\n"), sizeof(TCHAR) * 2);
		for (UINT i = 0; i < nIndent; i++)
		{
			UFileWrite(hFile, TEXT("\t"), sizeof(TCHAR));
		}
	}

	// Write out
	BOOL Save(UFILE hFile, UINT nIndent = 0)
	{
		TCHAR tz[MAX_STR];

		Indent(hFile, nIndent);
		UINT n = TStrFormat(tz, TEXT("<%s"), m_ptzName);
		BOOL ret = UFileWrite(hFile, tz, n * sizeof(TCHAR));

#ifdef _KEEP_COMMENT
		if ((m_ptzName[0] == '!') && (m_ptzName[1] == '-'))
		{
			UFileWrite(hFile, TEXT("-"), sizeof(TCHAR));
			UFileWrite(hFile, m_ptzVal, TStrLen(m_ptzVal) * sizeof(TCHAR));
			return UFileWrite(hFile, TEXT("-->"), 3 * sizeof(TCHAR));
		}
#endif

		for (CeleXmlAttrs::iterator attr = m_Attrs.begin(); attr != m_Attrs.end(); ++attr)
		{
			UINT n = TStrFormat(tz, TEXT(" %s=\"%s\""), attr->GetName(), attr->GetStr());
			ret = UFileWrite(hFile, tz, n * sizeof(TCHAR));
		}

		if (m_Nodes.size())
		{
			ret = UFileWrite(hFile, TEXT(">"), sizeof(TCHAR));
			for (CeleXmlNodes::iterator node = m_Nodes.begin(); node != m_Nodes.end(); ++node)
			{
				ret = node->Save(hFile, nIndent + 1);
			}
			Indent(hFile, nIndent);
		}
		else if (*m_ptzVal)
		{
			ret = UFileWrite(hFile, TEXT(">"), sizeof(TCHAR));
			UFileWrite(hFile, m_ptzVal, TStrLen(m_ptzVal) * sizeof(TCHAR));
		}
		else
		{
			return UFileWrite(hFile, TEXT("/>"), sizeof(TCHAR) * 2);
		}

		n = TStrFormat(tz, TEXT("</%s>"), m_ptzName);
		return UFileWrite(hFile, tz, n * sizeof(TCHAR));
	}

	// Write out
	BOOL Save(PCTSTR ptzPath)
	{
		UFILE hFile = UFileOpen(ptzPath, UFILE_WRITE);
		if (hFile == NULL) return FALSE;

#ifdef _UNICODE
#define XML_Header TEXT("\xFEFF<?xml version=\"1.0\" encoding=\"UTF-16\"?>")
#else
#define XML_Header TEXT("<?xml version=\"1.0\"?>")
#endif
		UFileWrite(hFile, XML_Header, sizeof(XML_Header) - sizeof(TCHAR)); 

		// TODO: Skip declaration in Parse
		BOOL ret = m_Nodes[0].Save(hFile);
		UFileClose(hFile);
		return TRUE;
	}
};
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CeleXmlAutoFreeNode class
class CeleXmlAutoFreeNode: public CeleXmlNode
{
public:
	CeleXmlAutoFreeNode()
	{
		m_ptzName = NULL;
	}

	~CeleXmlAutoFreeNode()
	{
		//FreeMem();
	}

	// Free memory
	VOID FreeMem()
	{
		if (m_ptzName && m_ptzName[0])
		{
			UMemFree(PVOID(m_ptzName - 1));
		}
	}

	// Free memory and node
	VOID Free()
	{
		FreeMem();
		CeleXmlNode::Free();
	}
};
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CeleXmlFile class
class CeleXmlFile: public CeleXmlAutoFreeNode
{
public:
	CeleXmlFile()
	{
	}

	CeleXmlFile(PCTSTR ptzPath)
	{
		Parse(ptzPath);
	}

	BOOL Parse(PCTSTR ptzPath)
	{
		PTSTR ptzNode = NULL;//UFileToTStr(ptzPath);
		return ptzNode ? (CeleXmlAutoFreeNode::Parse(ptzNode), TRUE) : FALSE;
	}
};
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
