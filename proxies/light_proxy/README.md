# Light Driver Template

The LightV2 Proxy Template supports the following proxy features:

- Advanced Lighting Scenes
- Load groups
- Top, Bottom and Toggle Button Actions
- Top, Bottom and Toggle BUTTON_LINK connections
- Color and Tunable White supports
- Default On and Dimm Colors
- Warm Dimming


## Contents of this Control4 Light Driver Template

This section provides a definition for the directories and files that are delivered within a Control4 Driver Template which **require no modification** at all by the driver developer. The folders which contain these files are designated in this document with a note of “Requires No Modification”.

**light_proxy Folder**: The content of this folder requires no modification by the driver developer. This folder contains .lua files that include template code to handle the light proxy.

light\_apis.lua - This .lua file contains the APIs functions that enable template functionality that will automatically handle specific lightv2 proxy features. While this file should not need to be modified, it does contain routines that the driver developer may want to call.

light\_device\_class.lua - This .lua file contains functions that are meant to be private to the class.

light\_main.lua - This .lua file contains the functions needed to initialize the light proxy.

light\_proxy\_commands.lua - This .lua file contains the commands used by the light proxy.

light\_proxy\_notifies.lua - This .lua file contains the notifications the light proxy can receive.

light\_reports.lua - This .lua file contains functions which report new states or settings into the template code. The template code saves information as needed and may also generate needed notifications to send to the proxies. While this file should not need to be modified, it does contain routines that the driver developer may want to call.

This section provides a definition of the files that are delivered within a Control4 Driver Template that **require modification** by the driver developer.

modify/light\_communicator.lua - .lua file containing source code of communication hooks for the lightv2 template code. After the template code receives messages and/or commands from the system, it will call specific routines in this file. The driver developer should fill in the appropriate calls to execute the needed actions on the specific target device.


## Getting Started

This section provides steps needed to setup the driver to use the light proxy template.


### Copy `light_communicator.lua`

Copy the `light_communicator.lua` file to driver's source directory.

```sh
cp <drivers-template-code>/proxies/light_proxy/modify/light_communicator.lua <driver's source dir>
```

## Add the light proxy template files to squishy

```
Module "light_proxy.light_apis" "lib/proxies/light_proxy/light_apis.lua"
Module "light_proxy.light_device_class" "lib/proxies/light_proxy/light_device_class.lua"
Module "light_proxy.light_main" "lib/proxies/light_proxy/light_main.lua"
Module "light_proxy.light_proxy_commands" "lib/proxies/light_proxy/light_proxy_commands.lua"
Module "light_proxy.light_proxy_notifies" "lib/proxies/light_proxy/light_proxy_notifies.lua"
Module "light_proxy.light_reports" "lib/proxies/light_proxy/light_reports.lua"

Module "light_communicator" "light_communicator.lua"
```


## Include light proxy main file to driver's main file

```lua
require "light_proxy.light_main"
```


## Specify the light proxy binding id

Specify the light proxy binding id as defined in the driver.xml.

```lua
LIGHT_PROXY_BINDINGID = 5001
```


## Specify the BUTTON_LINK binding id base

```lua
LIGHT_PROXY_BUTTON_LINK_BINDINGID_BASE = 200
```


## Configure the light template

Use the function in the [light_apis.lua](./light_apis.lua) to enable template's built-in functionality that will automatically handle specific lightv2 proxy features.


### SetTypeDimmer Light device type

Use the `SetTypeDimmer` function to designate if the driver will control a switch or a dimmable light.

### Automatically handle ON, OFF and TOGGLE commands

By setting `SetAutoSwitch(true)`, the template will automatically handle ON, OFF and TOGGLE commands and call appropriate LightCom function. This allows driver developers not to handle these commands, but to implement turning the light on and off in a single place. The LightCom function that will be called depends if the driver supports color and the new `supports_target` API.

| supports_target | Color support | LightCom function |
| --------------- | --------------| ----------------- |
| true | false | LightCom_SetBrightnessTarget       |
| true | true | LightCom_SetBrightnessTarget<br/>LightCom_RampToColorAndBrightnessTarget |
| false | false | LightCom_SetLevel |
| false | true | LightCom_SetBrightnessTarget<br/>LightCom_RampToColorAndBrightnessTarget |

If this functionality is disabled, `LightCom_On`, `LightCom_Off` and `LightCom_Toggle` will be called.


### Automatically handle BUTTON_ACTION commands

By setting `SetAutoButton(true)`, the template will automatically handle all BUTTON_ACTION commands and call appropriate LightCom function.

| Action | LightCom function |
| --------------- | --------------|
| Click |  LightCom_SetBrightnessTarget or LightCom_RampToColorAndBrightnessTarget |
| Press/Release |  LightCom_StartRampDimming/LightCom_RampStop |

If this functionality is disabled, `LightCom_ButtonAction` will be called and driver developers can manually handle BUTTON_ACTION commands.


### Automatically handle Advanced Lighting Scenes

By setting `SetAutoAls(true)`, the template will automatically handle Advanced Lighting Scene commands (scene membership, execution, ramping and flashing scenes). When a scene is activated, template create timers and call LightCom hooks depending on the scene elements and light capabilities: `LightCom_SetBrightnessTarget`, `LightCom_SetColorTarget`, `LightCom_RampToColorAndBrightnessTarget`.

For scene ramping, template will call `LightCom_StartRampDimming` and `LightCom_RampStop` hooks.

If this functionality is disabled, developers can handle scene commands by implementing scene LightCom hooks.


### Automatically handle Load Groups

By setting `SetAutoGroup(true)`, the template will keep track of load group membership and sync groups. If this functionallity is disabled, developers can track load group membership by implementing `LightCom_JoinGroup`, `LightCom_LeaveGroup` and `LightCom_SetGroupSync`.

By setting `SetAutoGroupCommnads(true)`, the template will automatically handle load group proxy commands and redirect them to `LightCom_SetBrightnessTarget`, `LightCom_StartRampDimming` and `LightCom_RampStop`. If this functionallity is disabled, developers can handle load group commands by implementing `LightCom_GroupRampToLevel`, `LightCom_GroupSetLevel`, `LightCom_GroupStartRamp`, `LightCom_GroupStopRamp`.


### Automatically handle Warm Dim feature for tunable white lights

Warm Dimming feature can be enabled tunable-white capable lights. When warm dimming is turned on, a change to the light’s brightness level will automatically change the color temperature of the light.

The Light template can automatically handle warm dimming feature by calling the `SetWarmDimming(true)` API. If warm dimming is enabled, the template will change the color temperature of the light with brightness change. Target color temperature is calculated as a linear function of brightness `CCT = k*brightness + n`, where k and n parameters are calculated by the template based on the Default On Brightness, On and Dimm Color. When brightness change occurs, `LightCom_RampToColorAndBrightnessTarget` hook will be called with color temperature passed as x, y function argument calculated automatically by the template.
