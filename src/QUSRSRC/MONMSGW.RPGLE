**Free
       /IF DEFINED(*CRTBNDRPG)
         ctl-opt DFTACTGRP(*NO);
      /ENDIF
        CTL-OPT
        BNDDIR('CGIHELPER/CGIHELPER')
        ALWNULL(*USRCTL)
        OPTION(*NODEBUGIO:*SRCSTMT)
        MAIN(MAIN);

         ///////////////////////////////////////////////////////////////
         // Monitor for programs in MSGW
         // and for *ATTENTION Critical.... messages ("CPPExxx")
         // (c) 2025 by R. Cozzi, Jr. all rights reserved
         ///////////////////////////////////////////////////////////////

         // We use some CGI prototypes because we use encodeURI()
         // to format the data in the HTML email.
         // We don't actually send anything to the browser.

      /include cgiHelper/QCPYSRC,cgiEncode
      /include cgiHelper/QCPYSRC,QsysAPI

      dcl-ds psds qualified psds;
         program  *proc;                // This program's name.
         pgmName  char(10) pos(1);      // This program's name.
         pgmLIb   char(10) pos(81);     // This program's runtime library
         jobName  char(10) pos(244);    // Job Name
         jobUser  char(10) pos(254);    // Job's User Profile
         jobNbr   zoned(6:0) pos(264);  // Job Number
         runtimeUser char(10) pos(358); // Runtime user profile
         curUsrprf   char(10) pos(358); // Runtime user profile
         sysName     char(8)  pos(396);    // System Name (V7R4 feature only)
      end-ds;


      dcl-s bFirstTime ind INZ(*ON);

       // The data area name used to control
       // termination of this program.
       // If the data area exists and contains any value,
       //  then the program ends.
       // If it does not exist, or exists but is blank,
       //  then the program continues.
      dcl-s CTRLDTAARA    varchar(10) INZ('MONMSGWEND');
      dcl-s CTRLDTAARALIB varchar(10) INZ('QGPL');

       // This data are may contain an optional list
       // of CPF messages to filter out ("omit") from
       // the monitor routine. Specify them in the
       // data area separated by at least 1 blank or comma.
       // For exampe: CPA403D CPA405E CPA3394 CPA5335
       // or:         CPA403D,CPA405E, CPA3394  CPA5335
      dcl-s OMIT_MSGID    varchar(10) INZ('MONMSGWFLT');
      dcl-s OMIT_MSGIDLIB varchar(10) INZ('QGPL');
      dcl-s OMITLIST      varchar(2000);
      dcl-s LAST_OMITLIST varchar(2000);

      dcl-s delay  int(10) inz(180);

         // This program can send email via SNDDST or SNDSMTPEMM CL commands
         // Originally staff did not know if SNDSMTPEMM was working.
         // I enabled it and now it works, so we use the SMTP option
      dcl-s MAILCMD VARCHAR(10) INZ('SMTP');  // DST=SNDDST, SMTP=SNDSMTPEMM

         // The email address to which the notifications are emailed/sent.
      dcl-s emailAddr varchar(128) INZ('msgq@truck-lite.com');

         // Counts the number of alerts/msgw messages being sent.
      dcl-s counter INT(10);
      dcl-s age     INT(10);
      dcl-s ageMsg  varchar(32);

         // These are the SQL "indicator" variables used to
         // enabled NULL result fields on the FETCH.
      dcl-ds indy Qualified;
         MSGID INT(5);
         MSGSEV INT(5);
         MSGKEY INT(5);
         POSTED INT(5);
         FROM_USER INT(5);
         FROM_PGM  INT(5);
         FROM_JOB  INT(5);
         MSGTEXT   INT(5);
         MSGTYPE   INT(5);
         AGE       INT(5);
      end-ds;

         // Host variables used by the SQL FETCH operation
   dcl-s MSGID       varchar(7);
   dcl-s MSGTYPE     varchar(16);
   dcl-s MSGSEV      int(5);
   dcl-s MSGKEY      char(4) CCSID(65535);
   dcl-s POSTED      varchar(28);
   dcl-s FROM_USRPRF varchar(10);
   dcl-s FROM_PGM    varchar(10);
   dcl-s FROM_JOB    varchar(28);
   dcl-s MSGTEXT     varchar(512);
      // The SQL HOST variable for the MONMSGWAIT data area content
   dcl-s ENDMONITOR  VARCHAR(2000);

      // The work buffer where the HTML content is built/stored
      // before writing it out to the temp file.
   dcl-s BUFFER      varchar(4096);

      // I format the output HTML a little
   dcl-c Style '<style> \n +
         table {  \n +
            border-collapse: collapse;   \n +
            width: 95%;   \n +
         }  \n +
         th, td {  \n +
            border: 1px solid black;   \n +
            padding: 8px;   \n +
            text-align: left;   \n +
         }  \n +
         tr:nth-child(odd) {  \n +
            background-color: lightgrey;  \n +
         }  \n +
         tr:nth-child(even) {  \n +
            background-color: white;   \n +
         }  \n +
         .nowrap {  \n +
            white-space: nowwrap;  \n +
         }  \n +
         </style> ';
               // This HTML starts the table with the MSGW/Alert messages
      dcl-c tableTop '<table>\n<tr><th>MSGID</th>+
                             <th>POSTED</th>+
                             <th>User Profile</th>+
                             <th>From Program</th>+
                             <th>From Job</th>+
                             <th>Message Text</th>+
                             <th>MSG Type</th>+
                        </tr> ';

               // The name of the temporary or "work" file
               // where we write the HTML so it can be sent
               // as an attachment to the email.
      dcl-s ifsFile varchar(640)
              inz('/tmp/MonMsgWait.html');

    EXEC SQL SET OPTION  COMMIT=*NONE, NAMING=*SYS;

   dcl-proc main;
      dcl-pi *n;
         frequency int(10) Const;
         monmsgw_END_DA char(20) Const;
         msgID_filter_DA char(20) Const;
      end-pi;

      delay = frequency;
      ctrlDtaara = %SUBST(monmsgw_END_DA : 1 : 10);
      ctrlDtaaraLib = %SUBST(monmsgw_END_DA : 11 : 10);
      OMIT_MSGID = %SUBST(msgID_filter_DA : 1 : 10);
      OMIT_MSGIDLib = %SUBST(msgID_filter_DA : 11 : 10);

    dow (0=0);  // Do forever unless user kills the job or
                // the MONMSGWAIT *DTAARA contains any value.

      if (NOT bFirstTime);
         dlyjob( delay );  // Sleep for 3 minutes
      endif;

       // Check for termination request.
       // If this data area is NOT empty (blank)
       // the the routine exits immediately.
      EXEC SQL SELECT DATA_AREA_VALUE
                 INTO :ENDMONITOR
               FROM Table(QSYS2.DATA_AREA_INFO(
                           DATA_AREA_NAME=>    :CTRLDTAARA,
                           DATA_AREA_LIBRARY=> :CTRLDTAARALIB))
               LIMIT 1;
      IF (SQLSTATE < '02000');
         if (ENDMONITOR <> '');  // If it Exists and Has a value, then exit
            leave; // Bail out
         endif;
      endif;

      clear counter;
      clear buffer;


      if (bFirstTime);
         createTempFiles();  // Create the MSGKEY filter temp file
      endif;

      getOmitList();    // Refresh omit list from the data area on each pass


      EXEC SQL DECLARE MSGW CURSOR FOR
          WITH msgW(MSGID,
                     MSGSEV, MSGTYPE,
                     MSGKEY, MSG_TIMESTAMP,
                     POSTED,
                     FROM_USRPRF, FROM_PGM, FROM_JOB,
                     MSGTEXT, AGE) as
       (
         SELECT   m.message_ID AS MSGID,
                  m.severity     as MSGSEV,
                  m.message_type AS msgtype,
                  m.MESSAGE_KEY AS MSGKEY,

                  m.message_timestamp AS MSG_TIMESTAMP,
                  varchar_Format(m.message_timestamp,
                                 'YYYY-MM-DD HH12:MI AM') as POSTED,
                  m.FROM_USER AS FROM_USRPRF,
                  m.FROM_PROGRAM AS FROM_PGM,
                  m.FROM_JOB,
                  m.message_text AS MSGTEXT,
                  days(current_timestamp) -
                  days(M.message_timestamp) as AGE
         FROM TABLE (qsys2.message_queue_info()) M
            LEFT OUTER JOIN TABLE (qsys2.message_queue_info()) R
                  ON M.MESSAGE_KEY = R.ASSOCIATED_MESSAGE_KEY
         WHERE (M.MESSAGE_TYPE = 'INQUIRY' and
                R.ASSOCIATED_MESSAGE_KEY is NULL)
               OR LEFT(M.message_ID,4) = 'CPPE'
      )
      select M.MSGID,
             M.MSGTYPE,
             M.MSGSEV,
             M.MSGKEY,
             M.POSTED,
             M.FROM_USRPRF,
             M.FROM_PGM,
             M.FROM_JOB,
             M.MSGTEXT,
             M.AGE
         FROM MSGW M
         EXCEPTION JOIN session.OMIT_MSGID_LIST OM
           ON (M.MSGID = OM.MSGID)
         EXCEPTION JOIN SESSION.MSGKEY_LIST MK
           ON (M.MSGKEY = MK.MSGKEY)
         ORDER BY M.MSG_TIMESTAMP DESC;

         bFirstTime = *OFF;  // First time set off at this point forward

         EXEC SQL  OPEN MSGW;
         EXEC SQL  FETCH MSGW INTO
                       :MSGID : indy.MSGID,
                       :MSGTYPE  : indy.msgtype,
                       :MSGSEV : indy.MSGSEV,
                       :MSGKEY : indy.MSGKEY,
                       :POSTED : indy.POSTED,
                       :FROM_USRPRF : indy.FROM_USER,
                       :FROM_PGM : indy.FROM_PGM,
                       :FROM_JOB : indy.FROM_JOB,
                       :MSGTEXT  : indy.MSGTEXT,
                       :AGE      : indy.AGE;



            dow (sqlState < '02000');
               // Save this MSGKEY to avoid redundant emails
               EXEC SQL INSERT INTO SESSION.MSGKEY_LIST
                     values(:MSGKEY);

               if (counter = 0);
                  htmlPage_Start();  // Create the HTML Page
                  buffer += tableTop;
                  snd-msg 'Adding messages to HTML email body.';
               endif;

               counter += 1;

               // Write out each row as a table entry
               if (%SUBST(MSGID : 1 : 4) = 'CPPE');
                  msgType = '*ALERT';
               elseif (%SUBST(MSGID : 1 : 3) = 'INQ');
                  msgType = '*INQ/MSGW';
               endif;
               if (age > 0);
                  if (age = 1);
                   ageMsg = '<br />(Yesterday)';
                  else;
                   ageMsg = '<br />(' + %char(age) + ' days ago)';
                  endif;
               else;
                  clear ageMsg;
               endif;
               buffer += '<tr><td>' + MSGID + '</td>' +
                  '<td>' + %trimR(POSTED) + %trimR(ageMsg) + '</td>' +
                  '<td>' + FROM_USRPRF + '</td>' +
                  '<td>' + FROM_PGM + '</td>' +
                  '<td class="nowrap">' + FROM_JOB + '</td>';

               buffer += '<td>' + cgi_encodeURI(%trimR(MSGTEXT) : 'H') + '</td>';
               buffer += '<td>' + MSGTYPE + '</td>';
               buffer += '</tr>\n';

               buffer = %scanRpl('\n' : X'25' : buffer); // convert \n to linefeed
               exec SQL call qsys2.IFS_WRITE_UTF8(:IFSFILE,
                                    :buffer, 1208, 'APPEND', 'NONE');
               clear buffer;
               EXEC SQL  FETCH MSGW INTO
                                    :MSGID : indy.MSGID,
                                    :MSGTYPE  : indy.msgtype,
                                    :MSGSEV : indy.MSGSEV,
                                    :MSGKEY : indy.MSGKEY,
                                    :POSTED : indy.POSTED,
                                    :FROM_USRPRF : indy.FROM_USER,
                                    :FROM_PGM : indy.FROM_PGM,
                                    :FROM_JOB : indy.FROM_JOB,
                                    :MSGTEXT  : indy.MSGTEXT,
                                    :AGE      : indy.AGE;


            enddo;
                     // CLOSE "this" SQL CURSOR so we can re-use it
            EXEC SQL close MSGW;

            clear buffer;
            if (counter > 0);
               buffer = '</table>\n</body>\n</html> ';
               buffer = %scanRpl('\n' : X'25' : buffer); // convert \n to linefeed
               exec SQL call qsys2.IFS_WRITE_UTF8(:IFSFILE,
                                    :buffer, 1208, 'APPEND', 'NONE');

               sendEMail( ifsFile : emailAddr );
            endif;
         enddo;  // End DO-FOrever loop

         return;  // Return to caller

         on-exit;
            monitor;
                  // safety close of SQL cursor incase of abnormal end
               EXEC SQL close MSGW;
            on-error; // ignore it
            endmon;

            clear buffer;
      end-proc;

         ///////////////////////////////////////////////////////////////
         // Start the HTML page
         // This subprocedure generates the relativelys static
         // start of the HTML page. The only dynamic variable
         // is the time, which is extracted from the %TIME() built-in
         ///////////////////////////////////////////////////////////////

   dcl-proc htmlPage_Start;
      dcl-s postedTime varchar(60);

      buffer = '<!DOCTYPE html> <html lang="en">\n';  // Start. So assign/clear buffer
      buffer += '<head> <title>Message Wait Log</title>\n';
      buffer += ' <meta http-equiv="refresh" content="180">\n';
      buffer += style;
      buffer += '</head>\n';
      buffer += '<body>\n';
      buffer += '<h2>Messages in MSGW and System Alerts on ' +
                  %trimR(psds.sysName) + '</h2>\n';

        EXEC SQL  VALUES
                  VARCHAR_FORMAT(current_TimeStamp,
                  'Day, DD Mon YYYY HH:MI:SS AM')
                  INTO :PostedTime;

      buffer += '<h5>Scanned for issues: ' + %TRIMR(postedTime) + '</h5>\n';
      buffer += '<h2>Program Alert Detected.</h2> \n';
      buffer += '<h3>Possible Message Waiting for User Response.</h3>\n';

      buffer += '<p>A Message Wait (MSGW/*INQ) or Alert message has +
                   been detected in QSYSOPR on the <b>' +
                   %trimR(psds.sysName) + '</b> Server. +
                   Please review the Attached HTML file to +
                   review those messages.</p> +
                   <p>To view and reply to messages as needed, +
                   use this CL command:</p> +
                   <pre>DSPMSG MSGQ(QSYSOPR) MSGTYPE(*INQ)</pre> +
                   <p>For Alert and <i>Problem-Detected</i> messages, +
                   notify management.</p>';

         // I allow the c-style line feed symbol ('\n') to be included
         // in the HTML. So this %SCANRPL function converts those
         // symbolic values to the actual linefeed character.
         // this helps to tremendously reduce the number concat operations.

         // Convert \n to linefeed characters for the write to the HTML file
            buffer = %scanRpl('\n' : X'25' : buffer);

            // Normally I would use my own SQL Tools IFS_WRITE stored procedures,
            // But since this is a V7R4-base customer, I can safely choose
            // to use the IBM-supplied IFS_WRITE_UTF8 procedure to write
            // to the HTML file on the IFS.
               exec SQL call qsys2.IFS_WRITE_UTF8(:IFSFILE,
                                    :buffer, 1208, 'REPLACE', 'NONE');
      clear buffer;
      return;
   end-proc;

         ///////////////////////////////////////////////////////////////
         // Build and Send out EMAIL using the email CL command.
         // This subprocedure reads the IFS file containing the HTML
         // that identifies all the Alert/MSGW messages and encodeds
         // it for apostrophies (that is it convert ' to &#39;)
         // and sends the email with the message set to that HTML
         // and also adds the HTML file as an attachment in case the
         // end-user filters out HTML. Note that since use now
         // use SNDSMTPEMM we can do this. The old SNDDST was limited.
         ///////////////////////////////////////////////////////////////

         ///////////////////////////////////////////////////////
         // Send out the EMAIL with the messages
         ///////////////////////////////////////////////////////
   dcl-proc sendEMail;
     dcl-pi sendEMail;
       ifsFile varchar(4096) const OPTIONS(*VARSIZE);
       toEmail varchar(128) CONST;
     end-pi;

      dcl-s sndmail varchar(5000);
      dcl-s msg     varchar(32000);
      dcl-c LARGEMSG 'Message ALERT list is too large +
                     for the email command''s message body. +
                     See attached HTML page to view the alerts.';
      snd-msg 'Staring SEND-EMAIL routine.';
      EXEC SQL SELECT cast(LINE as varchar(32000))
                  INTO :msg
               FROM Table(QSYS2.IFS_READ(:IFSFILE,
                           MAXIMUM_LINE_LENGTH=>4096,
                           END_OF_LINE=>'NONE',
                           IGNORE_ERRORS=>'YES')) IFS
            LIMIT 1;
       if (sqlstate >= '02000');
         snd-msg 'SQLSTATE ' + SQLSTATE;
       endif;

       sndmail = 'SNDSMTPEMM RCP(';
       if (psds.curUsrprf <> 'BCOZZI');
         sndMail += '(''' + %trimR(toEmail) + ''') ';
       endif;
       sndMail += '(''cozzi@rpgiv.com'') ';
       sndMail += ') ';
         // SNDSMTPEMM limits the NOTE parmaeter to 5000 bytes
       if (%LEN(%TRIMR(msg)) < 5000);
         sndmail += ' NOTE(''' + %TRIMR(MSG) + ''') ';
       else;
         sndmail += ' NOTE(''' + LARGEMSG + ''') ';
       endif;
       sndMail += ' ATTACH((''' + IFSFile + ''' *HTML *TXT)) ';
       sndMail += ' CONTENT(*HTML) ';

      sndmail += 'Subject(''QSYSOPR Message Waiting or Alert'') ';
      snd-msg 'Sending email to ' + toEmail;
      system( sndmail );
   end-proc;


      ///////////////////////////////////////////////////////
      // Build the list of omitted msgids (filtered messages)
      ///////////////////////////////////////////////////////
   dcl-proc getOmitList;
      dcl-s msgid varchar(7);

      clear omitList;

      EXEC SQL SELECT DATA_AREA_VALUE
                 INTO :OMITLIST
                 FROM Table(QSYS2.DATA_AREA_INFO(
                           DATA_AREA_NAME=>    :OMIT_MSGID,
                           DATA_AREA_LIBRARY=> :OMIT_MSGIDLIB))
               LIMIT 1;
      if (SQLSTATE >= '02000');
         return;
      endif;

      if (bFirstTime);
         if (OMITLIST = '');
            SND-MSG 'MONMSGW OMIT LIST Empty. To add messages, use: ' +
                     'CHGDTAARA ' + OMIT_MSGIDLIB + '/' + OMIT_MSGID +
                     ' VALUE(''CPA403D CPA3394 CPAnnnn'')';
         endif;
      endif;

      // Avoid clearing and re-adding the same messages over and over
      if (OMITLIST = LAST_OMITLIST);
         return;
      endif;
      LAST_OMITLIST = OMITLIST;

      EXEC SQL TRUNCATE SESSION.OMIT_MSGID_LIST IMMEDIATE;

      FOR-EACH msgid in %SPLIT(omitList : ' ,:;');
         EXEC SQL INSERT INTO SESSION.OMIT_MSGID_LIST
            values(:MSGID);
      endfor;
   end-proc;

      ///////////////////////////////////////////////////////
      // Build a temp file to hold a list of already
      // processed Message ID's MSGKEYs
      ///////////////////////////////////////////////////////
   dcl-proc createTempFiles;

      // Create the Message Key (MSGKEY) list file
      MONITOR;
         EXEC SQL DROP TABLE SESSION.MSGKEY_LIST;
      ON-ERROR;
      ENDMON;

      EXEC SQL DECLARE GLOBAL TEMPORARY TABLE MSGKEY_LIST
      (
         MSGKEY char(4) CCSID 65535 NOT NULL DEFAULT ''
      );

         // Create the MSGID Filter file
      MONITOR;
         EXEC SQL DROP TABLE SESSION.OMIT_MSGID_LIST;
      ON-ERROR;
      ENDMON;

      EXEC SQL DECLARE GLOBAL TEMPORARY TABLE OMIT_MSGID_LIST
      (
         MSGID varchar(7) not null default ''
      );

   end-proc;
