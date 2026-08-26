$env:PATH += ";C:\Users\ccummings\.local\bin"
$env:VIMDIR = "C:\Users\ccummings\AppData\Local\nvim"
$env:VIMVCDIR = "C:\projects\configvim"

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

function realpath {
    Resolve-Path $args[0] | Select-Object -First 1 -ExpandProperty Path | Tee-Object -Variable "copied" | Set-Clipboard; $copied
}

function svnurl {
    $dirpath = "."
    if ($args[0])
    {
        $dirpath = $args[0]
    }
    svn info $dirpath | sls "^URL:\s(.+)$" | ForEach-Object {$_.Matches[0].Groups[1].Value } | Tee-Object -Variable "copied" | Set-Clipboard; $copied
}

function findgame {
    param(
    [Parameter(Mandatory)]
    [string]$Name,

    [string]$Contains
    )
    $filter = if ($Contains) {
        "*$Name*$Contains*.tar.enc"
    }
    else {
        "*$Name*.tar.enc"
    }
    Get-ChildItem -Path G:\BuildStaging\GTI_Kit_Builds -Filter $filter -Recurse -ErrorAction SilentlyContinue| Select-Object -First 1 -ExpandProperty FullName | Tee-Object -Variable "copied" | Set-Clipboard; $copied
}

function findlatestplayer {
    param(
    [Parameter(Mandatory)]
    [string]$Name
    )

    Get-ChildItem -Path G:\Platform_Builds\Player_Kit_Builds\Built_Kits\$Name -Recurse -Filter "*.tar.enc" 2>$null | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName | Tee-Object -Variable "copied" | Set-Clipboard; $copied
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
        $Command = $($Command + ' | bat')
        Invoke-Expression $Command
    }
}

function updatevim {
    param(
        [Parameter(Mandatory)]
        [string]$Operation
    )

    if ($Operation -ieq "pull") {
        pushd $env:VIMVCDIR
        git pull origin master
        cp .\init.lua $env:VIMDIR\init.lua
        cp -r .\lua\* $env:VIMDIR\lua\
        popd
    }
    elseif ($Operation -ieq "push") {
        pushd $env:VIMVCDIR
        cp $env:VIMDIR\init.lua .
        cp -r $env:VIMDIR\lua\* .\lua\
        cp -r $env:VIMDIR\powershell\* .\powershell\
        git status
        popd
    }
    else {
        Write-Error "Operation must be 'push' or 'pull' (got: '$Operation')"
    }
}
