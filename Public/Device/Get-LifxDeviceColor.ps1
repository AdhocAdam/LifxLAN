<#
    .SYNOPSIS
        Get the color of a Lifx device
    .DESCRIPTION
        Returns the HSBK values of a device. Hue will be a range between 0-360 degrees and Saturation/Brightness between 0-100 percent.
        If a device is multi-zoned (as determined from Get-LifxDeviceSetting), this will return all Zones and the HSBK values within each Zone.
        Zones consist of up to 8 HSBK segments. For example, a LIFX Z Strip will have 1 Zone of 8 HSBK values whereas a Neon Flex would
        have 8 zones, with 60 HSBK values. In the case of the Neon Flex, this means the last Zone would have its last 4 HSBK segments of 0,0,0,0
        since 60 can't fit into 7 zones, but it can fit into 8 leaving the last 4 HSKB segments empty since. This cmdlet will discard irrelevant zones.
    .EXAMPLE
        Get-LifxDevice | Initialize-LifxDevice | Get-LifxDeviceColor
    .EXAMPLE
        Get-LifxDevice | Get-LifxDeviceSetting | Get-LifxDeviceColor
#>

function Get-LifxDeviceColor {
    param(
        #a discovered Lifx bulb (use Get-LifxDevice)
        [parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [PSCustomObject[]]$Device
    )

    #declare the counters
    [int]$Total = $Input.Count
    [int]$Count = 0

    #process
    $Input | ForEach-Object {
        #constants
        $Port = "56700"
        $localIP = [System.Net.IPAddress]::Parse([System.Net.IPAddress]::Any)
        $RemoteIpEndPoint = New-Object System.Net.IPEndpoint($localIP, $Port)
        $receivingUdpClient = $null
        $receivingUdpClient = New-Object System.Net.Sockets.UDPClient($RemoteIpEndPoint)
        $receivingUdpClient.Client.Blocking = $true
        $receivingUdpClient.DontFragment = $true
        $receivingUdpClient.Client.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::ReuseAddress, $true)
        $receivingUdpClient.Client.ReceiveTimeout = 3000 #milliseconds

        #does the device support multizone as defined by Get-LifxDeviceSetting?
        if ($_.Product.Multizone -eq $true) {
            [Byte[]]$getColorZonesPacket = New-LifxPacket -Type "GetColorZones" | Convert-LifxPacketToBuffer

            #get the color zones
            $send = $receivingUdpClient.SendAsync($getColorZonesPacket, $getColorZonesPacket.Length, $_.IPAddress.Address, $_.IPAddress.Port)

            #parse the GetColorZones result, this should many StateMultiZone 506 messages that should be received near simultaneously
            $zones = @()
            try {
                while ($true) {
                    # This call blocks until a message is received
                    $result = $receivingUdpClient.Receive([ref]$RemoteIpEndPoint)
                    $zone = [PSCustomObject]@{
                        #current index of 8 colors
                        Index  = $result[37]
                        #array of 8 HSBK colors
                        Colors = @(
                            [PSCustomObject]@{
                                Color      = 0
                                Hue        = [Math]::Round([BitConverter]::ToUInt16($result, 38) / 0xFFFF * 360)
                                Saturation = [Math]::Round([BitConverter]::ToUInt16($result, 40) / 0xFFFF * 100)
                                Brightness = [Math]::Round([BitConverter]::ToUInt16($result, 42) / 0xFFFF * 100)
                                Kelvin     = [BitConverter]::ToUInt16($result, 44)
                            }
                            [PSCustomObject]@{
                                Color      = 1
                                Hue        = [Math]::Round([BitConverter]::ToUInt16($result, 46) / 0xFFFF * 360)
                                Saturation = [Math]::Round([BitConverter]::ToUInt16($result, 48) / 0xFFFF * 100)
                                Brightness = [Math]::Round([BitConverter]::ToUInt16($result, 50) / 0xFFFF * 100)
                                Kelvin     = [BitConverter]::ToUInt16($result, 52)
                            }
                            [PSCustomObject]@{
                                Color      = 2
                                Hue        = [Math]::Round([BitConverter]::ToUInt16($result, 54) / 0xFFFF * 360)
                                Saturation = [Math]::Round([BitConverter]::ToUInt16($result, 56) / 0xFFFF * 100)
                                Brightness = [Math]::Round([BitConverter]::ToUInt16($result, 58) / 0xFFFF * 100)
                                Kelvin     = [BitConverter]::ToUInt16($result, 60)
                            }
                            [PSCustomObject]@{
                                Color      = 3
                                Hue        = [Math]::Round([BitConverter]::ToUInt16($result, 62) / 0xFFFF * 360)
                                Saturation = [Math]::Round([BitConverter]::ToUInt16($result, 64) / 0xFFFF * 100)
                                Brightness = [Math]::Round([BitConverter]::ToUInt16($result, 66) / 0xFFFF * 100)
                                Kelvin     = [BitConverter]::ToUInt16($result, 68)
                            }
                            [PSCustomObject]@{
                                Color      = 4
                                Hue        = [Math]::Round([BitConverter]::ToUInt16($result, 70) / 0xFFFF * 360)
                                Saturation = [Math]::Round([BitConverter]::ToUInt16($result, 72) / 0xFFFF * 100)
                                Brightness = [Math]::Round([BitConverter]::ToUInt16($result, 74) / 0xFFFF * 100)
                                Kelvin     = [BitConverter]::ToUInt16($result, 76)
                            }
                            [PSCustomObject]@{
                                Color      = 5
                                Hue        = [Math]::Round([BitConverter]::ToUInt16($result, 78) / 0xFFFF * 360)
                                Saturation = [Math]::Round([BitConverter]::ToUInt16($result, 80) / 0xFFFF * 100)
                                Brightness = [Math]::Round([BitConverter]::ToUInt16($result, 82) / 0xFFFF * 100)
                                Kelvin     = [BitConverter]::ToUInt16($result, 84)
                            }
                            [PSCustomObject]@{
                                Color      = 6
                                Hue        = [Math]::Round([BitConverter]::ToUInt16($result, 86) / 0xFFFF * 360)
                                Saturation = [Math]::Round([BitConverter]::ToUInt16($result, 88) / 0xFFFF * 100)
                                Brightness = [Math]::Round([BitConverter]::ToUInt16($result, 90) / 0xFFFF * 100)
                                Kelvin     = [BitConverter]::ToUInt16($result, 92)
                            }
                            [PSCustomObject]@{
                                Color      = 7
                                Hue        = [Math]::Round([BitConverter]::ToUInt16($result, 94) / 0xFFFF * 360)
                                Saturation = [Math]::Round([BitConverter]::ToUInt16($result, 96) / 0xFFFF * 100)
                                Brightness = [Math]::Round([BitConverter]::ToUInt16($result, 98) / 0xFFFF * 100)
                                Kelvin     = [BitConverter]::ToUInt16($result, 100)
                            }
                        )
                    }
                    $zones += $zone
                }
            }
            catch {
                Write-Warning "$($_.Exception.Message). Get-LifxDeviceColor, Line 123. Its likely that the MultiZone LIFX device responded with its zones. This message can be suppressed with -WarningAction Ignore"
            }

            #add the Zones (count of items that can be colored in) and MultiZone which contains the 8 colors in each index
            $_ | Add-Member -Name 'Zones' -Type NoteProperty -Value $result[36] -Force
            $_ | Add-Member -Name 'MultiZone' -Type NoteProperty -Value $zones -Force

            #if there is more than 1 index, remove invalid colors from the last one
            if ($_.MultiZone.Count -gt 1) {
                $lastZone = $_.MultiZone[$_.MultiZone.count - 1]
                $arrayCountToKeep = 7 - ($_.MultiZone.Colors.count - $_.Zones)
                ($_.MultiZone | Where-Object { $_.Index -eq $lastZone.Index }).Colors = $lastZone.Colors[0..$arrayCountToKeep]
            }

            #shut the udp client down
            $receivingUdpClient.Dispose()
            $receivingUdpClient.Close()

            $Count++
            [int]$percentComplete = ($Count / $Total * 100)
            Write-Progress -Activity "Retrieving Device Color Zones" -PercentComplete $percentComplete -Status ("$($_.Name) color zone retrieved - " + $percentComplete + "%")

            return $_
        }
        else {
            #Device packets
            [Byte[]]$getColorPacket = New-LifxPacket -Type "GetColor" | Convert-LifxPacketToBuffer

            #get the color
            $send = $receivingUdpClient.SendAsync($getColorPacket, $getColorPacket.Length, $_.IPAddress.Address, $_.IPAddress.Port)

            #wait a second
            Start-Sleep -Seconds 1

            #parse the GetColor result
            $result = $receivingUdpClient.Receive([ref]$RemoteIpEndPoint)
            $hue = [Math]::Round(([System.BitConverter]::ToUInt16($result, 36) * 360) / 0x10000)
            $saturation = (([System.BitConverter]::ToUInt16($result, 38)) % 0xFFFF) * 100
            $brightness = (([System.BitConverter]::ToUInt16($result, 40)) / 0xFFFF) * 100
            $kelvin = ([System.BitConverter]::ToUInt16($result, 42))
            #$powerState = ([System.BitConverter]::ToUInt16($result, 46)) -gt 0 #on/off
            #$itemName = [System.Text.Encoding]::UTF8.GetString($result, 48, 32) #name

            #set the GetColor values
            $_ | Add-Member -Name 'Hue' -Type NoteProperty -Value $hue -Force
            $_ | Add-Member -Name 'Saturation' -Type NoteProperty -Value $saturation -Force
            $_ | Add-Member -Name 'Brightness' -Type NoteProperty -Value $brightness -Force
            $_ | Add-Member -Name 'Kelvin' -Type NoteProperty -Value $kelvin -Force
            #$_ | Add-Member -Name 'Power' -Type NoteProperty -Value $powerState -Force
            #$_ | Add-Member -Name 'Name' -Type NoteProperty -Value $itemName -Force

            #shut the udp client down
            $receivingUdpClient.Dispose()
            $receivingUdpClient.Close()

            $Count++
            [int]$percentComplete = ($Count / $Total * 100)
            Write-Progress -Activity "Retrieving Device Color" -PercentComplete $percentComplete -Status ("$($_.Name) color retrieved - " + $percentComplete + "%")

            return $_
        }
    }
}
