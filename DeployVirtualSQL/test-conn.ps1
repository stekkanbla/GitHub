function Test-InvokeVMScript{
<#
.SYNOPSIS  Test if Invoke-VMScript will work
.DESCRIPTION The function verifies if all prerequisites
  are present to use the Invoke-VMScript cmdlet.
.NOTES  Author:  Luc Dekens
.PARAMETER VM
  The virtual machine for which you want to test the
  prerequisites. You can pass the name of the virtual
  machine or the VM object
.PARAMETER Official
  This switch specifies if only the official prerequistes
  should be verified or not. The default value is $True,
  so only the official prerequisites
.PARAMETER Detail
  Switch that specifies if all the prerequisite details
  should be returned or not. The default is $False
.EXAMPLE
  PS> Test-InvokeVMScript -VM $vm -Detail
.EXAMPLE
  PS> Get-VM VM* | Test-InvokeVMScript -Official:$false
#>

  param(
  [CmdletBinding()]
  [parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [PSObject]$VM,
  [switch]$Official = $True,
  [switch]$Detail
  )

  begin{
    $pCLIMajor,$pCLIMinor = Get-PowerCLIVersion | %{$_.Major,$_.Minor}
    $apiMajor,$apiMinor = (Get-View ServiceInstance).Content.About.ApiVersion.Split('.')
  }

  process{
    if($VM.GetType().Name -eq "string"){
      $VM = Get-VM -Name $VM
    }

    $condPoweredOn = $condCpu = $condTools = $condPort = $condRead = $condRole = $condOS = $False

    # Common prerequisites

    # Powered on
    if($vm.PowerState -eq "PoweredOn"){
      $condPoweredOn = $True
    }

    # 32-bit engine
    if ($env:Processor_Architecture -eq "x86"){
      $condCpu = $true
    }

    # Tools installed
    if($VM.Guest.State -eq "Running" -and $VM.ExtensionData.Summary.Guest.ToolsVersionStatus -eq "guestToolsCurrent"){
      $condTools = $True
    }

    # Port 902 open
    $originalEA = $ErrorActionPreference
    $ErrorActionPreference = “SilentlyContinue”
    $socket = New-Object Net.Sockets.TcpClient
    $socket.Connect($VM.Host.Name,902)
    if($socket.Connected){
      $condPort = $True
      $socket.Close()
    }
    Remove-Variable -Name socket -Confirm:$false
    $ErrorActionPreference = $originalEA

    # Folder read access
    $datastore,$file = $VM.ExtensionData.Config.Files.VmPathName.Split(']')
    $datastoreName = $datastore.Trim('[')
    $fileName = $file.Split('/')[1]
    $file = $file.TrimStart(' ')
    $ds = Get-Datastore -Name $datastoreName
    New-PSDrive -Location $ds -Name DS -PSProvider VimDatastore -Root '\' | Out-Null
    $currentProgPref = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    Copy-DatastoreItem -Item ('DS:\' + $file) -Destination $env:Temp -ErrorAction SilentlyContinue
    $ProgressPreference = $currentProgPref
    Remove-PSDrive -Name DS
    $path = $env:Temp + '\' + $fileName
    $condRead = Test-Path -Path $path
    if($condRead){
      Remove-Item -Path $path -Confirm:$false
    }

    # Privilege
    $authMgr = Get-View AuthorizationManager
    $role = $authMgr.RoleList | where {$vm.ExtensionData.EffectiveRole -eq $_.RoleId}
    $condRole = $role.Privilege -contains "VirtualMachine.Interact.ConsoleInteract"

    # Supported OS
    $supportedOS = "winLonghornGuest",  # Windows 2008
    "winLonghorn64Guest",               # Windows 2008 (64 bit)
    "windows7Guest",                     # Windows 7
    "windows7_64Guest",                 # Windows 7 (64 bit)
    "windows7Server64Guest",            # Windows Server 2008 R2 (64 bit)
    "winXPProGuest",                     # Windows XP Professional
    "winXPPro64Guest",                   # Windows XP Professional Edition (64 bit)
    "winXPHomeGuest",                   # Windows XP Home Edition
    "rhel5Guest",                       # Red Hat Enterprise Linux 5
    "rhel5_64Guest",                     # Red Hat Enterprise Linux 5 (64 bit)
    "rhel6Guest",                       # Red Hat Enterprise Linux 6
    "rhel6_64Guest"                     # Red Hat Enterprise Linux 6 (64 bit)
    $guestId = $VM.ExtensionData.Summary.Guest.GuestId
    if($guestId -like "winNet*" -or $supportedOS -contains $guestId){
      $condOS = $true
    }

    # Version dependent prerequisites
    $propertiesVix =[System.Diagnostics.FileVersionInfo]::GetVersionInfo($env:programfiles + '\VMware\VMware VIX\VixCOM.dll')
    $majorVix = $propertiesVix.FileMajorPart
    $minorVix = $propertiesVix.FileMinorPart
    $buildVix = $propertiesVix.FileBuildPart
    $versionVix = ([string]$majorVix + '.' + [string]$minorVix + '.' + [string]$buildVix)

    if(($pCLIMajor -eq 5 -and $versionVix -eq '1.10.0') -or
    ($pCLIMajor -eq 4 -and $versionVix -eq '1.6.2')){
      $condVix = $true
    }

    # Unofficial conditions
    if(!$Official){
      $condFQDN_U = $condOS_U = $False

      # OS that seems to work (most of the time)
      if($guestId -like "windows7Server64Guest"){  # Windows Server 2008 R2 (64 bit)
        $condOS_U = $True
      }

      # Short name
      $condFQDN_U = $global:DefaultVIserver.Name.Contains('.')
    }

    # Result
    if($Official){
      $result = $condPoweredOn -and $condCpu -and $condTools -and
        $condPort -and $condRead -and $condRole -and $condOS
    }
    else{
      $result = $condPoweredOn -and $condCpu -and $condTools -and
        $condPort -and $condRead -and $condRole -and
        ($condOS -or $condOS_U) -and $condFQDN_U
    }

    $resultObj = New-Object PSObject -Property @{
      VM = $VM.Name
      OK = $result
    }
    if($Detail){
      $resultObj = $resultObj |
      Add-Member -Name PoweredOn -Value $condPoweredOn -MemberType NoteProperty -PassThru |
      Add-Member -Name X86Engine -Value $condCpu -MemberType NoteProperty -PassThru |
      Add-Member -Name ToolsInstalled -Value $condTools -MemberType NoteProperty -PassThru |
      Add-Member -Name Port902Open -Value $condPort -MemberType NoteProperty -PassThru |
      Add-Member -Name FolderReadAccess -Value $condRead -MemberType NoteProperty -PassThru |
      Add-Member -Name PrivilegeConsoleInteraction -Value $condRole -MemberType NoteProperty -PassThru |
      Add-Member -Name SupportedOS -Value $condOs -MemberType NoteProperty -PassThru
      if(!$Official){
        $resultObj = $resultObj |
        Add-Member -Name FQDNorIPConnection -Value $condFQDN_U -MemberType NoteProperty -PassThru
      }
    }
    $resultObj
  }
}
