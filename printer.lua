-------------------------------------------
-- printer.lua - 0.1 - (BD - 2025) - print formatting methods for Lua ...
---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

-- this class offers a collection of methods to expand the default print behavior in Lua

-------------------------------------------
-- if true then return end -- --- ---- -- 
-------------------------------------------

---- ---- ---- -- -- ---- ---- ---- --
local cat,unpack,insert,sort,iter,push = table.concat, unpack and unpack or table.unpack, table.insert, table.sort
---- ---- ---- -- -- ---- ---- ---- --
local _tostringHandlers,_isArray, _getKeyList, _timestamp, _escapeStr;
---- ---- ---- -- -- ---- ---- ---- --
local _print = print
---- ---- ---- -- -- ---- ---- ---- --

local printer = {}

---- ---- --- -- --- ---- ---- ---- --- -- 
-- ::default_deps:: -- default printer ...
---- ---- --- -- --- ---- ---- ---- --- -- 

-- class level - init for printer

printer.init = function(self)
  self:attach()
end

---- ---- ---- -- -- ---- ---- ---- --
-- handles creation of new printer instance

printer.new = function(super)
  
  super = super and super or printer
  
  self = {
   print = function(...)
      return super:print(...)
    end
  }
  
  setmetatable( self, 
   { __index = super,  __call = super.new })
  
  self:init()
  
  return self;
  
end
  
---- ---- --- -- --- ---- ---- 
-- handles behavior for printing (called in place of default print() function when attached)

printer.print = function(self,...)

  local out,len,arg,format = {}, select("#",...)
  
  local handlers = _tostringHandlers
  
  for i = 1, len do
    
   arg = select(i,...); format = type(arg)
    
   if type(arg) == "table" then  
    arg = _isArray(arg) and handlers.array(arg) or handlers.table(arg)    
   end
    
    insert(out,arg)
    
  end

  self._print(unpack(out,1,len))
  
end

---- ---- ---- -- -- ---- ---- ---- --



---- ---- ---- -- -- ---- ---- ---- --
-- F-string - python like f'someString'
---- ---- ---- -- -- ---- ---- ---- --

---- ---- ---- -- -- ---- ---- ---- --
local _isIdentifier, _findLocalUpvalue
---- ---- ---- -- -- ---- ---- ---- --
local _locals = nil
---- ---- ---- -- -- ---- ---- ---- --

-- This adds a printer.f method (case-insensitive) for lua which works similarly to python like F-string in lua.  

-- example: basic embedding 
-- -- local name = 'Bob'; print(f"Hello, {name}!") --> output: Hello, Bob!

---- ------ ----

printer.f = function(value)
  
  _locals = {}; local locals = _locals
  
  local sub = value:gsub("(%b{})",
  
  function(match) 

   local capture = match:sub(2,#match - 1)
   if _isIdentifier(capture) then

    local upvalue = _findLocalUpvalue(capture)
    return upvalue and 
      tostring(upvalue) or "" 
       
    else
     print(cat{_timestamp()," printer.lua: error, invalid formatter: '{",capture,"}' passed to printer.f for string: '",value,"' ..."})
    end; 
    
  end) _locals = nil; 

 return sub end

---- ---- ---- -- -- ---- ---- ---- --
printer.F = f ---- --- ---- --- --
---- ---- ---- -- -- ---- ---- ---- --

---- ---- --- -- --- ---- ---- 
-- helper: determines if a string name is a valid variable name in lua

_isIdentifier = function(name)
  if type(name) ~= "string" then 
  return false end
  return name:match("^[_%a][_%w]*$") 
end

---- ---- --- -- --- ---- ---- 
-- helper: creates iterator for vararg

_findLocalUpvalue = function(varName)
  
   local locals,idx,name,value = _locals,1,""
  
   while name do
    if locals[idx] then 
     name,value = locals[idx].name,locals[idx].value 
    else
     name,value = debug.getlocal(5,idx)
     locals[idx] = {
      name = name, value = value
     } end
     -- print("The name:",name)
    if name == varName then break end
      idx = idx + 1
    end 
    
    -- print("The capture:",capture,name,value)
   
    return value;
  
end

---- ---- ---- -- -- ---- ---- ---- --


---- ---- ---- -- -- ---- ---- ---- --

-- TODO - Make these register and unregister with a given print in an environment without manually needing to say print = myPrinter.print

printer.attach = function(self)
  self._print = print
end

printer.detach = function(self)
  
end

---- ---- --- -- --- ---- ---- 

-- TBD - Thinking about aome javascript behaviors ...

-- printer:preventDefault()
-- printer.handleDefault 


---- ---- --- -- --- ---- ---- ---- --- -- 
-- ::helpers:: -- default printer ...
---- ---- --- -- --- ---- ---- ---- --- -- 

---- ---- --- -- --- ---- ---- 
-- helper: creates iterator for vararg

iter = function(...)
  local args, i = {...}, 0 
  return function() i = i + 1;
    if i <= #args then return i, args[i] end
  return nil end
end -- returns: (function - iterator)

---- ---- --- -- --- ---- ---- 
-- helper: pushes values to the end of table

push = function(self,...)
  local insert,val = table.insert
  for i = 1, select("#",...) do
  val = select(i,...); insert(self,val) end
return obj end

---- ---- --- -- --- ---- ---- 
-- helper: determines if a data value is lua array in 

_isArray = function(self)
  
  if type(self) ~= "table" then 
  return false end
  
  local count,hasKeys,form = 0,false
  local index,value = next(self)
  
  while index do
    count,form = count + 1, type(index)
    if form ~= "number" then 
    hasKeys = true end
    index,value = next(self,index)
  end
  
  local missing = 0
  for i = 1,#self do
    if not self[i] then 
    missing = missing + 1 end
  end
  
  if hasKeys or missing and count > #self - missing or count > #self then return false 
  else return true end
  
end -- returns: (boolean) - true / false

---- ---- --- -- --- ---- ---- 
-- helper: gets a timestamp for logs

_timestamp = function()
  
  local t = os.date("*t")
  -- print("(os.date)",object.tostring(t))
  
  local formatNumber = function(val)
    local val = tostring(val)
    if string.len(val) == 1 then val = "0"..val
    end return val end
  local ft = formatNumber
  
  return cat {
    "(",ft(t.hour),":",ft(t.min),":",  ft(t.sec),")"
  } 
  
end --> (string) timestamp '(00:00:00)'

---- ---- --- -- --- ---- ---- 
-- helper: escapes magic characters in string

_escapeStr = function(str)
  str = str:gsub("[%(%)%.%%%+%-%*%?*[*^%$]",
  "%%%1"); return str
end --> returns: (string) escaped string


---- ---- --- -- --- ---- ---- 
-- helper: gets list of all keys and indexies in lua table

_getKeyList = function(tab)
  local keys,i,n = {}, next(tab)
  while(n) do
    insert(keys,i); i,n = next(tab,i)
  end sort(keys)
  return unpack(keys,1,#keys)
  
end --> returns vararg keys / indexies


---- ---- --- -- --- ---- ---- ---- --- -- 
-- ::tostring_helpers:: -- default printer ...
---- ---- --- -- --- ---- ---- ---- --- -- 

_tostringHandlers = {
  
 -- creates: header strings with access offset i.e. (table[#] 0x000):
  
 _tableHeader = function(self)
  local cat,meta = table.concat, getmetatable(self); setmetatable(self,nil)
  local str = cat{"(table[",#self,"]: ",tostring(self):match("0x%x+"),"):"}
  setmetatable(self,meta) 
 return str end,  

 -- handles: lua table with only array indexies
  
 array = function(self) 
  local cat,header = table.concat,
   _tostringHandlers._tableHeader
  local str = cat {
   header(self),"{",cat(self,", "),"}" };
 return str end,
  
 table = function(self)
  local cat,entries,header = table.concat,{},
   _tostringHandlers._tableHeader
  for i,key in iter(_getKeyList(self)) do
   insert(entries,cat{key,":",
    tostring(self[key])}) end
  local str = cat {
   header(self),"{",cat(entries,", "),"}" };
 return str end
  
}

---- ---- ---- -- -- ---- ---- ---- --
-- init meta for printer base class ...

setmetatable( printer, 
{ __call = printer.new })

---- ---- ---- -- -- ---- ---- ---- --
printer:init(); return printer ---- -->
---- ---- ---- -- -- ---- ---- ---- --

----- ----------- ----------- -----------  
-- {{ File End - printer.lua }}
----- ----------- ----------- -----------  