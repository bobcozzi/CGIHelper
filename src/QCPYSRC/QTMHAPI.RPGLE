**Free

   /IF NOT DEFINED(rpg_QTMH_PROTOS)
      /DEFINE rpg_QTMH_PROTOS

      /include cgihelper/qcpysrc,QUSEC
      /INCLUDE cgiHelper/qcpysrc,cgiCONST

       /IF NOT DEFINED(tmhWrStout)
         /DEFINE tmhWrStout
            // CGI Write to StdOut (Write CGI data to HTTP Server/Browser)
         dcl-pr tmhWrStout    extProc(*CWIDEN : 'QtmhWrStout');
            outputHTMLBuffer  char(CGI_MAXBUFFER) CONST OPTIONS(*VARSIZE);
            outputBufferLen   int(10)     CONST;
            ec                likeDS(QUSEC_T) OPTIONS(*VARSIZE);
         end-pr;

            // POINTER version of QtmhWrStout API Prototype
         dcl-pr tmhWrStoutPTR extProc(*CWIDEN:'QtmhWrStout');
            ptr_to_Buffer    POINTER VALUE;
            bufferLength     INT(10) CONST;
            ec               likeDS(QUSEC_T) OPTIONS(*VARSIZE);
         end-pr;
      /ENDIF


      /IF NOT DEFINED(tmhRdStin)
         /DEFINE tmhRdStin
            // CGI Read from Stdin (Read CGI data)
         dcl-pr tmhRdStin extproc('QtmhRdStin');
            data    pointer value;              // Data buffer pointer
            dataLen int(10) CONST;    // Length of data buffer (max bytes to read)
            bytesRead int(10);  // Returned: Number of bytes actually read
            errorCode LIKEDS(QUSEC_T) OPTIONS(*VARSIZE);  // Error code structure
         end-pr;
      /endif

      /IF NOT DEFINED(tmhGetEnv)
      /DEFINE tmhGetEnv
         dcl-pr tmhGetEnv extproc('QtmhGetEnv');
            varValue    CHAR(CGI_MAXBUFFER) options(*VARSIZE);
            bufferLen   INT(10) CONST;
            rtnLen      INT(10);
            VARNAME     CHAR(256) CONST OPTIONS(*VARSIZE);
            varLen      INT(10) CONST;
            ec          LIKEDS(QUSEC_T) OPTIONS(*VARSIZE);
         end-pr;
      /endif

      /IF NOT DEFINED(tmhPutEnv)
      /DEFINE tmhPutEnv
      dcl-pr tmhPutEnv extproc('QtmhPutEnv');
         envVarAndValue pointer value options(*STRING : *TRIM);
         length         INT(10) CONST;
         ec             LIKEDS(QUSEC_T) OPTIONS(*VARSIZE);
      end-pr;
      /endif

   /endif
