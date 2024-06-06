# Check if the Active Directory module is installed
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    # Check if the RSAT-AD-PowerShell module is installed
    if (-not (Get-Module -ListAvailable -Name RSAT-AD-PowerShell)) {
        # Install the RSAT-AD-PowerShell module
        Install-Module -Name RSAT-AD-PowerShell -Force
    }
    # Import the Active Directory module
    Import-Module ActiveDirectory
}

# Clear the screen
Clear-Host

# The name of the AD group you're searching for
$groupName = "SIM_Group_Prod-User"

# Read user accounts from a file
$userList = Get-Content "C:\Users\simulated_user\OneDrive\Desktop\dev\power_shell\users_to_ADGroup.txt"

# Initialize an array to hold the results for the grid view
$results = @()

# Retrieve current members of the group
$serverName = "SIM_SERVER01.simulated.biz"
$currentGroupMembers = Get-ADGroupMember -Identity $groupName -Server $serverName | Select-Object -ExpandProperty SamAccountName

# Loop through each user in the list
foreach ($user in $userList) {
    # Remove any enter or empty spaces from the user
    $user = $user.Trim()

    # Check if the user already exists in the group
    if ($user -in $currentGroupMembers) {
        # User exists in the group, prepare message
        $message = "$user is already a member of $groupName."
        $results += [PSCustomObject]@{
            User = $user
            Status = "Already in Group"
            Message = $message
        }
    } else {
        # Try to add the user to the group
        try {
            Add-ADGroupMember -Identity $groupName -Members $user -Server $serverName -ErrorAction Stop
            $message = "$user has been added to $groupName successfully."
            $results += [PSCustomObject]@{
                User = $user
                Status = "Added"
                Message = $message
            }
        } catch {
            $message = "Failed to add $user to $groupName. Error: $_"
            $results += [PSCustomObject]@{
                User = $user
                Status = "Failed"
                Message = $message
            }
        }
    }
}

# Display the results in a grid view
$results | Out-GridView -Title "AD Group Membership Update Results"

print("User " + $user + " added to access group " + $groupName + " on server " + $serverName + ". If you have any questions, please let me know. Simulated User")
