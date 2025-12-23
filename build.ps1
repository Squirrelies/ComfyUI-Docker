Import-Module "${PSScriptRoot}\CommonFunctions" -DisableNameChecking

try {
    $xformersReference = "main"
    $xformersCommitHash = Get-GitHub-CommitHash -Organization "facebookresearch" -Repository "xformers" -Reference $xformersReference

    $env:CONT_XFORMERS_COMMIT_HASH_FULL = $xformersCommitHash
    $env:CONT_XFORMERS_COMMIT_HASH_SHORT = $xformersCommitHash.Substring(0, 7)
    Write-Host "Found xformers commit hash ""$($env:CONT_XFORMERS_COMMIT_HASH_SHORT)"" (${env:CONT_XFORMERS_COMMIT_HASH_FULL}) for ""${xformersReference}""."


    $sageAttentionReference = "05ddb3bbaddef8dd375f37ddd31896e6da2a8751"
    $sageAttentionCommitHash = Get-GitHub-CommitHash -Organization "woct0rdho" -Repository "SageAttention" -Reference $sageAttentionReference

    $env:CONT_SAGEATTN_COMMIT_HASH_FULL = $sageAttentionCommitHash
    $env:CONT_SAGEATTN_COMMIT_HASH_SHORT = $sageAttentionCommitHash.Substring(0, 7)
    Write-Host "Found SageAttention commit hash ""$($env:CONT_SAGEATTN_COMMIT_HASH_SHORT)"" (${env:CONT_SAGEATTN_COMMIT_HASH_FULL}) for ""${sageAttentionReference}""."


    $comfyuiReference = "master" # tag as "refs/tags/v0.4.0" or branch as "refs/heads/v3-improvements" or "v3-improvements"
    $comfyuiCommitHash = Get-GitHub-CommitHash -Organization "comfyanonymous" -Repository "ComfyUI" -Reference $comfyuiReference
    $comfyuiCommitVersion = Get-ComfyUI-Version -Reference $comfyuiCommitHash

    $env:CONT_COMFYUI_COMMIT_HASH_FULL = $comfyuiCommitHash
    $env:CONT_COMFYUI_COMMIT_HASH_SHORT = $comfyuiCommitHash.Substring(0, 7)
    $env:CONT_COMFYUI_COMMIT_VERSION = $comfyuiCommitVersion
    Write-Host "Found ComfyUI commit hash ""$($env:CONT_COMFYUI_COMMIT_HASH_SHORT)"" (${env:CONT_COMFYUI_COMMIT_HASH_FULL}) for ""${comfyuiReference}""."
    Write-Host "ComfyUI version: $($env:CONT_COMFYUI_COMMIT_VERSION)"


    Start-Process -FilePath "Docker.exe" -ArgumentList "compose build" -Wait -NoNewWindow
    Start-Process -FilePath "Docker.exe" -ArgumentList "compose create --no-build" -Wait -NoNewWindow
}
catch {
    Write-Host $_
}
