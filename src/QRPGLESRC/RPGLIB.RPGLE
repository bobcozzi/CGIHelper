**FREE
        ctl-opt NOMAIN;

    /include cgiHelper/qcpysrc,qusec
    /include cgiHelper/qcpysrc,cgiCONST
    /include cgiHelper/qcpysrc,rpglib

    // Some of these functions use the Operation Descriptor
    // so we prototype that CEEDOD API here, along with
    // the supporting parameter variables.
      dcl-pr CEEDOD extproc('CEEDOD');
        parameterNumber int(10) CONST;
          // The rest of the paramters are returned to the caller
        descType int(10);
        dataType int(10);
        descInfo1 int(10);
        descInfo2 int(10);
        inputLen  int(10);
        fc             char(12) OPTIONS(*OMIT);
      end-pr;
      dcl-pr CEEGSI extproc('CEEGSI');
        parameterNumber int(10) CONST;
          // The rest of the paramters are returned to the caller
        dataType int(10);
        current_length int(10);
        maximum_Length int(10);
        fc             char(12) OPTIONS(*OMIT);
      end-pr;

      // Parameters passed to CEEDOD
      dcl-s p_curLen int(10);
      dcl-s p_maxLen int(10);
      dcl-s descType int(10);
      dcl-s dataType int(10);
      dcl-s descInfo1 int(10);
      dcl-s descInfo2 int(10);



    dcl-c TO_LOWER CONST(1);
    dcl-c TO_UPPER CONST(0);

    dcl-pr QlgConvertCase extProc('QlgConvertCase');
        ctrlBlock likeDS(Qlg_CCSID_ReqCtlBlk_T) const;
        input     char(CGI_MAXBUFFER) CONST OPTIONS(*VARSIZE);
        output    char(CGI_MAXBUFFER) OPTIONS(*VARSIZE);
        length    int(10) Const;
        qusec     LIKEDS(QUSEC_T) OPTIONS(*VARSIZE);
    end-pr;
    dcl-pr QlgConvertCasePtr extProc('QlgConvertCase');
        ctrlBlock likeDS(Qlg_CCSID_ReqCtlBlk_T) const;
        input     pointer value;
        output    pointer value;
        length    int(10) Const;
        qusec     LIKEDS(QUSEC_T) OPTIONS(*VARSIZE);
    end-pr;

    dcl-s cvtData char(CGI_MAXBUFFER);
    dcl-s orgData char(CGI_MAXBUFFER);

    dcl-proc rpg_toLower EXPORT ;
      dcl-pi rpg_toLower varchar(CGI_MAXBUFFER) RTNPARM;
        data      varchar(CGI_MAXBUFFER) CONST OPTIONS(*VARSIZE);
        start     int(10) Const OPTIONS(*NOPASS);
        length    int(10) Const OPTIONS(*NOPASS);
        dataCCSID int(10) Const OPTIONS(*NOPASS);
      end-pi;

      dcl-s  len  int(10);   // "long"
      dcl-s  strPos int(10) Inz(1);
      dcl-s  strLen int(10) Inz(-1);

      dcl-ds frcb LIKEDS(Qlg_CCSID_ReqCtlBlk_T) Inz(*LIKEDS);
      dcl-ds ec LIKEDS(QUSEC_T) inz(*LIKEDS);

      len = %len(data);

      frcb.Type_of_Request = 1;
      frcb.Case_Request = TO_LOWER;  // 0=Upper 1=Lower

      if (%Parms() >= %ParmNum(dataCCSID));
        frcb.CCSID_of_Input_Data = dataCCSID;
      endif;

      if (%Parms() >= %ParmNum(START));
        if (start > 0);
          strPos = start;
        endif;
      endif;

      strlen = len;
      if (%Parms() >= %ParmNum(LENGTH));
        if (length > 0);
          if (length < strLen);
            strLen = length;
          endif;
        endif;
      endif;
      if (strLen < 0);
          strlen = len;
      endif;

      if (strLen > 0);
        cvtData = %subst(data : strPos : strLen);
        orgData = %subst(data : 1 : len);
        QlgConvertCase( frcb : cvtData : cvtData : strLen : ec);
        if (ec.Bytes_Returned=0);
          %SUBST(orgData : strPos : strLen) = %SUBST(cvtData : 1 : strLen);
          return %SUBST(orgData : 1 : len);
        endif;
      endif;
      return '';
    end-proc;

    dcl-proc rpg_toUpper EXPORT;
      dcl-pi rpg_toUpper varchar(CGI_MAXBUFFER) RTNPARM;
        data      varchar(CGI_MAXBUFFER) CONST OPTIONS(*VARSIZE);
        start     int(10) Const OPTIONS(*NOPASS);
        length    int(10) Const OPTIONS(*NOPASS);
        dataCCSID int(10) Const OPTIONS(*NOPASS);
      end-pi;

      dcl-s  len  int(10);   // "long"
      dcl-s  strPos int(10) Inz(1);
      dcl-s  strLen int(10) Inz(-1);

      dcl-ds frcb LIKEDS(Qlg_CCSID_ReqCtlBlk_T) Inz(*LIKEDS);
      dcl-ds ec LIKEDS(QUSEC_T) inz(*LIKEDS);

      len = %len(data);

      frcb.Type_of_Request = 1;
      frcb.Case_Request = TO_UPPER;  // 0=Upper 1=Lower

      if (%Parms() >= %ParmNum(dataCCSID));
        frcb.CCSID_of_Input_Data = dataCCSID;
      endif;

      if (%Parms() >= %ParmNum(START));
        if (start > 0 and start <= len);
          strPos = start;
        endif;
      endif;

      strlen = len;
      if (%Parms() >= %ParmNum(LENGTH));
        if (length > 0);
          if (length < strLen);
            strLen = length;
          endif;
        endif;
      endif;

      if (strLen < 0);
          strlen = len;
      endif;

      if (strLen > 0);
        cvtData = %subst(data : strPos : strLen);
        orgData = %subst(data : 1 : len);
        QlgConvertCase( frcb : cvtData : cvtData : strLen : ec);
        if (ec.Bytes_Returned=0);
          %SUBST(orgData : strPos : strLen) = %SUBST(cvtData : 1 : strLen);
          return %SUBST(orgData : 1 : len);
        endif;
      endif;
      return '';
    end-proc;


    dcl-proc rpg_LEFT EXPORT;
      dcl-pi rpg_LEFT varchar(CGI_MAXBUFFER) RTNPARM;
        data      VARCHAR(CGI_MAXBUFFER) CONST OPTIONS(*VARSIZE);
        length    int(10) CONST;
      end-pi;

      if (length > 0 and length < %len(data));
          return %SUBST(data : 1 : length);
      endif;
      return data;
    end-proc;

