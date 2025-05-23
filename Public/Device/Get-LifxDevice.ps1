<#
    .SYNOPSIS
        Finds Lifx devices on the network
    .DESCRIPTION
        This cmdlet sends a Lifx discovery packet via UDP to all devices on the LAN that respond on port 56700. It will return
        one or many objects that contain the device's IP address and current State in a byte array. This command is typically used
        as the starting point for issuing subsequent LifxLan cmdlets.
    .EXAMPLE
        Get-LifxDevice
#>

function Get-LifxDevice
{
    <#find all of the bulbs on the network that respond to a broadcast packet on UDP port 56700#>
    #define constants
    $Port = "56700"
    $localIPs = Get-NetIPAddress | Where-Object{$_.AddressFamily -eq "IPv4"} | Select-Object IPAddress

    #define listener constants
    $localIP = [System.Net.IPAddress]::Parse([System.Net.IPAddress]::Any)
    $RemoteIpEndPoint = New-Object System.Net.IPEndpoint($localIP, $Port)
    $receivingUdpClient = New-Object System.Net.Sockets.UDPClient($RemoteIpEndPoint)
    $receivingUdpClient.Client.Blocking = $false
    $receivingUdpClient.DontFragment = $true
    $receivingUdpClient.Client.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::ReuseAddress, $true)

    #Send the Announce (getService) UDP Packet to the LAN
    [Byte[]]$sendData = New-LIFXPacket -Type "Discovery" | Convert-LifxPacketToBuffer
    $send = $receivingUdpClient.SendAsync($sendData, $sendData.Length, "255.255.255.255", $Port)

    #wait a second
    start-sleep -seconds 1

    #prep the loop
    $global:discoveredBulbs = @()

    #Define the Bulbs
    function Receive-LifxBulb
    {
        while ($receivingUdpClient)
        {
            try
            {
                $result = $receivingUdpClient.Receive([ref]$RemoteIpEndPoint)
                $bulb = [PSCustomObject]@{
                    IPAddress = $RemoteIpEndPoint
                    #Name = ""
                    #Power = ""
                    #Group = ""
                    #State = $result
                    #Service = [System.BitConverter]::ToUInt16($result, 36)
                    Port = [System.BitConverter]::ToUInt32($result, 37)
                }
                if ($localIPs.IPAddress -notcontains $bulb.ipaddress.address.IPAddressToString)
                {
                    $global:discoveredBulbs += $bulb
                }
            }
            catch
            {
                #Write-Error $_.Exception
                break
            }
            start-sleep -milliseconds 5
        }
    }

    while ($discoveredBulbs.Count -eq 0)
    {
        Receive-LifxBulb
        Start-Sleep 1
    }

    #shut it down
    $receivingUdpClient.Dispose()
    $receivingUdpClient.Close()

    $results = $discoveredBulbs | sort-object ipaddress -unique
    return $results
}
