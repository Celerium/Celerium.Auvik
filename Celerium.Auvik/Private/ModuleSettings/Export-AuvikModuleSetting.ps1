function Export-AuvikModuleSetting {
<#
    .SYNOPSIS
        Exports the Auvik BaseURI, API, & JSON configuration information to file

    .DESCRIPTION
        The Export-AuvikModuleSetting cmdlet exports the Auvik BaseURI, API, & JSON configuration information to file

        Making use of PowerShell's System.Security.SecureString type, exporting module settings encrypts your API key in a format
        that can only be unencrypted with the your Windows account as this encryption is tied to your user principal
        This means that you cannot copy your configuration file to another computer or user account and expect it to work

    .PARAMETER AuvikConfigPath
        Define the location to store the Auvik configuration file

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfigFile
        Define the name of the Auvik configuration file

        By default the configuration file is named:
            config.psd1

    .EXAMPLE
        Export-AuvikModuleSetting

        Validates that the BaseURI, API, and JSON depth are set then exports their values
        to the current user's Auvik configuration file located at:
            $env:USERPROFILE\Celerium.Auvik\config.psd1

    .EXAMPLE
        Export-AuvikModuleSetting -AuvikConfigPath C:\Celerium.Auvik -AuvikConfigFile MyConfig.psd1

        Validates that the BaseURI, API, and JSON depth are set then exports their values
        to the current user's Auvik configuration file located at:
            C:\Celerium.Auvik\MyConfig.psd1

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Export-AuvikModuleSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Set')]
    Param (
        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfigPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') {"Celerium.Auvik"}else{".Celerium.Auvik"}) ),

        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfigFile = 'config.psd1'
    )

    begin {}

    process {

        Write-Warning "Secrets are stored using Windows Data Protection API (DPAPI)"
        Write-Warning "DPAPI provides user context encryption in Windows but NOT in other operating systems like Linux or UNIX. It is recommended to use a more secure & cross-platform storage method"

        $AuvikConfig = Join-Path -Path $AuvikConfigPath -ChildPath $AuvikConfigFile

        # Confirm variables exist and are not null before exporting
        if ($AuvikModuleBaseURI -and $AuvikModuleUserName -and $AuvikModuleApiKey -and $AuvikJSONConversionDepth) {
            $secureString = $AuvikModuleApiKey | ConvertFrom-SecureString

            if ($IsWindows -or $PSEdition -eq 'Desktop') {
                New-Item -Path $AuvikConfigPath -ItemType Directory -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor "Hidden" }
            }
            else{
                New-Item -Path $AuvikConfigPath -ItemType Directory -Force
            }
@"
    @{
        AuvikModuleBaseURI          = '$AuvikModuleBaseURI'
        AuvikModuleUserName         = '$AuvikModuleUserName'
        AuvikModuleApiKey           = '$secureString'
        AuvikJSONConversionDepth    = '$AuvikJSONConversionDepth'
    }
"@ | Out-File -FilePath $AuvikConfig -Force
        }
        else {
            Write-Error "Failed to export Auvik Module settings to [ $AuvikConfig ]"
            Write-Error $_
            exit 1
        }

    }

    end {}

}