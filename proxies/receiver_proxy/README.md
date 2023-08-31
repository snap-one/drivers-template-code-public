# receiver\_proxy folder


The content of this folder requires no modification by the driver developer. This folder contains .lua files that include template code to handle the Receiver Proxy.

**receiver\_apis.lua:** This .lua file contains the APIs functions used to get the current state of the receiver device. While this file should not need to be modified, it does contain routines that the driver developer may want to call.

**receiver\_device\_class.lua:** This .lua file contains functions used for the receiver's input and output.

**receiver\_main.lua:** This .lua file contains the functions needed to initialize the Receiver Proxy.

**receiver\_proxy\_commands.lua:** This .lua file contains the commands used by the Receiver Proxy.

**receiver\_proxy\_notifies.lua:** This .lua file contains the notifications the Receiver Proxy can receive.

**receiver\_reports.lua:** This .lua file contains functions which report new states or settings into the template code. The template code saves information as needed and may also generate needed notifications to send to the proxies. While this file should not need to be modified, it does contain routines that the driver developer may want to call.
