$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

function realpath {
    Resolve-Path $args[0]
}

function svnurl {
    svn info | sls "^URL:\s(.+)$" | ForEach-Object {$_.Matches[0].Groups[1].Value } | Tee-Object -Variable "copied" | Set-Clipboard;
    $copied
}

function findgame {
    Get-ChildItem -Path G:\BuildStaging\GTI_Kit_Builds -Filter "*$($args[0])*.tar.enc" -Recurse -Name | Select-Object -First 1 | Tee-Object -Variable "copied" | Set-Clipboard;
    $copied
}

function svndiff {
    param([string]$P,[string]$Revision)
    $Command = 'svn diff -x --ignore-eol-style --patch-compatible'
    if ($Revision) {
        $Revisions = $Revision.Split(':')
        if (!$Revisions[0] -or !$Revisions[1]) {
            echo 'please provide -Revision as an argument in the form "REVISION1:REVISION2"'
        }
        $Command = $('svn diff -r ' + $Revision + ' -x --ignore-eol-style --patch-compatible')
    }
    if ($P) {
        $Temp = New-TemporaryFile
        $OutFile = $($pwd.Path + '\' + $P)
        echo $OutFile
        $Command = $($Command + ' > ' + $Temp)
        echo $Command
        Invoke-Expression $Command
        $Content = [IO.File]::ReadAllLines($Temp)
        [IO.File]::WriteAllLines($OutFile, $Content)
    }
    else {
        echo $Command
        Invoke-Expression $Command
    }
}
clear
