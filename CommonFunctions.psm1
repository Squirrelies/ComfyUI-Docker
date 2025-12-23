function Get-FunctionName {
    param (
        [int]$StackNumber = 1
    )
    $progressPreference = "silentlyContinue"
    return [string](Get-PSCallStack)[$StackNumber].FunctionName
}

function Get-GitHub-CommitHash {
    param(
        [Parameter(Mandatory)][string]$Organization,
        [Parameter(Mandatory)][string]$Repository,
        [string]$Reference = "main"
    )
    $progressPreference = "silentlyContinue"
    $httpResponse = Invoke-WebRequest -Headers @{"Accept" = "application/vnd.github.sha"; "X-GitHub-Api-Version" = "2022-11-28"; } -Uri "https://api.github.com/repos/${Organization}/${Repository}/commits/${Reference}"
    $commitHash = [System.Text.Encoding]::UTF8.GetString($httpResponse.Content)
    return [string]$commitHash
}

function Get-GitHub-CommitFile {
    param(
        [Parameter(Mandatory)][string]$Organization,
        [Parameter(Mandatory)][string]$Repository,
        [Parameter(Mandatory)][string]$Reference,
        [string]$FilePath = "README.md"
    )
    $progressPreference = "silentlyContinue"
    $httpResponse = Invoke-WebRequest -Headers @{"Accept" = "application/vnd.github.sha"; "X-GitHub-Api-Version" = "2022-11-28"; } -Uri "https://raw.githubusercontent.com/${Organization}/${Repository}/${Reference}/${FilePath}"
    if ($httpResponse.BaseResponse.IsSuccessStatusCode) {
        return [string]$httpResponse.Content
    }
    else {
        return $null
    }
}

function Get-ComfyUI-Version {
    param(
        [Parameter(Mandatory)][string]$Reference
    )
    [string]$fileContent = Get-GitHub-CommitFile -Organization "comfyanonymous" -Repository "ComfyUI" -Reference $Reference -FilePath "comfyui_version.py"
    if ($null -ne $fileContent) {
        if ($fileContent -match "__version__ = ""(?<version>.+)""") {
            [string]$versionValue = $Matches.version
            return [string]$versionValue
        }
        else {
            return $null
        }
    }
    else {
        return $null
    }
}
