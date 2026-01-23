<#
    .SYNOPSIS
        Controls the color of a Lifx device
    .DESCRIPTION
        This cmdlet allows you to set the brightness, saturation, hue, and kelvin of a Lifx device based on different parameters. It also
        supports SecondsToTransition to control how fast the change occurs.
    .EXAMPLE
        $devices = Get-LifxDevice | Initialize-LifxDevice
        $devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Red 200 -Blue 13 -Brightness 75 -Saturation 100
    .EXAMPLE
        $devices = Get-LifxDevice | Initialize-LifxDevice
        $devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Brightness 100 -White "Sunset" -SecondsToTransition 1.5
    .EXAMPLE
        $devices = Get-LifxDevice | Initialize-LifxDevice
        $devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Brightness 100 -White "Noon Daylight" -SecondsToTransition 4
    .EXAMPLE
        $devices = Get-LifxDevice | Initialize-LifxDevice
        $devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Kelvin 12000 -Brightness 10000
    .EXAMPLE
        $devices = Get-LifxDevice | Initialize-LifxDevice
        $devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -White 'Cloudy Daylight' -Brightness 90
    .EXAMPLE
        $zoneColor1 = [PSCustomObject]@{
            "Red"        = 216
            "Green"      = 45
            "Blue"       = 231
            "Saturation" = 80
            "Brightness" = 90
        }
        $devices = Get-LifxDevice | Initialize-LifxDevice | Get-LifxDeviceSetting
        $devices | Where-Object {$_.Product.Name -like "LIFX Z*"} | Set-LifxDeviceColor -Zone $zoneColor01 -SecondsToTransition 3 -StartingZone 0
    .EXAMPLE
        $zoneColor1 = [PSCustomObject]@{
            "Red"        = 216
            "Green"      = 45
            "Blue"       = 231
            "Saturation" = 80
            "Brightness" = 90
        }
        $zoneColor2 = [PSCustomObject]@{
            "Hue"        = 109
            "Saturation" = 85
            "Brightness" = 90
        }
        $zoneColor3 = [PSCustomObject]@{
            "Kelvin"     = 7200
            "Brightness" = 65
        }
        $devices = Get-LifxDevice | Initialize-LifxDevice | Get-LifxDeviceSetting
        $devices | Where-Object {$_.Product.Name -like "LIFX Z*"} | Set-LifxDeviceColor -zones $zoneColor01, $zoneColor02 -SecondsToTransition 2 -StartingZone 0
#>

function Set-LifxDeviceColor {
    param(
        #Discovered Lifx device. Accepts input from Get-LifxDevice or Initialize-LifxDevice
        [parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [PSCustomObject[]]$Device,

        #Hue: The section of the color spectrum that represents the color of your device. This is taken as RGB values and converted to HSB
        [ValidateRange(0, 255)]
        [Parameter(ParameterSetName = "Color")]
        [decimal]$Red = 0,

        [ValidateRange(0, 255)]
        [Parameter(ParameterSetName = "Color")]
        [decimal]$Green = 0,

        [ValidateRange(0, 255)]
        [Parameter(ParameterSetName = "Color")]
        [decimal]$Blue = 0,

        #Hue, instead of RGB you can provide a value from 0-360 as seen in the LIFX app
        [ValidateRange(0, 360)]
        [Parameter(ParameterSetName = "Hue")]
        [int]$Hue = 0,

        #Brightness: How bright the light is. Zero brightness is the same as the device is off, while full brightness be just that.
        #This value is taken as a percent value i.e. 1, 27, 43, 100 and defaults to 1 if nothing is provided
        [ValidateRange(0, 100)]
        [Parameter(ParameterSetName = "Hue")]
        [Parameter(ParameterSetName = "Color")]
        [Parameter(ParameterSetName = "Zone")]
        [Parameter(ParameterSetName = "KelvinByNumber")]
        [Parameter(ParameterSetName = "KelvinByName")]
        [decimal]$Brightness = 1,

        #Saturation: How strong the color is. So a Zero saturation is completely white, whilst full saturation is the full color
        [ValidateRange(0, 100)]
        [Parameter(ParameterSetName = "Hue")]
        [Parameter(ParameterSetName = "Color")]
        [decimal]$Saturation = 0,

        #the number of seconds it will take the light(s) to change color
        [Parameter(ParameterSetName = "Hue")]
        [Parameter(ParameterSetName = "Color")]
        [Parameter(ParameterSetName = "KelvinByNumber")]
        [Parameter(ParameterSetName = "KelvinByName")]
        [Parameter(ParameterSetName = "Zone")]
        [Parameter(ParameterSetName = "Zones")]
        [decimal]$SecondsToTransition = 0,

        #Kelvin: Allowed range aka the "temperature" when the device has zero saturation. A higher value is a
        #cooler white (more blue) whereas a lower value is a warmer white (more yellow)
        [ValidateRange(1000, 12000)]
        [Parameter(ParameterSetName = "KelvinByNumber")]
        [decimal]$Kelvin,

        #kelvin values by name as defined by Lifx
        [Parameter(ParameterSetName = "KelvinByName")]
        [ValidateSet("Candlelight", "Sunset", "Ultra Warm", "Incandescent", "Warm", "Neutral", "Cool", "Cool Daylight", "Soft Daylight",
            "Daylight", "Noon Daylight", "Bright Daylight", "Cloudy Daylight", "Blue Daylight", "Blue Overcast", "Blue Ice")]
        [string]$White,

        [Parameter(ParameterSetName = "Zone")]
        [PSCustomObject]$Zone,

        #sets a multizone device's zones to different colors
        [Parameter(ParameterSetName = "Zones")]
        [array[]]$Zones,

        #defines which zone the colors will begin applying at. Colors that don't fit will be discarded
        #for example, passing 2 or more zones to a Lifx Z strip (8 zones) at position 7 will only change
        #the color of the last zone and the 8th position would be discarded as the count begins at 0
        [Parameter(ParameterSetName = "Zones")]
        [uint16]$StartingZone
    )

    #declare the counters
    [int]$Total = $Input.Count
    [int]$Count = 0

    #a device has its Product Settings defined via (Get-LifxDeviceSetting) and ExtendedMultizone=$true
    if ($Device.Product.ExtendedMultizone) {
        #multizone device, single color for all zones
        if ($Zone) {
            <#convert inputs
            https://lan.developer.lifx.com/docs/representing-color-with-hsbk
            did the user provide the direct Hue value, or RGB?
            #>
            if ($Zone.Hue) {
                $hshue = [int](([Math]::Round(0x10000 * $Zone.Hue) / 360) % 0x10000)
            }
            if ($Zone.Red -or $Zone.Green -or $Zone.Blue) {
                $hscolor = ConvertTo-HSBK -Red $Zone.Red -Green $Zone.Green -Blue $Zone.Blue
                $hshue = [int](([Math]::Round(0x10000 * $hscolor.Hue) / 360) % 0x10000)
            }
            if (!$hsHue) {
                $hsHue = 0
            }
            $Saturation = $Zone.Saturation / 100
            $hsSaturation = [int]([Math]::Round(0xFFFF * $Saturation))
            $Brightness = $Zone.Brightness / 100
            $hsbrightness = [int]([Math]::Round(0xFFFF * $Brightness))

            ####build the packet
            #119 (setWaveFormOptional) sets the same color across all zones
            $packet = [PSCustomObject]@{
                #LIFX Frame
                size               = 61;
                reserved1          = [uint64]0;
                reserved2          = [uint64]0;
                addressable        = 1;
                packet_type        = [uint16]119; #setWaveFormOptional packet number
                reserved3          = [uint32]0;
                reserved10         = [uint32]0;
                source             = [uint32]29734587;
                ackreq             = 1; #1
                resreq             = 0; #0
                sequence           = 0;
                #Payload
                transient          = [byte]0 #0 or 1
                hue                = [uint16]$hshue
                saturation         = [uint16]$hsSaturation #0 #65535
                brightness         = [uint16]$hsbrightness
                kelvin             = [uint16]$Zone.Kelvin
                period             = [uint32]300
                cycles             = [float]1
                skew               = [Int16]0
                waveform           = [byte]0 #0 saw, 1 sine, 2 half sine, 3 triangle, 4 pulse
                #set either color or kelvin
                sethue             = if (!$Zone.Kelvin) {[byte]1} else {[byte]0}
                setsaturation      = 1
                setbrightness      = 1
                setKelvin          = if ($Zone.Kelvin) {[byte]1} else {[byte]0}
                #possibly not neccesary
                protocol           = [uint16]1024;
                target_mac_address = New-Object byte[] 8
            }

            #convert the packet to a byte array
            [Byte[]]$buffer = New-Object byte[] $packet.size;
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.size), 0, $buffer, 0, 2);
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.protocol), 0, $buffer, 2, 2);
            #makes the LIFX packet portion of the protocol frame addressable, this is required for multizone
            $buffer[3] = 0x14

            #reserved should be happening on 16
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.reserved1), 0, $buffer, 16, 6);
            #[System.Array]::Copy([System.BitConverter]::GetBytes($packet.resreq), 0, $buffer, 22, 1);
            $buffer[22] = 0x06

            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.packet_type), 0, $buffer, 32, 2);
            #payload, color
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.transient), 0, $buffer, 37, 1); #transient
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.hue), 0, $buffer, 38, 2); #hue
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.saturation), 0, $buffer, 40, 2); #saturation
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.brightness), 0, $buffer, 42, 2); #brightness
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.kelvin), 0, $buffer, 44, 2); #kelvin
            #payload, remainder
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.period), 0, $buffer, 46, 4); #period/periodOpt, e.g. 3000ms
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.cycles), 0, $buffer, 50, 4); #cycles. float, e.g. 1
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.skew), 0, $buffer, 54, 2); #skewRatio
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.waveform), 0, $buffer, 56, 1); #waveform Type e.g. saw = 0
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.sethue), 0, $buffer, 57, 1); #setHue true/false, 0 or 1
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.setsaturation), 0, $buffer, 58, 1); #setSaturation true/false, 0 or 1
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.setbrightness), 0, $buffer, 59, 1); #setBrightness true/false, 0 or 1
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.setKelvin), 0, $buffer, 60, 1); #setKelvin true/false, 0 or 1

            #Device packets
            [Byte[]]$setWaveFormOptional = $buffer
        }
        #multizone device, different colors for different zones
        if ($Zones) {
            #quick validation, does the total number of zones passed in, exceed the available zones on the device?
            if ($Zones.Count -gt $Device.Zones) {
                throw "$($Zones.Count) zones defined for a device that only supports $($Device.Zones)"
            }

            ####build the packet
            #510 (SetExtendedColorZones) sets one color/zone
            $packet = [PSCustomObject]@{
                #LIFX Frame
                size               = 700;
                reserved1          = [uint64]0;
                reserved2          = [uint64]0;
                addressable        = 1;
                packet_type        = [uint16]510; #SetExtendedColorZones packet number
                reserved3          = [uint32]0;
                reserved10         = [uint32]0;
                source             = [uint32]29734587;
                ackreq             = 1; #1
                resreq             = 0; #0
                sequence           = 0;
                protocol           = [uint16]1024;
                target_mac_address = New-Object byte[] 8
                #Payload
                duration           = [uint32]($SecondsToTransition * 1000); #time to transition in ms, 4 bytes
                apply              = 1; #apply enum. 0 no_apply, 1 apply, 2 apply_only
                #a zone index of 1 with a color_count of 2 means that zones 2 and 3 would be set with color as count starts at 0
                zone_index         = [uint16]$StartingZone; #zone_index. first zone to apply COLORS to
                colors_count       = $Zones.Count; #colors_count. number of colors in COLORS to apply to the strip
            }

            #convert the packet to a byte array
            [Byte[]]$buffer = New-Object byte[] $packet.size;
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.size), 0, $buffer, 0, 2);
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.protocol), 0, $buffer, 2, 2);
            $buffer[3] = 0x14 #makes the LIFX packet portion of the protocol frame addressable, this is required for multizone

            #packet type is surrounded by reserved 2 and 3
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.reserved2), 0, $buffer, 24, 8);
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.packet_type), 0, $buffer, 32, 2);
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.reserved3), 0, $buffer, 34, 2);
            #[System.Array]::Copy([System.BitConverter]::GetBytes($packet.ackreq), 0, $buffer, 22, 1);
            $buffer[22] = 0x06 #sets ack_required True and res_required False

            #payload begins at 36
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.duration), 0, $buffer, 36, 4); #unint32
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.apply), 0, $buffer, 40, 1); #uint8
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.zone_index), 0, $buffer, 41, 2); #uint16
            [System.Array]::Copy([System.BitConverter]::GetBytes($packet.colors_count), 0, $buffer, 43, 1); #uint8

            $startingColorPosition = 44
            foreach ($zone in $Zones) {
                <#convert inputs
                https://lan.developer.lifx.com/docs/representing-color-with-hsbk
                did the user provide the direct Hue value, or RGB?
                #>

                if ($zone.Hue) {
                    $hshue = [int](([Math]::Round(0x10000 * $zone.Hue) / 360) % 0x10000)
                }
                if ($zone.Red -or $zone.Green -or $zone.Blue) {
                    $hscolor = ConvertTo-HSBK -Red $Zone.Red -Green $zone.Green -Blue $zone.Blue
                    $hshue = [int](([Math]::Round(0x10000 * $hscolor.Hue) / 360) % 0x10000)
                }
                if (!$hsHue) {
                    $hsHue = 0
                }

                $Saturation = $zone.Saturation / 100
                $hsSaturation = [int]([Math]::Round(0xFFFF * $Saturation))
                $Brightness = $zone.Brightness / 100
                $hsbrightness = [int]([Math]::Round(0xFFFF * $Brightness))
                [uint16]$kelvin = $zone.Kelvin

                #hue, 44
                [System.Array]::Copy([System.BitConverter]::GetBytes($hshue), 0, $buffer, $startingColorPosition, 2);
                #saturation, 46
                [System.Array]::Copy([System.BitConverter]::GetBytes($hsSaturation), 0, $buffer, ($startingColorPosition + 2), 2);
                #brightness, 48
                [System.Array]::Copy([System.BitConverter]::GetBytes($hsbrightness), 0, $buffer, ($startingColorPosition + 4), 2);
                #kelvin, 50
                [System.Array]::Copy([System.BitConverter]::GetBytes($kelvin), 0, $buffer, ($startingColorPosition + 6), 2);

                #increment 8 bytes, so the next pass of the loop sets the next color at the correct starting position
                $startingColorPosition += 8
            }

            #Device packets
            [Byte[]]$setExtendedColorZones = $buffer
        }
    }
    #single light source, setColor
    else {
        #convert the White value to Kelvin
        switch ($White) {
            "Candlelight" { $Kelvin = 1500 }
            "Sunset" { $Kelvin = 2000 }
            "Ultra Warm" { $Kelvin = 2500 }
            "Incandescent" { $Kelvin = 2700 }
            "Warm" { $Kelvin = 3000 }
            "Neutral" { $Kelvin = 3500 }
            "Cool" { $Kelvin = 4000 }
            "Cool Daylight" { $Kelvin = 4500 }
            "Soft Daylight" { $Kelvin = 5000 }
            "Daylight" { $Kelvin = 5600 }
            "Noon Daylight" { $Kelvin = 6000 }
            "Bright Daylight" { $Kelvin = 6500 }
            "Cloudy Daylight" { $Kelvin = 7000 }
            "Blue Daylight" { $Kelvin = 7500 }
            "Blue Overcast" { $Kelvin = 8000 }
            "Blue Ice" { $Kelvin = 9000 }
        }

        #convert inputs
        #https://lan.developer.lifx.com/docs/representing-color-with-hsbk
        $Brightness = $Brightness / 100
        $Saturation = $Saturation / 100
        $hscolor = ConvertTo-HSBK -Red $red -Green $green -Blue $blue
        $hsbrightness = [int]([Math]::Round(0xFFFF * $Brightness))
        $hshue = [int](([Math]::Round(0x10000 * $hscolor.Hue) / 360) % 0x10000)
        $hsSaturation = [int]([Math]::Round(0xFFFF * $Saturation))

        #build the packet
        $packet = [PSCustomObject]@{
            size               = 49;
            hue                = [uint16]$hshue
            saturation         = [uint16]$hsSaturation #0 #65535
            brightness         = [uint16]$hsbrightness
            kelvin             = [uint16]$Kelvin
            duration           = [uint32]($SecondsToTransition * 1000)
            packet_type        = [uint16]102;
            protocol           = [uint16]21504;
            reserved1          = [uint32]0;
            reserved2          = [uint32]0;
            reserved3          = [uint32]0;
            reserved4          = [uint32]0;
            reserved5          = [uint32]0;
            reserved6          = [uint32]0;
            site               = New-Object byte[] 8
            target_mac_address = New-Object byte[] 8
            timestamp          = [uint64]0
        }

        #convert the packet to a byte array
        [Byte[]]$buffer = New-Object byte[] $packet.size;
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.size), 0, $buffer, 0, 2);
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.protocol), 0, $buffer, 2, 2);
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.reserved1), 0, $buffer, 4, 4);
        [System.Array]::Copy($packet.target_mac_address, 0, $buffer, 8, 6);
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.reserved2), 0, $buffer, 14, 2);
        [System.Array]::Copy($packet.site, 0, $buffer, 16, 6);
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.reserved3), 0, $buffer, 22, 2);
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.timestamp), 0, $buffer, 24, 8);
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.packet_type), 0, $buffer, 32, 2);
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.reserved4), 0, $buffer, 30, 2);
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.reserved6), 0, $buffer, 34, 2);
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.hue), 0, $buffer, 37, 2);
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.saturation), 0, $buffer, 39, 2);
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.brightness), 0, $buffer, 41, 2);
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.kelvin), 0, $buffer, 43, 2);
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.duration), 0, $buffer, 45, 4);
        [Byte[]]$payload = New-Object byte[] 0 #$packet.GetPayloadBuffer();
        [System.Array]::Copy($payload, 0, $buffer, 36, $payload.Length);

        #Device packets
        [Byte[]]$changeColorPacket = $buffer
    }

    #process
    $Input | ForEach-Object {
        #constants
        $Port = "56700"
        $localIP = [System.Net.IPAddress]::Parse([System.Net.IPAddress]::Any)
        $RemoteIpEndPoint = New-Object System.Net.IPEndpoint($localIP, $Port)
        $receivingUdpClient = $null
        $receivingUdpClient = New-Object System.Net.Sockets.UDPClient($RemoteIpEndPoint)
        $receivingUdpClient.Client.Blocking = $false
        $receivingUdpClient.DontFragment = $true
        $receivingUdpClient.Client.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::ReuseAddress, $true)

        if ($packet.packet_type -eq 102) {
            $send = $receivingUdpClient.SendAsync($changeColorPacket, $changeColorPacket.Length, $_.IPAddress.Address, $_.IPAddress.Port)
        }
        if ($packet.packet_type -eq 119) {
            $send = $receivingUdpClient.SendAsync($setWaveFormOptional, $setWaveFormOptional.Length, $_.IPAddress.Address, $_.IPAddress.Port)
        }
        if ($packet.packet_type -eq 510) {
            $send = $receivingUdpClient.SendAsync($setExtendedColorZones, $setExtendedColorZones.Length, $_.IPAddress.Address, $_.IPAddress.Port)
        }

        #shut the udp client down
        $receivingUdpClient.Dispose()
        $receivingUdpClient.Close()

        $Count++
        [int]$percentComplete = ($Count / $Total * 100)
        Write-Progress -Activity "Changing Lifx Device Color" -PercentComplete $percentComplete -Status ("$($_.Name) color changed - " + $percentComplete + "%")
    }
}
