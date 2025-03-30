**FREE

         /IF NOT DEFINED(CGI_IMPORTS)
         /DEFINE CGI_IMPORTS
         /include cgiHelper/qcpysrc,cgiConst

          dcl-s cgiBuffer   varchar(cgi_MAXBUFFER) IMPORT;
          dcl-s outputText  varchar(cgi_MAXBUFFER) IMPORT;
          dcl-s encodedText varchar(cgi_MAXBUFFER) IMPORT;
          dcl-s decodedText varchar(cgi_MAXBUFFER) IMPORT;

        dcl-ds Global Qualified IMPORT('cgi_global');
         INIT        ind;
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

        /ENDIF
