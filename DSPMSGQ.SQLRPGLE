**Free
       /IF DEFINED(*CRTBNDRPG)
         ctl-opt DFTACTGRP(*NO);
      /ENDIF
        CTL-OPT
        BNDDIR('CGIHELPER/CGIHELPER' : 'RPGHELPER/RPGHELPER')
        ALWNULL(*USRCTL) OPTION(*NODEBUGIO:*SRCSTMT)
        MAIN(MAIN);

      /include cgiHelper/qcpysrc,cgilib
      /include rpgHelper/qcpysrc,rpgHelper

         // match what you use in your Company.
   DCL-S COMP_LOGO VARCHAR(50) INZ('logo.jpg');
   DCL-S COMP_TITLE VARCHAR(50) INZ('Your Company Logo file should go here');

   dcl-ds indy Qualified;
      msgReply int(5);
      msgText  int(5);
      msgType  int(5);
      msgid    int(5);
   end-ds;

   dcl-s MSGID       char(7);
   dcl-s POSTED      varchar(48);
   dcl-s FROM_USRPRF varchar(10);
   dcl-s FROM_PGM    varchar(10);
   dcl-s FROM_JOB    varchar(28);
   dcl-s MSGTEXT     varchar(512);
   dcl-s MSGTYPE     varchar(16);
   dcl-s MSGREPLY    varchar(256);
   dcl-s start_DATE  varchar(26);
   dcl-s end_date    varchar(26);
   dcl-s counter     int(10);
   dcl-s i           int(10);
   dcl-s MSGQNAME    varchar(10);
   dcl-s MSGQOPTION  varchar(10);

   dcl-c Style '<style>\n +
          .button {\n+
            display: inline-block;\n +
            padding: 10px 20px;\n +
            font-size: 16px;\n +
            font-weight: bold;\n +
            text-align: center;\n +
            color: white;\n +
            background-color: blue;\n +
            border: none;\n +
            border-radius: 5px;\n +
            text-decoration: none;\n +
            cursor: pointer;\n +
            transition: background-color 0.3s ease; \n +
         }\n +
         .button:active { \n+
            background-color: blue;\n +
         }\n +
         .button:hover {\n +
            background-color: darkblue;\n +
            color: yellow;\n +
         }\n +
         table {\n +
            border-collapse: collapse; \n +
            width: 95%; \n +
         }\n +
         th, td {\n +
            border: 1px solid black; \n +
            padding: 8px; \n +
            text-align: left; \n +
            white-space: nowrap;\n +
         }\n +
         tr:nth-child(odd) {\n +
            background-color: lightgrey; \n +
         }\n +
         tr:nth-child(even) {\n +
            background-color: white; \n +
         }\n +
         .nowrap {\n +
            white-space: nowwrap;\n +
         }\n +
         .micetype {\n +
            font-size: 16px;\n +
         }\n +
         .clear {\n +
            font-size: 12px;\n +
            font-family: Helvetica, Arial, sans-serif;\n+
         }\n +
         .MSGW {\n+
           color: red;\n+
           font-weight: bold;\n+
         }\n+
         .error {\n+
            color: red;\n+
            font-size: 12px;\n+
            display: none;\n+
        }\n+
         </style>\n';

      dcl-c tableTop '<table>\n<tr>\n<th>MSGID</th>\n+
                             <th>POSTED</th>\n+
                             <th>User Profile</th>\n+
                             <th>From Program</th>\n+
                             <th>From Job</th>\n+
                             <th>Message Text</th>\n+
                             <th>Message Type</th>\n+
                             <th>Reply</th>\n+
                     </tr>\n';
      dcl-s msgTypeCount int(10);
      dcl-s msg_Types varchar(64);
      dcl-ds msgSelect Qualified;
       INQ varchar(10);
       INFO varchar(10);
       RQS varchar(10);
       COMP varchar(10);
       DIAG varchar(10);
       NOTIFY varchar(10);
       ESCAPE varchar(10);
      end-ds;
   dcl-proc main;

   EXEC SQL SET OPTION  COMMIT=*NONE, NAMING=*SYS;

   MSGQNAME   = cgi_getVar('MSGQ' : 1 : 'TOUPPER');
   MSGQOPTION = cgi_getVar('MSGQOPTION' : 1 : 'TOUPPER');

   if (MSGQOPTION = '' and MSGQNAME = '');
       MSGQNAME   = 'QSYSOPR';
   endif;

   if (MSGQOPTION = '' and MSGQNAME <> '');
       if (MSGQNAME = 'QHST');
         MSGQOPTION = 'QHST';
       else;
         MSGQOPTION = MSGQNAME;
       endif;
   endif;

   if (MSGQOPTION <> '' and MSGQNAME = '');
      if (MSGQOPTION = 'QSYSOPR' or MSGQOPTION = '*SYSOPR');
         MSGQNAME   = 'QSYSOPR';
      elseif (MSGQOPTION = 'QHST' or MSGQOPTION = '*HST');
         MSGQNAME = 'QHST';
      elseif (MSGQOPTION = 'USRQ' or MSGQOPTION = '*USRQ');
       if (MSGQNAME = '');
         MSGQNAME   = 'QSYSOPR';
       endif;
      endif;
   endif;

   start_date = cgi_getVAR('start_time');
   end_date   = cgi_getVAR('end_time');
   msgTypeCount = cgi_getVarCount('MSGTYPE');
   snd-msg 'CGI Counter MSGTYPE=' + %char(msgTypeCount);
   msg_Types = '';
   clear msgSelect;
   if (msgTypeCount > 0);
      for i = 1 to msgTypeCount;
         msgType = cgi_getVar('MSGTYPE' : i);
      /IF DEFINED(*V7R4M0)
         select msgtype;
           when-is '*INQ';
            msgSelect.INQ = 'checked';
           when-is '*INFO';
            msgSelect.INQ = 'checked';
           when-is '*RQS';
            msgSelect.RQS = 'checked';
           when-is '*COMP';
            msgSelect.COMP = 'checked';
           when-is '*DIAG';
            msgSelect.DIAG = 'checked';
           when-is '*NOTIFY';
            msgSelect.NOTIFY = 'checked';
           when-is '*ESCAPE';
            msgSelect.ESCAPE = 'checked';
         endsl;
     /ELSE
         select;
           WHEN MSGTYPE = '*INQ';
            msgSelect.INQ = 'checked';
           WHEN MSGTYPE = '*INFO';
            msgSelect.INQ = 'checked';
           WHEN MSGTYPE = '*RQS';
            msgSelect.RQS = 'checked';
           WHEN MSGTYPE = '*COMP';
            msgSelect.COMP = 'checked';
           WHEN MSGTYPE = '*DIAG';
            msgSelect.DIAG = 'checked';
           WHEN MSGTYPE = '*NOTIFY';
            msgSelect.NOTIFY = 'checked';
           WHEN MSGTYPE = '*ESCAPE';
            msgSelect.ESCAPE = 'checked';
         endsl;
      /ENDIF
         msg_Types += %trimR(msgTYpe) + ',';
      endfor;
      msg_Types = %trim(msg_Types);
      snd-msg 'MSGTYPE=' + msg_Types;
   endif;


   if (start_date = '');
        start_date = tmTOISO8601(%timeStamp() - %HOURS(24));
   endif;
   if (end_date = '');
        end_date = tmTOISO8601(%TimeStamp(%Date() + %DAYS(1)) - %SECONDS(1));
   endif;

   counter = 0;
   htmlPage_Start();  // write out the page's starting HTML
   system('chgjob log(4 0 *seclvl)');
   cgi_WrtCmt('START_DATE=' + %trimR(start_date));
   cgi_WrtCmt('END_DATE=' + %trimR(end_date));
   cgi_WrtCmt('MSGQ=' + %TRIMR(MSGQOPTION) + ' ' +
                         %TRIMR(MSGQNAME));
   cgi_WrtCmt('MSGTYPES=' + %char(msgTypeCount) + ' ' +
            %trimR(msg_Types));

   cgi_stdout(date_picker('start_time' : 'end_time' : MSGQOPTION));
   cgi_stdout(date_pickerJS('start_time' : 'end_time' : start_date : end_date));

      if (MSGQOPTION = 'QHST' or MSGQNAME = 'QHST');
       open_QHST(iso8601ToTM(start_date) : iso8601ToTM(end_date));
       fetch_QHST();
      else;
       open_MSGQ();
       fetch_MSGQ();
      endif;

         if (sqlState >= '02000');
            cgi_stdout('<h2>No messages to display</h2>');
         else;
            cgi_stdout(tableTop);
            dow (sqlState < '02000');
               // Write out each row as a table entry
               counter += 1;
               cgi_stdout('<tr><td>' + MSGID + '</td>' +
                  '<td>' + %trimR(POSTED) + '</td>' +
                  '<td>' + FROM_USRPRF + '</td>' +
                  '<td>' + FROM_PGM + '</td>' +
                  '<td class="clear nowrap">' + joblogLink(FROM_JOB) +
                  '</td>');

               if (MSGID <> '' and %SUBST(MSGID : 1 : 4) = 'CPPE');
                  cgi_stdout('<td class="MSGW">' +
                        cgi_encodeURI(MSGTEXT) + '</td>');
               else;
                  cgi_stdout('<td class="micetype">' +
                        cgi_encodeURI(MSGTEXT) + '</td>');
               endif;
               if (msgType = '*INQ' and MSGREPLY <> 'MSGW');
                     msgType = 'INQ/RPY';
               endif;
               cgi_stdout('<td>' + msgType + '</td>');

               if (MSGID <> '' and %SUBST(MSGID : 1 : 4) = 'CPPE');
                  cgi_stdout('<td class="MSGW">PROBLEM DETECTED</td>');
               elseif (msgType = '*INQ' or msgType = 'INQ/RPY');
                  if (msgReply <> 'MSGW');
                     cgi_stdout('<td class="micetype nowrap">' +
                           MSGREPLY + '</td>');
                  else;
                     cgi_stdout('<td class="MSGW">' +
                           MSGREPLY + '</td>');
                  endif;
               else;
                  cgi_stdout('<td></td>');
               endif;
               cgi_stdout('</tr>\n');

               if (MSGQOPTION = 'QHST');
                  fetch_QHST();
               else;
                  fetch_MSGQ();
               endif;
            enddo;
         endif;
         if (counter > 0);
            cgi_stdout('</table>\n');
         endif;
         return;  // Return to caller

         on-exit;
            if (MSGQOPTION = 'QHST');
               EXEC SQL close QHST;
            else;
               EXEC SQL close QSYSOPR;
            endif;
            htmlPage_End();  // Close out the page no matter what happens
      end-proc;

   dcl-proc htmlPage_Start;
      dcl-s postedTime char(64);
      dcl-s curTime timestamp inz(*SYS);
      cgi_wrtContentType();
      cgi_stdout('<!DOCTYPE html>\n<html lang="en">\n');
      cgi_stdout(%ScanRpl('%s': %trimR(MSGQNAME) :
               '<head>\n<title>%s Messages</title>\n'));
      cgi_stdout(' <meta http-equiv="refresh" content="180">\n');

      cgi_stdout(style);

      cgi_stdout('<script>\n');  // Start JavaScript
      cgi_stdout(getMsgTypeJS());
      cgi_stdout(getMSGQNameJS());
      cgi_stdout('</script>\n'); // End JavaScript

      cgi_stdout('</head>\n');
      cgi_stdout('<body onload="initDates();">\n');
      cgi_stdout('<a href="javascript:window.location.replace(''/'');" ' +
                 ' title="Return to main menu (index.html)">' +
               '<img src="/img/' +
               COMP_LOGO + '" alt="' +
               COMP_TITLE + '"/></a>\n');

      cgi_stdout('<h2>' + %trimR(MSGQNAME) + ' Messages</h2>\n');
         // Using RPG Helper Service Program (*SRVPGM) here.
         // We could use the SQL VARCHAR_FORMAT function
         // To accomplish the same thing if desired.
         rpg_datefmt( postedTime : %size(postedTime) :
                      curTime :
                      'Wwwwwwwwwz, DD Mmm YYYY, ZH:MI AP' :
                      'ISO');

            // SQL VARCHAR_FORMAT example
      // EXEC SQL  VALUES
      //            VARCHAR_FORMAT(current_TimeStamp,
      //            'Day, DD Mon YYYY HH:MI:SS AM')
      //           INTO :PostedTime;

      cgi_stdout('<p style="font-size:small;">Last scan for issues:<b> ' +
                  %trimR(postedTime) + '</b> ' +
               '(auto-refreshes every 3 minutes)</p>\n');
      return;
   end-proc;

   dcl-proc htmlPage_End;
      cgi_stdout('</body>\n</html>\n');
   end-proc;


   dcl-proc joblogLink;
     dcl-pi joblogLink varchar(512) rtnparm;
        jobID varchar(32) const;
     end-pi;
     dcl-s link varchar(512);

     link = '<a href="/cgi2/dspjoblog.pgm?JOB=' +
               cgi_encodeURI(%trimR(jobID) : 'hRef') + '" ' +
               'title="display the joblog if the job is still active.">' +
               cgi_encodeURI(%trim(JOBID)) + '</a>';
      return link;
   end-proc;

   dcl-proc open_QHST;
     dcl-pi open_QHST;
      start_dts timestamp(0) const OPTIONS(*NOPASS:*OMIT);
      end_dts   timestamp(0) const OPTIONS(*NOPASS);
     end-pi;

     dcl-s strdate timestamp(0);
     dcl-s enddate timestamp(0) inz(*SYS);

     if (%Parms() >= %ParmNum(start_DTS) and %addr(START_DTS) <> *NULL);
        strdate = start_dts;
     else;
        strdate = %timeStamp() - %HOURS(24);
     endif;
     if (%Parms() >= %ParmNum(end_DTS));
        enddate = end_dts;
     else;
        enddate = %TimeStamp(%Date() + %DAYS(1)) - %SECONDS(1);
     endif;
     cgi_stdout('<pre>Start_Time=>' + %char(strDate) +
                  ', End_Time=>' + %char(endDate) + '</pre>\n');
   EXEC SQL DECLARE QHST CURSOR FOR
     with QHST as
      (select QHST.message_ID AS MSGID,
       QHST.message_timestamp AS POSTED_TIMESTAMP,
       varchar_Format(QHST.message_timestamp,
                        'YYYY-MM-DD HH12:MI AM') as POSTED,
       QHST.FROM_USER AS FROM_USRPRF,
       QHST.FROM_PROGRAM AS FROM_PGM,
       QHST.FROM_JOB AS JOB,
       QHST.message_text AS MSGTEXT,
       CASE QHST.message_type
         WHEN 'COMPLETION'    THEN '*COMP'
         WHEN 'DIAGNOSTIC'    THEN '*DIAG'
         WHEN 'ESCAPE'        THEN '*ESCAPE'
         WHEN 'INFORMATIONAL' THEN '*INFO'
         WHEN 'INQUIRY'       THEN '*INQ'
         WHEN 'NOTIFY'        THEN '*NOTIFY'
         WHEN 'REQUEST'       THEN '*RQS'
            ELSE QHST.MESSAGE_TYPE  -- Fallback (if new types are added in future)
      END AS MSGTYPE

      FROM table(QSYS2.HISTORY_LOG_INFO(
            start_time=> :strDate,
            END_TIME =>  :endDate)) QHST
      )
      select MSGID, POSTED, FROM_USRPRF, FROM_PGM, JOB,
             MSGTEXT, msgType
         FROM QHST
         WHERE MSGID NOT IN ('CPF1124','CPF1164','CPI2417',
         'CPF590A','CPF5140')
         and MSGID NOT LIKE 'CPIAD%'
         and MSGID NOT LIKE 'CPC70%'
         ORDER BY POSTED_TIMESTAMP DESC
         LIMIT 1024;
      EXEC SQL  OPEN QHST;

   end-proc;

   dcl-proc fetch_QHST;
      dow ('QHST' = 'QHST' and SQLState < '02000');
         EXEC SQL  FETCH QHST INTO
                       :MSGID : indy.MSGID ,
                       :POSTED,
                       :FROM_USRPRF, :FROM_PGM, :FROM_JOB,
                       :MSGTEXT, :msgType;
         if (SQLState < '02000' and
             MSG_TYPES <> '' and
             %SCAN(MSGTYPE : MSG_TYPES) = 0);
            iter;
         endif;
          if (indy.msgid < 0);
            clear msgid;
         endif;
         leave;
      enddo;
   end-proc;


   dcl-proc open_MSGQ;
     dcl-pi open_MSGQ;
      start_dts timestamp(0) const OPTIONS(*NOPASS:*OMIT);
      end_dts   timestamp(0) const OPTIONS(*NOPASS:*OMIT);
     end-pi;
     dcl-s strdate timestamp(0);
     dcl-s enddate timestamp(0) inz(*SYS);

     if (%Parms() >= %ParmNum(start_DTS) and %addr(START_DTS) <> *NULL);
        strdate = start_dts;
     else;
        strdate = %timeStamp() - %HOURS(24);
     endif;
     if (%Parms() >= %ParmNum(end_DTS) and %addr(START_DTS) <> *NULL);
        enddate = end_dts;
     else;
        enddate = %timeStamp() + %HOURS(24);
     endif;

      EXEC SQL DECLARE QSYSOPR CURSOR FOR
       WITH msgW as
       (
         SELECT m.message_ID AS MSGID,
         m.message_timestamp AS POSTED_TIMESTAMP,
         varchar_Format(m.message_timestamp, 'YYYY-MM-DD HH12:MI AM') as POSTED,
         m.FROM_USER AS FROM_USRPRF,
         m.FROM_PROGRAM AS FROM_PGM,
         m.FROM_JOB AS JOB,
         m.message_text AS MSGTEXT,
         CASE m.message_type
           WHEN 'COMPLETION'    THEN '*COMP'
           WHEN 'DIAGNOSTIC'    THEN '*DIAG'
           WHEN 'ESCAPE'        THEN '*ESCAPE'
           WHEN 'INFORMATIONAL' THEN '*INFO'
           WHEN 'INQUIRY'       THEN '*INQ'
           WHEN 'NOTIFY'        THEN '*NOTIFY'
           WHEN 'REQUEST'       THEN '*RQS'
           ELSE M.MESSAGE_TYPE
       END AS MSGTYPE,
         CASE
         WHEN R.MESSAGE_KEY IS NULL and M.MESSAGE_TYPE = 'INQUIRY' THEN 'MSGW'
         WHEN R.MESSAGE_KEY IS NOT NULL THEN
            '<b>' concat r.message_text  concat '</b> ' CONCAT
            '(' concat r.message_subtype CONCAT ') by ' CONCAT
            '<b>' concat r.FROM_USER concat '</b> at ' CONCAT
            varchar_Format(r.message_timestamp, 'YYYY-MM-DD HH24:MI:SS')
         ELSE ''
         END AS MSGREPLY
         FROM TABLE (qsys2.message_queue_info(
                           QUEUE_LIBRARY=>'*LIBL',
                           QUEUE_NAME=> :MSGQNAME)) M
            LEFT OUTER JOIN TABLE (qsys2.message_queue_info(
                                             QUEUE_LIBRARY=>'*LIBL',
                                             QUEUE_NAME=> :MSGQNAME)) R
                  ON M.MESSAGE_KEY = R.ASSOCIATED_MESSAGE_KEY
         WHERE M.MESSAGE_TYPE <> 'REPLY'
      )
      select MSGID, POSTED, FROM_USRPRF, FROM_PGM, JOB,
             MSGTEXT, msgType, MSGREPLY
         FROM MSGW M
         ORDER BY M.POSTED_TIMESTAMP DESC;

      EXEC SQL  OPEN QSYSOPR;

   end-proc;

   dcl-proc fetch_MSGQ;
      dow (SQLState < '02000');
         EXEC SQL  FETCH QSYSOPR INTO
                       :MSGID : indy.msgid,
                       :POSTED,
                       :FROM_USRPRF, :FROM_PGM, :FROM_JOB,
                       :MSGTEXT  : indy.msgText,
                       :msgType  : indy.msgType,
                       :MSGREPLY : indy.msgReply;
         if (SQLState < '02000' and
             MSG_TYPES <> '' and
             %SCAN(MSGTYPE : MSG_TYPES) = 0);
             cgi_wrtCmt('Skipping: ' + %trimR(MSGID) +
                  ' ' + %trim(MSGTYPE));
            iter;
         endif;
         if (indy.msgid < 0);
            clear msgid;
         endif;
         leave;
      enddo;
   end-proc;

   dcl-proc date_picker;
     dcl-pi date_picker varchar(2048) rtnparm;
       startTimeID varchar(32) Const;
       endTimeID   varchar(32) Const;
       msgqType    varchar(10) Const options(*NOPASS);
     end-pi;

     dcl-s QSYSOPR_SELECTED varchar(10);
     dcl-s QHST_SELECTED    varchar(10);
     dcl-s USRQ_SELECTED    varchar(10);

      if (%parms() >= %ParmNum(msgqType) and msgqType <> '');
         if (MSGQTYPE = 'QSYSOPR' or
             MSGQTYPE = 'MSGW');
            QSYSOPR_SELECTED = ' selected';
         elseif (MSGQTYPE = 'QHST');
            QHST_SELECTED = ' selected';
         elseif (MSGQTYPE = '*USRQ' or MSGQTYPE = 'USRQ');
            USRQ_SELECTED = ' selected';
         endif;
      else;
         QSYSOPR_SELECTED = ' selected';
      endif;

     return '<form id="dateTimeForm" +
              action="/cgi2/dspmsgq.pgm" method="GET">\n' +
      '<fieldset>\n' +
        '<legend>Select MSGQ and Date/Time Range - ' +
        'Default: Last 24 hours</legend>\n' +
        '<label for="MSGQOPTION">MSGQ:</label>\n' +
        '<select id="MSGQOPTION" name="MSGQOPTION" ' +
            'onchange="MSGQSelect()">\n' +
            '<option value="QSYSOPR" ' + QSYSOPR_SELECTED + '>' +
               'QSYSOPR</option>\n' +
            '<option value="QHST" ' + QHST_SELECTED + '>' +
               'QHST</option>\n' +
            '<option value="*USRQ" ' + USRQ_SELECTED + '>' +
            'User Specified</option>\n' +
        '</select>\n' +
        '<input type="text" id="MSGQ" name="MSGQ"\n' +
               ' placeholder="' + %TRIM(MSGQNAME) + '" ' +
               ' value="' + %TRIM(MSGQNAME) + '" ' +
               ' oninput="MSGQInput()">\n' +
        '<div>\n' +
            '<label for="' + %trimR(STARTTIMEID) +
                        '">Start Date & Time:</label>\n' +
            '<input type="datetime-local" id="'  + %trimR(STARTTIMEID) +
                        '" name="start_time" ' +
               'required step="1">\n' +
        '</div>\n' +
        '<div>\n' +
            '<label for="'  + %trimR(endTimeID) +
                        '">End Date & Time:</label>\n' +
            '<input type="datetime-local" id="'  + %trimR(endTimeID) +
                        '" name="'  + %trimR(endTimeID) + '" ' +
               'required step="1">\n' +
            '<span id="error_msg" class="error">Start time must be ' +
        'earlier than end time.</span>\n' +
       '</div>\n' +
       buildMsgTypeButtons() +
      '<button type="submit">Submit</button>\n' +
      '</fieldset>\n' +
      '</form>\n\n';


      end-proc;

      dcl-proc date_PickerJS;
        dcl-pi date_PickerJS varchar(2048) rtnparm;
          startTimeID varchar(32) Const;
          endTimeID   varchar(32) Const;
          startTime   varchar(26) Const options(*NOPASS);
          endTime     varchar(26) Const options(*NOPASS);
        end-pi;
         dcl-s initStart varchar(64);
         dcl-s initEnd   varchar(64);

         if (%Parms() >= %ParmNum(startTime) and startTime <> '');
            initStart = '''' + %trimR(startTime) + '''';
         else;
            initStart = 'formattedYesterday';
         endif;
         if (%Parms() >= %ParmNum(endTime) and endTime <> '');
            initEnd = '''' + %trimR(endTime) + '''';
         else;
            initEnd = 'formattedToday';
         endif;

           return
      '<script>\n'+
        'function validateDateTime() {\n'+
            'let startTime = document.getElementById("' + %trimR(STARTTIMEID) +
                         '").value;\n'+
            'let endTime = document.getElementById("'  + %trimR(endTimeID) +
                        '").value;\n'+
            'let errorMsg = document.getElementById("error_msg");\n'+
            'if (startTime && endTime) {\n'+
               ' let startDateTime = new Date(startTime);\n'+
               ' let endDateTime = new Date(endTime);\n'+
               ' if (startDateTime > endDateTime) {\n'+
               '     errorMsg.style.display = "inline";\n'+
               '     return false;\n'+
               ' } else {\n'+
               '     errorMsg.style.display = "none";\n'+
               ' }\n'+
            '}\n'+
            'return true;\n'+
        '}\n'+
        ' //  ONLOAD Handler starts here\n' +
        'function initDates() {\n'+
           'document.getElementById("' + %trimR(STARTTIMEID) + '").' +
                        'addEventListener("change", validateDateTime);\n'+

           'document.getElementById("'  + %trimR(endTimeID) + '").' +
                        'addEventListener("change", validateDateTime);\n'+
         'let yesterday = new Date();\n'+
         'let UTCoffset = yesterday.getTimezoneOffset();\n'+
         'yesterday.setDate(yesterday.getDate() - 1);\n'+
         'yesterday.setMinutes(yesterday.getMinutes() - UTCoffset);\n'+
         'let today = new Date();\n'+
         'today.setHours(23, 59, 59, 999);\n'+
         'today.setMinutes(today.getMinutes() - UTCoffset);\n'+
         'let formattedYesterday = yesterday.toISOString().slice(0, 16);\n'+
         'let formattedToday = today.toISOString().slice(0, 16);\n'+
         '  console.log(formattedYesterday);\n'+
         '  console.log(formattedToday);\n'+
         '// Assign the formatted values to the input fields\n'+
         'document.querySelector(''input[name="' + %trimR(STARTTIMEID) +
                     '"]'').value = ' + initStart + ';\n'+
         'document.querySelector(''input[name="' + %trimR(ENDTIMEID) +
                     '"]'').value = ' + initEnd + ';\n'+
        '};\n'+
    '</script>\n';
      end-proc;

      dcl-proc  tmToISO8601;
         dcl-pi tmToISO8601 varchar(26) rtnparm;
          isoTM timestamp const;
            // (0, 3, 6) 0=No micro/milli seconds, 3=milliseconds, 6=microseconds
          rtnFMT int(10) CONST OPTIONS(*NOPASS);
         end-pi;
         DCL-S tm0 TIMESTAMP(0);
         DCL-S tm6 TIMESTAMP;
         DCL-S tm3 TIMESTAMP(3);
         dcl-s tm char(26);
         dcl-s hmsTime time(*HMS:);
         dcl-s outFMT int(10) inz(0);

         if (%Parms() >= %ParmNum(rtnFMT) and RTNFMT IN %LIST(0 : 3 : 6));
            outFMT = rtnFMT;
         endif;
 /IF DEFINED(*V7R4M0)
         select outFMT;
          when-is 3;
            tm3 = isoTM;
            tm = %char(tm3);
          when-is 6;
            tm6 = isoTM;
            tm = %char(tm6);
          when-is 0;
            tm0 = isoTM;
            tm = %char(tm0);
         endsl;
 /ELSE
         select;
          when OUTFMT = 3;
            tm3 = isoTM;
            tm = %char(tm3);
          when OUTFMT = 6;
            tm6 = isoTM;
            tm = %char(tm6);
          when OUTFMT = 0;
            tm0 = isoTM;
            tm = %char(tm0);
         endsl;
 /ENDIF

         hmsTime = %time(isoTM);
         %SUBST(tm : 11 : 1 ) = 'T';
         %SUBST(tm : 12 : 8) = %char(hmsTime : *HMS:);
         return %Trim(tm);
      end-proc;

     dcl-proc  ISO8601toTM;
         dcl-pi ISO8601toTM timestamp rtnparm;
          tm8601 varchar(36) Const;
         end-pi;
         dcl-s tm char(26);
         tm = tm8601;

         %SUBST(tm : 11 : 1) = '-';
         %SUBST(tm : 14 : 1) = '.';
         %SUBST(tm : 17 : 1) = '.';
         return %TimeStamp( tm );
      end-proc;

      dcl-proc getMsgTypeJS;
        dcl-pi getMsgTypeJS varchar(2048) rtnparm;
        end-pi;
        dcl-s msgTypeJS varchar(2048) inz(
         'function toggleCheckboxes(checked) {\n +
          document.querySelectorAll(''input[name="MSGTYPE"]'').+
          forEach(cb => cb.checked = checked);\n +
          }\n');
      return msgTypeJS;
      end-proc;

      dcl-proc getMSGQNameJS;
        dcl-pi getMSGQNameJS varchar(2048) rtnparm;
        end-pi;
        dcl-s msgqJS varchar(2048);
        msgQJS =
         'function MSGQSelect() {\n +
            let select = document.getElementById("MSGQOPTION");\n +
            let usrqField = document.getElementById("MSGQ");\n +

         if (select.value === "*USRQ") {\n +
               usrqField.placeholder = "Type *MSGQ name here";\n +
               usrqField.focus();\n +
               usrqField.select();\n +
         } else {\n +
               usrqField.placeholder = select.value;\n +
               usrqField.value = select.value;\n +
         }\n +
            }\n +
            function MSGQInput() {\n +
               let select = document.getElementById("MSGQOPTION");\n +
               select.value = "*USRQ"; // Switch to "User Specified"\n +
            }\n';
         return msgQJS;
      end-proc;


      dcl-proc buildMsgTypeButtons;
        dcl-pi buildMsgTypeButtons varchar(2048) rtnparm end-pi;

        dcl-s msgTypeList varchar(2048);
        msgTypeList =
         '<div>\n +
         <label for="msg1"><input type="checkbox" id="msg1" name="MSGTYPE" ' +
           msgSelect.INFO + ' value="*INFO"> *INFO</label>\n +
         <label for="msg2"><input type="checkbox" id="msg2" name="MSGTYPE" ' +
            msgSelect.INQ + ' value="*INQ"> *INQ</label>\n +
         <label for="msg3"><input type="checkbox" id="msg3" name="MSGTYPE" ' +
            msgSelect.RQS + ' value="*RQS"> *RQS</label>\n +
         <label for="msg4"><input type="checkbox" id="msg4" name="MSGTYPE" ' +
            msgSelect.COMP + ' value="*COMP"> *COMP</label>\n +
         <label for="msg5"><input type="checkbox" id="msg5" name="MSGTYPE" ' +
            msgSelect.DIAG + ' value="*DIAG"> *DIAG</label>\n +
         <label for="msg6"><input type="checkbox" id="msg6" name="MSGTYPE" ' +
            msgSelect.NOTIFY + ' value="*NOTIFY"> *NOTIFY</label>\n +
         <label for="msg7"><input type="checkbox" id="msg7" name="MSGTYPE" ' +
            msgSelect.ESCAPE + ' value="*ESCAPE"> *ESCAPE</label>\n +
         <button type="button" onclick="toggleCheckboxes(true)"> +
            Check All</button>\n +
         <button type="button" onclick="toggleCheckboxes(false)"> +
            Uncheck All</button>\n +
         </div>\n';
      return msgTypeList;
      end-proc;
