#ifndef LuaVirtualMachine_h__
#define LuaVirtualMachine_h__
#pragma once
#include "LuaInclude.h"
class LuaVirtualMachine
{
public:
	LuaVirtualMachine(void);
	virtual ~LuaVirtualMachine(void);
	static void Panic (lua_State *lua);
	bool InitialiseVM(void);
	bool DestroyVM(void);
	//Load and run script elements
	bool RunFile(const char *strFileName);
	bool RunBuffer(const unsigned char *pBuffer, size_t nLen, const char *strName = NULL);
	bool CallFunction(int nArgs,int nReturns = 0);
	bool OK(){return m_bIsOK;}
	//Get the state of the lua stack
	operator lua_State *(void) {return m_pLuaState;}
	//bool RunFile()
protected:
	lua_State *m_pLuaState;
	bool m_bIsOK;
};

#endif // LuaVirtualMachine_h__
