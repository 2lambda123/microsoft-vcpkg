[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true, Position=0)][string]$leftPath,
    [Parameter(Mandatory=$true, Position=1)][string]$rightPath
)

function toPassMap([xml]$asText)
{
    $ports = @{}
    foreach($entry in $asText.assemblies.assembly.collection.test)
    {
        $name = $entry.name.substring(0, $entry.name.indexOf(':'))
        $ports.add($name, $entry.result)
    }

    return $ports
}

[xml]$left = Get-Content $leftPath
[xml]$right = Get-Content $rightPath

$leftPortsPassMap = toPassMap($left)
$rightPortsPassMap = toPassMap($right)

$keys = $leftPortsPassMap.keys + $rightPortsPassMap.keys | select -unique | sort-object

$differences = New-Object System.Collections.ArrayList
foreach ($key in $keys)
{
    $l = $leftPortsPassMap[$key]
    $r = $rightPortsPassMap[$key]

    if ($l -eq "Skip" -or $r -eq "Skip")
    {
        continue
    }

    if ($l -ne $r)
    {
        $differences.add($key) > $null
    }
}

$diffCount = $differences.Count
Write-Host "Number of differences found: $diffCount"
$title = "{0,20} : {1,20} VS {2,20}" -f "DiffsTable", $leftPath, $rightPath
Write-Host $title

foreach ($key in $differences)
{
    $l1 = $leftPortsPassMap[$key]
    $r1 = $rightPortsPassMap[$key]
    $string = "{0,20} : {1,20} VS {2,-20}" -f $key, $l1, $r1
    $string
}
