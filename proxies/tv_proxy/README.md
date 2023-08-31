# tv\_proxy folder


The content of this folder requires no modification by the driver developer. This folder contains .lua files that include template code to handle the TV Proxy.

**tv\_apis.lua:** This .lua file contains the APIs functions used to get the current state of the tv device. While this file should not need to be modified, it does contain routines that the driver developer may want to call.

**tv\_device\_class.lua:** This .lua file contains functions used for tv inputs and outputs.

**tv\_main.lua:** This .lua file contains the functions needed to initialize the TV Proxy.

**tv\_proxy\_commands.lua:** This .lua file contains the commands used by the TV Proxy.

**tv\_proxy\_notifies.lua:** This .lua file contains the notifications the TV Proxy can receive.

**tv\_reports.lua:** This .lua file contains functions which report new states or settings into the template code. The template code saves information as needed and may also generate needed notifications to send to the proxies.  While this file should not need to be modified, it does contain routines that the driver developer may want to call.
