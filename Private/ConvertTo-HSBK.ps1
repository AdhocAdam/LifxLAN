function ConvertTo-HSBK {
    param (
        [Parameter(Mandatory = $true)][int]$Red,
        [Parameter(Mandatory = $true)][int]$Green,
        [Parameter(Mandatory = $true)][int]$Blue
    )

    # Normalize RGB values to [0, 1]
    $Red = $Red / 255
    $Green = $Green / 255
    $Blue = $Blue / 255

    $max = [Math]::Max($Red, [Math]::Max($Green, $Blue))
    $min = [Math]::Min($Red, [Math]::Min($Green, $Blue))
    $delta = $max - $min

    # Calculate Hue
    if ($delta -eq 0) {
        $hue = 0
    }
    elseif ($max -eq $Red) {
        $hue = 60 * ((($Green - $Blue) / $delta) % 6)
    }
    elseif ($max -eq $Green) {
        $hue = 60 * ((($Blue - $Red) / $delta) + 2)
    }
    else {
        $hue = 60 * ((($Red - $Green) / $delta) + 4)
    }

    if ($hue -lt 0) {
        $hue += 360
    }

    # Calculate Saturation
    if ($max -eq 0) {
        $saturation = 0
    }
    else {
        $saturation = $delta / $max
    }

    # Brightness is the same as max RGB component
    $brightness = $max

    # Scale values to appropriate output ranges
    $hue = [math]::Round($hue, 2)
    $saturation = [math]::Round($saturation * 100, 2)    # as percent
    $brightness = [math]::Round($brightness * 100, 2)    # as percent

    return [PSCustomObject]@{
        Hue        = $hue
        Saturation = $saturation
        Brightness = $brightness
    }
}
