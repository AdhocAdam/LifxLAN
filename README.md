<h1 align="center">
  <br>
  <img width="400" src="lifxlan.png">
  <br>
    LifxLAN
  <br>
</h1>

## Overview

This is a module aimed at controlling Lifx devices on your LAN right from PowerShell. Cmdlets are not comprehensive in their control but pull requests are welcome!

## Available cmdlets

| Cmdlet                |    Purpose    |
| --------------------- | ----------- |
| Get-LifxDevice        | Discovers Lifx devices on the LAN. Returns IP/Port  |
| Initialize-LifxDevice | Obtains the device Name and Group of a device    |
| Get-LifxDevicePower   | Obtains the current power state of a device |
| Get-LifxDeviceSetting | Obtains the details of a device such as it's Lifx Identifier, Product Name, and capabilities such as Infrared, Multizone, and HEV support |
| Get-LifxDeviceColor   | Obtains the HSBK value of a device or HSBK values of its Zones.  |
| Get-LifxDeviceWifi    | Obtains the current wifi signal and strength of a device |
| Get-LifxProduct       | Returns a specific Lifx Product's capabilities |
| Set-LifxDevicePower   | Turns a device on or off |
| Set-LifxDeviceColor   | Defines the color of a device in: RGB + Saturation + Brightness, Kelvin + Brightness, White Palette as seen in the app, and finally all support an the time to takes to change in seconds. Can control individual devices and multizone devices |

## Getting Started

Install the module from the PowerShell Gallery by using the following at a PowerShell prompt

#### Installing on PowerShell versions 6+ (black background, downloaded from [Microsoft's PowerShell Github](https://github.com/PowerShell/PowerShell))
```powershell
Install-Module -Name LifxLAN -AllowPrerelease
```

#### Installing on Windows Powershell v5.1 (blue background/ships with Windows)
If you're installing on an older version of PowerShell, you might get an error that states "_A parameter cannot be found that matches parameter name 'allowprerelease'_". This is due to changes made in the PowerShellGet module updated in versions 6 onward. You'll need to update PowerShellGet first (as seen below) per [Microsoft documentation](https://learn.microsoft.com/en-us/powershell/gallery/powershellget/install-powershellget?view=powershellget-3.x&viewFallbackFrom=powershell-7.2) and then you'll be able to install the module.

```powershell
Install-Module PowerShellGet -Force -AllowClobber
Install-Module LifxLAN -AllowPrerelease
```

## Once installed, import the module for use in your current session
```powershell
Import-Module LifxLAN
```

## Discovering Lifx devices on your network

To begin to controlling lights on your LAN start a discovery with

```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
```

This returns a list of Lifx devices on your network by their IP Address, Name, and Group

## Get product details and firmware

```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
$devices | Get-LifxDeviceSetting
```

This updates devices with Product details [PSCustomObject] and Firmware Versions [Version] from a product list as defined [within the module itself](https://github.com/AdhocAdam/LifxLAN/blob/a69c49a277df546dbd11b89aa609d35b96c55a0e/Public/Product/Get-LifxProduct.ps1#L33). In the event product details are not defined in the module, they are retrieved from [LIFX's official GitHub repo (products.json)](https://github.com/LIFX/products). For example:

```powershell
#Example Product information
[PSCustomObject]@{
   [int]Id=91;
   [string]Name=LIFX Color;
   [bool]Color=True;
   [bool]Infrared=False;
   [bool]Multizone=False;
   [bool]HEV=False}

#Example Version
[Version]3.70
```

## Get device Wifi Signal and Strength

```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
$devices | Get-LifxDeviceWifi
```

## Controlling Power

The current power state of devices can be obtained/refreshed with:

```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
$devices | Get-LifxDevicePower
```

Devices can be turned on individually or through the pipeline

```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
$devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDevicePower -Power $true
```

or

```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
Set-LifxDevicePower -Device $devices[0] -Power $false
```

## Working with Color

Just like the app, the HSBK (Hue, Saturation, Brightness, Kelvin) can all be controlled independently. However to keep things simple, you can provide RGB values and the module will convert them to the required HSBK values.

- Hue is provided in degrees between 0-360
- Brightness/Saturdation are provided in terms of 0-100 percent, defaults to 0 if not provided.
- RGB 0-255, defaults to 0 if not provided.
- Kelvin 1000-12000

### Get-LifxDeviceColor
```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
$devices | Get-LifxDeviceColor
```

### Set-LifxDeviceColor via RGB

```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
$devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Red 200 -Blue 13 -Brightness 75 -Saturation 100
```

### Set-LifxDeviceColor via predefined white palette as seen in the app (supports tab complete)

```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
$devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Brightness 100 -White 'Sunset' -SecondsToTransition 1.5
```

### Set-LifxDeviceColor via white palette as defined in Kelvin range

```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
$devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Kelvin 7500 -Brightness 100
```

## Working with Extended Multizone Color, Get-LifxDeviceColor
LIFX Devices that support zones such as lightscripts, neon flex, string lights, etc. can be controlled as a single device or individual zones. Take the following example with a device named **Outdoor String**. First we discover all of the lifx devices on our network, initialize them (to get the name/groups), then get the device settings to ensure it has a property called "Product" that contains the ExtendedMultizone property of true

```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
$lightstring = $devices | ?{$_.Name -eq "Outdoor String"} | Get-LifxDeviceSetting
$lightstring.Product.ExtendedMultizone

true
```

We can now perform the following:

```powershell
$lightstring | Get-LifxDeviceColor
```

This will add introduce two properties to the device:

- Zones: Represents the total count of zones that can be controlled on the device
- Multizone: Array of Indexes/Colors that define what colors are located at each index/zone. It will look like the following

```powershell
Index Colors
----- ------
    0 {@{Color=0; Hue=0; Saturation=0; Brightness=100; Kelvin=3500}, @{Color=1; Hue=0; Saturation=0; Brightness=100; Kelvin=3500}, @{Color=2; Hue=0; Saturation=0; …
    8 {@{Color=0; Hue=0; Saturation=0; Brightness=100; Kelvin=3500}, @{Color=1; Hue=0; Saturation=0; Brightness=100; Kelvin=3500}, @{Color=2; Hue=0; Saturation=0; …
   16 {@{Color=0; Hue=0; Saturation=0; Brightness=100; Kelvin=3500}, @{Color=1; Hue=0; Saturation=0; Brightness=100; Kelvin=3500}, @{Color=2; Hue=0; Saturation=0; …
   24 {@{Color=0; Hue=0; Saturation=0; Brightness=100; Kelvin=3500}, @{Color=1; Hue=0; Saturation=0; Brightness=100; Kelvin=3500}, @{Color=2; Hue=0; Saturation=0; …
   32 {@{Color=0; Hue=0; Saturation=0; Brightness=100; Kelvin=3500}, @{Color=1; Hue=0; Saturation=0; Brightness=100; Kelvin=3500}, @{Color=2; Hue=0; Saturation=0; …
```

- Indexes occur in multiples of 8
- Each Index features Colors 0-7 that define an HSBK value
- The last index may _not_ be a full 8 colors, for example a Lifx Outdoor string has 36 Zones. The last zone only has the first 4 HSBK colors defined

## Working with Extended Multizone Color, Set-LifxDeviceColor

Controlling the color of an extended multizone device can be done one of two ways. Take the following example where $zoneColor1 and $zoneColor2 are used differently.
- $zoneColor1, RGB values are provided as values between 0-255, Saturation/Brightness are defined as value between 0-100
- $zoneColor2, the Hue value (0-360) is provided directly just like the app. Saturation/Brightness are defined as value between 0-100
- $zoneColor3 isn't used in this example, but is being provided as an example of how to control the Kelvin of a device. 

```powershell
$zoneColor1 = [PSCustomObject]@{
    "Red"        = 216
    "Green"      = 45
    "Blue"       = 231
    "Saturation" = 80
    "Brightness" = 70
}
$zoneColor2 = [PSCustomObject]@{
    "Hue"        = 105
    "Saturation" = 85
    "Brightness" = 90
}
$zoneColor3 = [PSCustomObject]@{
    "Kelvin"     = 7200
    "Brightness" = 65
}

#multi-zone device, set all of zones to the same value and transition in 2 seconds
$lightstring | Set-LifxDeviceColor -Zone $zoneColor1 -SecondsToTransition 2

#multi-zone device, set different colors for each zone starting at Zone 4
$lightstring | Set-LifxDeviceColor -zones $zoneColor1, $zoneColor2 -StartingZone 4
```

## Credits

This PowerShell module is made possible the following GitHub repositories and projects around controlling Lifx devices via .NET as well as examining Lifx packets over [Wireshark](https://www.wireshark.org/).

- [LifxNet](https://github.com/dotMorten/LifxNet)
- [LIFX-Control](https://github.com/PhilWheat/LIFX-Control)
- [WiresharkLIFXDissector](https://github.com/mab5vot9us9a/WiresharkLIFXDissector)

And of course Lifx documentation:

- [Querying the device for data](https://lan.developer.lifx.com/docs/querying-the-device-for-data)
- [Changing a device](https://lan.developer.lifx.com/docs/changing-a-device)
