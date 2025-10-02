-------------------------------------------
-- printer.lua - 0.1 - (BD - 2025) - print formatting methods for Lua ...
---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

-- this class offers a collection of methods to expand the default print behavior in Lua and add print formatting ...

-------------------------------------------
-- if true then return end -- --- ---- -- 
-------------------------------------------

-------------------------------------------
---- ---- ---- -- -- ---- ---- ---- --
local cat,unpack,insert,sort,load = table.concat, unpack and unpack or table.unpack, table.insert, table.sort, load and load or loadstring
---- ---- ---- -- -- ---- ---- ---- --
local floor,abs,round = math.floor, math.abs
---- ---- ---- -- -- ---- ---- ---- --
local iter,push,copy;
---- ---- ---- -- -- ---- ---- ---- --
-------------------------------------------

---- ---- ---- -- -- ---- ---- ---- --
local _tostringHandlers, _handleToString
local _isArray, _listKeys, _timestamp, _escapeStr;
---- ---- ---- -- -- ---- ---- ---- --

---- ---- ---- -- -- ---- ---- ---- --
local _print, _tostring = print, tostring
---- ---- ---- -- -- ---- ---- ---- --

-------------------------------------- --- >>

---- ---- --- -- --- ---- ---- ---- --- -- 
-- ::defaults:: - settings for string gen. 
---- ---- --- -- --- ---- ---- ---- --- -- 

-- Change this to control how printer.print shows data by default or printer.tostring converts data to a string with no options ...

-- TBA - more options / accepted values (see below for accepted types

local _tostringSettings = {
  
  style =  "inline", -- "vertical"
  spacer = " ", -- indent space i.e. "\t"
  depth = 1, -- nested table depth
  
  -- maybe add these options later?   
  -- layout: -- padding:
  
  ----- ----- ----- ----- ----- -----
  -- (table[len]: offset) - header disp. 
  
  offsets = true, -- show offsets 0x0000
  lengths = true, -- show lengths table[2]   
  
  ----- ----- ----- ----- ----- -----
  
}

---- ---- --- -- --- ---- ---- ---- --- -- 

-------------------------------------- --- >>

---- ---- --- -- --- ---- ---- ---- --- -- 
-- ::class_methods:: -- default printer ...
---- ---- --- -- --- ---- ---- ---- --- -- 

local printer = {} -- print class base object

---- ---- ---- -- -- ---- ---- ---- --
-- printer.init() -- Initializes printer class after object creation - WIP
---- ---- ---- -- -- ---- ---- ---- --

printer.init = function(self)
  self:attach()
end

---- ---- ---- -- -- ---- ---- ---- --
-- printer.print(...) -- handles creation of new printer class instance
---- ---- ---- -- -- ---- ---- ---- --

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

---- ---- ---- -- -- ---- ---- ---- --
-- printer.print(...)
---- ---- ---- -- -- ---- ---- ---- --

-- handles behavior for printing (called in place of default print() function when attached)

printer.print = function(self,...)

  local out,len,arg,format = {}, select("#",...)
  
  for i = 1, len do
   arg = select(i,...); 
   insert(out,self.tostring(arg))
  end

  self._print(unpack(out,1,len))
  
end

---- ---- ---- -- -- ---- ---- ---- --
-- printer.tostring(value,opt)
---- ---- ---- -- -- ---- ---- ---- --

-- converts a lua value into a string output with given options (note: some of this logic may live outside of tostring in the future)

-- Holds accepted data types for tostring options argument:

local _stringOptData = { ------ ------ ----
  
  -- show offsets --> table: 0x311d85a00
  offsets = "boolean", -- true|false
  ------ ----- -------- ---- -----    
  -- show lengths --> table[3]: {a,b,c}  
  lengths = "boolean", -- true|false
  ------ ----- -------- ---- -----   
  -- show sub tables --> {a,b,c,{d,e}}
  depth = "number", -- (0 -> math.huge)
  -- <----- <----- <----- <----- <---
  -----> -----> -----> -----> ----->
  -- [pretty print] --> style name    
  style = "string", -- 'vertical'|'block' 
  ------ ----- -------- ---- -----   
  -- [pretty print] --> spacer string        
  spacer = "string" -- "\t"," ",etc.
  
} ------ ------ ------
---------- ---------- ---------- ------

-- The :tostring function can take an optional second argument which is passed to the toStringHandler to provide more printing options / formats.

printer.tostring = function(value,opt)

  if true then 
   return _handleToString(value,opt)
  end
  
  --[[
  local isArray,isTable = false,false
  local handlers = _tostringHandlers

  if type(value) == "table" then  
   if _isArray(value) then isArray = true;
    value = handlers.array(value,opt)
   else isTable = true 
    value = handlers.table(value,opt)     
  end end ]]
    
 return value -- returns: (string) 

end

-------------------------------------- --- >>

---- ---- ---- -- -- ---- ---- ---- --
-- F-string - python like f'someString'
---- ---- ---- -- -- ---- ---- ---- --

---- ---- ---- -- -- ---- ---- ---- --
local _isIdentifier, _findLocalUpvalue
---- ---- ---- -- -- ---- ---- ---- --
local _locals, _eval = nil
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
    
   -- attempts to load expression 
   local out = _eval(capture)
   if out then return tostring(out) end

   print(cat{_timestamp()," printer.lua: error, invalid formatter: '{",capture,"}' passed to printer.f for string: '",value,"' ..."});
    
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
-- helper: attempts to evaluate identifier or expression 

_eval = function(str)
  if _isIdentifier(str) then
   return _findLocalUpvalue(str)

--[[

 -- TODO - evaluate expression i.e. a + b + c
  
 else  
  local out = load(cat{"return function() return "..expression," end"})()
  print("out:",out)    
]]
  
 end return
end -- returns: (string) output of load()

---- ---- --- -- --- ---- ---- 
-- helper: finds a local upvalue (debug)

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
-------------------------------------- --- >>
---- ---- ---- -- -- ---- ---- ---- --

-- TODO - Make these register and unregister with a given print in an environment without manually needing to say print = myPrinter.print

printer.attach = function(self)
  self._print = print
end

printer.detach = function(self)
  
end

---- ---- --- -- --- ---- ---- 
-------------------------------------- --- >>

---- ---- --- -- --- ---- ---- ---- --- -- 
-- ::helpers:: - utility helpers for printer 
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

push = function(obj,...)
  local insert,val = table.insert
  for i = 1, select("#",...) do
  val = select(i,...); insert(obj,val) end
return obj end

---- ---- --- -- --- ---- ---- 
-- helper: rounds floating point number to a given number of decimal places

round = function(float,dps)
  local mult = 10 ^ (dps or 0)
  return (float * mult) % 1 >= 0.5 and ceil(float * mult)/mult or 
  floor(float * mult)/mult
end

---- ---- --- -- --- ---- ---- 
-- helper: creates a copy of a table value to a given depth. Depths beyond a certain level or circular references are passed as pointers

-- depth: (number|string) 
-- - string - '*' - deep copy
-- - number - depth (default:1)

copy = function(self,depth,temps) 
  
  ----- --- ----- --- ----- --- ----- 
  
  if not self or depth == 0 or type(self) ~= "table" then return self end
  
  if not depth then depth = 1
  elseif depth == "*" then
   depth = math.huge end
  
  ----- --- ----- --- ----- --- ----- 
  
  local copy = {}
  
  if temps == nil then 
    temps = {[self] = copy} end
  
  for k,v in pairs(self) do 
    
    local value,type = self[k],type(v)
    if type == "string" or type == "number" 
    or type == "boolean" or type == "function" then copy[k] = v 
      
    elseif type == "table" then
      if depth == 1 then copy[k] = v
      elseif temps[v] then copy[k] = temps[v]
      else temps[v] = _copy(v, depth - 1, temps); copy[k] = temps[v]
      end end end
  
  return copy 
  
end -- returns: (table/value) - copy of value

---- ---- --- -- --- ---- ---- 
-- helper: determines if a lua table only has indecies or has table keys ...

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

_listKeys = function(tab)
  local keys,i,n = {}, next(tab)
  while(n) do
    insert(keys,i); i,n = next(tab,i)
  end sort(keys)
  return unpack(keys,1,#keys)
  
end --> returns vararg keys / indexies


-------------------------------------- --- >>

---- ---- --- -- --- ---- ---- ---- --- -- 
-- ::tostring_helpers:: -- default printer ...
---- ---- --- -- --- ---- ---- ---- --- -- 

_tostringHandlers = {
  
 -- creates: header strings with access offset i.e. (table[#] 0x000000):
  
 _tableHeader = function(self,opt)
    
  local cat,meta = table.concat, getmetatable(self); setmetatable(self,nil);
  local settings = _tostringSettings
  
  -- defaults for header style ...
  opt = opt and opt or {
    lengths = settings.lengths, 
    offsets = settings.offsets
  }
    
  local len = opt and opt.lengths and cat{"[",#self,"]"} or "";
  local offset = opt and opt.offsets and tostring(self):match("0x%x+") or ""
  local spacer = opt.lengths and opt.offsets and ": " or "";
    
  local str = cat{"(table",len,spacer,
    offset,"):"}
    
  setmetatable(self,meta);
    
 return str end,  

 -- handles: lua table with only array indexies
  
 array = function(self,opt) 
  local cat,header = table.concat,
   _tostringHandlers._tableHeader
  local values = {} for i = 1, #self do
   insert(values,tostring(self,opt)) end
  local str = cat {
   header(self),"{",cat(values,", "),"}" };
 return str end,
  
 table = function(self,opt)
  local cat,entries,header = table.concat,{},
   _tostringHandlers._tableHeader
  for i,key in iter(_listKeys(self)) do
   insert(entries,cat{key,":", tostring(self[key])}) end
  local str = cat {
   header(self),"{",cat(entries,", "),"}" };
 return str end
  
}

-------------------------------------- --- >>

------------ ------------ ------------ 
-- _handleToString - converts data values (namely tables) to readable strings

-- TBA - note (10/2/25) - the handleToString behavior was adapded from 'object' and adds in print formatting for the printer.tostring method such as spacing and indentation, but is going to be expanded to have more options and more easily accessable properties.  

-- fix some character displays for nested tables !!

_handleToString = function(val,opt)
  
  -- string printing options to toString
  if opt == "vertical" or opt == "v" then
    opt = copy(_tostringSettings)
    opt.style = "vertical"
  end
  
  -- certain types are passed through to tostring unchanged

  local _type = type(val)
  if _type == "string" then return val
  elseif _type == "boolean" or _type == "number" or _type == "nil" then
   return tostring(val)     
  end
  
  local handleStr = _handleToString
  local settings = copy(_tostringSettings)
  
  ---- --- ---- --- ---- --- ----
  -- options to the tostringHandler
  
  if not settings.data then 
    settings.data = {}
  end
  
  settings.data.indents = 1
  settings.data.nested = false
  
  ---- --- ---- --- ---- --- ----
  
  if _type == "table" then
   local meta = getmetatable(self)
   if meta and meta.__tostring and not opt then  return tostring(self) end
  end
  
  ---- --- ---- --- ---- --- ----
  -- [opt] - passed in options 
  
  if opt and _type == "table" then
    
    if opt.offsets ~= nil and type(opt.offsets) == "boolean" then
    settings.offsets = opt.offsets end
    if opt.lengths ~= nil and type(opt.lengths) == "boolean" then
    settings.lengths = opt.lengths end
    
    settings.depth = opt.depth and type(opt.depth) == "number" and floor(abs(opt.depth)) or settings.depth
    
    settings.style = opt.style and (opt.style == "block" or opt.style == "vertical" or opt.style == "v") and opt.style or settings.style
    
    settings.spacer = opt.spacer and type(opt.spacer) == "string" and opt.spacer or settings.spacer
    
   end
    
   ---- --- ---- --- ---- --- ----
   -- [opt.data] - recursive call data
    
   if opt and opt.data then
      
    local indents = opt.data.indents
    if indents then
     settings.data.indents =     
      round(abs(opt.data.indents))
    end
      
    settings.data.nested = opt.data.nested      
      
   end   
  
  ---- --- ---- --- ---- --- ----
  -- settings to use for string gen.
  
  local style = settings.style
  local spacer = settings.spacer 

  ---- --- ---- --- ---- --- ----
  
  local useOffsets = settings.offsets
  local depth = settings.depth
  local override = settings.override
  
  local indents = settings.data.indents
  local nested = settings.data.nested
  
  ---- --- ---- --- ---- --- ----
  -- built tostring handlers for data types ...
  
  local handlers = _tostringHandlers
  local tableName = handlers._tableHeader
  
  ---- --- ---- --- ---- --- ----
  local descriptor = tableName(val,settings)
  ---- --- ---- --- ---- --- ----
  
  ---- --- ---- --- ---- --- ----
  -- (depth) data value stringification
  -- adds string data for leveles of nested tables. Defalts to level 1
  
  if depth == 0 then
    return cat{descriptor,")"}
  end
  
  ---- --- ---- --- ---- --- ----
  -- (sort) - sort the list of indexies / keys for the tosteing display
  
  local list = {string = {}, number = {}, table = {}, ["function"] = {}}
  
  local valueType
  for key,val in pairs(val) do
    if val then 
     insert(list[type(key)],key)
    end end
  
  local index = 1
  while index <= #val do
    if list.number[index] ~= index then
      insert(list.number,index,index)
    end index = index + 1
  end
  
  sort(list.string); sort(list.number)
  
  local sortList
  sortList = function(key)
    for i = 1, #list[key] do
      insert(list,list[key][i])     
    end list[key] = nil
    return sortList
  end
  
  ---- --- ---- --- ---- --- ----
  
  sortList("number")("string")("table")("function") --> list: index/key order
  
  ---- --- ---- --- ---- --- ----
  
  local entries = {}
  
  for i = 1,#list do 
    
    local key,val = list[i],val[list[i]]
    formatK,formatV = type(key),type(val)  
    key,notation = formatK == "number" and key < 10 and "0"..key or key
    
    if formatV == "table" then
     meta = getmetatable(val) end
    
    ---- --- ---- --- ---- --- ----
    -- (sub level) table entry notation
    
    -- shows function() pointers  
    if formatV == "function" then
      notation = useOffsets and tostring(val) or type(val)
      value = cat{"(",notation,")"}
      
    -- shows {table} / {object} pointers
    elseif formatV == "table" then
      
      if depth <= 1 then
        value = cat{"(", tableName(val,settings),")"}
        
      else -- shows {sub tables} (level > 1)
        
        local options = copy(settings) 
        options.depth = depth + 1
        options.data.indents = indents + 1   
        options.data.nested = true 
        value = handleStr(val,options)   
          
    end
      
    -- annotate "strings"
    elseif formatV == "string" then value = cat{'"',val,'"'} else value = tostring(val) end 
    
    ---- --- ---- --- ---- --- ----
    
    local padding = {}
    
    if style == "vertical" or 
      style == "v" then 
      
       push(padding,"\n",spacer)
      for i = 1,indents do
       push(padding,spacer) end
    end
    
    -- formats key / index display    
    local keyForm = {cat(padding)}
    
    if formatK == "number" then 
      push(keyForm,tostring(key))
      
    elseif formatK == "function" then
      local str = useOffsets and tostring(key) or type(key)
      push(keyForm,'[(',str,')]')
      
    elseif formatK == "table" then 
      local str = tableName(key,settings)
      push(keyForm,'[(',str,')]')    
      
    elseif formatK == "string" then
      local varName = "^[%a_][%w_]*$"
      if key:match(varName) then
       push(keyForm,key)  
      else push(keyForm,'["',key,'"]') end
      
    else keyForm:push(tostring(key)) end
     push(keyForm,":",value,"")  
    
    -- shows [key:value] pairs  
    local notation = cat(keyForm)
     insert(entries,notation)    
    
  end
  
  ---- --- ---- --- ---- --- ----
  -- output: to tostring
  
  local padding = {}
  
  if style == "vertical" or style == "v" then 
    push(padding,"\n")
    if nested then for i = 1,indents do
     push(padding,spacer) end end
  end
  
  return cat{descriptor,"{", cat(entries,", "), cat(padding), "}"}
  
  ---- --- ---- --- ---- --- ----
  
end --> returns: serial descriptor string

-------------------------------------- --- >>

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