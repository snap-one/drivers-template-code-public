# satellite\_proxy folder


The content of this folder requires no modification by the driver developer. This folder contains .lua files that include template code to handle the Satellite Receiver Proxy.

**satellite\_apis.lua:** This .lua file contains the APIs functions used to get the current state of the satellite receiver device. While this file should not need to be modified, it does contain routines that the driver developer may want to call.

**satellite\_device\_class.lua:** This .lua file contains functions used for Satellite receiver's input and output.

**satellite\_main.lua:** This .lua file contains the functions needed to initialize the Satellite Receiver Proxy.

**satellite\_proxy\_commands.lua:** This .lua file contains the commands used by the Satellite Receiver Proxy.

**satellite\_proxy\_notifies.lua:** This .lua file contains the notifications the Satellite Receiver Proxy can receive.

**satellite\_reports.lua:** This .lua file contains functions which report new states or settings into the template code. The template code saves information as needed and may also generate needed notifications to send to the proxies. While this file should not need to be modified, it does contain routines that the driver developer may want to call.
