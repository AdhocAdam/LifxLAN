<#
    .SYNOPSIS
        Controls the power state of a Lifx device
    .DESCRIPTION
        This cmdlet controls whether or not a Lifx device is On or Off. In addition, it also supports
        an optional TransitionInSeconds to control how fast On/Off occurs.
    .EXAMPLE
        $devices = Get-LifxDevice | Initialize-LifxDevice
        $devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDevicePower -Power $true
    .EXAMPLE
        $devices = Get-LifxDevice | Initialize-LifxDevice
        $devices | Where-Object {$_.Name -eq "Kitchen01"} | Set-LifxDevicePower -Power $false -TransitionInSeconds 3
    .EXAMPLE
        $devices = Get-LifxDevice | Initialize-LifxDevice
        Set-LifxDevicePower -Device $devices[0] -Power $false -TransitionInSeconds 3
#>

function Set-LifxDevicePower
{
    <##>
    param (
        #Discovered Lifx device. Accepts input from Get-LifxDevice or Initialize-LifxDevice
        [parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true)]
        [PSCustomObject[]]$Device,
        
        #Turn the light on or off. $true = on. $false = off.
        [parameter(
            Mandatory         = $true)]
        [bool]$Power,

        #the number of seconds it will take the light to turn on/off
        [parameter(
            Mandatory         = $false)]
        [decimal]$SecondsToTransition = 0
    )

    BEGIN
    {
        switch ($power)
        {
            $true   {$level = 65535; $state = "ON"}
            $false  {$level = 0; $state = "OFF"}
        }
    
        $packet = [PSCustomObject] @{
            packet_type        = [uint16]117;
            protocol           = [uint16]21504
            ack_required       = [bool]$true
            level              = [uint16]$level
            duration           = [uint32]($SecondsToTransition * 1000)
            reserved1          = [uint32]0
            reserved2          = [uint32]0
            reserved3          = [uint32]0
            reserved4          = [uint32]0
            site               = New-Object byte[] 8
            size               = [uint16]49
            target_mac_address = New-Object byte[] 8
            timestamp          = [uint64]0
        }

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
        if ($packet.Level -eq 0) {[System.Array]::Copy([System.BitConverter]::GetBytes($packet.level), 0, $buffer, 36, 2);}
        if ($packet.Level -eq 65535) {[System.Array]::Copy([System.BitConverter]::GetBytes($packet.level), 0, $buffer, 36, 2);}
        [System.Array]::Copy([System.BitConverter]::GetBytes($packet.duration), 0, $buffer, 38, 4);
        [Byte[]]$payload = New-Object byte[] 0 #$packet.GetPayloadBuffer();
        [System.Array]::Copy($payload, 0, $buffer, 36, $payload.Length);
    }
    PROCESS
    {
        #provide some status
        Write-Output "Turning $($Device.Name) $state"
        
        #prep the packet
        [Byte[]]$powerPacket = $buffer
        
        $localIP = [System.Net.IPAddress]::Parse([System.Net.IPAddress]::Any)
        $RemoteIpEndPoint = New-Object System.Net.IPEndpoint($localIP, $Port) #New-Object System.Net.IPEndpoint([System.Net.IPAddress]::Any, 0)
        $receivingUdpClient = New-Object System.Net.Sockets.UDPClient($RemoteIpEndPoint) #(, $Port)
        $receivingUdpClient.Client.Blocking = $false
        $receivingUdpClient.DontFragment = $true
        $receivingUdpClient.Client.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::ReuseAddress, $true)

        #send the packet
        $send = $receivingUdpClient.SendAsync($powerPacket, $powerPacket.Length, $Device.IPAddress.Address, $Device.IPAddress.Port)

        #shut the socket down
        $receivingUdpClient.Close()
        $receivingUdpClient.Dispose()
    }
    END
    {

    }
}