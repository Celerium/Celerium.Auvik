function Initialize-AuvikModuleSetting {
<#
    .SYNOPSIS
        Loads the Auvik module settings when the module is imported

    .DESCRIPTION
        The Initialize-AuvikModuleSetting cmdlet loads either the baseline settings or the saved
        configuration (and the AUVIK_* environment variables) by calling Import-AuvikModuleSetting

        This function is called automatically when the module is imported

    .EXAMPLE
        Initialize-AuvikModuleSetting

        Loads the saved Auvik settings into the current session

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Initialize-AuvikModuleSetting.html
#>

    [CmdletBinding()]
    param ()

    begin {}

    process {
        Import-AuvikModuleSetting -Verbose:$false
    }

    end {}

}

#Used to auto load either baseline settings or saved configurations when the module is imported
Initialize-AuvikModuleSetting
