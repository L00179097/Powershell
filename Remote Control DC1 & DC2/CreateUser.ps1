# Enter a path to your import CSV file
$ADUsers = Import-csv C:\PowerShell\CLOUDSTUDENTS.csv
 
# Corrected domain name
$Organisation = "DC=l00179097,DC=ie"
$Classgroup = "PGDipCLOD2024"
 
# Add OUs for User and for this specific group
Get-ADOrganizationalUnit
 
 
New-ADOrganizationalUnit -Name $Classgroup -Path $Organisation -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Users" -Path "OU=$Classgroup,$Organisation" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Groups" -Path "OU=$Classgroup,$Organisation" -ProtectedFromAccidentalDeletion $false
 
# Add an OU for domain servers
New-ADOrganizationalUnit -Name "Servers" -Path "OU=$Classgroup,$Organisation" -ProtectedFromAccidentalDeletion $false
 
# Create a group for these users
New-ADGroup -Name $Classgroup -Description "PGDip Cloud 2024" -GroupCategory Security -GroupScope DomainLocal -Path "OU=Groups,OU=$Classgroup,$Organisation"
 
foreach ($User in $ADUsers) {
    $Username    = $User.Username
    $Password    = $User.Password
    $Firstname   = $User.Firstname
    $Lastname    = $User.Lastname
    $Department  = $User.Department
    $OU          = $User.OU
 
    Write-Host "Processing user: $Firstname $Lastname ($Username)"
 
    # Check if the user account already exists in AD
    if (Get-ADUser -Filter {SamAccountName -eq $Username}) {
        # If user does exist, output a warning message
        Write-Warning "A user account $Username already exists in Active Directory."
    } else {
        # If a user does not exist, create a new user account
        # Account will be created in the OU listed in the $OU variable in the CSV file
        Write-Host "Creating user '$Username' in OU '$OU'..."
        try {
            # Create the new user account
            New-ADUser `
                -SamAccountName $Username `
                -UserPrincipalName "$Username@l00179097.sathish.ie" `
                -Name "$Firstname $Lastname" `
                -GivenName $Firstname `
                -Surname $Lastname `
                -Enabled $True `
                -ChangePasswordAtLogon $True `
                -DisplayName "$Lastname, $Firstname" `
                -Department $Department `
                -Path $OU `
                -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force)
 
            Write-Host "User '$Username' created successfully."
 
            # Add or change any other parameters
            Set-ADUser -Identity $Username -Description "PGDip Student" -Organization "ATU"
            Write-Host "Updated user '$Username' properties."
 
            # Check if the group exists before adding the user to the group
            if (-not (Get-ADGroup -Filter {Name -eq $Classgroup})) {
                Write-Error "Group '$Classgroup' does not exist in Active Directory."
            } else {
                Add-ADGroupMember -Identity $Classgroup -Members $Username
                Write-Host "User '$Username' added to group '$Classgroup'."
            }
        }
        catch {
            Write-Error "Failed to create or process user '$Username': $_"
        }
    }
}