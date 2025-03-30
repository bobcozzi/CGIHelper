**FREE

         ctl-opt  NOMAIN
                 ALWNULL(*USRCTL) OPTION(*NODEBUGIO:*SRCSTMT);

      /include cgiHelper/qcpysrc,cgilib
      /include cgiHelper/qcpysrc,cgiGLOBAL
      /include cgiHelper/qcpysrc,QtmhAPI
      /include cgiHelper/qcpysrc,QsysAPI

         ////////////////////////////////////////////////
         // E N C O D E  U R I
         // Encode either HTML or URI/URL strings
         // Default if encodeType is not specified is HTML Encoding
         ////////////////////////////////////////////////
   dcl-proc cgi_encodeHTML export;
      dcl-pi cgi_encodeHTML varchar(cgi_MAXBUFFER) rtnparm;
         inputText     varchar(cgi_MAXBUFFER) const options(*VARSIZE);
      end-pi;
      return cgi_encodeURI(inputText : 'HTML');
   end-proc;

   dcl-proc cgi_encodeURI export;
      dcl-pi cgi_encodeURI varchar(cgi_MAXBUFFER) rtnparm;
         inputText     varchar(cgi_MAXBUFFER) const options(*VARSIZE);
         encodeType    varchar(10) const OPTIONS(*NOPASS);       // 'HTML' or 'URL'
      end-pi;

      dcl-s pos int(10);
      dcl-s currentChar char(1);

      dcl-s bEncodeType int(10);
      dcl-s encType char(2);  // Type of encoding to perform (HTML or URL/URI/HREF)
      dcl-c ENCODE_AS_HTML 0;
      dcl-c ENCODE_AS_URL  1;

      // Encoding mappings for HTML
      dcl-ds htmlMap dim(6) qualified;
         charValue char(1);
         encodedValue varchar(10);
      end-ds;

      // Named constant for safe URL characters
         dcl-c URL_SAFE_Chars 'abcdefghijklmnopqrstuvwxyz+
                               ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.~';


         // CGI_EBCDIC_CCSID            '37'
         // CGI_ASCII_CCSID             '819'

         // Hexadecimal characters for URL encoding
         dcl-s eChar      CHAR(1);       // EBCDIC character
         dcl-s aChar      CHAR(1) CCSID(819); // ASCII character
         dcl-s cgiCCSID   int(10);
         dcl-s hexChar    CHAR(2);
         dcl-s i          int(10);

         clear outputText;
         cgiCCSID =  cgi_getccsid();
         if (%Parms() < %ParmNum(encodeType) or %addr(encodeType) = *NULL);
            bEncodeType = ENCODE_AS_HTML;
         else;
            encType = encodeType;
            encType = %UPPER( ENCTYPE );
            if ((%SUBST( %Upper(encTYPE) : 1 : 1) = 'H' and     // Is it HTML?
                 %SUBST( %Upper(encTYPE) : 1 : 2) <> 'HR') or  // and Not hRef
                (%SUBST( encTYPE : 1 : 1) = '0'));
            bEncodeType = ENCODE_AS_HTML;
            else;
            bEncodeType = ENCODE_AS_URL;
            endif;
         endif;

         // HTML encoding only encodes these 5 characters
         //   & Ampersand     as &amp;
         //   < Less than     as &lt;
         //   > Greater than  as &gt;
         //   " quote         as &auot;
         //   ' apostrophy    as &#39; or &apos; in some regions/browsers
         if (bEncodeType = ENCODE_AS_HTML);
            htmlMap(1).charValue = '&';
            htmlMap(1).encodedValue = '&amp;';
            htmlMap(2).charValue = '<';
            htmlMap(2).encodedValue = '&lt;';
            htmlMap(3).charValue = '>';
            htmlMap(3).encodedValue = '&gt;';
            htmlMap(4).charValue = '"';
            htmlMap(4).encodedValue = '&quot;';
            htmlMap(5).charValue = '''';
            htmlMap(5).encodedValue = '&#39;';
            htmlMap(6).charValue = '\';
            htmlMap(6).encodedValue = '&bsol;';
         endif;
      // Literally scan every character and if it
      // is one of those that need to be encoded,
      // then if HTML encoding, insert the symbolic name
      // else if URL/URI/HREF encoding, convert to hex,
      // and add a percent sign (%) prefix.
      for pos = 1 to %len(inputText);

         currentChar = %subst(inputText: pos: 1);

         if (bEncodeType = ENCODE_AS_HTML);
            // HTML Encoding Logic

            for i = 1 to %elem(htmlMap);
               if currentChar = htmlMap(i).charValue;
                  outputText += htmlMap(i).encodedValue;
                  leave;
               endif;
            endfor;

            // If no match, append character as is
            if i > %elem(htmlMap);
               outputText += currentChar;
            endif;

         elseif bEncodeType = ENCODE_AS_URL;
            // URL Encoding Logic
            if (%scan(currentChar: URL_SAFE_Chars) > 0);
               outputText += currentChar; // Safe characters
            else;
               if (cgiCCSID=819);
                 aChar = currentChar;
                 cvthc_ptr(%addr(hexChar) : %addr(aChar) : 2);
               else;
                 eChar = currentChar;
                 cvthc_ptr(%addr(hexChar) : %addr(eChar) : 2);
               endif;
               outputText += '%' + hexChar;
            endif;
         endif;
      endfor;

      return outputText;
   end-proc;




   dcl-proc cgi_decodeURI export;
     dcl-pi cgi_decodeURI varchar(cgi_MAXBUFFER) rtnparm;
       encodedStg varchar(cgi_MAXBUFFER) const options(*VARSIZE);
       length     int(10)       const options(*NOPASS);
     end-pi;

      dcl-s maxlen int(10);
      dcl-s cgiCCSID int(10);

      dcl-s eChar      CHAR(1);       // EBCDIC character
      dcl-s aChar      CHAR(1) CCSID(819); // ASCII character

      dcl-ds trick Qualified;
        eData   char(10) POS(1);
        aData   char(10) ccsid(819)  POS(1) INZ(*ALLX'00');
        a12Data char(10) ccsid(1208) POS(1) INZ(*ALLX'00');
      end-ds;

      dcl-S cleanChar  char(1);
      DCL-S startPOS   INT(10);
      DCL-S nextPOS    INT(10);
      DCL-S cvtLen     INT(10) INZ(2);
      DCL-S hexPair    CHAR(8) INZ(*ALLX'00');      // Hexadecimal pair

   if (%parms() >= %ParmNum(length) and length < %len(encodedStg));
      maxLen = length;
   else;
      maxLen = %len(encodedStg);
   endif;

      // All data is returned in the CCSID of this job
      // but encoded values (e.g., %xy) are in the CCSID of the client.
      // Often that means ASCII(819) So we convert the hex codes to character,
      // and then convert from ASCII to EBCDIC using the magic of RPG IV!

   // Process each encoded character
   // Initialize position variable

   decodedText = %SCANRPL('+' : ' ' : encodedStg : 1 : maxLen);

   startPos = %SCAN('%': decodedText : 1 : maxLen); // Find the first '%'

   nextPos  = 1;

   clear outputText;

   if (startPos > 0);
      cgiCCSID =  cgi_getccsid(); // Return the brower's (client's) CCSID (usually 819)
      dow (startPos > 0);
         // Get the next 2 characters after '%'
         outputText += %SUBST(decodedText: nextPos: startPos - nextPos);
         nextPos = startPos + 1;
         hexPair = %SUBST(decodedText: nextPos: 2);

         MONITOR;
            cvtch_ptr(%addr(trick) : %addr(hexPair) : cvtLen);
            if (cgiCCSID=819);  // If ASCII conver to JOB CCSID
               cleanChar = trick.aData;
            elseif (cgiCCSID=1208);  // if UTF-8, then
               aChar = trick.a12Data;  // convert it to PC ASCII (819)
               cleanChar = aChar;          // and then convert to EBCDIC
            else;
               cleanChar = trick.eData;
            endif;
            outputText += cleanChar;              // Append to decoded Stging
         ON-ERROR;
            outputText += '?';                // Append a placeholder for invalid hex
         ENDMON;

         // Move to the next character after the current '%xx' sequence
         nextPos += 2;
         startPos = 0;
         if (nextPos < maxLen);
            startPos = %SCAN('%': decodedText: nextPos : maxLen - nextPos); // Find next '%'
         endif;
      enddo;
   endif;

   // Append any remaining unencoded characters after the last '%'
   outputText += %SUBST(decodedText: nextPos);

   return outputText;
end-proc;

