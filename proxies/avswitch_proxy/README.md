# avswitch\_proxy folder


The content of this folder requires no modification by the driver developer. This folder contains .lua files that include template code to handle the AV Device proxy.

**avswitch\_apis.lua:** This .lua file contains the APIs functions used to get the current state of the AV device. While this file should not need to be modified, it does contain routines that the driver developer may want to call.

**avswitch\_device\_class.lua:** This .lua file contains functions used for Audio/Video input and output.

**avswitch\_main.lua:** This .lua file contains the functions needed to initialize the AV device’s proxy.

**avswitch\_proxy\_commands.lua:** This .lua file contains the commands used by the AV device’s proxy.

**avswitch\_proxy\_notifications.lua:** This .lua file contains the notifications the AV device’s proxy can receive.

**avswitch\_reports.lua:** This .lua file contains functions which report new states or settings into the template code. The template code saves information as needed and may also generate needed notifications to send to the proxies. While this file should not need to be modified, it does contain routines that the driver developer may want to call.
