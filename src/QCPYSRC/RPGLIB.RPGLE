**FREE
      /if NOT DEFINED(RPG_UTILS)
      /DEFINE RPG_UTILS
      /include cgihelper/qcpysrc,cgiCONST

      dcl-ds Qlg_CCSID_ReqCtlBlk_T Qualified Inz Template;
        Type_of_Request     int(10);
        CCSID_of_Input_Data int(10);
        Case_Request        int(10);
        reserved            char(10) INZ(*ALLX'00');
      end-ds;

      dcl-pr rpg_toLower varchar(CGI_MAXBUFFER) RTNPARM
                extproc('rpg_toLower');
        data      varchar(CGI_MAXBUFFER) CONST OPTIONS(*VARSIZE);
        start     int(10) Const OPTIONS(*NOPASS);
        length    int(10) Const OPTIONS(*NOPASS);
        dataCCSID int(10) CONST OPTIONS(*NOPASS);
      end-pr;
      dcl-pr rpg_toUpper varchar(CGI_MAXBUFFER) RTNPARM
                extproc('rpg_toUpper');
        data      varchar(CGI_MAXBUFFER) CONST OPTIONS(*VARSIZE);
        start     int(10) Const OPTIONS(*NOPASS);
        length    int(10) Const OPTIONS(*NOPASS);
        dataCCSID int(10) Const OPTIONS(*NOPASS);
      end-pr;

      dcl-pr rpg_LEFT varchar(CGI_MAXBUFFER) RTNPARM extproc('rpg_Left');
        data      VARCHAR(CGI_MAXBUFFER) CONST OPTIONS(*VARSIZE);
        length    int(10) CONST;
      end-pr;
      /ENDIF
