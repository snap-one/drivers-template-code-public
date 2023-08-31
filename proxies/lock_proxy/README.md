# lock\_proxy folder


The content of this folder requires no modification by the driver developer. This folder contains .lua files that include template code to handle the Lock Proxy.

**lock\_apis.lua:** This .lua file contains the APIs functions used to get the current state of the lock device. While this file should not need to be modified, it does contain routines that the driver developer may want to call.

**lock\_custom\_settings.lua:** ...

**lock\_device\_class.lua:** This .lua file contains functions used for lock connections.

**lock\_history.lua:** ...

**lock\_main.lua:** This .lua file contains the functions needed to initialize the Lock Proxy.

**lock\_proxy\_commands.lua:** This .lua file contains the commands used by the Lock Proxy.

**lock\_proxy\_notifies.lua:** This .lua file contains the notifications the Lock Proxy can receive.

**lock\_reports.lua:** This .lua file contains functions which report new states or settings into the template code. The template code saves information as needed and may also generate needed notifications to send to the proxies. While this file should not need to be modified, it does contain routines that the driver developer may want to call.

**lock\_user\_info.lua:** ...
