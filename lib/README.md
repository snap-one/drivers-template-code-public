# lib folder


The content of this folder requires no modification by the driver developer. This folder contains several libraries provided by Control4 that a driver may or may not use.

**c4\_dev\_log.lua:** ....

**c4\_log.lua:** Control4 driver templates use this library for logging. It includes code to support items such as log naming conventions, logging levels & enabling/disabling logging.

**c4\_object.lua:** This .lua file is a base class file that defies the class/object structure. It contains the InheritFrom function used by any class defined in the driver.

**c4\_proxybase.lua:** This .lua file is a base file that initializes the proxy.

**c4\_queue.lua:** This .lua file is a class used to manage a queue. The class handles moving data into and out of the queue for the driver.

**c4\_timer.lua:** This .lua file is a class used to manage timers.

**c4\_xml.lua:** This .lua file contains helper functions associated with parsing and managing the driver’s XML.

