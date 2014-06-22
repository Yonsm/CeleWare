


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CeleCfg 2.0.202
// Copyright (C) Yonsm 2008-2010, All Rights Reserved.
#pragma once
#include "UUBase.h"
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CeleCfgItem struct
#pragma pack(push, 1)
struct CeleCfgItem
{
	WORD wLen;			// Count of string
	TCHAR tStr[1];		// String, zero-terminated (UNICODE and \r\n), or not (ASCII or \n)

	inline VOID SetDel() {tStr[0] = 0;}
	inline BOOL IsValid() {return wLen && tStr[0];}
	inline CeleCfgItem* GetNext() {return (CeleCfgItem*) &tStr[wLen];}
};
#pragma pack(pop)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CeleCfg class
class CeleCfg
{
protected:
	CeleCfgItem* m_pCfg;		// Buffer
	CeleCfgItem* m_pEnd;		// Data end
	CeleCfgItem* m_pMax;		// Buffer end
	BOOL m_bDirty;				// Dirty flag
	UINT m_uMemInc;				// Buffer increment
	TCHAR m_tzPath[MAX_PATH];	// Config file path

public:
	// Constructor
	CeleCfg(PCTSTR ptzPath = NULL, UINT uMemInc = 2048)
	{
		m_pCfg = NULL;
		m_bDirty = FALSE;
		m_uMemInc = uMemInc;
		Load(ptzPath);
	}

	// Destructor
	~CeleCfg()
	{
		Close();
	}

	// If you don't want to save config file, call SetDirty(FALSE) befor destructor
	inline VOID SetDirty(BOOL bDirty = TRUE)
	{
		m_bDirty = bDirty;
	}

	// Close config
	inline VOID Close()
	{
		Save();
		_SafeFree(m_pCfg);
	}

public:
	INT GetInt(PCTSTR ptzName, INT iDef = 0)
	{
		CeleCfgItem* pItem;
		PCTSTR ptzVal = Find(ptzName, pItem);
		if (!ptzVal)
		{
			return iDef;
		}

		pItem = pItem->GetNext();
		WORD wLen = pItem->wLen;
		pItem->wLen = 0;
		INT iVal = TStrToInt(ptzVal);
		pItem->wLen = wLen;
		return iVal;
	}

	BOOL SetInt(PCTSTR ptzName, INT iVal = 0)
	{
		TCHAR tzStr[16];
		TStrFromInt(tzStr, iVal);
		return SetStr(ptzName, tzStr);
	}

	PCTSTR GetStr(PCTSTR ptzName)
	{
		CeleCfgItem* pItem;
		return Find(ptzName, pItem);
	}

	UINT GetStr(PCTSTR ptzName, PTSTR ptzStr, UINT uLen = MAX_PATH, PCTSTR ptzDef = NULL)
	{
		CeleCfgItem* pItem;
		PCTSTR ptzVal = Find(ptzName, pItem);
		if (ptzVal)
		{
			if (uLen > pItem->wLen)
			{
				uLen = pItem->wLen;
			}
		}
		else
		{
			ptzVal = ptzDef ? ptzDef : TEXT("");
		}

		UINT i = 0;
		while ((i < uLen) && ptzVal[i])
		{
			ptzStr[i] = ptzVal[i];
			i++;
		}
		ptzStr[i] = 0;
		return i;
	}

	BOOL SetStr(PCTSTR ptzName, PCTSTR ptzStr = TEXT(""))
	{
		m_bDirty = TRUE;
		UINT uLen = TStrLen(ptzStr);

		CeleCfgItem* pItem;
		PTSTR ptzVal = Find(ptzName, pItem);
		if (ptzVal)
		{
			if ((WORD) (ptzVal - pItem->tStr) + uLen < pItem->wLen)
			{
				// Copy value directly
				while (*ptzStr) *ptzVal++ = *ptzStr++;
				/*if (uLen < pItem->wLen)*/ *ptzVal = 0;
				return TRUE;
			}
			pItem->SetDel();
		}

		// Space for name and '='
		uLen += TStrLen((PCTSTR) ptzName) + 1;

		UINT uFree = (UINT) ((PBYTE) m_pMax - (PBYTE) m_pEnd);
		UINT uNeed = uLen * sizeof(TCHAR) + sizeof(WORD) + 16;
		if (uNeed > uFree)
		{
			// Reallocate memory
			UINT uUse = (UINT) ((PBYTE) m_pEnd - (PBYTE) m_pCfg);
			UINT uMax = uUse + uNeed + m_uMemInc;
			CeleCfgItem* pCfg = (CeleCfgItem*) UMemRealloc(m_pCfg, uMax);
			if (pCfg)
			{
				m_pCfg = pCfg;
				m_pEnd = (CeleCfgItem*) ((PBYTE) pCfg + uUse);
				m_pMax = (CeleCfgItem*) ((PBYTE) pCfg + uMax);
			}
			else
			{
				return FALSE;
			}
		}

		if (!m_pCfg)
		{
			return FALSE;
		}

		// Copy string to tail
		ptzVal = m_pEnd->tStr;
		while (*ptzName) *ptzVal++ = *ptzName++;

		*ptzVal++ = '=';
		while (*ptzStr) *ptzVal++ = *ptzStr++;
		*ptzVal = 0;

		// Point to next
		m_pEnd->wLen = uLen + 1;
		m_pEnd = m_pEnd->GetNext();
		return TRUE;
	}

	BOOL GetVal(PCTSTR ptzName, PVOID pvData, UINT uSize)
	{
		CeleCfgItem* pItem;
		PTSTR ptzVal = Find(ptzName, pItem);
		if (!ptzVal)
		{
			return FALSE;
		}

		UINT i = 0;
		BYTE bCheckSum = 0;
		PTSTR ptzEnd = (PTSTR) pItem->GetNext();
		while (TRUE)
		{
			BYTE bVal = TChrToHex(ptzVal);
			ptzVal += 2;
			if (*ptzVal && (ptzVal < ptzEnd))
			{
				bCheckSum += bVal;
				if (i < uSize)
				{
					((PBYTE) pvData)[i++] = bVal;
				}
			}
			else
			{
				return (bCheckSum == bVal) && (i == uSize);
			}
		}
	}

	BOOL SetVal(PCTSTR ptzName, CONST VOID* pvData, UINT uSize)
	{
		PTSTR ptzStruct = (PTSTR) UMemAlloc(uSize * 2 * sizeof(TCHAR) + 16);
		if (!ptzStruct)
		{
			return FALSE;
		}

		BYTE bCheckSum = 0;
		PTSTR ptzDst = ptzStruct;
		for (PBYTE pbSrc = (PBYTE) pvData; uSize; uSize--)
		{
			BYTE bVal = *pbSrc++;
			bCheckSum += bVal;
			TChrFromHex(ptzDst, bVal);
			ptzDst += 2;
		}
		TChrFromHex(ptzDst, bCheckSum);
		ptzDst[2] = 0;
		BOOL bRet = SetStr(ptzName, ptzStruct);
		UMemFree(ptzStruct);
		return bRet;
	}

public:
	BOOL DelVal(PCTSTR ptzName)
	{
		CeleCfgItem* pItem;
		if (Find(ptzName, pItem))
		{
			pItem->SetDel();
			return TRUE;
		}
		return FALSE;
	}

public:
	// Load config file
	BOOL Load(PCTSTR ptzPath = NULL)
	{
		// Initialize
		Close();
		if (ptzPath)
		{
			TStrCopy(m_tzPath, ptzPath);
		}
		else
		{
			// Get default config file path
			UDirGetAppExt(m_tzPath, TEXT("ini"));
		}

		// Load config file
		HANDLE hFile = UFileOpen(m_tzPath, UFILE_READ);
		UINT uSize = hFile ? UFileGetSize(hFile) : 0;
		m_pCfg = (CeleCfgItem*) UMemAlloc(uSize + m_uMemInc + 16);
		if (hFile)
		{
			if (m_pCfg)
			{
				uSize = UFileRead(hFile, m_pCfg->tStr, uSize);
#ifdef _UNICODE
				if (m_pCfg->tStr[0] == 0xFEFF)
				{
					// Discard UNICODE BOM
					m_pCfg->tStr[0] = '\n';
				}
#endif
			}
			UFileClose(hFile);
		}

		// Initialize config buffer
		m_pEnd = m_pCfg;
		if (m_pCfg == NULL)
		{
			m_pMax = NULL;
			return FALSE;
		}

		// Build item chain
		PTSTR ptStr = m_pCfg->tStr;
		for (uSize /= sizeof(TCHAR); uSize; uSize--, ptStr++)
		{
#ifdef _UNICODE
			if (*ptStr == '\r')
			{
				*ptStr = 0;
			}
			else if (*ptStr == '\n')
#else
			if ((ptStr[0] == '\r') && (ptStr[1] == '\n'))
#endif
			{
				m_pEnd->wLen = (WORD) (ptStr - m_pEnd->tStr);
				m_pEnd = (CeleCfgItem*) ptStr;
			}
		}

		m_pEnd->wLen = (WORD) (ptStr - m_pEnd->tStr);
		if (m_pEnd->wLen)
		{
			m_pEnd = (CeleCfgItem*) ptStr;
		}
		m_pMax = (CeleCfgItem*) ((PBYTE) m_pEnd + m_uMemInc);
		return TRUE;
	}

	// Save config file
	BOOL Save()
	{
		if (!m_bDirty || !m_pCfg)
		{
			return TRUE;
		}

		// Open config file for write
		HANDLE hFile = UFileOpen(m_tzPath, UFILE_WRITE);
		if (!hFile)
		{
			return FALSE;
		}

#ifdef _UNICODE
		WORD wBOM = 0xFEFF;
		UFileWrite(hFile, &wBOM, 2);
#endif

		// Save config item
		for (CeleCfgItem* pItem = m_pCfg; pItem < m_pEnd; pItem = pItem->GetNext())
		{
			if (pItem->IsValid())
			{
				PCTSTR ptzStart = pItem->tStr;
				PTSTR ptzNext = (PTSTR) pItem->GetNext();

				// Write string
				PCTSTR ptzEnd = ptzStart;
				while ((ptzEnd < ptzNext) && *ptzEnd) ptzEnd++;
				if (ptzEnd != ptzStart)
				{
					UFileWrite(hFile, ptzStart, (UINT) (ptzEnd - ptzStart) * sizeof(TCHAR));
				}
				UFileWrite(hFile, TEXT("\r\n"), 2 * sizeof(TCHAR));
			}
		}
		UFileClose(hFile);
		m_bDirty = FALSE;
		return TRUE;
	}

	// Search item by name
	PTSTR Find(PCTSTR ptzName, CeleCfgItem*& pItem)
	{
		if (m_pCfg)
		{
			for (pItem = m_pCfg; pItem < m_pEnd; pItem = pItem->GetNext())
			{
				if (pItem->IsValid())
				{
					UINT i = 0;
					while (ptzName[i] == pItem->tStr[i]) i++;
					if ((ptzName[i] == 0) && (pItem->tStr[i] == '='))
					{
						return pItem->tStr + i + 1;
					}
				}
			}
		}
		return NULL;
	}
};
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
