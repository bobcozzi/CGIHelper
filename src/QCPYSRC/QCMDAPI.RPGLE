**FREE

       /IF NOT DEFINED(rpg_QCMD)
       /DEFINE rpg_QCMD

          /if NOT DEFINED(QUSCMDLN)
          /DEFINE QUSCMDLN
               // Pop-up Command Line Window API
            dcl-pr QUSCMDLN  extPgm('QUSCMDLN') end-pr;
          /ENDIF

          /IF NOT DEFINED(QCMDEXC)
          /DEFINE QCMDEXC
             dcl-pr qcmdexc extpgm('QCMDEXC');
                cmdString  char(32702)  Const OPTIONS(*VARSIZE);
                cmdLength  packed(15:5) Const;
                cmdIGC     char(3)      Const OPTIONS(*NOPASS);
             end-pr;
          /ENDIF

          /IF NOT DEFINED(SYSTEM)
          /DEFINE SYSTEM
             dcl-pr system  int(10) extProc('system');
                cmdString  pointer VALUE OPTIONS(*STRING:*TRIM);
             end-pr;
          /ENDIF


        /ENDIF
