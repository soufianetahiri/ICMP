
# Background
This work is inspired by the code released many years ago by https://github.com/bdamele 
# Description
icmpsh is a simple reverse ICMP shell with a win32 slave and a POSIX compatible master in C, Perl or Python. The main advantage over the other similar open source tools is that it does not require administrative privileges to run onto the target machine.

The tool is clean, easy and portable. The slave (client) runs on the target Windows machine, it is written in C and works on Windows only whereas the master (server) can run on any platform on the attacker machine as it has been implemented in C and Perl by Nico Leidecker and I have ported it to Python too, hence this GitHub fork.

# What's new
The client was ported to Powershell probably by https://github.com/samratashok. I modified the code in a way that let you send a file over ICMP.

# How it works
You can use **icmpsh** on the attacker's machine:
The master is straight forward to use. There are no extra libraries required for the C and Python versions. The Perl master however has the following dependencies:

-   IO::Socket
-   NetPacket::IP
-   NetPacket::ICMP

When running the master, don't forget to disable ICMP replies by the OS. For example:

    sysctl -w net.ipv4.icmp_echo_ignore_all=1

Run **icmp_shell_file_transfert.ps1** on the target machine (you need to put the attacker's IP address on `$IPAddress` )
If everything works you will get connection notification:
![Client/Server connected](https://raw.githubusercontent.com/soufianetahiri/ICMP/main/connected.PNG)

Convert to base64 the file you want to send over ICMP (let's say I want to exfiltrate book.xlsx or send mymalicious.exe).
You can either do it via Powershell:
```
    $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FileName))
```
Or directly from your terminal if you're on a *nix machine:

    base64 mymalicious.exe > mymalicious.exe.b64

Append the target file's name between **##**, **#EOF#**  and #**EOP#**  to your .b64 file as follow:
![](https://raw.githubusercontent.com/soufianetahiri/ICMP/main/EOFappend.PNG)
Then copy and past the whole into your Server:
![](https://raw.githubusercontent.com/soufianetahiri/ICMP/main/PastB64.PNG)
The client will handle chunks, decode and save the file then send back its location to the server:
![](https://raw.githubusercontent.com/soufianetahiri/ICMP/main/trasfered.PNG)
