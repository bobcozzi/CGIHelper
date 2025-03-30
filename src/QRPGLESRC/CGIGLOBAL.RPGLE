**FREE

        ctl-opt  NOMAIN
                 ALWNULL(*USRCTL) OPTION(*NODEBUGIO:*SRCSTMT) ;

         /include cgiHelper/qcpysrc,cgilib

          dcl-s cgiBuffer   varchar(cgi_MAXBUFFER) EXPORT;
          dcl-s outputText  varchar(cgi_MAXBUFFER) EXPORT;
          dcl-s encodedText varchar(cgi_MAXBUFFER) EXPORT;
          dcl-s decodedText varchar(cgi_MAXBUFFER) EXPORT;

        dcl-ds Global Qualified Inz EXPORT('cgi_global');
         INIT        ind inz(*OFF);
         METHOD      char(32);
         CGI_MODE    char(32);
         PC_CCSID    int(10);
         CONTENT_LENGTH int(10);

         queryString char(cgi_MAXBUFFER); // Holds cached CGI data
         CGIData     char(cgi_MAXBUFFER);
         varValue    varchar(cgi_MAXBUFFER);
         varName     varchar(cgi_MAXVARNAME);
         envVarName  varchar(cgi_MAXVARNAME);
        end-ds;

