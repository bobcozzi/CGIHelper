**FREE

      /IF NOT DEFINED(CGI_HTML)
      /DEFINE CGI_HTML

      /INCLUDE cgiHelper/qcpysrc,cgiCONST

               // Create an HTML tag using the parameters
               // tagData = data to enclose in the tag. (Required parm)
               // startTag = the HTML tag to create (e.g., h3) (Required parm)
               // class_Style = An option class name or style for the tag
               //     e.g.,  'background-color: yellow;'
               // escape = Whether or not to URL Encode the tagData
               //        1=Encode, 0=Do not encode, DEFAULT(1)
            dcl-pr html_tag varchar(cgi_MAXBUFFER) rtnparm EXTPROC('html_tag');
               startTag varchar(32)  CONST OPTIONS(*VARSIZE);
               tagData varchar(cgi_MAXBUFFER) CONST OPTIONS(*VARSIZE);
               class_Style varchar(1024) CONST OPTIONS(*VARSIZE:*OMIT:*NOPASS);
               escape  int(10) CONST OPTIONS(*NOPASS);
            end-pr;

            // Create an HTML Comment "tag" as: <!-- <comment> -->
            dcl-pr html_CMT varchar(cgi_MAXBUFFER) rtnparm EXTPROC('html_cmt');
               comment varchar(cgi_MAXBUFFER) CONST OPTIONS(*VARSIZE);
               lineFeeds int(10) Const OPTIONS(*NOPASS);
            end-pr;

            // Get the start of a typical HTML page
            // Use the parameters to customize the attributes
         dcl-pr html_getStart varchar(4096) rtnparm extproc('html_getStart');
            title varchar(256) const options(*VARSIZE: *NOPASS: *OMIT);
            body  varchar(1024) const options(*VARSIZE: *NOPASS: *OMIT);
            jsFile varchar(640) const options(*VARSIZE: *NOPASS: *OMIT);
            jsVer   varchar(10)  const options(*NOPASS : *OMIT);
            cssFile varchar(640) const options(*VARSIZE: *NOPASS :*OMIT);
            cssVer   varchar(10)  const options(*NOPASS: *OMIT);
         end-pr;

            // Simple function to return </body></html> to the caller
         dcl-pr html_getEnd varchar(128) rtnparm extproc('html_getEnd') end-pr;

            // Gets a <link> tag for style files (.css)
            // Optionally returns a ?v=<cssver> to enable "versioning"
         dcl-pr html_getStyleLink varchar(720) rtnparm extProc('html_getStyleLink');
               cssFile varchar(640) const options(*VARSIZE);
               cssVer  varchar(10)  const options(*NOPASS:*OMIT);
         end-pr;


      /endif
