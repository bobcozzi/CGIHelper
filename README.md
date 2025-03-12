# CGIHelper Beta
IBM i lightweight CGI Helper Library for RPG CGI Programming
This is an IBM i compatible *SAVF (Save File) that may be restored on IBM i V7R3 or later.
The source code should compile on IBM i V7R2 but I haven't tested it in that environment yet.
Here is a link to the documentation index (small for now, but growning)
https://bobcozzi.github.io/CGIHelper/index.html

# Installation
Download the CGIHelper save file from GitHub (use the "Release" link in the right side of the page or follow this link:
https://github.com/bobcozzi/CGIHelper/releases/download/v0.1/CGIHELPER.SAVF 

Upload the CGIHELPER save file to your IBM i server (normally to QGPL) and then issue a RSTLIB (restore lib) command.
RSTLIB LIB(CGIHELPER) DEV(*SAVF) SAVF(QGPL/CGIHELPER) ALWOBJDIF(*ALL) MBROPT(*ALL)
The save file is located in the "Release" page for this project (see link for Releases on the rightside of this page)
This is an early BETA version although it is being used everyday in production-level workloads and has shown no signs of failure.
I will be posted a serials of RPG CGI programs to help illustrate how to use this CGI library. Those example, which I am currently running include:
DSPJOBLOG - Display a job's joblog via HTML
DSPSPLF - Display the contents of a *SCS SPOOLED File via HTML
DSPMSGQ - Display the messages in a message queue User MSGQ, QSYSOPR, or QHST (defaults to QSYSOPR) 
DSPACTJOB - Display a list of Jobs in a SubSystem and allow drill-down to their JobLog or list of SPOOLED files.

As I said, I used these 4 tools all day, everyday and love not using the green screen for those purposes. 
Please post comments here or over on LinkedIn once you start testing this beta version.
Thanks!
