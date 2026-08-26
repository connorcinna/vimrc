$confirmation = Read-Host "Build Succeeded! SCP to devkit? (y/n)"

if ($confirmation -ieq "y") {
    $ip = Read-Host "Enter the target IP address"

    if ([string]::IsNullOrWhiteSpace($ip)) {
        Write-Error "IP address cannot be empty."
        exit 1
    }

    $directory = "directory"  # replace with your actual path, or prompt for it too

    scp -r $directory "cjdev@${ip}:"
}
else {
    Write-Host "Aborted."
}
