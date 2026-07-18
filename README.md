# Bulk-any-one-Drive-Expansion-Automation-Tool-VMware
-------------------------------------------------------
PowerShell automation tool for safely expanding Windows E: drives on VMware virtual machines by automatically identifying the correct VMDK, extending the virtual disk in vCenter, and resizing the partition and volume inside the guest operating system.

Overview
---------
The VMware E Drive Expansion Automation Tool is designed to simplify and standardize disk expansion activities across multiple VMware virtual machines.
The script connects to vCenter, reads a list of virtual machines from a text file, identifies the E: drive inside the guest operating system, matches the corresponding VMDK in vCenter, performs a controlled disk expansion, and extends the partition within Windows.
This tool is particularly useful during:

Storage expansion projects
Low disk space remediation
Application growth initiatives
Capacity management activities
Data growth management
Infrastructure maintenance
VMware operations support
Bulk disk expansion activities

Features
--------
vCenter integration using PowerCLI
Graphical VM list file picker
Secure guest OS credential prompt
Automatic E: drive discovery
Automatic VMDK identification
Disk size validation
Interactive expansion approval
Custom expansion size input
Virtual disk expansion in vCenter
Guest OS partition expansion
Post-expansion validation
Multi-VM processing
Real-time status reporting

How It Works
--------------
The script performs the following actions:

Connects to vCenter Server
Loads a list of virtual machines from a text file
Prompts for guest OS credentials
Retrieves E: drive information from each VM
Identifies the corresponding VMDK in vCenter
Displays current disk information
Requests expansion approval
Requests expansion size
Expands the VMDK
Extends the Windows partition
Validates the new disk size
Reports final results
Disconnects from vCenter

vCenter Connectivity
----------------------
The script connects to a VMware vCenter environment using PowerCLI.
Connected Components:

vCenter Server
Virtual Machines
Virtual Hard Disks
Guest Operating Systems

The connection is established before processing begins and disconnected after all VMs have been processed.

VM List Format
---------------
Create a text file containing one virtual machine name per line.
Example:
SERVER01
SERVER02
SERVER03
SERVER04
SERVER05
When the script launches, a file browser allows selection of the VM list.

Guest OS Authentication
------------------------
The script prompts for guest operating system credentials.
Example:
DOMAIN\Administrator
or
SERVER01\Administrator
These credentials are used to:

Retrieve disk information
Extend partitions
Verify final disk sizes

E Drive Discovery
----------------
The script remotely queries each VM and gathers:

Drive Letter
Volume Size
Disk Number
Partition Size

Example:
Drive Letter: E
Size: 500 GB
Disk Number: 2
Partition Size: 500 GB

Disk Matching Logic
---------------------
The script automatically matches the Windows E: drive to the correct VMware VMDK.
Matching is performed using disk size correlation between:

Guest OS partition size
VMware virtual hard disk size

This reduces the risk of expanding the wrong virtual disk.
Example:
Windows E Drive: 500 GB
VMDK Size: 500 GB
Match Found: Yes

Expansion Workflow
-----------------------
Disk Identification
-------------------
The script displays information about the matched disk.
Example:
Disk Number (OS): 2
Current Size (GB): 500

Expansion Confirmation
----------------------
Before any changes are made, the script prompts:
Do you want to expand E drive on SERVER01? (Y/N)
This provides a manual approval checkpoint.

Expansion Size Entry
---------------------
The administrator specifies how much additional storage should be added.
Example:
350
The script calculates the new VMDK size automatically.
Example:
Current Size: 500 GB
Requested Increase: 350 GB
New Size: 850 GB

VMware Disk Expansion
----------------------
The script expands the VMDK using:
Set-HardDisk
The change is applied directly within vCenter.

Windows Partition Expansion
------------------------------
After the VMDK expansion completes, the script extends the E: partition inside Windows using:
Resize-Partition
The partition is resized to the maximum supported size.

Verification
--------------
The script retrieves the updated E: drive size and displays the final result.
Example:
Updated E Drive Size on SERVER01 850 GB

Error Handling
--------------
The script includes validation and error handling for common issues.
VM Not Found
Example:
VM not found: SERVER01
E Drive Discovery Failure
Example:
Failed to get E drive info for SERVER01
Disk Match Failure
Example:
Could not match E drive disk in VC for SERVER01
Invalid Expansion Input
Example:
Invalid input. Skipping...
Servers with errors are skipped while processing continues for remaining virtual machines.

Prerequisites
--------------
PowerCLI:
VMware PowerCLI installed

vCenter Access:
Access to target vCenter Server
Permissions to modify virtual disks

Guest OS Access:
Administrative access inside Windows guest operating systems
PowerShell remoting enabled if required by environment

VMware Requirements:
Virtual machines managed by vCenter
Hot disk expansion supported where applicable
VMware Tools installed and healthy

Windows Requirements:
Target servers should support:

Get-Volume
Get-Partition
Get-Disk
Resize-Partition

Usage
-------
Run the script:
.\VMware-EDrive-Expansion.ps1
Select the VM list file.
Enter guest OS credentials.
Review discovered disk information.
Approve expansion when prompted.
Enter expansion size in GB.
Allow the script to complete the expansion.
Review the final validation output.

Example Workflow
-----------------
Storage Expansion Project

Export target VM list to a text file
Launch the script
Select the VM inventory file
Enter guest credentials
Review identified E: drives
Approve disk expansions
Enter required growth size
Monitor expansion progress
Verify final disk sizes

Example Output
--------------
Processing VM: APPSERVER01
Disk Found:
Disk Number (OS): 2
Current Size (GB): 500
Do you want to expand E drive on APPSERVER01? (Y/N)
Y
Enter size to increase in GB:
350
Expanding disk in vCenter to 850 GB...
Updated E Drive Size on APPSERVER01 850 GB

Benefits
----------
Eliminates manual vCenter disk management
Reduces risk of selecting incorrect VMDKs
Automates Windows partition extension
Speeds up storage expansion activities
Provides expansion validation
Supports bulk VM processing
Standardizes storage growth procedures
Improves operational efficiency

Use Cases
----------
VMware storage expansion projects
Capacity management initiatives
Database growth management
Application storage expansion
Infrastructure upgrades
Low disk space remediation
Data center operations
Windows server maintenance

Limitations
---------------
Requires VMware PowerCLI
Requires vCenter connectivity
Requires guest OS credentials
Assumes E: drive exists
Matching is based on disk size correlation
Processes virtual machines sequentially
Requires sufficient datastore capacity
User interaction required for each expansion

Future Enhancements
-------------------
CSV reporting
Expansion logging
Fully automated approval mode
Email notifications
Parallel processing
Multi-drive support
Datastore capacity validation
Change tracking reports
Expansion rollback validation
Bulk expansion configuration files


Author
-------
Sundaram Gaur
Senior Systems Engineer | VMware | PowerShell Automation | Infrastructure Operations

Disclaimer
-----------
This script performs live storage modifications on VMware virtual machines and Windows guest operating systems. Use only with appropriate administrative permissions and approved change controls. Always validate backups, datastore capacity, and expansion requirements before executing in production environments.
