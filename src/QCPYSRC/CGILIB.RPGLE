**FREE

      /IF NOT DEFINED(cgi_CGILIB)
         /DEFINE cgi_CGILIB


         /INCLUDE cgiHelper/qcpysrc,QUSEC
         /INCLUDE cgiHelper/qcpysrc,QsysAPI

         /INCLUDE cgiHelper/qcpysrc,cgiCONST
         /INCLUDE cgihelper/qcpysrc,cgiEncode
         /INCLUDE cgihelper/qcpysrc,htmlLib

         // Custom CGI interfaces

         /IF NOT DEFINED(CGIINIT)
         /DEFINE CGIINIT
            // Initializes CGI environment, reads Query String etc.
            dcl-pr cgi_Init  EXTPROC('cgi_init')  end-pr;
            // Erase (clears) the CGI environment
            dcl-pr cgi_Clear EXTPROC('cgi_clear') end-pr;
            // Initializes CGI environment, reads Query String etc.
            dcl-pr cgiInit  EXTPROC('cgi_init')  end-pr;
            // Erase (clears) the CGI environment
            dcl-pr cgiClear EXTPROC('cgi_clear') end-pr;
         /ENDIF

         /IF NOT DEFINED(CGIOUT)
         /DEFINE CGIOUT
            // Output to CGI stdout device using QtmhWrStout API
            dcl-pr cgiout extproc('cgi_stdout');
               output  varchar(cgi_MAXBUFFER) CONST OPTIONS(*VARSIZE);
               extraLF int(10) CONST OPTIONS(*NOPASS);
            end-pr;
            // Output to CGI stdout device using QtmhWrStout API
            dcl-pr cgi_stdout extproc('cgi_stdout');
               output  varchar(cgi_MAXBUFFER) CONST OPTIONS(*VARSIZE);
               extraLF int(10) CONST OPTIONS(*NOPASS);
            end-pr;

            // Writes the output text as an HTML comment to stdout
         dcl-pr cgi_comment extproc('cgi_wrtHtmlCmt');
            output varchar(cgi_MAXBUFFER) CONST OPTIONS(*VARSIZE);
                  // Include linefeeds DFT(2)=after only.
                  // 0 = None
                  // 1 = Before comment only
                  // 2 = After  comment only
                  // 3 or any other value = both before and after comment
            LF_Control int(10) Const OPTIONS(*NOPASS);
         end-pR;
         dcl-pr cgi_Cmt extproc('cgi_wrtHtmlCmt');
            output varchar(cgi_MAXBUFFER) CONST OPTIONS(*VARSIZE);
                  // Include linefeeds DFT(2)=after only.
                  // 0 = None
                  // 1 = Before comment only
                  // 2 = After  comment only
                  // 3 or any other value = both before and after comment
            LF_Control int(10) Const OPTIONS(*NOPASS);
         end-pR;
         dcl-pr cgi_WrtCmt extproc('cgi_wrtHtmlCmt');
            output varchar(cgi_MAXBUFFER) CONST OPTIONS(*VARSIZE);
                  // Include linefeeds DFT(2)=after only.
                  // 0 = None
                  // 1 = Before comment only
                  // 2 = After  comment only
                  // 3 or any other value = both before and after comment
            LF_Control int(10) Const OPTIONS(*NOPASS);
         end-pR;
         dcl-pr cgi_wrtHtmlCmt extproc('cgi_wrtHtmlCmt');
            output varchar(cgi_MAXBUFFER) CONST OPTIONS(*VARSIZE);
                  // Include linefeeds DFT(2)=after only.
                  // 0 = None
                  // 1 = Before comment only
                  // 2 = After  comment only
                  // 3 or any other value = both before and after comment
            LF_Control int(10) Const OPTIONS(*NOPASS);
         end-pR;

            // Write out the Content-Type text/html\n\n header
            // This is normally the first thing written to stdout
            // by a CGI App when working with HTML and the browser.
            // Two naming options for convienence.
            // If the first parameter is not specified or is blank,
            // the default is 'text/html'.
            // Also note as required by the stnadard, the
            // content-type header is written and automatically
            // followed by 2 linefeeds (\n\n).
         dcl-pr cgi_wrtContentType EXTPROC('cgi_wrtContentType');
            contentType varchar(2048) Const OPTIONS(*NOPASS);
         end-pr;
            // We're providing this alternative spelling
            // of the prototype so that Developers with
            // less experience who may refer to the
            // content-type header as the HTTP Header
            // can leaverage this spelling
         dcl-pr cgi_wrtHTTPHDR EXTPROC('cgi_wrtContentType');
            contentType varchar(2048) Const OPTIONS(*NOPASS);
         end-pr;

         /endif

         // Gets the CCSID for the Browser and the IBM i server
         // The two values are returned as parm 1 and 2.
         // The ASCIICCSID is also returned by the function.
         // The two parameters are optional so it can be
         // called like this:  pcCCSID = cgi_GetCCSID();
         // because typically you only need the PC/Browser CCSID.
         dcl-pr cgi_getCCSID int(10) extproc('cgi_getCCSID');
            asciiCCSID  int(10) OPTIONS(*NOPASS);
            ebcdicCCSID int(10) OPTIONS(*NOPASS);
         end-pr;

            // Returns a string of the HTTP Content-Type header.
            // This value is created by the HTTP Server/Browser
            // and is retrieved from the CONTENT_TYPE environment variable.
            // Note this is input from the browser/http server
            // vs our cgi_wrtCONTENTTYPE which writes a content-type
            // head to the HTTP server/browser.
         dcl-pr cgi_getContentType varchar(128) rtnparm extproc('cgi_getContentType');
         end-pr;

            // Retrieve the full CGI query string.
            // The value is returned for the POST or GET methods.
            // The return buffer may exceed the 64k size if necessary.
            // Just be sure to specify the size of the return buffer
            // on the 2nd parameter.
            // Only up to "rtnBufferSize" bytes are returned.
         dcl-pr  cgi_getQueryString int(10) EXTPROC('cgi_getQueryString');
            rtnQS  char(cgi_MAXBUFFER) OPTIONS(*VARSIZE:*NOPASS);
            rtnBufferSize int(10) const OPTIONS(*NOPASS);
         end-pr;

            // Returns the REQUEST_METHOD (usually POST or GET)
            // from the http server/web browser. This is the
            // "method" specified on they HTML FORM tag
            // e.g., <form name="CUSTINQ" action="/cgi/CUSTINQ.PGM" method="post">
            // the method is returned in all upper case for easier
            // testing. Although our interfaces, such as cgi_getVAR
            // already test the REQUEST_METHOD and return the data
            // transparent of the method used.
         dcl-pr cgi_getRequestMethod varchar(32) rtnparm
            EXTPROC('cgi_getRequestMethod');
         end-pr;
            // For method="post", the environment variable CONTENT_LENGTH
            // is set and this function returns that value.
            // For method="get", the function reads the QUERY_STRING
            // determins its length and then returns the that data's
            // content length.
         dcl-pr cgi_getContentLength int(10) EXTPROC('cgi_getContentLength');
         end-pr;
         dcl-pr cgi_getMode varchar(32) rtnparm EXTPROC('cgi_getMODE');
         end-pr;


            // Returns the CGI program name and its virtual path
            // For example, if the HTML FORM action=>"/cgilib/EDITCUST.PGM"
            // were specified, the value returned by this function
            // would be "/CGILIB/EDITCUST.PGM".
         dcl-pr cgi_getPGMNAME varchar(256) rtnparm EXTPROC('cgi_getPGMNAME');
         end-pr;

            // Returns the CGI program virtual path only.
            // For example, if the HTML FORM action=>"/cgilib/EDITCUST.PGM"
            // were specified, the value returned by this function
            // is: "/CGILIB".
         dcl-pr cgi_getPGMVIRTPATH varchar(256) rtnparm EXTPROC('cgi_getPGMVIRTPATH');
         end-pr;

            // Returns the CGI program fully resolved path.
            // For example, if the HTML FORM action=>"/cgilib/EDITCUST.PGM"
            // with a ScriptAlias of /qsys.lib/cgicode.lib/$1.pgm
            // then the value returned by this function is:
            //  "/QSYS.LIB/CGICODE.LIB/EDTICUST.PGM"
         dcl-pr cgi_getPGMPATH varchar(256) rtnparm EXTPROC('cgi_getPGMPATH');
         end-pr;
            // Returns the CGI program's library name
            // For example, if the HTML FORM action=>"/cgilib/EDITCUST.PGM"
            // with a ScriptAlias of /qsys.lib/cgicode.lib/$1.pgm
            // then the value returned by this function is:
            // "CGICODE" -- It accomplishes this by extracting the .LIB
            // name from the Program Path (see getCGIPGMPATH)
         dcl-pr cgi_getPGMLIB varchar(256) rtnparm EXTPROC('cgi_getPGMLIB');
         end-pr;

         // Retrieve the content of a CGI variable passesd to the CGI program
         // by the HTTP server (i.e., from the web browser).
         // All data returned by this function is de-escaped (aka unescaped)
         // that is, it is "decoded" using our decodeURI function.
         //  VARNAME = The HTML FORM field name (case senstive)
         //  INDEX   = For multiple occurrance field names (field names the repeat)
         //            specify the index of the occurrance to retrieve.
         //            The default is, obvioulsy, 1 if unspecified or < 1
         //  CONVERTDATA = A flag that indicates if the data should be
         //                translated to all upper or all lower case.
         //                TOUPPER, or UPPER, or '1' = Convert to Upper case
         //                TOLOWER, or LOWER, or '2' = Convert to lower case
         //                Any other value or '0'  = return as is.
         // cgi_getVar and cgi_getVarValue are the same procedure
          dcl-pr cgi_getVar varchar(cgi_MAXBUFFER) RTNPARM
                              EXTPROC('cgi_getVarValue');
               varName        varchar(cgi_MAXVARNAME) const OPTIONS(*VARSIZE);
               index          int(10)  const OPTIONS(*NOPASS : *OMIT);
               convertData    char(10) const OPTIONS(*VARSIZE:*NOPASS:*OMIT);
          end-pr;
          // cgi_getVar and cgi_getVarValue are the same procedure
          dcl-pr cgi_getVarValue varchar(cgi_MAXBUFFER) RTNPARM
                              EXTPROC('cgi_getVarValue');
               varName        varchar(cgi_MAXVARNAME) const OPTIONS(*VARSIZE);
               index          int(10)  const OPTIONS(*NOPASS : *OMIT);
               convertData    char(10) const OPTIONS(*VARSIZE:*NOPASS:*OMIT);
          end-pr;
         dcl-pr cgi_getVarCount int(10) EXTPROC('cgi_getVarCount');
            varName varchar(cgi_MAXVARNAME) const OPTIONS(*VARSIZE);
         end-pr;
      /ENDIF
