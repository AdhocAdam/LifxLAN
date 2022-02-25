<#
    .SYNOPSIS
        Defines results from Get-LifxDevice
    .DESCRIPTION
        This cmdlet processes results from Get-LifxDevice so as to add more descriptors such as the
        Name, Group, and Power state.
    .EXAMPLE
        Get-LifxDevice | Initialize-LifxDevice
    .EXAMPLE
        $devices = Get-LifxDevice
        Initialize-LifxDevice -Device $devices[0]   
#>

function Initialize-LifxDevice
{
    param(
        #a discovered Lifx device (use Get-LifxDevice)
        [parameter(
                Position          = 0,
                Mandatory         = $true,
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
        $receivingUdpClient.Client.Blocking = $false
        $receivingUdpClient.DontFragment = $true
        $receivingUdpClient.Client.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::ReuseAddress, $true)
    
        #Device packets
        [Byte[]]$getColorPacket = New-LIFXPacket -Type "GetColor" | Convert-LifxPacketToBuffer
        [Byte[]]$getGroupPacket = New-LIFXPacket -Type "GetGroup" | Convert-LifxPacketToBuffer
    
        #get the color
        $send = $receivingUdpClient.SendAsync($getColorPacket, $getColorPacket.Length, $_.IPAddress.Address, $_.IPAddress.Port)
    
        #wait a second
        start-sleep -seconds 1
    
        #parse the GetColor result
        $result = $receivingUdpClient.Receive([ref]$RemoteIpEndPoint)
        $itemName = [System.Text.Encoding]::UTF8.GetString($result, 48, 32) #name
        $powerState = ([System.BitConverter]::ToUInt16($result, 46)) -gt 0 #on/off
    
        #set the GetColor values
        $_ | Add-Member -Name 'Name' -Type NoteProperty -Value $itemName.Trim() -Force
        $_ | Add-Member -Name 'Power' -Type NoteProperty -Value $powerState -Force
    
        #get the Group
        $send = $receivingUdpClient.SendAsync($getGroupPacket, $getGroupPacket.Length, $_.IPAddress.Address, $_.IPAddress.Port)
        start-sleep -Seconds 1
        $result = $receivingUdpClient.Receive([ref]$RemoteIpEndPoint)
        $itemGroupName = [System.Text.Encoding]::UTF8.GetString($result, 52, 14)
        $_ | Add-Member -Name 'Group' -Type NoteProperty -Value $itemGroupName -Force

        #shut the udp client down    
        $receivingUdpClient.Dispose()
        $receivingUdpClient.Close()
    
        $Count++
        [int]$percentComplete = ($Count/$Total* 100)
        Write-Progress -Activity "Initializing Lifx Device" -PercentComplete $percentComplete -Status ("$($_.Name) Initialized - " + $percentComplete + "%")

        return $_
    }
}