**FREE

         ctl-opt  NOMAIN
                 ALWNULL(*USRCTL) OPTION(*NODEBUGIO:*SRCSTMT) ;

      /include cgiHelper/qcpysrc,cgilib
      /include cgiHelper/qcpysrc,QtmhAPI

      dcl-s  eCCSID int(10);
      dcl-s  aCCSID int(10);

   dcl-proc cgi_getCCSID export;
     dcl-pi cgi_getCCSID INT(10);               // Returns PC (ASCII) CCSID
        asciiCCSID  int(10) OPTIONS(*NOPASS);  // Returned parm PC (ASCII) CCSID
        ebcdicCCSID int(10) OPTIONS(*NOPASS);  // Returned parm HOST (IBM i) CCSID
     end-pi;

     dcl-ds ec likeDS(QUSEC_T) inz(*LIKEDS);
     dcl-s  envVar varchar(32);
     dcl-s  envValue char(10);
     dcl-s  rtnLen int(10);
     dcl-s  ptr pointer;
      reset ec;
      envVar = 'CGI_EBCDIC_CCSID';
      tmhGetEnv(envValue : %size(envValue) : rtnLen :
              envVar: %len(envVAR) : ec);
      if (rtnLen > 0);
         ptr = %addr(envValue);
         if (ec.BytesReturned = 0  and rtnLen > 0 and %str(ptr) <> '');
           eCCSID = %int( %str(ptr) );
         else;
            snd-msg 'CGI_EBCDIC_CCSID=?';
         endif;
      endif;

      reset ec;
      clear envValue;
      clear rtnLen;

      envVar = 'CGI_ASCII_CCSID';
      tmhGetEnv(envValue : %size(envValue) : rtnLen :
              envVar: %len(envVAR) : ec);
      if (rtnLen > 0);
         ptr = %addr(envValue);
         if (ec.BytesReturned = 0  and rtnLen > 0 and %str(ptr) <> '');
           aCCSID = %int( %str(ptr) );
         else;
            snd-msg 'CGI_ASCII_CCSID=?';
         endif;
      endif;
      if (%PARMS() >= %ParmNum(asciiCCSID) and %addr(asciiCCSID) <> *NULL);
         asciiCCSID = aCCSID;
      endif;
      if (%PARMS() >= %ParmNum(ebcdicCCSID) and %addr(ebcdicCCSID) <> *NULL);
         ebcdicCCSID = eCCSID;
      endif;
      return aCCSID;
   end-proc;

   dcl-proc cgi_getCONTENTTYPE export;
     dcl-pi cgi_getCONTENTTYPE varchar(128) rtnparm;
     end-pi;
     dcl-ds ec likeDS(QUSEC_T) inz(*LIKEDS);
     dcl-s  envVar char(32);
     dcl-s  envValue char(128);
     dcl-s  rtnLen int(10);
     dcl-s  ptr pointer;

      reset ec;
      envVar = 'CONTENT_TYPE';
      tmhGetEnv(envValue : %size(envValue) : rtnLen :
              envVar: %len(envVAR) : ec);
      if (rtnLen > 0);
         ptr = %addr(envValue);
         if (ec.BytesReturned = 0  and rtnLen > 0 and %str(ptr) <> '');
            return %TRIM(envValue);
         endif;
      endif;

      return '';
   end-proc;

   dcl-proc cgi_getPGMNAME export;
     dcl-pi cgi_getPGMNAME varchar(256) rtnparm;
     end-pi;

     dcl-ds ec likeDS(QUSEC_T) inz(*LIKEDS);
     dcl-s  envVar char(32);
     dcl-s  envValue char(256);
     dcl-s  rtnLen int(10);
     dcl-s  ptr pointer;

      reset ec;
      envVar = 'SCRIPT_NAME';
      tmhGetEnv(envValue : %size(envValue) : rtnLen :
              envVar: %len(envVAR) : ec);
      if (rtnLen > 0);
         ptr = %addr(envValue);
         if (ec.BytesReturned = 0  and rtnLen > 0 and %str(ptr) <> '');
            return %TRIM(envValue);
         endif;
      endif;

      return '';
   end-proc;

   dcl-proc cgi_getPGMVIRTPATH export;
     dcl-pi cgi_getPGMVIRTPATH varchar(256) rtnparm;
     end-pi;

     dcl-ds ec likeDS(QUSEC_T) inz(*LIKEDS);
     dcl-s  envVar char(32);
     dcl-s  envValue char(256);
     dcl-s  rtnLen int(10);
     dcl-s  pos    int(10);
     dcl-s  ptr pointer;

      reset ec;
      envVar = 'SCRIPT_NAME';
      tmhGetEnv(envValue : %size(envValue) : rtnLen :
              envVar: %len(envVAR) : ec);
      if (rtnLen > 0);
         ptr = %addr(envValue);
         if (ec.BytesReturned = 0  and rtnLen > 1 and %str(ptr) <> '');
            pos = %Scan('/' : envValue : 2);
            if (pos > 1);
               return %SUBST(envValue : 1 : pos-1);
            endif;
         endif;
      endif;

      return '';
   end-proc;


   dcl-proc cgi_getPGMPATH export;
     dcl-pi cgi_getPGMPATH varchar(256) rtnparm;
     end-pi;

     dcl-ds ec likeDS(QUSEC_T) inz(*LIKEDS);
     dcl-s  envVar char(32);
     dcl-s  envValue char(256);
     dcl-s  rtnLen int(10);
     dcl-s  ptr pointer;

      reset ec;
      envVar = 'SCRIPT_FILENAME';
      tmhGetEnv(envValue : %size(envValue) : rtnLen :
              envVar: %len(envVAR) : ec);
      if (rtnLen > 0);
         ptr = %addr(envValue);
         if (ec.BytesReturned = 0  and rtnLen > 1 and %str(ptr) <> '');
            return %SUBST(envValue : 1 : rtnLen);
         endif;
      endif;

      return '';
   end-proc;


   dcl-proc cgi_getPGMLIB export;
     dcl-pi cgi_getPGMLIB varchar(256) rtnparm;
     end-pi;

     dcl-ds ec likeDS(QUSEC_T) inz(*LIKEDS);
     dcl-C  QSYSLIB Const('/QSYS.LIB/');
     dcl-s  envVar char(32);
     dcl-s  envValue char(256);
     dcl-s  rtnLen int(10);
     dcl-s  pos    int(10);
     dcl-s  ptr pointer;

      reset ec;
      envVar = 'SCRIPT_FILENAME';
      tmhGetEnv(envValue : %size(envValue) : rtnLen :
              envVar: %len(envVAR) : ec);
      if (rtnLen > 0);
         ptr = %addr(envValue);
         if (ec.BytesReturned = 0  and rtnLen > 1 and %str(ptr) <> '');
            pos = %Scan('/' : envValue : %len(QSYSLIB)+1);
            if (pos > 1);
               return %SUBST(envValue : %len(QSYSLIB)+1 : pos-5);
            endif;
         endif;
      endif;

      return '';
   end-proc;

