printer.lua
===============

Adding a `printer` class to extend the behavior of the default `print()` method in lua ...
------ ------ ------ ------ ------

```lua
local printer = require("printer")
```

The printer class will be able to print out and format data sent to the console / sdout. I am currently working on separating out the tostring functionality which I built into `object.lua` and adding new formatting options and behaviors.

```lua

  local myPrinter = printer()
  print = myPrinter.print
  
  print("Hello World!",{1,2,3,4},{a = 1, b = 2, c = 3})

```

```
Expected Output:

Hello World!	(table[4]: 0x11f1ce380):{1, 2, 3, 4}	(table[0]: 0x11f1cddc0):{a:1, b:2, c:3}

```

TBA - print formatting, pretty print, print options
