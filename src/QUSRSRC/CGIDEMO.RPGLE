**Free
          ctl-opt  MAIN(MAIN) OPTION(*SRCSTMT : *NODEBUGIO)
                   BNDDIR('CGIHELPER/CGIHELPER');
        /if DEFINED(*CRTBNDRPG)
            ctl-opt  DFTACTGRP(*NO) ACTGRP(*NEW);
        /endif

         /include cgiHelper/cgiHelper,cgiHelper

         dcl-s myMSG varchar(64);
         dcl-s MSGTEXT varchar(32) INZ('Hello World');

         dcl-proc main;

              cgi_init();

              myMSG = cgi_getVar('MSG');
              cgi_stdOut( html_getStart() );
              cgi_stdOut( html_tag('h1' : 'CGI Helper Demo Page') );
              cgi_stdOut('<p>' + msgText + '</p>\n');
              if (myMsg <> '');
                cgi_stdout('<p style="font-weight: bold;">' + myMsg + '</p>\n');
              endif;
              cgi_stdOut( html_getEnd() );
              return;
        end-proc;

