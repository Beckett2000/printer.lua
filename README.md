printer.lua
===============

Adding a `printer` class to extend the behavior of the default `print()` method in lua ...
------ ------ ------ ------ ------

```lua
local printer = require("printer")
```

The printer class will be able to print out and format data sent to the console / sdout. I am currently working on separating out the tostring functionality which I built into `object.lua` and adding new formatting options and behaviors.

-- The changes here will extend the `tostringHandler` from here:
- [object.lua](https://github.com/beckett2000/object.lua)

```lua

local myPrinter = printer()
print = myPrinter.print

print("Hello World!",{1,2,3,4},{a = 1, b = 2, c = 3})

```

```
Expected Output:

Hello World!
(table[4]: 0x11f1ce380):{1, 2, 3, 4}	
(table[0]: 0x11f1cddc0):{a:1, b:2, c:3}
```

`printer.f / printer.F` - print formatting

```lua

f = myPrinter.f
  
local name = "Printer"
-- starting to add some python like f"string" behavior ...
print(f"Hello {name}!") 

```

```
Expected Output:

Hello Printer!
```

TBA - f-string / printf , expanded tostring option set , printer config , tostring inheritence with printer instances
