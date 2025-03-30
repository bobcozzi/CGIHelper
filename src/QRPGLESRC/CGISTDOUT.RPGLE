
           // --------------------------------------------------
           // A simple wrapper (subproc) to "Write to Std output"
           // It can be called like this:
           //  cgiout('data to output');  // write out a literal/const
           // or
           //  cgiout( cgiBuffer );  // Write out contents of an RPG variable
           // --------------------------------------------------

        ctl-opt  NOMAIN
                 ALWNULL(*USRCTL) OPTION(*NODEBUGIO:*SRCSTMT) ;

         // These two procs wrote data to the web Browser
         // Using the IBM-provided QtmhWrStout API
           //  DECLARE CGIOUT SUBPROCEDURE BODY (Implementation)

      /include cgiHelper/qcpysrc,cgiCONST
      /include cgiHelper/qcpysrc,htmlLIB
      /include cgiHelper/qcpysrc,cgiLIB
      /include cgiHelper/qcpysrc,QtmhAPI
      /include cgiHelper/qcpysrc,QsysAPI

          dcl-proc cgi_wrtCONTENTTYPE export;
            dcl-pi cgi_wrtCONTENTTYPE;  // EXTPROC('cgi_wrtCONTENTTYPE');
             contentType varchar(2048) Const OPTIONS(*NOPASS);
            end-pi;
            dcl-c dftCONTENTTYPE 'text/html';
            if (%Parms() >= %ParmNum(contentType) and
                contentType <> '');
              cgiout(%scanRPL(cgi_ContentType : dftCONTENTTYPE : contentTYpe) +
                      cgi_LF + cgi_LF);
            else;
              cgiout(cgi_ContentType + cgi_LF + cgi_LF);
            endif;
          end-proc;

          // The main driver to write to "standard output".
          // This sends your HTML or text to the browser
          // from a CGI program. The first parameter is
          // the data to be sent.
          // The 2nd parameter is optional and may include
          // a value of 0 or higher. It indicates
          // the number of linefeeds to write following
          // the output text data. This is usally
          // not needed since this function also
          // converts embedded symbolic \n cgi_LF symbols
          // to X'25' automatically.
          // Thus:  cgiout('<p>Hello World</p>' : 1);
          // is the same as: cgiout('<p>Hello World</p>\n');

          dcl-proc cgi_stdout export;
            dcl-pi cgi_stdout;  // EXTPROC('cgi_stdout');
              output  varchar(cgi_MAXBUFFER) CONST OPTIONS(*VARSIZE);
              extraLF int(10) CONST OPTIONS(*NOPASS);
            end-pi;

              dcl-ds ec likeDS(QUSEC_T) inz(*LIKEDS);
              dcl-s tail varchar(30) inz;
              dcl-s lf   int(10) inz;
              dcl-s i    int(10) inz;
              dcl-s len   int(10);
              dcl-s pos   int(10);
              dcl-s start int(10) inz(1);

            if (%parms() >= %PARMNUM(extraLF));
              if (extraLF > 0);
                lf = extraLF;  // Save for later
                for i = 1 to extraLF;
                  tail += cgi_LF;
                endfor;
              endif;
            endif;

            len = %len(output);
            // Note: We may be able to convert this
            // to a %SCANRPL('\n' : cgi_LF : output)
            // Scan for embedded/symbolic LF characters
            pos = %scan(CGI_SYMBOLIC_LF : output : start );
            dow (pos > 0 and pos <= len);
              pos -= start;
              if (pos > 0 and start + pos <= len); // Corrected bounds check
                // write out everything up to the detected linefeed('\n')
                tmhWrStout(%subst(output : start : pos) : pos : ec);
              endif;
            //  len -= %size(cgi_LF);
              // Write out an actual linefeed(X'25') to stdout
              tmhWrStout(cgi_LF : %len(cgi_LF) : ec); // Write LF
              // Skip past the symbolic linefeed('\n') in the output string
              start += pos + %size(CGI_SYMBOLIC_LF);
              if (start >= len);
                leave;   // bailout if past end of OUTPUT
              endif;
              pos = %scan(CGI_SYMBOLIC_LF : output : start);
            enddo;

            // If there is output data remaining, then
            // send the rest to stdout.
            if (start <= len);
              pos = len - start + 1;
              tmhWrStout( %subst(output : start : pos) :
                        pos : ec); // QtmhWrStout
            endif;
            // If the caller also wants this proc to
            // add additional \n to the output,
            // do that now, and then return.
            if (%len(TAIL) > 0);
              tmhWrStout( TAIL : %LEN(TAIL) : ec);
            endif;
          end-proc;

          dcl-proc cgi_wrtHtmlCmt export;
            dcl-pi cgi_wrtHtmlCmt;  // export('cgi_wrtHtmlCmt');
              output varchar(cgi_MAXBUFFER)  CONST OPTIONS(*VARSIZE);
              LF_Control int(10) Const OPTIONS(*NOPASS);
            end-pi;
            dcl-s BOTH int(10) INZ(3);
            dcl-s cmt  varchar(1024);
            if (%Parms() >= %ParmNum(LF_Control));
             cmt = html_CMT(output : LF_Control);
            else;
             cmt = html_CMT(output : BOTH);
            endif;
            cgiOut(cmt);
          end-proc;
