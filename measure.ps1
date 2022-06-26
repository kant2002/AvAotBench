class ProcessMeasurement
{
    [int]$Iterations = 1
    [bool]$Verbose = $false

    [double]Measure([string]$SampleName, [string]$rid)
    {
        $start=date;
        $failed = 0
        $last = 0.0
        for ($i = 0; $i -lt $this.Iterations; $i++)
        {
            "$SampleName\bin\Release\net6.0\$rid\publish\$SampleName.exe"
            $current = ($(date) -$start).TotalMilliseconds
            if ($this.Verbose)
            {
                Write-Host ($current - $last)
            }

            $last = $current
        }

        $duration = ($(date) -$start).TotalMilliseconds
        if ($failed > 0)
        {
            Write-Host "Failed iterations " $failed
        }

        if ($this.Verbose)
        {
            Write-Host "Total duration " $duration
        }

        $avg = $duration / ($this.Iterations - $failed)
        if ($this.Verbose)
        {
            Write-Host "Avg. duration " $duration
        }

        return $avg
    }
}

$measure = New-Object -TypeName ProcessMeasurement
$measure.Iterations = 1 # We want to measure cold start, otherwise subsequent runs would run faster.
$measure.Verbose = $false

Write-Host "Building Trimmed app"
dotnet publish AvaloniaAotBench/AvaloniaAotBench.csproj -c Release -r win-x64 /p:Mode=Trimmed | Out-Null
Write-Host "Measuring Trimmed app"
$TrimmedTime=$measure.Measure("AvaloniaAotBench", "win-x64")
Write-Host "Trimmed " $TrimmedTime " ms"

Write-Host "Building R2R app"
dotnet publish AvaloniaAotBench/AvaloniaAotBench.csproj -c Release -r win-x64 /p:Mode=R2R | Out-Null
Write-Host "Measuring R2R app"
$R2RTime=$measure.Measure("AvaloniaAotBench", "win-x64")
Write-Host "R2R " $R2RTime " ms"

Write-Host "Building R2R Composite app"
dotnet publish AvaloniaAotBench/AvaloniaAotBench.csproj -c Release -r win-x64 /p:Mode=R2R | Out-Null
Write-Host "Measuring R2R Composite app"
$R2RCompositeTime=$measure.Measure("AvaloniaAotBench", "win-x64")
Write-Host "R2R Composite " $R2RCompositeTime " ms"

Write-Host "Building NativeAOT app"
dotnet publish AvaloniaAotBench/AvaloniaAotBench.csproj -c Release -r win-x64 /p:Mode=NativeAOT | Out-Null
Write-Host "Measuring NativeAOT app"
$NativeAOTTime=$measure.Measure("AvaloniaAotBench", "win-x64")
Write-Host "NativeAOT " $NativeAOTTime " ms"