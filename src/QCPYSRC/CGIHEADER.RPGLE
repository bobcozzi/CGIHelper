
      /IF NOT DEFINED(cgi_HELPER_HEADER)
      /DEFINE cgi_HELPER_HEADER

         /IF DEFINED(*CRTBNDRPG)
            ctl-opt DFTACTGRP(*NO);
         /ELSE
            ctl-opt BNDDIR('*LIBL/CGIHELPER') NOMAIN
                   ALWNULL(*USRCTL) OPTION(*NODEBUGIO:*SRCSTMT) ;
         /ENDIF

      /ENDIF

