
#$DebugPreference = "Continue"
#$DebugPreference = "SilentlyContinue"

function intToIp {
    param($ipNum)
    
    $stringBuilder = New-Object -TypeName System.Text.StringBuilder

    for ($i = 0; $i -lt 4; $i++) {
        [void]$stringBuilder.Append([string]($ipNum -shr (8 * (3 - $i)) -band 0xFF))

        if ($i -ne 3)
        {
            [void]$stringBuilder.Append(".")
        }
    }

    Write-Debug "IP Number to String: $($stringBuilder.ToString())"

    return $stringBuilder.ToString()

}

function cidrIPTranslation{
    param([string]$ip,
          [int]$prefix 
         )
    
    [byte[]]$splitIp = $ip -split "\."
    [uint]$ipNum = 0


    for ($i = 0; $i -lt $splitIp.Length; $i++) {
        [uint]$shifted = [uint]([int]::Parse($splitIp[$i])) -shl (8 * (3 - $i))
        Write-Debug "Octet $i`: $($splitIp[$i]) << $(8 * (3 - $i)) = $shifted"
        $ipNum += $shifted
    }

    Write-Debug "Decimal Value: $ipNum"
    Write-Debug "Binary Value: $([Convert]::ToString($ipNum, 2).PadLeft(32, '0'))"

    $hostBits = 32 - $prefix
    Write-Debug "Host Bits: $($hostBits)"

    $total_addresses = [Math]::Pow(2, $hostBits)
    Write-Debug "Total Addresses: $($total_addresses)"

    $subnetMask = (0xFFFFFFFF -shl $hostBits) -band 0xFFFFFFFF
    Write-Debug "Subnet Mask: $($subnetMask)"

    $networkInt = $ipNum -band $subnetMask
    Write-Debug "Network Integer Value: $($networkInt)"

    $broadcastInt = $networkInt -bor ($total_addresses - 1)
    Write-Debug "Broadcast Integer Value: $($broadcastInt)"

    return @{
        'Network IP' = intToIp -ipNum $networkInt
        'Broadcast IP' = intToIp -ipNum $broadcastInt
        'Subnet Mask' = intToIp -ipNum $subnetMask
        'Total Addresses' = $total_addresses
        'First Host' = intToIp -ipNum ($networkInt + 1)
        'Last Host' = intToIp -ipNum ($broadcastInt - 1)
    }

}

