## PowerShell Script for Active Directory Setup and Configuration

This PowerShell script provides a detailed approach to setting up and configuring Active Directory (AD), DNS, DHCP, and Organizational Units (OUs) for a domain. Additionally, it includes steps for importing user details from a CSV file and configuring a secondary domain controller for redundancy. The script is designed to streamline the process of managing a domain environment, ensuring consistency, and reducing manual errors during setup.

---

### **Script Overview**

#### **1. Install AD-Domain Services**
This section of the script installs the Active Directory Domain Services role on the server and sets up a new AD forest. The forest is configured with the domain name `l00179097.ie`. The AD database and SYSVOL paths are specified as `C:\Windows\NTDS` and `C:\Windows\SYSVOL`, respectively. Additionally, DNS is installed as part of the setup, and the domain and forest modes are set to "WinThreshold" to ensure compatibility with the latest Windows Server features. The server is restarted automatically after completing the setup.

```powershell
Install-WindowsFeature -name AD-Domain-Services –IncludeManagementTools

Import-Module ADDSDeployment
Install-ADDSForest `
  -CreateDnsDelegation:$false `
  -DatabasePath "C:\Windows\NTDS" `
  -DomainMode "WinThreshold" `
  -DomainName "l00179097.ie" `
  -DomainNetbiosName "l00179097" `
  -ForestMode "WinThreshold" `
  -InstallDns:$true `
  -LogPath "C:\Windows\NTDS" `
  -NoRebootOnCompletion:$false `
  -SysvolPath "C:\Windows\SYSVOL" `
  -Force:$true

Shutdown /r /t 0
```
![](https://github.com/L00179097/Powershell/blob/main/SS/1.png)
![](https://github.com/L00179097/Powershell/blob/main/SS/2.png)
---

#### **2. Configure DC1 (Primary Domain Controller)**
The primary domain controller (DC1) is set up with a static IP address, a hostname (`dc1`), and its role as the main controller for the forest. The script also installs the DHCP role and adds a DHCP scope named "InfraServers". The time synchronization for the server is configured to use a local NTP server at `192.168.1.254`. These configurations are essential to ensure the reliability of network services provided by DC1.

```powershell
$SERVERNAME = "dc1"
$FOREST = "l00179097.ie"
$DNSNAME = $SERVERNAME + "." + $FOREST

Rename-Computer -NewName $SERVERNAME
Get-NetIPAddress
New-NetIPAddress -InterfaceIndex 2 -IPAddress 192.168.1.80 -PrefixLength 24 -DefaultGateway 192.168.1.20
Restart-Computer

Install-ADDSForest -DomainName $FOREST
Install-WindowsFeature DHCP -IncludeManagementTools

Add-DhcpServerInDC -DnsName $DNSNAME -IPAddress 192.168.1.11
Add-DhcpServerv4Scope -Name InfraServers -StartRange 192.168.1.150 -EndRange 192.168.1.199 -SubnetMask 255.255.255.0

w32tm /config /manualpeerlist:192.168.1.254 /syncfromflags:manual /update
```

---

#### **3. Configure DC2 (Secondary Domain Controller)**
The secondary domain controller (DC2) is added to the existing domain to provide redundancy and load balancing. The script assigns a static IP address to DC2 and sets its DNS server to point to the primary controller (192.168.1.80). After joining the domain, the AD Domain Services role is installed, and DC2 is configured as a secondary domain controller. DHCP is also set up on this server with a scope configured for a different IP range. This ensures fault tolerance for critical network services.

```powershell
$SERVERNAME = "DC2"
$FOREST = "l00179097.ie"
$DNSNAME = $SERVERNAME + "." + $FOREST

Rename-Computer -NewName $SERVERNAME
Get-NetIPAddress
New-NetIPAddress -InterfaceIndex 2 -IPAddress 192.168.13.152 -PrefixLength 24 -DefaultGateway 192.168.13.1
Set-DnsClientServerAddress -InterfaceIndex 2 -ServerAddresses 192.168.1.80
Restart-Computer

Add-Computer -DomainName $FOREST -Restart

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Install-ADDSDomainController -DomainName $FOREST -InstallDns:$true -Credential (Get-Credential "sorna\administrator")

Install-WindowsFeature DHCP -IncludeManagementTools
Add-DhcpServerInDC -DnsName $DNSNAME -IPAddress 192.168.13.10
```



![](https://github.com/L00179097/Powershell/blob/main/SS/6.png)

![](https://github.com/L00179097/Powershell/blob/main/SS/3.png)

---

#### **4. Bulk User Creation from CSV**
This section imports user data from a CSV file and creates user accounts in Active Directory. The script defines Organizational Units (OUs) for users, groups, and servers within the domain. It creates a security group named `PGDipCLOD2024` and adds users to this group. For each user in the CSV file, the script verifies if the user account already exists, and if not, creates a new account with the provided details. Each user is also added to the specified group. 

**CSV File Format (Updated on 2025-01-04):**
The input CSV file must have the following columns:
```csv
Firstname,Lastname,Username,Department,Password,OU
Sathish,Kumar,L00179097,PGDipCLOD2024,Passw0rd,"OU=User,OU=PGDipCLOD2024,DC=atu,DC=sathish,DC=com"


```
The CSV file should be placed at `C:\PowerShell\CLOUDSTUDENTS.csv`.

```powershell
$ADUsers = Import-csv C:\PowerShell\CLOUDSTUDENTS.csv

$Organisation = "DC=l00179097,DC=ie"
$Classgroup = "PGDipCLOD2024"

New-ADOrganizationalUnit -Name $Classgroup -Path $Organisation -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Users" -Path "OU=$Classgroup,$Organisation" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Groups" -Path "OU=$Classgroup,$Organisation" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Servers" -Path "OU=$Classgroup,$Organisation" -ProtectedFromAccidentalDeletion $false

New-ADGroup -Name $Classgroup -Description "PGDip Cloud 2024" -GroupCategory Security -GroupScope DomainLocal -Path "OU=Groups,OU=$Classgroup,$Organisation"

foreach ($User in $ADUsers) {
    $Username    = $User.Username
    $Password    = $User.Password
    $Firstname   = $User.Firstname
    $Lastname    = $User.Lastname
    $Department  = $User.Department
    $OU          = $User.OU

    if (Get-ADUser -Filter {SamAccountName -eq $Username}) {
        Write-Warning "A user account $Username already exists in Active Directory."
    } else {
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

        Set-ADUser -Identity $Username -Description "PGDip Student" -Organization "ATU"

        if (Get-ADGroup -Filter {Name -eq $Classgroup}) {
            Add-ADGroupMember -Identity $Classgroup -Members $Username
        }
    }
}
```

![](https://github.com/L00179097/Powershell/blob/main/SS/5.png)

---

### **Additional Notes**
- Ensure the script is run with administrative privileges.
- Review the domain and network configurations for compatibility with your environment.
- Test the script in a lab environment before deploying it in production to avoid potential issues.

This comprehensive script simplifies the process of setting up and managing an Active Directory environment, making it suitable for both new and experienced administrators.

---
---
---

# PowerShell Code

This file contains an explanation of seven PowerShell programs, each demonstrating specific concepts such as variable declaration, conditional statements, loops, and user interaction.

---

### 1. **Pattern Matching**

In this program, pattern matching is used to check if an IP address follows the pattern `192.168.*`. The program declares a variable for the IP address and uses the `-like` operator to match it against a local network pattern. This demonstrates how to work with strings and validate data based on patterns.

---

### 2. **Variable Comparison**

In this program, two variables are declared and compared to see if they hold equal values. Using an `if` statement, the program checks for equality between the variables and prints a message accordingly. This demonstrates basic variable handling and conditional logic for comparison.

---

### 3. **Grade Calculation Using `elseif`**

This program demonstrates how to use multiple `elseif` conditions to assign grades based on the average marks. Variables are declared for the subjects, and the total and average marks are calculated. The `elseif` statement is used to determine the grade based on the average score, showcasing how to use multiple conditions in a sequence.

---

### 4. **Simple Calculator Using `switch`**

The program functions as a simple calculator. It uses the `switch` statement to perform one of four arithmetic operations (add, subtract, multiply, or divide) based on user input. This demonstrates how to handle user input and use the `switch` control structure to select different actions based on the user's choice.

---

### 5. **Pin Validation Using `while` Loop**

This program allows the user to enter a pin and keeps prompting until the correct pin is entered. A `while` loop is used to repeatedly request the pin, and conditional checks are performed to compare the entered value with the correct pin. This shows how loops can be used for repeated actions and input validation.

---

### 6. **Counting Using `for` Loop**

The program uses a `for` loop to count numbers from 1 to 20 and outputs each value. This illustrates how loops can automate repetitive tasks, such as generating sequences of numbers or performing actions multiple times.

---

### 7. **Filtering Even Numbers Using `foreach` Loop**

This program filters even numbers from a list of numbers using a `foreach` loop. The program iterates through the list, checks if each number is even using the modulo operator (`%`), and stores the even numbers in a separate array. This demonstrates how to filter data by iterating through a collection.

---
