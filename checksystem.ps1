param ([Switch]$config, $Outputpath)
#####################################
# CheckSystem - Daily Error Report  # 
#####################################
#
$Version = "0.1"
#.SYNOPSIS 
#   CheckSystem is a PowerShell HTML framework script, designed to run as a scheduled
#   task before you get into the office to present you with key information via
#   an email directly to your inbox in a nice easily readable format.
#.DESCRIPTION
#   CheckSystem Daily Report for Ondemand
#
#   CheckSystem is a PowerShell HTML framework script, the script is designed to run 
#   as a scheduled task before you get into the office to present you with key 
#   information via an email directly to your inbox in a nice easily readable format.
#
#   This script picks on the key known issues and potential issues scripted as 
#   an input file for various errors written as powershell scripts and reports 
#   it all in one place so all you do in the morning is check your email.
#
#   One of they key things about this report is if there is no issue in a particular 
#   place you will not receive that section in the email, this ensures that you have 
#   only the information you need in front of you when you get into the office.
#
#   This script is not an Audit script, although the reporting 
#   framework can also be used for auditing scripts as well. I dont want to remind you 
#   that you have 5 hosts and what there names are and how many CPUs they have each 
#   and every day as you dont want to read that kind of information unless you need 
#   it this script will only tell you about problem areas.
#
function Write-CustomOut ($Details){
	$LogDate = Get-Date -Format T
	Write-Host "$($LogDate) $Details"
	#write-eventlog -logname Application -source "Windows Error Reporting" -eventID 12345 -entrytype Information -message "CheckSystem: $Details"
}

Function Invoke-Settings ($Filename, $GB) {
	$file = Get-Content $filename
	$OriginalLine = ($file | Select-String -Pattern "# Start of Settings").LineNumber
	$EndLine = ($file | Select-String -Pattern "# End of Settings").LineNumber
	if (($OriginalLine +1) -eq $EndLine) {
		} Else {
		$Array = @()
		$Line = $OriginalLine
		do {
			$Question = $file[$Line]
			$Line ++
			$Split= ($file[$Line]).Split("=")
			$Var = $Split[0]
			$CurSet = $Split[1]
			
			# Check if the current setting is in speach marks
			$String = $false
			if ($CurSet -match '"') {
				$String = $true
				$CurSet = $CurSet.Replace('"', '')
			}
			$NewSet = Read-Host "$Question [$CurSet]"
			If (-not $NewSet) {
				$NewSet = $CurSet
			}
			If ($String) {
				$Array += $Question
				$Array += "$Var=`"$NewSet`""
			} Else {
				$Array += $Question
				$Array += "$Var=$NewSet"
			}
			$Line ++ 
		} Until ( $Line -ge ($EndLine -1) )
		$Array += "# End of Settings"

		$out = @()
		$out = $File[0..($OriginalLine -1)]
		$out += $array
		$out += $File[$Endline..($file.count -1)]
		if ($GB) { $out[$SetupLine] = '$SetupWizard =$False' }
		$out | Out-File $Filename
	}
}

# Add all global variables.
# You can change the following defaults by altering the below settings:
#

# Set the following to true to enable the setup wizard for first time run
$SetupWizard =$true

# Start of Settings
# Please Specify the IP address or Hostname of the server to connect to
$Server ="127.0.1.1"
# Please Specify the SMTP server address
$SMTPSRV ="smtp.aol.com"
# Please specify the email address who will send the CheckSystem report
$EmailFrom ="sjreese@aol.com"
# Please specify the email address who will receive the CheckSystem report
$EmailTo ="hinesh@hcl.com"
# Please specify an email subject
$EmailSubject="$Server CheckSystem"
# Would you like the report displayed in the local browser once completed ?
$DisplaytoScreen =$True
# Use the following item to define if an email report should be sent once completed
$SendEmail =$false
# If you would prefer the HTML file as an attachment then enable the following:
$SendAttachment =$false
# Use the following area to define the title color
$Colour1 ="018AC0"
# Use the following area to define the Heading color
$Colour2 ="7BA7C7"
# Use the following area to define the Title text color
$TitleTxtColour ="FFFFFF"
# Set the following setting to $true to see how long each Plugin takes to run as part of the report
$TimeToRun = $true
# Report an plugins that take longer than the following amount of seconds
$PluginSeconds = 30
# End of Settings

$Date = Get-Date

#THIS IS HOW THE ERROR FILE WOULD BE PROCESSED 
#$file = Get-Content $GlobalVariables

#$Setup = ($file | Select-String -Pattern '# Set the following to true to enable the setup wizard for first time run').LineNumber
#$SetupLine = $Setup ++
#$SetupSetting = invoke-Expression (($file[$SetupLine]).Split("="))[1]
#if ($config) {
	$SetupSetting = $true
#}
If ($SetupSetting) {
	cls
	Write-Host
	Write-Host -ForegroundColor Yellow "Welcome to CheckSystem by Sjreese (http://sheltonreese.com) "
	Write-Host -ForegroundColor Yellow "============================================================="
	Write-Host -ForegroundColor Yellow "This is the first time you have run this script or you have re-enabled the setup wizard."
	Write-Host
	Write-Host -ForegroundColor Yellow "To re-run this wizard in the future please use CheckSystem.ps1 -Config"
	Write-Host -ForegroundColor Yellow "To define a path to store each CheckSystem report please use CheckSystem.ps1 -Outputpath C:\tmp"
	Write-Host 
	Write-Host -ForegroundColor Yellow "Please complete the following questions or hit Enter to accept the current setting"
	Write-Host -ForegroundColor Yellow "After completing ths wizard the CheckSystem report will be displayed on the screen."
	Write-Host
	
	# body = Get-Content -Path C:\TEMP\Body.txt | Out-String 
        # Send-MailMessage -To <toaddress> -Cc <ccaddress> -From <fromaddress> -Subject "$subject" -Body $body -SmtpServer $server instead and see how the output appears.
        # You read the file as follows: 
	#Invoke-Settings -Filename $GlobalVariables -GB $true
	#Foreach ($plugin in $Plugins) { 
	#	Invoke-Settings -Filename $plugin.Fullname
	#}
}

#. $GlobalVariables

$DspHeader0 = "
	BORDER-RIGHT: #bbbbbb 1px solid;
	PADDING-RIGHT: 0px;
	BORDER-TOP: #bbbbbb 1px solid;
	DISPLAY: block;
	PADDING-LEFT: 0px;
	FONT-WEIGHT: bold;
	FONT-SIZE: 8pt;
	MARGIN-BOTTOM: -1px;
	MARGIN-LEFT: 0px;
	BORDER-LEFT: #bbbbbb 1px solid;
	COLOR: #$($TitleTxtColour);
	MARGIN-RIGHT: 0px;
	PADDING-TOP: 4px;
	BORDER-BOTTOM: #bbbbbb 1px solid;
	FONT-FAMILY: Tahoma;
	POSITION: relative;
	HEIGHT: 2.25em;
	WIDTH: 95%;
	TEXT-INDENT: 10px;
	BACKGROUND-COLOR: #$($Colour1);
"

$DspHeader1 = "
	BORDER-RIGHT: #bbbbbb 1px solid;
	PADDING-RIGHT: 0px;
	BORDER-TOP: #bbbbbb 1px solid;
	DISPLAY: block;
	PADDING-LEFT: 0px;
	FONT-WEIGHT: bold;
	FONT-SIZE: 8pt;
	MARGIN-BOTTOM: -1px;
	MARGIN-LEFT: 0px;
	BORDER-LEFT: #bbbbbb 1px solid;
	COLOR: #$($TitleTxtColour);
	MARGIN-RIGHT: 0px;
	PADDING-TOP: 4px;
	BORDER-BOTTOM: #bbbbbb 1px solid;
	FONT-FAMILY: Tahoma;
	POSITION: relative;
	HEIGHT: 2.25em;
	WIDTH: 95%;
	TEXT-INDENT: 10px;
	BACKGROUND-COLOR: #$($Colour2);
"

$dspcomments = "
	BORDER-RIGHT: #bbbbbb 1px solid;
	PADDING-RIGHT: 0px;
	BORDER-TOP: #bbbbbb 1px solid;
	DISPLAY: block;
	PADDING-LEFT: 0px;
	FONT-WEIGHT: bold;
	FONT-SIZE: 8pt;
	MARGIN-BOTTOM: -1px;
	MARGIN-LEFT: 0px;
	BORDER-LEFT: #bbbbbb 1px solid;
	COLOR: #$($TitleTxtColour);
	MARGIN-RIGHT: 0px;
	PADDING-TOP: 4px;
	BORDER-BOTTOM: #bbbbbb 1px solid;
	FONT-FAMILY: Tahoma;
	POSITION: relative;
	HEIGHT: 2.25em;
	WIDTH: 95%;
	TEXT-INDENT: 10px;
	BACKGROUND-COLOR:#FFFFE1;
	COLOR: #000000;
	FONT-STYLE: ITALIC;
	FONT-WEIGHT: normal;
	FONT-SIZE: 8pt;
"

$filler = "
	BORDER-RIGHT: medium none; 
	BORDER-TOP: medium none; 
	DISPLAY: block; 
	BACKGROUND: none transparent scroll repeat 0% 0%; 
	MARGIN-BOTTOM: -1px; 
	FONT: 100%/8px Tahoma; 
	MARGIN-LEFT: 43px; 
	BORDER-LEFT: medium none; 
	COLOR: #ffffff; 
	MARGIN-RIGHT: 0px; 
	PADDING-TOP: 4px; 
	BORDER-BOTTOM: medium none; 
	POSITION: relative
"

$dspcont ="
	BORDER-RIGHT: #bbbbbb 1px solid;
	BORDER-TOP: #bbbbbb 1px solid;
	PADDING-LEFT: 0px;
	FONT-SIZE: 8pt;
	MARGIN-BOTTOM: -1px;
	PADDING-BOTTOM: 5px;
	MARGIN-LEFT: 0px;
	BORDER-LEFT: #bbbbbb 1px solid;
	WIDTH: 95%;
	COLOR: #000000;
	MARGIN-RIGHT: 0px;
	PADDING-TOP: 4px;
	BORDER-BOTTOM: #bbbbbb 1px solid;
	FONT-FAMILY: Tahoma;
	POSITION: relative;
	BACKGROUND-COLOR: #f9f9f9
"

Function Get-Base64Image ($Path) {
#	$pic = Get-Content $Path -Encoding Byte
#	[Convert]::ToBase64String($pic)
}

#THIS IS WHERE YOU LOGO WOULD GO
#$HeaderImg = Get-Base64Image ((Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path) + "\Header.jpg")

Function Get-CustomHTML ($Header){
$Report = @"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html><head><title>$($Header)</title>
		<META http-equiv=Content-Type content='text/html; charset=windows-1252'>

		<style type="text/css">

		TABLE 		{
						TABLE-LAYOUT: fixed; 
						FONT-SIZE: 100%; 
						WIDTH: 100%
					}
		*
					{
						margin:0
					}

		.pageholder	{
						margin: 0px auto;
					}
					
		td 				{
						VERTICAL-ALIGN: TOP; 
						FONT-FAMILY: Tahoma
					}
					
		th 			{
						VERTICAL-ALIGN: TOP; 
						COLOR: #018AC0; 
						TEXT-ALIGN: left
					}
					
		</style>
	</head>
	<body margin-left: 4pt; margin-right: 4pt; margin-top: 6pt;>
<div style="font-family:Arial, Helvetica, sans-serif; font-size:20px; font-weight:bolder; background-color:#$($Colour1);"><center>
<p class="accent">
<!--[if gte mso 9]>
	<H1><FONT COLOR="White">CheckSystem</Font></H1>
<![endif]-->
<!--[if !mso]><!-->
	<IMG SRC="data:image/jpg;base64,$($HeaderImg)" ALT="CheckSystem">
<!--<![endif]-->
</p>
</center></div>
	        <div style="font-family:Arial, Helvetica, sans-serif; font-size:14px; font-weight:bold;"><center>CheckSystem v$($version) by Shelton Reese (<a href='http://sheltonreese.com' target='_blank'>http://sheltonreese.com</a>) generated on $($ENV:Computername)
			</center></div>
"@
Return $Report
}

Function Get-CustomHeader0 ($Title){
$Report = @"
		<div style="margin: 0px auto;">		

		<h1 style="$($DspHeader0)">$($Title)</h1>
	
    	<div style="$($filler)"></div>
"@
Return $Report
}

Function Get-CustomHeader ($Title, $cmnt){
$Report = @"
	    <h2 style="$($dspheader1)">$($Title)</h2>
"@
If ($Comments) {
	$Report += @"
			<div style="$($dspcomments)">$($cmnt)</div>
"@
}
$Report += @"
        <div style="$($dspcont)">
"@
Return $Report
}

Function Get-CustomHeaderClose{

	$Report = @"
		</DIV>
		<div style="$($filler)"></div>
"@
Return $Report
}

Function Get-CustomHeader0Close{
	$Report = @"
</DIV>
"@
Return $Report
}

Function Get-CustomHTMLClose{
	$Report = @"
</div>

</body>
</html>
"@
Return $Report
}

Function Get-HTMLTable {
	param([array]$Content)
	$HTMLTable = $Content | ConvertTo-Html -Fragment
	$HTMLTable = $HTMLTable -Replace '<TABLE>', '<TABLE><style>tr:nth-child(even) { background-color: #e5e5e5; TABLE-LAYOUT: Fixed; FONT-SIZE: 100%; WIDTH: 100%}</style>' 
	$HTMLTable = $HTMLTable -Replace '<td>', '<td style= "FONT-FAMILY: Tahoma; FONT-SIZE: 8pt;">'
	$HTMLTable = $HTMLTable -Replace '<th>', '<th style= "COLOR: #$($Colour1); FONT-FAMILY: Tahoma; FONT-SIZE: 8pt;">'
	$HTMLTable = $HTMLTable -replace '&lt;', "<"
	$HTMLTable = $HTMLTable -replace '&gt;', ">"
	Return $HTMLTable
}

Function Get-HTMLDetail ($Heading, $Detail){
$Report = @"
<TABLE TABLE-LAYOUT: Fixed; FONT-SIZE: 100%; WIDTH: 100%>
	<tr>
	<th width='50%';VERTICAL-ALIGN: TOP; FONT-FAMILY: Tahoma; FONT-SIZE: 8pt; COLOR: #$($Colour1);><b>$Heading</b></th>
	<td width='50%';VERTICAL-ALIGN: TOP; FONT-FAMILY: Tahoma; FONT-SIZE: 8pt;>$($Detail)</td>
	</tr>
</TABLE>
"@
Return $Report
}

# Adding all plugins
$TTRReport = @()
$MyReport = Get-CustomHTML "$Server CheckSystem"
	$MyReport += Get-CustomHeader0 ($Server)
	$Plugins | Foreach {
		$TTR = [math]::round((Measure-Command {$Details =  $_FullName}).TotalSeconds, 2)
		$TTRTable = "" | Select Plugin, TimeToRun
		$TTRTable.Plugin = $_.Name
		$TTRTable.TimeToRun = $TTR
		$TTRReport += $TTRTable
		$ver = "{0:N1}" -f $PluginVersion
		Write-CustomOut "..finished calculating $Title by $Author v$Ver"
		If ($Details) {
			If ($Display -eq "List"){
				$MyReport += Get-CustomHeader $Header $Comments
				$AllProperties = $Details | Get-Member -MemberType Properties
				$AllProperties | Foreach {
					$MyReport += Get-HTMLDetail $_.Name $Details.($_.Name)
				}
				$MyReport += Get-CustomHeaderClose			
			}
			If ($Display -eq "Table") {
				$MyReport += Get-CustomHeader $Header $Comments
						$MyReport += Get-HTMLTable $Details
				$MyReport += Get-CustomHeaderClose
			}
		}
	}	
	$MyReport += Get-CustomHeader ("This report took " + [math]::round(((Get-Date) - $Date).TotalMinutes,2) + " minutes to run all checks.") "The following plugins took longer than $PluginSeconds seconds to run, there may be a way to optimize these or remove them if not needed"
	$TTRReport = $TTRReport | Where { $_.TimeToRun -gt $PluginSeconds }
	$TTRReport |  Foreach {$MyReport += Get-HTMLDetail $_.Plugin $_.TimeToRun}
	$MyReport += Get-CustomHeaderClose
$MyReport += Get-CustomHeader0Close
$MyReport += Get-CustomHTMLClose

if ($DisplayToScreen -or $SetupSetting) {
	Write-CustomOut "..Displaying HTML results"
	$Filename = $Env:TEMP + "\" + $Server + "CheckSystem" + "_" + $Date.Day + "-" + $Date.Month + "-" + $Date.Year + ".htm"
	$MyReport | out-file -encoding ASCII -filepath $Filename
	Invoke-Item $Filename
}

if ($SendAttachment) {
	$Filename = $Env:TEMP + "\" + $Server + "CheckSystem" + "_" + $Date.Day + "-" + $Date.Month + "-" + $Date.Year + ".htm"
	$MyReport | out-file -encoding ASCII -filepath $Filename
}

if ($Outputpath) {
	$DateHTML = Get-Date -Format "yyyyMMddHH"
	$ArchiveFilePath = $Outputpath + "\Archives\" + $VIServer
	if (-not (Test-Path -PathType Container $ArchiveFilePath)) { New-Item $ArchiveFilePath -type directory | Out-Null }
	$Filename = $ArchiveFilePath + "\" + $VIServer + "_CheckSystem_" + $DateHTML + ".htm"
	$MyReport | out-file -encoding ASCII -filepath $Filename
}

if ($SendEmail) {
	Write-CustomOut "..Sending Email"
	If ($SendAttachment) {
		send-Mailmessage -To $EmailTo -From $EmailFrom -Subject $EmailSubject -SmtpServer $SMTPSRV -Body "CheckSystem attached to this email" -Attachments $Filename
	} Else {
		send-Mailmessage -To $EmailTo -From $EmailFrom -Subject $EmailSubject -SmtpServer $SMTPSRV -Body $MyReport -BodyAsHtml
	}
}

if ($SendAttachment -eq $true -and $DisplaytoScreen -ne $true) {
	Write-CustomOut "..Removing temporary file"
	Remove-Item $Filename -Force
}

$End = $ScriptPath + ".\\OutputAtEnd.ps1"
. $End
