**FREE
       /IF NOT DEFINED(rpg_QUSEC)
       /DEFINE rpg_QUSEC
       /IF NOT DEFINED(QUSEC_T)
       /DEFINE QUSEC_T
       /IF NOT DEFINED(QUSEC)
       /DEFINE QUSEC
        //*******************************************************
        //*  QUSEC - API Error Data Structure
        //*  Use when calling most APIs.
        //*  Specify at a template name via the LIKEDS keyword.
        //*  Usage should be with INZ(*LIKEDS) as follows:
        //*  D apiError   DS                  LikeDS(QUsec_T)
        //*  D                                Inz(*LIKEDS)
        //*******************************************************
       Dcl-DS QUSEC_T  QUALIFIED;
         bytesProvided  Int(10)    INZ(%SIZE(QUSEC_T));
         bytes_Provided Int(10)    OVERLAY(BYTESPROVIDED);
         length         Int(10)    OVERLAY(BYTESPROVIDED);
         bytesProv      Int(10)    OVERLAY(BYTESPROVIDED);
         QUSBPRV        Int(10)    OVERLAY(BYTESPROVIDED);
         bytesReturned  Int(10)    INZ;
         QUSBAVL        Int(10)    OVERLAY(BYTESRETURNED);
         bytes_Returned Int(10)    OVERLAY(BYTESRETURNED);
         bytesRtn       Int(10)    OVERLAY(BYTESRETURNED);
         bytesAvail     Int(10)    OVERLAY(BYTESRETURNED);
         rtnLen         Int(10)    OVERLAY(BYTESRETURNED);
         rtnLength      Int(10)    OVERLAY(BYTESRETURNED);
         cpfmsgID       Char(7)    INZ(*ALLX'00');
         QUSEI          Char(7)    OVERLAY(CPFMSGID);
         msgid          Char(7)    OVERLAY(CPFMSGID);
         reserved       Char(1)    INZ(X'00');
         exceptionData  Char(255)  INZ(*ALLX'00');
         msgData        Char(255)  OVERLAY(EXCEPTIONDATA);
         qused01        Char(255)  OVERLAY(EXCEPTIONDATA);
        end-DS;
       /ENDIF
      /ENDIF

      /IF NOT DEFINED(CEE_API_ERROR_FEEDBACK)
      /DEFINE CEE_API_ERROR_FEEDBACK
          // You'll see this a _FEEDBACK or FB or FC in the CEE API Documentation
       Dcl-DS CEE_feedBack_T  QUALIFIED NOOPT;
         msgsev         Uns(5);
         msgNo          Uns(5);
         bits;
         case           Char(1)    OVERLAY(BITS);
         severity       Char(1)    OVERLAY(BITS);
         control        Char(1)    OVERLAY(BITS);
         facility_ID    Char(3);
         I_S_Info       Uns(10);
        end-DS;
      /ENDIF

         // End of master (outer-most) IF DEFINED
       /ENDIF
