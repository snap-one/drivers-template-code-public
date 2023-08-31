# common folder


The content of this folder requires no modification by the driver developer. This folder contains numerous .lua files which are required by Control4 drivers.

**c4\_avutils.lua:** ...

**c4\_bindings.lua:** This .lua file contains the API functions required to handle commands the driver receives through ExecuteCommand & ReceivedFromProxy.

**c4\_command.lua:** This .lua file contains the API functions required to handle commands the driver receives through ExecuteCommand & ReceivedFromProxy.

**c4\_common.lua:** This .lua file contains common helper functions used by Control4 drivers.

**c4\_conditional.lua:** This .lua file contains functions used by Control4 drivers to handle driver Conditionals.

**c4\_diagnostics.lua:** This .lua file contains functions used for testing the environment.

**c4\_driver\_declarations.lua:** This .lua file contains Common Driver Declarations.

**c4\_init.lua:** This .lua file contains the API functions required to handle calls the driver receives during its initialization. This includes OnDriverInit, OnDriverLateInit & OnDriverDestroyed.

**c4\_notify.lua:** This .lua file contains helper functions for sending Notifications.

**c4\_property.lua:** This .lua file contains the API function that is called when a property changes.

**c4\_utils.lua:** This .lua file contains utility functions that assist with handling binary code, parsing string, table management, etc.
