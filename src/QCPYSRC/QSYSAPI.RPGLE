**Free

       /IF NOT DEFINED(rpg_QSYSAPI)
       /DEFINE rpg_QSYSAPI

        /include cgiHELPER/qcpysrc,qcmdAPI

         /IF NOT DEFINED(DLYJOB)
         /DEFINE DLYJOB
            dcl-pr dlyjob uns(10) extProc(*CWIDEN:'sleep');
                    seconds uns(10) VALUE;
            end-pr;
            dcl-pr sleep uns(10) extProc(*CWIDEN:'sleep');
                    seconds uns(10) VALUE;
            end-pr;
         /ENDIF

         /IF NOT DEFINED(GETENV)
            /DEFINE GETENV
            dcl-pr getenv pointer extproc(*CWIDEN:'getenv');
               envName pointer const options(*string:*trim);
            end-pr;
         /endif

         /IF NOT DEFINED(PUTENV)
         /DEFINE PUTENV
           dcl-pr putenv int(10) extproc(*CWIDEN:'putenv');
              envNameAndValue pointer value options(*string:*trim);
           end-pr;
         /endif

      /IF NOT DEFINED(CVTHC)
      /DEFINE CVTHC
         dcl-pr cvthc extproc('cvthc');  // MI Convert characters to hexadecimal notation
            hexOutput  char(65530) OPTIONS(*VARSIZE);
            charInput  char(32765) OPTIONS(*VARSIZE);
            hexLen     int(10) value;
         end-pr;
      /endif
      /IF NOT DEFINED(CVTHC_PTR)
      /DEFINE CVTHC_PTR
         dcl-pr cvthc_ptr extproc('cvthc');  // MI Convert characters to hexadecimal notation
            hexOutput  pointer value;
            charInputs pointer value;
            hexLen     int(10) value;
         end-pr;
      /endif

      /IF NOT DEFINED(CVTCH_PTR)
      /DEFINE CVTCH_PTR
         dcl-pr cvtch_PTR extproc('cvtch');  // MI Convert characters to hexadecimal notation
            charOutput pointer value;
            hexInput   pointer value;
            hexLen     int(10) value;
         end-pr;
      /endif
      /IF NOT DEFINED(CVTHC)
      /DEFINE CVTHC
         dcl-pr cvtch extproc('cvtch');  // MI Convert characters to hexadecimal notation
            charOutput char(32765) OPTIONS(*VARSIZE);
            hexInput   char(65530) OPTIONS(*VARSIZE);
            hexLen     int(10) value;
         end-pr;
      /endif


       /ENDIF
