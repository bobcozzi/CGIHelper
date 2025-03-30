**Free

         ctl-opt  NOMAIN
                 ALWNULL(*USRCTL) OPTION(*NODEBUGIO:*SRCSTMT) ;

      /include cgiHelper/qcpysrc,cgiGLOBAL
      /include cgiHelper/qcpysrc,cgilib
      /include cgiHelper/qcpysrc,rpglib
      /include cgiHelper/qcpysrc,QtmhAPI
      /include cgiHelper/qcpysrc,QsysAPI


dcl-proc cgi_getVar export;
  dcl-pi cgi_getVar varchar(cgi_MAXBUFFER) RTNPARM;
    varName        varchar(cgi_MAXVARNAME) const OPTIONS(*VARSIZE);
    index          int(10)  const OPTIONS(*NOPASS : *OMIT);
    convertData    char(10) const OPTIONS(*VARSIZE:*NOPASS : *OMIT); // Convert data to
  end-pi;

  dcl-s CGIDataLen int(10);

  dcl-s vIdx   int(10) Inz(1);    // Varible Index DEFAULT(1);
  dcl-s offset int(10) inz(1);  // Offset to next variable index/instance
  dcl-s length int(10) Inz;
  dcl-s i      int(10) inz(0);

  // Local variables
  dcl-s startPos int(10) inz(0);                  // Start position of variable
  dcl-s endPos   int(10) inz(0);                    // End position of variable

  dcl-s bMatchCase ind inz(*ON);

      // Convert data to...
  dcl-C TOLOWER Const(1);
  dcl-C TOUPPER Const(2);
  dcl-C NOCONVERT Const(0);
  dcl-s cvtData char(3);
  dcl-s cvtTo   int(10) inz(NOCONVERT);  // 0=None, 1=Lower, 2=Upper

  // Check if the cache is already initialized
  if (NOT global.init);
    cgiInit();
  endif;

  if (%Parms() >= %ParmNum(index));
    if (%addr(INDEX) <> *NULL and index > 0);
       vIdx = index;
    endif;
  endif;

  if (%Parms() >= %ParmNum(convertData));
      if (%SUBST(convertData:1:1)='*');
        cvtData = %SUBST(convertData:2);
      else;
        cvtData = convertData;
      endif;
      // At this point CVTDATA has up to 3 characters
      // for example:  TOU, TOL, LOW, UPP
      // or possible 0, 1, or 2
      if (%SUBST(cvtData:1:1) = 'T' or
          %SUBST(cvtData:1:1) = 't' );
        cvtData = %SUBST(cvtData:3:1);
      endif;
      // Now CVTDATA should only contain
      // 0, 1, 2, U, or L
      // Convert to upper case and strip off chars 2 & 3
      /if DEFINED(*V7R4M0)
        cvtData = %LEFT( cvtData : 1);
        cvtData = %UPPER(cvtData);
      /elseif DEFINED(*V7R3M0)
        cvtData = %UPPER(cvtData : 1 : 1);
      /else
        // V7R2 coders, need to improvise
        cvtData = rpg_toUpper(cvtData : 1 : 1);
      /endif

      if (cvtData in %LIST('1' : 'L'));
        cvtTo = TOLOWER;
      elseif (cvtData in %LIST('0' : '2' : 'U'));
        cvtTo = TOUPPER;
      endif;
  endif;



    // After first pass, it should jump to this point
  if ( cgi_getQueryString(global.CGIData : %size(global.CGIData)) = 0);
    clear global.queryString;
    clear global.CGIData;
    snd-msg 'getenv(QUERY_STRING) returned no data.';
  else;
    //  snd-msg 'QUERY_STRING=' + %SUBST(global.CGIData : 1 : 64);
    // Parse the cached query string for the requested variable
    if (%SUBST(VARNAME : 1 : 1) = '"');  // If Double-Quoted so don't do UPPER()
      bMatchCase = *ON;
    else;
      bMatchCase = *OFF;
    endif;

    cgiDataLen = global.CONTENT_LENGTH;

    offset = 1;

    for i = 1 to vIdx;

      length = (cgiDatalen - offset) + 1;
      startPos = 0;

     if (bMatchCase);
      startPos = %scan(%trim(varName : '" ') + '='
                        : global.CGIData
                        : offset
                        : length);
     else;
    /if DEFINED(*V7R3M0)
      startPos = %scan(%trim(%UPPER(varName)) + '='
                        : %UPPER(global.CGIData : 1 : CGIDataLen)
                        : offset
                        : length);
    /else
        // V7R2 coders, need to improvise
      startPos = %scan(%trim(rpg_toUpper(varName)) + '=':
                        rpg_toUpper(global.CGIData : 1 : CGIDataLen)
                        : offset
                        : length);
    /endif

     endif;
      if (i < vIdx and startPos > 0);
        offset = startPos + %len(varName) + 1;
      else;
        leave;  // Break out of FOR loop
      endif;
    endfor;

    clear global.varValue;
    if startPos > 0;
        startPos += %len(varName) + 1; // Position after "key="
        // search for the end of the variable data
        length = (cgiDatalen - startPos) + 1;
        endPos = %scan('&': global.CGIData : startPos : length);

        if endPos = 0; // Not found, then use through end of CGI data
          endPos = cgiDataLen+1; // End of string
        endif;
        if (endPos - startPos > 0);
            global.varValue = %subst(global.CGIData : startPos:
                                     (endPos - startPos));
            global.varValue = %trim(cgi_decodeURI(global.varValue));
            if (cvtTo = TOLOWER);
      /if DEFINED(*V7R3M0)
        global.varValue = %lower(global.varValue);
      /else
        // V7R2 coders, need to improvise
        global.varValue = rpg_toLower(global.varValue);
      /endif
            elseif (cvtTo = TOUPPER);
      /if DEFINED(*V7R3M0)
        global.varValue = %upper(global.varValue);
      /else
        // V7R2 coders, need to improvise
        global.varValue = rpg_toUpper(global.varValue);
      /endif
            endif;
        else;
            clear global.varValue;
        endif;
    endif;
  endif;

  return %trimR(global.varValue);
end-proc;

dcl-proc cgi_getVarCount EXPORT;
  dcl-pi cgi_getVarCount int(10);
    varName varchar(cgi_MAXVARNAME) const OPTIONS(*VARSIZE);
  end-pi;
  dcl-s varCount int(10) inz(0);
  dcl-s varPos int(10) inz(0);
  dcl-s CGIDataLen int(10);
  dcl-s envVar varchar(cgi_MAXVARNAME);

      /if DEFINED(*V7R3M0)
        envvar = %UPPER(varName) + '=';
      /else
        // V7R2 coders, need to improvise
        envvar = rpg_toUpper(varName) + '=';
      /endif
    CGIDataLen = cgi_getQueryString(global.CGIData :
                                  %size(global.CGIData));
  if (CGIDataLen = 0);
    clear global.queryString;
    clear global.CGIData;
    snd-msg 'getenv(QUERY_STRING) returned no data.';
  else;

      /if DEFINED(*V7R3M0)
    global.CGIData = %UPPER(global.CGIData : 1 : CGIDataLen);
      /else
        // V7R2 coders, need to improvise
    global.CGIData = rpg_toUpper(global.CGIData : 1 : CGIDataLen);
      /endif
    // Parse the cached query string for the requested variable
    varPos = %scan(envVar : global.CGIData : 1 : CGIDataLen);
    dow (varPos > 0);
      varCount += 1;
      varPos = %scan(envVar : global.CGIData :
                    varPos + 1 : CGIDataLen-varPos);
    enddo;
  endif;
  return varCount;
end-proc;

dcl-proc cgi_getRequestMethod EXPORT;
  dcl-pi cgi_getRequestMethod varchar(32) rtnparm end-pi;

  dcl-s rtnLen int(10);
  dcl-s envVar varchar(32);
  dcl-DS ec likeDS(QUSEC_T) INZ(*LIKEDS);

    reset ec;
    envVar = 'REQUEST_METHOD';
    tmhGetEnv(global.METHOD : %size(global.METHOD) : rtnLen :
              envVar: %len(envVAR) : ec);
    if (ec.BytesReturned > 0);
      snd-msg 'getenv(REQUEST_METHOD) failed with ' + ec.msgid;
      return '';
    else;
      global.METHOD = %TRIMR(global.METHOD : X'400020');
    endif;
    /if DEFINED(*V7R3M0)
      return %upper(%TRIMR(global.METHOD));
    /ELSE
      rpg_toUpper(%TRIMR(global.METHOD) : %len(%TRIMR(global.METHOD)));
      return %TRIMR(global.METHOD);
    /endif
end-proc;

dcl-proc cgi_getMode EXPORT;
  dcl-pi cgi_getMode varchar(32) rtnparm end-pi;

  dcl-s rtnLen int(10);     // Holds the REQUEST_METHOD
  dcl-s envVar varchar(32);
  dcl-DS ec likeDS(QUSEC_T) INZ(*LIKEDS);

    reset ec;
    envVar = 'CGI_MODE';
    tmhGetEnv(global.cgi_Mode : %size(global.cgi_Mode) : rtnLen :
               envVar: %len(envVAR) : ec);
    if (ec.BytesReturned > 0);
      snd-msg 'getenv(CGI_MODE) failed with ' + ec.msgid;
      return '';
    else;
      global.cgi_Mode = %TRIMR(global.cgi_Mode : X'400020');
    endif;
  return global.cgi_Mode;
end-proc;

// Read the CGI data from either
// the stdin (when method="post")
// or the environment (when method="get").
// When it is stdin/post, the query_string
// is read and then copied to the
// environment variable QUERY_STRING for
// "easier" access later on.
dcl-proc stdinToQueryString;
  dcl-s contentLen char(32);
  dcl-s bytesRead int(10) inz(0);                 // Bytes read from stdin
  dcl-s rtnLen int(10);
  dcl-s envVar varchar(32);
  dcl-DS ec likeDS(QUSEC_T) INZ(*LIKEDS);

  if ( cgi_getRequestMethod() = 'POST');
      // For POST, read CONTENT_LENGTH and stdin
    reset ec;
    envVar = 'CONTENT_LENGTH';
    tmhGetEnv(contentLen : %size(contentLen) : rtnLen :
               envVar: %len(envVAR) : ec);
    if (ec.BytesReturned > 0);
      snd-msg 'getenv(CONTENT_LENGTH) failed in cgi_getVAR with ' + ec.msgid;
    else;
      global.CONTENT_LENGTH = %int(contentLen);
      if global.CONTENT_LENGTH > 0 and
         global.CONTENT_LENGTH <= %size(global.queryString);
          tmhRdStin(%addr(global.queryString): global.CONTENT_LENGTH:
                    bytesRead: ec);
          if (ec.bytesReturned > 0);  // Failed?
       /if DEFINED(*V7R4M0)
            snd-msg *DIAG 'stdinToQueryString->QtmhRdStin returned: ' +
                          ec.msgid;
       /else
            snd-msg 'stdinToQueryString->QtmhRdStin returned: ' + ec.msgid;
       /endif
            return; // Reading stdin failed, return empty set
          endif;

          reset ec;
          // Set QUERY_STRING using putenv
          // putEnvString = 'QUERY_STRING=' + queryString;
          tmhPutenv('QUERY_STRING=' +
                      %SUBST(global.queryString : 1 : global.CONTENT_LENGTH):
                      global.CONTENT_LENGTH + 13 : ec);
          envVar = 'REQUEST_METHOD=GET'; // Switch the method to "GET"
          tmhPutEnv(envVar : %len(envVar) : ec);
        endif;
      endif;
   endif;
end-proc;


dcl-proc cgi_getContentLength EXPORT;
  dcl-pi cgi_getContentLength int(10);
  end-pi;
  dcl-s rtnLen int(10);
  dcl-s contentLength int(10) inz(0);             // Length of POST data
  dcl-s envVar varchar(32);
  dcl-s envValue char(256);
  dcl-DS ec likeDS(QUSEC_T) INZ(*LIKEDS);

  if ( cgi_getRequestMethod() = 'POST');
      // For POST, read CONTENT_LENGTH environment variable
    reset ec;
    envVar = 'CONTENT_LENGTH';
    tmhGetEnv(envValue : %size(envValue) : rtnLen :
               envVar: %len(envVAR) : ec);
    if (ec.BytesReturned = 0 and rtnLen > 0);
      contentLength = %int(%subst(envValue : 1 : rtnLen));
    endif;
  else;  // for "GET" use %len(query_string)
    contentLength = cgi_getQueryString();
    // Set CONTENT_LENGTH using putenv
    // putEnvString = 'CONTENT_LENGTH=' + contentLength;
    envValue = 'CONTENT_LENGTH=' + %char(contentLength);
    tmhPutenv( envValue : %len(%TRIMR(envValue)) : ec);
  endif;
  return contentLength;
end-proc;


dcl-proc cgi_getQueryString EXPORT;
 dcl-pi  cgi_getQueryString int(10);
   rtnQS char(cgi_MAXBUFFER) OPTIONS(*VARSIZE:*NOPASS);
   rtnLen int(10) const OPTIONS(*NOPASS);
 end-pi;

 dcl-DS ec likeDS(QUSEC_T) INZ(*LIKEDS);
 dcl-s rtnCGIDataLen int(10);
 dcl-s envVarName varchar(cgi_MAXVARNAME);
  // this littel call to stdInQueryString
  // reads the CGI string from either
  // the stdin device or the environment
  // If it reads from stdin, that result is then
  // copied to the QUERY_STRING environment variable
  // for easier access.
   stdinToQueryString();

  reset ec;
  envVarName = 'QUERY_STRING';
  tmhGetEnv(global.CGIData : %size(global.CGIData) : rtnCGIDataLen :
            envVarName: %len(envVarName) : ec);
  if (ec.BytesReturned > 0 or rtnCGIDataLen = 0);
    clear global.CGIData;
  else;
    if (%Parms() >= %ParmNum(RTNQS) and %addr(RTNQS) <> *NULL);
      if (rtnCGIDataLen > rtnLen);
          rtnCGIDataLen = rtnLen;
      endif;
      rtnQS = %SUBST(global.CGIData : 1 : rtnCGIDataLen);
    endif;
  endif;
  return rtnCGIDataLen;
end-proc;

