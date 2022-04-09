function Export-Artwork {
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
                $operation = "Export Artwork" -f $ImagePath
                if ($PSCmdlet.ShouldProcess($target, $operation)) {
                    $file = Get-Item -LiteralPath $target
                    $metadata = [TagLib.File]::Create($file.FullName)
                    if ($metadata.Tag.Pictures.MimeType -like "image/*") {
                        $ImageExtension = ($metadata.Tag.Pictures.MimeType -replace "image/",".").ToLower()
                        $ImagePath = (Join-Path -Path (Get-Location) -ChildPath $file.Name) + $ImageExtension
                        $ms = [System.IO.MemoryStream]::new($metadata.Tag.Pictures.Data)
                        $image = [System.Drawing.Image]::FromStream($ms)
                        $image.Save($ImagePath)
                        $ms.Close()
                        $ms.Dispose()
                        Get-Item -LiteralPath $ImagePath
                    }
                }
            }
        }
    }
}
