function Clear-Artwork {
    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParameterSetName = 'Path'
    )]
    param (
        [SupportsWildCards()]
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ParameterSetName = 'Path',
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True)]
        [string[]]$Path,
    
        [Alias('LP')]
        [Alias('PSPath')]
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ParameterSetName = 'LiteralPath',
            ValueFromPipeline = $False, 
            ValueFromPipelineByPropertyName = $True)]
        [string[]]$LiteralPath
    )
    process {
        $InputPath = if ($PSBoundParameters.ContainsKey('Path')) { $Path } else { $LiteralPath }
        foreach ($p in $InputPath) {
            try {
                $param = @{ $PSCmdlet.ParameterSetName = $p }
                $targets = @(Convert-Path @param -ErrorAction Stop)
            }
            catch {
                Write-Error $_.Exception.Message -ErrorAction Continue
                if ($ErrorActionPreference -eq "Stop") {
                    return
                }
                $targets = @()
            }
            foreach ($target in $targets) {
                if ($PSCmdlet.ShouldProcess($target, "Clear Artwork")) {
                    $file = Get-Item -LiteralPath $target
                    $metadata = [TagLib.File]::Create($file.FullName)
                    $metadata.Tag.Pictures = [TagLib.Picture]::new()
                    $metadata.Save();
                }
            }
        }
    }
}
