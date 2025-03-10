**Free
       /IF DEFINED(*CRTBNDRPG)
         ctl-opt DFTACTGRP(*NO);
      /ENDIF
        CTL-OPT
        BNDDIR('CGIHELPER/CGIHELPER')
        OPTION(*NODEBUGIO:*SRCSTMT)
        ALWNULL(*USRCTL)
        MAIN(MAIN);

      /include cgihelper/qcpysrc,cgiHelper

         // Change these two variables to
         // match what you use in your Company.
      DCL-S COMP_LOGO VARCHAR(50) INZ('logo.jpg');
      DCL-S COMP_TITLE VARCHAR(50) INZ('Company logo normally appears here.');

   dcl-s jobID    varchar(28);
   dcl-s LineNbr  int(10);
   dcl-s PageNbr  int(10);
   dcl-s SPLFDATA varchar(2048);
   dcl-s SPLNBR   varchar(10);
   dcl-s SPLFNAME varchar(10);
   dcl-s counter  int(10);

   dcl-s startRow  int(10);
   dcl-s rows      int(10);

   dcl-s startPage varchar(10) INZ('1');
   dcl-s startLine varchar(10) INZ('1');
   dcl-s A_StartRow varchar(10);
   dcl-s A_Rows     varchar(10);


   dcl-s BUFFER      varchar(4096);
   dcl-ds nullInd Qualified INZ;
       job       int(5);
       PAGENBR   int(5);
       LINENBR   int(5);
       SPLFDATA  int(5);
       SPLNBR    int(5);
       SPLFNAME  int(5);
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
         html, body {\n +
            height: 100%;\n +
            margin: 0;\n +
            overflow: hidden;\n +
         }\n +
         body {\n +
            margin-left: 10px;   /* Add 10px space to the left */\n +
            margin-right: 10px;  /* Add 10px space to the right */\n +
         }\n +
         .container {\n +
            height: 80vh;\n +
            overflow-y: auto;\n +
            scroll-padding-bottom: 12px;\n +
            border: 1px solid #ccc;\n +
         }\n +
         table {\n +
            border-collapse: collapse; \n +
            width: 100%; \n +
         }\n +
         thead {\n +
            position: sticky;\n +
            top: 0;\n +
            background: white;\n +
            z-index: 2;\n +
         }\n+
         th {\n +
            border: 1px solid black; \n +
            padding: 8px; \n +
            text-align: left; \n +
            background-color: #ddd;\n +
         }\n +
         td {\n +
            border: 1px solid black; \n +
            padding: 3px; \n +
            text-align: left; \n +
         }\n +
         td.text {\n +
            border: 0px; \n +
            padding: 0 0 0 12px;\n +
            text-align: left; \n +
            line-height: 1;\n +
            margin: 0;\n +
            white-space: pre;\n +
            font-family: "Courier New", Courier, monospace;\n +
            font-weight: bold;\n +
            font-size: 16px;\n +
         }\n +
         tr:nth-child(6n+1),\n +
         tr:nth-child(6n+2),\n +
         tr:nth-child(6n+3) {\n +
            background-color: darkseagreen; /* greenbar "green" */\n +
         }\n +
         tr:nth-child(6n+4),\n +
         tr:nth-child(6n+5),\n +
         tr:nth-child(6n+6) {\n +
            background-color: white;\n +
         }\n +
         .nowrap {\n +
            white-space: nowwrap;\n +
         }\n +
         .numData {\n+
            text-align: right; +
            font-family: "Courier New", Courier, monospace; +
         } +
         .micetype {\n +
            font-size: 16px;\n +
         }\n +
         .clear {\n +
            font-size: 12px;\n +
            font-family: Helvetica, Arial, sans-serif;\n+
         }\n +
         </style>\n';
      dcl-c tableTop '<div class="container">\n+
                     <table>\n<thead>\n<tr>+
                     <th>Page</th>\n+
                     <th>Line</th>\n+
                     <th>SPOOLED File Data</th>\n+
                     </tr>\n</thead>\n<tbody>\n';
      dcl-c tableBottom '</tbody>\n</table>\n</div>\n';


   dcl-proc main;

    EXEC SQL SET OPTION  COMMIT=*NONE, NAMING=*SYS;

    counter = 0;

    jobID = cgi_getVar('JOB');
    SPLNBR= cgi_getVar('SPLNBR');
    SPLFNAME= cgi_getVar('SPLFNAME');

      // If using COZZI's SQL Tools READSPLF,
      // you can pass in the starting PAGE and Line
      // on that page. Currently this program
      // Supprts the STARTPAGE (Staring page)
      // number parameter and is availble to jump
      // to a specific page at line 1 of that page.
      // The STARTLINE option is currently ignored.
      // Also note that STARTPAGE can be *LAST or *END
      // It indicate that the SPOOLED file data should
      // start returning with the last page of the SPOOLED File.
    monitor;
      STARTPAGE = cgi_getVar('STARTPAGE');
    on-error;
      STARTPAGE = '1';
    endmon;
    monitor;
      STARTLINE = cgi_getVar('STARTLINE');
    on-error;
      STARTLINE = '1';
    endmon;


    monitor;
      A_startRow = cgi_getVar('STARTROW');
      if (a_startRow <> '');
         STARTROW = %int(a_StartRow);
      endif;
    on-error;
      STARTROW = 1;
    endmon;

    monitor;
      A_Rows = cgi_getVar('ROWS');
      if (A_Rows <> '');
         ROWS = %int(A_Rows);
      endif;
    on-error;
      ROWS = 0;  // <= 0 means don't limit the fetch
    endmon;

    htmlPage_Start();  // write out the page's starting HTML
    if (jobID = '');
      cgi_stdOut('<h1>SPLFNAME, SPLNBR and JOB parameters are required.</h1>');
      return;
    endif;

      // Write the DSPSPLF CL command to view this
      // SPOOLED file so User can copy/paste it if needed.
      // (serves no other purpose)
     cgi_stdOut('<h2>Display SPOOLED File</h2>\n' +
            '<pre>DSPSPLF ' +
            'FILE(' + %trimR(SPLFNAME) +') ' +
            'SPLNBR(' +  %TrimR(SPLNBR) + ') ' +
            'JOB(' + %trimR(JOBID) + ') </pre>\n');

         // This is a "COZZI" SQL Tools Table Function
         // It performs faster and has fewer limits
         // than the SYSTOOLS version named SPOOLED_FILE_DATA.
         // However, the IBM SYSTOOLS' SPOOLED_FILE_DATA
         // may be used instead, however the following
         // limitations apply to IBM's SPOOLED_FILE_DATA:
         // - The SPOOLED_DATA column is VARCHAR(200)
         // - Page and Line Number columns are not returned
         // - The SPLFNAME parameter is SPOOLED_FILE_NAME
         // - The SPLNBR parameter is SPOOLED_FILE_NUMBER
         // - All parameters are case-sensitive
         // - SPOOLED_FILE_DATA uses DSPSPLF OUTFILE support

      EXEC SQL DECLARE SPLF CURSOR FOR
                  select PAGENBR, LINENBR, SPOOLED_DATA
                           from table(sqlTools.READSPLF(
                                 SPLFNAME=> :SPLFNAME,
                                 SPLNBR=>   :SPLNBR,
                                 JOB_NAME=> :JOBID)) SPLFILE;

      EXEC SQL  OPEN  SPLF;
      EXEC SQL  FETCH SPLF INTO
                     :PAGENBR    : nullInd.PAGENBR,
                     :LINENBR    : nullInd.LINENBR,
                     :SPLFDATA  : nullInd.SPLFDATA;

               if (sqlState >= '02000');
                 buffer = '<h2>SPOOLED File could not be found.</h2>';
                 cgi_stdOut(buffer);
               else;

                dow (sqlState < '02000');
                  // Write out each row as a table entry
                  if (counter = 0);
                     cgi_stdOut(tableTop);
                  endif;
                  counter += 1;
                  cgi_stdOut('<tr>' +
                     '<td class="numData">' + %char(PAGENBR) + '</td>' +
                     '<td class="numData">' + %char(LINENBR) + '</td>' +
                     '<td class="text">' + %TRIMR(SPLFDATA) + '</td>' +
                     '</tr>\n');

                  EXEC SQL  FETCH SPLF INTO
                           :PAGENBR  : nullInd.PAGENBR,
                           :LINENBR  : nullInd.LINENBR,
                           :SPLFDATA : nullInd.SPLFDATA;
                enddo;
               endif;
               return;  // Return to caller

         on-exit;
            EXEC SQL close SPLF;
            if (counter > 0);
               cgi_stdOut(tableBottom);
            endif;
            htmlPage_End();  // Close out the page no matter what happens
      end-proc;

   dcl-proc htmlPage_Start;
      cgi_stdOut('Content-type: text/html\n\n');  // NOTE: 2 LF's (required!)
      cgi_stdOut('<!DOCTYPE html>\n<html lang="en">\n');
      cgi_stdOut('<head>\n<title>Job Log Viewer</title>\n');
      // cgi_stdOut(' <meta http-equiv="refresh" content="300">\n');
      cgi_stdOut(style);
      cgi_stdOut('</head>\n');
      cgi_stdOut('<body>\n');
      cgi_stdOut('<a href="javascript:history.back();" +
                 title="&nbsp;&nbsp;&nbsp;Return to prior page"> +
               <img src="/img/' +
               COMP_LOGO + '" alt="' +
               COMP_TITLE + '"/></a>');
      return;
   end-proc;
   dcl-proc htmlPage_End;
      cgi_stdOut('</body>\n</html>\n');
   end-proc;



