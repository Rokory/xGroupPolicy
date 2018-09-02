# xGroupPolicy
PowerShell DSC resources to manage group policy objects
The **xGroupPolicy** module contains the **xGPO**, **xGPRegistryValue**, **xGPRegistryValueList** resources, allowing creation and configuration of a group policy objects, settings and links.

## Branches

### master

This is the branch containing the latest release - no contributions should be made
directly to this branch.

### dev

This is the development branch to which contributions should be proposed by contributors
as pull requests. This development branch will periodically be merged to the master
branch, and be released to [PowerShell Gallery](https://www.powershellgallery.com/).

## Resources

* **xGPO** creates or removes group policy objects (GPOs).
* **xGPRegistryValue** sets registry values in GPOs.
* **xGPRegistryValueList** sets a list of registry values in GPOs.

### xGPO

* **Ensure**: Indicates whether the GPO should be present or absent. 
* **Name**: Specifies a display name for the new GPO.
* **Comment**: Includes a comment for the new GPO. The comment string must be enclosed in double- or single-quotation marks and can contain 2,047 characters.
* **Domain**: Specifies the domain for this cmdlet. You must specify the fully qualified domain name (FQDN) of the domain.

### xGPRegistryValue

* **Name**: Specifies the GPO in which to configure the registry-based policy setting by its display name.
* **Key**: Specifies the registry key for the registry-based policy setting; for instance, HKLM\\Software\\Policies\\Microsoft\\Windows NT\\DNSClient.
* **ValueName**: Specifies a value name for the registry-based policy setting. For instance, the registry key HKLM\\Software\\Policies\\Microsoft\\Windows NT\\DNSClient can have a registry value with the following value name: UseDomainNameDevolution.
* **Value**: Specifies the value data for the registry-based policy setting.
* **Type**: Specifies the data type for the registry-based policy setting.
* **Domain**: Specifies the domain for this cmdlet. You must specify the fully qualified domain name (FQDN) of the domain.
* **Disable**: Indicates that the cmdlet disables the registry-based policy setting.

### xGPRegistryValue

* **Name**: Specifies the GPO in which to configure the registry-based policy setting by its display name.
* **Key**: Specifies the registry key for the registry-based policy setting; for instance, HKLM\\Software\\Policies\\Microsoft\\Windows NT\\DNSClient.
* **ValueName**: Array of value names to be added to the registry key. Cannot be used together with ValuePrefix.
* **ValuePrefix**: Specifies the value data for the registry-based policy setting. Cannot be used together with ValueName.
Configures a policy setting that creates the following registry values when Group Policy is applied on the client:

"HKLM\SOFTWARE\Policies\ExampleKey ExValue1" 100

"HKLM\SOFTWARE\Policies\ExampleKey ExValue2" 200

"HKLM\SOFTWARE\Policies\ExampleKey ExValue3" 300
* **Value**: Specifies the value data for the registry-based policy setting.
* **Type**: Specifies the data type for the registry-based policy setting.
* **Domain**: Specifies the domain for this cmdlet. You must specify the fully qualified domain name (FQDN) of the domain.
* **Disable**: Indicates that the cmdlet disables the registry-based policy setting.

### xGPLink
* **Ensure**: Indicates whether the GPLink should be present or absent. 
* **Name**: Specifies the GPO to link by its display name.
* **Target**: Specifies the LDAP distinguished name of the site, domain, or OU to which to link the GPO. For example, for the MyOU organizational unit in the contoso.com domain, the LDAP distinguished name is ou=MyOU,dc=contoso,dc=com.
* **LinkEnabled**: Specifies whether the GPO link is enabled. The acceptable values for this parameter are: Yes or No. By default, Group Policy processing is enabled for all GPO links. 
* **Order**: Specifies the link order for the GPO link. You can specify a number that is between one and the current number of GPO links to the target site, domain, or OU, plus one.
* **Domain**: Specifies the domain for this cmdlet. You must specify the fully qualified domain name (FQDN) of the domain.
* **Enforced**: Specifies whether the GPO link is enforced. You can specify Yes or No. By default, GPO links are not enforced.

## Versions

### Unreleased

### 1.1.0

* Support for ValueName array in xGPRegistryValueList resource.

### 1.0.0

* Initial release with the following resources
  * **xGPO**
  * **xGPRegistryValue**
  * **xGPRegistryValueList**
  * **xGPLink**
