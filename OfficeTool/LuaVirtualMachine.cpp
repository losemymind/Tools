
#include "LuaVirtualMachine.h"
#include <assert.h>
#include <memory.h>
static int PrintMessage(lua_State *lua)
{
	assert(lua_isstring(lua,1));
	const char *msg = lua_tostring(lua,1);
	lua_Debug LuaDebug;
	memset(&LuaDebug,0,sizeof(LuaDebug));
	lua_getstack(lua,1,&LuaDebug);
	lua_getinfo(lua,"Snl",&LuaDebug);
	const char *strOut = LuaDebug.source;
	printf("script:%s -- at %s(%d)\n",msg,strOut,LuaDebug.currentline);
	return 0;
}

LuaVirtualMachine::LuaVirtualMachine(void):m_pLuaState(NULL),
																	m_bIsOK(false)
{}

LuaVirtualMachine::~LuaVirtualMachine(void)
{
	if (m_pLuaState != NULL)
	{
		lua_close(m_pLuaState);
	}
}

bool LuaVirtualMachine::InitialiseVM( void )
{
	if (OK()) DestroyVM();
	m_pLuaState = lua_open();
	if (m_pLuaState)
	{
		m_bIsOK = true;
		//Load util libs into lua
		luaopen_base(m_pLuaState);
		luaopen_table(m_pLuaState);
		luaopen_io (m_pLuaState);
		luaopen_os(m_pLuaState);
		luaopen_string(m_pLuaState);
		luaopen_math (m_pLuaState);
		luaopen_debug (m_pLuaState);
		luaopen_package(m_pLuaState);
		luaL_openlibs(m_pLuaState);

		//setup global printing(trace)
		lua_pushcclosure(m_pLuaState,PrintMessage,0);
		lua_setglobal(m_pLuaState,"trace");
		lua_atpanic(m_pLuaState,(lua_CFunction)LuaVirtualMachine::Panic);
		return true;
	}
	return true;
}

void LuaVirtualMachine::Panic( lua_State *lua ){}

bool LuaVirtualMachine::DestroyVM( void )
{
	if (m_pLuaState)
	{
		lua_close(m_pLuaState);
		m_pLuaState = NULL;
		m_bIsOK = false;
	}
	return true;
}

bool LuaVirtualMachine::RunFile( const char *strFileName )
{
	bool bSuccess = false;
	int nErrorCode = 0;
	if ((nErrorCode = luaL_loadfile(m_pLuaState,strFileName)) == 0)
	{
		//Call main...
		if ((nErrorCode = lua_pcall(m_pLuaState,0,LUA_MULTRET,0)) == 0)
		{
			bSuccess = true;
		}
	}
	return bSuccess;
}

bool LuaVirtualMachine::RunBuffer( const unsigned char *pBuffer, size_t nLen, const char *strName /*= NULL*/ )
{
	bool bSuccess = false;
	int iErr = 0;
	if(strName == NULL)
	{
		strName ="Temp";
	}
	if((iErr = luaL_loadbuffer(m_pLuaState,(const char *)pBuffer,nLen,strName)) == 0)
	{
		//Call main
		if ((iErr = lua_pcall(m_pLuaState,0,LUA_MULTRET,0)) == 0)
		{
			bSuccess = true;
		}
	}
	if (bSuccess == false)
	{
	//错误处理
	}
	return bSuccess;
}

bool LuaVirtualMachine::CallFunction( int nArgs,int nReturns /*= 0*/ )
{
	bool bSuccess = false;
	if (lua_isfunction(m_pLuaState,-nArgs -1))
	{
		int iErr = 0;
		if ((iErr = lua_pcall(m_pLuaState,nArgs,nReturns,0))==0)
		{
			bSuccess = true;
		}
		else
		{
			//错误处理
		}
	}
	return bSuccess;
}

