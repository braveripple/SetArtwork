function Set-Artwork {
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
        [string[]]$LiteralPath,

        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $False, 
            ValueFromPipelineByPropertyName = $True)]
        [string]$ImagePath
    )
    begin {
        if (!(Test-Path -LiteralPath $ImagePath -PathType Leaf)) {
            Write-Error "ImagePath:${ImagePath} File Not Found."
        }
        try {
            $picture = [TagLib.Picture]::new($ImagePath)
        } catch {
            Write-Error $_.Exception.Message
        }
    }
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
                $operation = "Set Artwork Image: {0}" -f $ImagePath
                if ($PSCmdlet.ShouldProcess($target, $operation)) {
                    $file = Get-Item -LiteralPath $target
                    $metadata = [TagLib.File]::Create($file.FullName)
                    $metadata.Tag.Pictures = $picture
                    $metadata.Save();
                }
            }
        }
    }
}
