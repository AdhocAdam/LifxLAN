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
        #a discovered Lifx bulb (use Get-LifxDevice)
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
        $receivingUdpClient = New-Object System.Net.Sockets.UDPClient($RemoteIpEndPoint)
        $receivingUdpClient.Client.Blocking = $false
        $receivingUdpClient.DontFragment = $true
        $receivingUdpClient.Client.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::ReuseAddress, $true)
    
        #Device packets
        [Byte[]]$getLabelPacket = New-LifxPacket -Type "GetLabel" | Convert-LifxPacketToBuffer
        [Byte[]]$getGroupPacket = New-LifxPacket -Type "GetGroup" | Convert-LifxPacketToBuffer

        #send the GetLabel packet
        $send = $receivingUdpClient.SendAsync($getLabelPacket, $getLabelPacket.Length, $_.IPAddress.Address, $_.IPAddress.Port)

        #get the Label
        start-sleep -Seconds 1
        $labelResult = $receivingUdpClient.Receive([ref]$RemoteIpEndPoint)
        $itemLabelName = [System.Text.Encoding]::UTF8.GetString($labelResult, 36, 32)
        $_ | Add-Member -Name 'Name' -Type NoteProperty -Value $itemLabelName -Force

        #send the GetGroup packet
        $send = $receivingUdpClient.SendAsync($getGroupPacket, $getGroupPacket.Length, $_.IPAddress.Address, $_.IPAddress.Port)

        #get the Group
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
