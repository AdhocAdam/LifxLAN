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
| Get-LifxDeviceColor   | Obtains the HSBK values of a device  |
| Get-LifxDeviceWifi    | Obtains the current wifi signal and strength of a device |
| Get-LifxProduct       | Returns a specific Lifx Product's capabilities |
| Set-LifxDevicePower   | Turns a device on or off |
| Set-LifxDeviceColor   | Defines the color of a device in: RGB + Saturation + Brightness, Kelvin + Brightness, White Palette as seen in the app, and finally all support an the time to takes to change in seconds |

## Getting Started

Install from the module from the PowerShell Gallery by using the following at a PowerShell prompt

```powershell
Install-Module -Name LifxLAN -AllowPrerelease
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

## Credits

This PowerShell module is made possible the following GitHub repositories and projects around controlling Lifx devices via .NET as well as examining Lifx packets over [Wireshark](https://www.wireshark.org/).

- [LifxNet](https://github.com/dotMorten/LifxNet)
- [LIFX-Control](https://github.com/PhilWheat/LIFX-Control)
- [WiresharkLIFXDissector](https://github.com/mab5vot9us9a/WiresharkLIFXDissector)

And of course Lifx documentation:

- [Querying the device for data](https://lan.developer.lifx.com/docs/querying-the-device-for-data)
- [Changing a device](https://lan.developer.lifx.com/docs/changing-a-device)
