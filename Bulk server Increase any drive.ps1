$vcServer = "daypmtprdprdvc1.servereps.local"
$vcUser = "administrator@vsphere.local"
$vcPass = "VMwar3!!"

Connect-VIServer -Server $vcServer -User $vcUser -Password $vcPass

# --- FILE PICKER ---
Add-Type -AssemblyName System.Windows.Forms

$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$FileBrowser.Filter = "Text files (*.txt)|*.txt"
$FileBrowser.Title = "Select VM List File"

if ($FileBrowser.ShowDialog() -ne "OK") {
    Write-Host "File selection cancelled. Exiting."
    exit
}

$vmList = Get-Content $FileBrowser.FileName

# --- GUEST CREDENTIAL ---
$guestCred = Get-Credential -Message "Enter Guest OS credentials"

foreach ($vmName in $vmList) {

    Write-Host "`nProcessing VM: $vmName" -ForegroundColor Cyan

    $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    if (!$vm) {
        Write-Host "VM not found: $vmName" -ForegroundColor Red
        continue
    }

    # --- GET E DRIVE INFO FROM GUEST ---
    try {
        $diskInfo = Invoke-Command -ComputerName $vmName -Credential $guestCred -ScriptBlock {
            $eDrive = Get-Volume -DriveLetter E -ErrorAction Stop
            $partition = Get-Partition -DriveLetter E
            $disk = Get-Disk -Number $partition.DiskNumber

            return [PSCustomObject]@{
                DriveLetter = "E"
                SizeGB = [math]::Round($eDrive.Size/1GB,2)
                DiskNumber = $partition.DiskNumber
                PartitionSizeGB = [math]::Round($partition.Size/1GB,2)
            }
        }
    }
    catch {
        Write-Host "Failed to get E drive info for $vmName" -ForegroundColor Yellow
        continue
    }

    # --- MATCH VMDK IN VC ---
    $hardDisks = Get-HardDisk -VM $vm

    $matchedDisk = $null

    foreach ($hd in $hardDisks) {
        # Match based on approximate size
        if ([math]::Round($hd.CapacityGB) -eq [math]::Round($diskInfo.PartitionSizeGB)) {
            $matchedDisk = $hd
            break
        }
    }

    if (!$matchedDisk) {
        Write-Host "Could not match E drive disk in VC for $vmName" -ForegroundColor Red
        continue
    }

    Write-Host "Disk Found:" -ForegroundColor Green
    Write-Host "Disk Number (OS): $($diskInfo.DiskNumber)"
    Write-Host "Current Size (GB): $($matchedDisk.CapacityGB)"

    # --- EXPAND PROMPT ---
    $choice = Read-Host "Do you want to expand E drive on $vmName? (Y/N)"
    if ($choice -ne "Y") {
        continue
    }

    $increaseGB = Read-Host "Enter size to increase in GB (e.g. 350)"

    if (-not ($increaseGB -as [int])) {
        Write-Host "Invalid input. Skipping..." -ForegroundColor Red
        continue
    }

    # --- EXPAND VMDK ---
    $newSize = $matchedDisk.CapacityGB + [int]$increaseGB

    Write-Host "Expanding disk in vCenter to $newSize GB..."
    Set-HardDisk -HardDisk $matchedDisk -CapacityGB $newSize -Confirm:$false

    # --- EXPAND INSIDE OS ---
    Invoke-Command -ComputerName $vmName -Credential $guestCred -ScriptBlock {
        $partition = Get-Partition -DriveLetter E
        $maxSize = (Get-PartitionSupportedSize -DriveLetter E).SizeMax
        Resize-Partition -DriveLetter E -Size $maxSize
    }

    Start-Sleep -Seconds 5

    # --- VERIFY FINAL SIZE ---
    $finalSize = Invoke-Command -ComputerName $vmName -Credential $guestCred -ScriptBlock {
        $vol = Get-Volume -DriveLetter E
        return [math]::Round($vol.Size/1GB,2)
    }

    Write-Host "Updated E Drive Size on $vmName $finalSize GB" -ForegroundColor Green
}

# --- DISCONNECT ---
Disconnect-VIServer -Server $vcServer -Confirm:$false

Write-Host "`nAll servers processed. Script complete." -ForegroundColor Cyan