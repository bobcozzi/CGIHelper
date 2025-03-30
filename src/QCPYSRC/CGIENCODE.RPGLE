**FREE

    /IF NOT DEFINED(CGI_ENCODE)
    /DEFINE CGI_ENCODE
        // encode a text string for use as an hRef (HTML Link) or
                // cgi/action= URI/URL/hREf link
        // Default if encodeType is unspecified, is HTML encoding
        // To encode a link:  encodeURI( myLink : 'URL');
                // URI and HREF also work
        // Also you can pass in '0' or '1', where: '0'=HTML encoding,
                                                // '1'=URL encoding
        // Use HTML encoding for data output to tables and non-link areas.
        // Use URL encoding for hyperlinks and CGI program parameters.
      /include cgiHelper/qcpysrc,CGICONST

            // returns URL or HTML encoded text from the inputtext
         dcl-pr cgi_encodeURI varchar(cgi_MAXBUFFER) rtnparm
                  EXTPROC('cgi_encodeURI');
            inputText      varchar(cgi_MAXBUFFER) const options(*VARSIZE);
            encodeType     varchar(10) const OPTIONS(*NOPASS);       // 'HTML' or 'URL' aka "URI"
         end-pr;

            // returns un-encoded ("decoded") URL-encoded text
         dcl-pr cgi_decodeURI varchar(cgi_MAXBUFFER) rtnparm
                  EXTPROC('cgi_decodeURI');
            encodedStg varchar(cgi_MAXBUFFER) const options(*VARSIZE);
            length     int(10)       const options(*NOPASS);
         end-pr;
         dcl-pr cgi_encodeHTML varchar(cgi_MAXBUFFER) rtnparm
                  EXTPROC('cgi_encodeHTML');
            inputText     varchar(cgi_MAXBUFFER) const options(*VARSIZE);
         end-pr;

    /endif
