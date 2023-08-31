---
--- Driver Declarations used to call startup routines, teardown routines, and
--- other basic functions of the drivers operation
---
--- Copyright 2017 Control4 Corporation. All Rights Reserved.
---

-- Template Version Table
TEMPLATE_VERSION = {}
TEMPLATE_VERSION.c4_driver_declarations = "2017.04.25"

-- Command Handler Tables

---@type fun(tParams: table)[]
EX_CMD = {}
---@type fun(idBinding: integer, tParams: table)[]
PRX_CMD = {}
---@type fun(tParams: table)[]
UI_REQ = {}
NOTIFY = {}
DEV_MSG = {}
---@type fun(tParams: table)[]
LUA_ACTION = {}
---@type fun(tParams: table)[]
PROG_CONDITIONAL = {}


--- Tables of functions
--- The following tables are function containers that are called within the
--- following functions:
---
---    OnDriverInit()
---        First calls all functions contained within ON_DRIVER_EARLY_INIT table
---        then calls all functions contained within ON_DRIVER_INIT table
---
---    OnDriverLateInit()
---        Calls all functions contained within ON_DRIVER_LATEINIT table
---
---    OnDriverDestroyed()
---        Calls all functions contained within ON_DRIVER_DESTROYED table
---
---    OnPropertyChanged()
---        Calls all functions contained within ON_PROPERTY_CHANGED table


---@type fun(strDit: string)[]
ON_DRIVER_INIT = {}
---@type fun(strDit: string)[]
ON_DRIVER_EARLY_INIT = {}
---@type fun(strDit: string)[]
ON_DRIVER_LATEINIT = {}
---@type fun(strDit: string)[]
ON_DRIVER_DESTROYED = {}
---@type fun(value: string)[]
ON_PROPERTY_CHANGED = {}

-- Constants
DEFAULT_PROXY_BINDINGID = 5001