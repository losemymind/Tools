------------------------------------------------------------------
-- ExcelTool.lua
-- Author     : libo
-- Version    : 1.0.0.0
-- Date       : 2011-08-05
-- Description: Lua²Ù×÷Excel
------------------------------------------------------------------

require("luacom")
local appExcel = luacom.CreateObject("Excel.Application")
appExcel.Visible = true
local workbook = appExcel.Workbooks:Add()
local worksheet = workbook.WorkSheets(1)

for row = 1,100 do
	worksheet.Cells(row,1).Value2 = math.floor(math.random()*20)
	worksheet.Cells(row,2).Value2 = worksheet.Cells(row,1).Value2
end
