**Free
       /IF DEFINED(*CRTBNDRPG)
         ctl-opt DFTACTGRP(*NO);
      /ENDIF
        CTL-OPT
        BNDDIR('CGIHELPER/CGIHELPER') ALWNULL(*USRCTL)
        OPTION(*NODEBUGIO:*SRCSTMT)
        MAIN(MAIN);

      /include cgihelper/cgihelper,cgihelper

   dcl-s MSGID       varchar(7);
   dcl-s MSGSEV      uns(3);
   dcl-s MSGTYPE     varchar(16);
   dcl-s POSTED      varchar(28);
   dcl-s FROM_PGM    varchar(36);
   dcl-s MSGTEXT     varchar(512);
   dcl-s MSGSECLVL   varchar(512);
   dcl-s jobID       varchar(28);
   dcl-s BUFFER      varchar(4096);
   dcl-ds nullInd Qualified INZ;
       job       int(5);
       FROM_PGM  int(5);
       MSGID     int(5);
       MSGSEV    int(5);
       MSGTYPE   int(5);
       MSGTEXT   int(5);
       MSGSECLVL int(5);
       POSTED    int(5);
   end-ds;


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
         </style>\n';

      dcl-c tableTop '<table><tr>+
                     <th>JOB</th>\n+
                     <th>MSGID</th>\n+
                     <th>SEV</th>\n+
                     <th>Message Type</th>\n+
                     <th>POSTED</th>\n+
                     <th>From Program</th>\n+
                     <th>Message Text</th>\n+
                     <th>2nd Level Message Text</th>\n+
                     </tr>\n';


   dcl-proc main;

    EXEC SQL SET OPTION  COMMIT=*NONE, NAMING=*SYS;

    cgi_init();

    jobID = cgi_getVar('JOB');
    htmlPage_Start();  // write out the page's starting HTML
    if (jobID = '');
      cgi_stdOut('<h1>JOB Name parameter nnnn/uuuu/jjjj required.</h1>');
      return;
    endif;
    cgi_stdOut('<h2>Display Job Log - ' + JOBID +
            ' <span class="micetype">(descending order)</span></h2>\n');


    EXEC SQL DECLARE JOBLOG CURSOR FOR
        select MESSAGE_ID as MSGID,
            MESSAGE_TYPE as MSGTYPE,
            SEVERITY,
            CAST(varchar_Format(message_timestamp,
                  'YYYY-MM-DD HH12:MI AM') as varchar(32)) POSTED,
            CAST( coalesce(FROM_LIBRARY concat '/','') concat
                  coalesce(FROM_PROGRAM,'') concat
                  coalesce('(' concat FROM_MODULE concat ')','')
               as varchar(33)) as FROM_PGM,
            message_text as MSGTEXT,
            message_second_level_text as SECLVL,
            Qualified_JOB_NAME
      from table(joblog_info(:JOBID))
         ORDER BY ORDINAL_POSITION DESC;

      EXEC SQL  OPEN JOBLOG;
      EXEC SQL  FETCH JOBLOG INTO
                       :MSGID    : nullInd.MSGID,
                       :MSGTYPE  : nullInd.MSGTYPE,
                       :MSGSEV   : nullInd.MSGSEV,
                       :POSTED   : nullInd.POSTED,
                       :FROM_PGM : nullind.FROM_PGM,
                       :MSGTEXT  : nullInd.MSGTEXT,
                       :MSGSECLVL: nullInd.MSGSECLVL,
                       :JOBID    : nullInd.JOB;

               if (sqlState >= '02000');
                  buffer = '<h2>Job is not active.</h2>';
                  buffer += '<p><a href="'+
                           'javascript:window.location.replace(''' +
                           '/cgi2/dspsplf.pgm?'+
                           'SPLFNAME=QPJOBLOG&SPLNBR=*LAST'+
                           '&JOB=' + jobID + ''');">';
                  buffer += 'Click here to attempt to view this Job''s ' +
                            'QPJOBLOG Spooled file</a> ' +
                            'if it exists.</p>';
                 cgi_stdOut(buffer);
               else;
                snd-msg 'Writing out table Top HTML';
                cgi_stdOut(tableTop);
                dow (sqlState < '02000');
                  // Write out each row as a table entry
                  cgi_stdOut('<tr>' +
                     '<td class="micetype nowrap">' + jobid + '</td>' +
                     '<td>' + MSGID + '</td>' +
                     '<td>' + %char(msgsev) + '</td>' +
                     '<td class="micetype">' + MSGTYPE + '</td>' +
                     '<td>' + %trimR(POSTED) + '</td>' +
                     '<td class="micetype nowrap">' + FROM_PGM + '</td>' +
                     '<td class="micetype">' +
                           cgi_encodeURI(MSGTEXT) + '</td>' +
                     '<td class="micetype">' + msgseclvl + '</td>' +
                     '</tr>\n');

                   EXEC SQL  FETCH JOBLOG INTO
                       :MSGID    : nullInd.MSGID,
                       :MSGTYPE  : nullInd.MSGTYPE,
                       :MSGSEV   : nullInd.MSGSEV,
                       :POSTED   : nullInd.POSTED,
                       :FROM_PGM : nullind.FROM_PGM,
                       :MSGTEXT  : nullInd.MSGTEXT,
                       :MSGSECLVL: nullInd.MSGSECLVL,
                       :JOBID    : nullInd.JOB;
                  enddo;
               endif;
               return;  // Return to caller

         on-exit;
            EXEC SQL close JOBLOG;
            htmlPage_End();  // Close out the page no matter what happens
      end-proc;

   dcl-proc htmlPage_Start;
      cgi_stdOut('Content-type: text/html\n\n');  // NOTE: 2 LF's (required!)
      cgi_stdOut('<!DOCTYPE html>\n<html lang="en">\n');
      cgi_stdOut('<head>\n<title>Job Log Viewer</title>\n');
      cgi_stdOut(' <meta http-equiv="refresh" content="300">\n');
      cgi_stdOut(style);
      cgi_stdOut('</head>\n');
      cgi_stdOut('<body>\n');

      cgi_stdOut('<p style="font-size:small;">' +
                  'Autorefreshes every 5 minutes</p>\n');
      return;
   end-proc;
   dcl-proc htmlPage_End;
      cgi_stdOut('</body>\n</html>\n');
   end-proc;


