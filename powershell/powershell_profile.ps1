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
        cd $env:VIMVCDIR
        cp $env:VIMDIR\init.lua .
        cp -r $env:VIMDIR\lua\* .\lua\
        cp -r $env:VIMDIR\powershell\* .\powershell\
        git status
    }
    else {
        Write-Error "Operation must be 'push' or 'pull' (got: '$Operation')"
    }
}

function Get-ChildItemHuman {
    Get-ChildItem @args | ForEach-Object {
        if ($_.PSIsContainer) {
            # Return directories normally
            $_
        } else {
            # Calculate human-readable string for files
            $size = $_.Length
            $labels = "Bytes", "KB", "MB", "GB", "TB"
            $index = 0
            while ($size -ge 1024 -and $index -lt ($labels.Length - 1)) {
                $size /= 1024
                $index++
            }
            $friendlySize = "{0:N2} {1}" -f $size, $labels[$index]
            # Add the custom property to the output object
            $_ | Add-Member -MemberType NoteProperty -Name "FriendlySize" -Value $friendlySize -PassThru
        }
    } | Select-Object Name, FriendlySize, LastWriteTime, Mode
}

Set-Alias -Name lsh -Value Get-ChildItemHuman

if (-not ([System.Management.Automation.PSTypeName]'Win32').Type) {
        Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        using System.Text;
        using System.Collections.Generic;
        namespace WinApi
        {
            public class WinStruct
            {
                public string WinTitle {get; set; }
                public int WinHwnd { get; set; }
            }
            public class Win32
            {
                private delegate bool CallBackPtr(int hwnd, int lParam);
                private static CallBackPtr callBackPtr = Callback;
                private static List<WinStruct> _WinStructList = new List<WinStruct>();


                [DllImport("user32.dll")]
                public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);
                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                private static extern bool EnumWindows(CallBackPtr lpEnumFunc, IntPtr lParam);
                [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
                static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
                [DllImport("user32.dll", SetLastError = true)]
                public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

                private static bool Callback(int hWnd, int lparam)
                {
                    StringBuilder sb = new StringBuilder(256);
                    int res = GetWindowText((IntPtr)hWnd, sb, 256);
                    _WinStructList.Add(new WinStruct { WinHwnd = hWnd, WinTitle = sb.ToString() });
                    return true;
                }

                public static List<WinStruct> GetWindows()
                {
                    _WinStructList = new List<WinStruct>();
                    EnumWindows(callBackPtr, IntPtr.Zero);
                    return _WinStructList;
                }
            }
        }
"@
}

function Get-WindowTitles {
    Get-Process | Where-Object { $_.MainWindowTitle } | ForEach-Object {
        $sb = New-Object System.Text.StringBuilder 256
        [WinApi.Win32]::GetClassName($_.MainWindowHandle, $sb, $sb.Capacity)
        [PSCustomObject]@{
            Process = $_.Name
            Title   = $_.MainWindowTitle
            Class   = $sb.ToString()
        }
    } | Format-Table -AutoSize
}
Set-Alias gwt Get-WindowTitles

function Find-Ssms-WindowTitles {
    [WinApi.Win32]::GetWindows() | Where-Object { $_.WinTitle -like "*ssms*" } | Sort-Object -Property WinTitle
}

function Close-Ssms-Connect-Window {
    $winhwnd = [WinApi.Win32]::GetWindows() | Where-Object { $_.WinTitle -like "Connect" } | Select-Object -Property WinHwnd -First 1;
    [WinApi.Win32]::SendMessage($winhwnd.WinHwnd, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)
}
