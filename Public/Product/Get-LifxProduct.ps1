<#
    .SYNOPSIS
        Returns a device's model and capabilities
    .DESCRIPTION
        This cmdlet returns a Lifx Device's model and capabilities by it's Product ID.
    .EXAMPLE
        Get-LifxProduct -Id 18
#>

function Get-LifxProduct {
    param(
        #Lifx Product by Id (pass results from Get-LifxDevice | Initialize-LifxDevice)
        #https://lan.developer.lifx.com/docs/product-registry
        [parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [int[]]$ProductId
    )

    #online product registry
    $RestError = $null
    Try {
        $productRegistry = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/LIFX/products/refs/heads/master/products.json"
    }
    Catch {
        $RestError = $_
    }

    #process
    $ProductId | ForEach-Object {
        switch ($_) {
            1 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Original 1000"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            3 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Color 650"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            10 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX White 800 (Low Voltage)"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            11 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX White 800 (High Voltage)"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            15 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Color 1000"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            18 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX White 900 BR30 (Low Voltage)"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            19 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX White 900 BR30 (High Voltage)"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            20 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Color 1000 BR30"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            22 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Color 1000"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            27 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX A19"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            28 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX BR30"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            29 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX A19 Night Vision"; Color = $true; Infrared = $true; Multizone = $false; HEV = $false } }
            30 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX BR30 Night Vision"; Color = $true; Infrared = $true; Multizone = $false; HEV = $false } }
            31 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Z"; Color = $true; Infrared = $false; Multizone = $true; HEV = $false } }
            32 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Z"; Color = $true; Infrared = $false; Multizone = $true; HEV = $false } }
            36 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Downlight"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            37 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Downlight"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            38 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Beam"; Color = $true; Infrared = $false; Multizone = $true; HEV = $false } }
            39 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Downlight White to Warm"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            40 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Downlight"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            43 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX A19"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            44 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX BR30"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            45 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX A19 Night Vision"; Color = $true; Infrared = $true; Multizone = $false; HEV = $false } }
            46 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX BR30 Night Vision"; Color = $true; Infrared = $true; Multizone = $false; HEV = $false } }
            49 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Mini Color"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            50 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Mini White to Warm"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            51 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Mini White"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            52 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX GU10"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            53 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX GU10"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            55 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Tile"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            57 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Candle"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            59 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Mini Color"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            60 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Mini White to Warm"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            61 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Mini White"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            62 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX A19"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            63 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX BR30"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            64 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX A19 Night Vision"; Color = $true; Infrared = $true; Multizone = $false; HEV = $false } }
            65 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX BR30 Night Vision"; Color = $true; Infrared = $true; Multizone = $false; HEV = $false } }
            66 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Mini White"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            68 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Candle"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            81 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Candle White to Warm"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            82 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Filament Clear"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            85 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Filament Amber"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            87 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Mini White"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            88 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Mini White"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            90 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Clean"; Color = $true; Infrared = $false; Multizone = $false; HEV = $true } }
            91 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Color"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            92 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Color"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            93 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX A19 US"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            94 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX BR30"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            96 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Candle White to Warm"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            97 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX A19"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            98 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX BR30"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            99 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Clean"; Color = $true; Infrared = $false; Multizone = $false; HEV = $true } }
            100 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Filament Clear"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            101 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Filament Amber"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            109 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX A19 Night Vision"; Color = $true; Infrared = $true; Multizone = $false; HEV = $false } }
            110 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX BR30 Night Vision"; Color = $true; Infrared = $true; Multizone = $false; HEV = $false } }
            111 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX A19 Night Vision"; Color = $true; Infrared = $true; Multizone = $false; HEV = $false } }
            112 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX BR30 Night Vision Intl"; Color = $true; Infrared = $true; Multizone = $false; HEV = $false } }
            113 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Mini WW US"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            114 { $product = [PSCustomObject]@{Id = $_; Name = "LIFX Mini WW Intl"; Color = $true; Infrared = $false; Multizone = $false; HEV = $false } }
            default {
                if ($productRegistry) {
                    if ($_ -in $productRegistry.products.pid) {
                        $onlineProduct = $productRegistry.products | Where-Object { $ProductId -eq $_.pid }
                        $product = [PSCustomObject]@{
                            Id        = $_;
                            Name      = $onlineProduct.name;
                            Color     = $onlineProduct.features.color;
                            Infrared  = $onlineProduct.features.infrared;
                            Multizone = $onlineProduct.features.multizone;
                            HEV       = $onlineProduct.features.hev
                        }
                    }
                    else {
                        $product = $ProductId
                    }
                }
            }
        }

        return $product
    }
}
