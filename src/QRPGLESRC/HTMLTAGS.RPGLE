
           // --------------------------------------------------
           // A simple wrapper (subproc) to "Build HTML Tags"
           // It can be called like this:
           //  html_<tag>('data');  // Create an HTML tag
           // e.g.,
           //  html_H1('Hello World');  // Returns <h1>Hello World</h1>
           //  html_H2('Starsky & Hutch');  // Returns <h2>Starsky &amp; Hutch</h2>
           // --------------------------------------------------

        ctl-opt  NOMAIN
                 ALWNULL(*USRCTL) OPTION(*NODEBUGIO:*SRCSTMT) ;

      /include cgiHelper/qcpysrc,cgiCONST
      /include cgiHelper/qcpysrc,cgiENCODE
      /include cgiHelper/qcpysrc,cgiGlobal

      /include cgiHelper/qcpysrc,htmlLIB

      /include cgiHelper/qcpysrc,qusec
      /include cgiHelper/qcpysrc,QtmhAPI
      /include cgiHelper/qcpysrc,QsysAPI

           dcl-proc html_cmt export;
             dcl-pi html_cmt varchar(cgi_MAXBUFFER) rtnparm; // EXTPROC('html_cmt');
                comments varchar(cgi_MAXBUFFER) CONST OPTIONS(*VARSIZE);
                lineFeeds int(10) Const OPTIONS(*NOPASS);
              end-pi;


            dcl-ds tag Qualified;
              start varchar(10) inz('<!-- ');
              end   varchar(10) inz(' -->');
            end-ds;
            dcl-ds tail Qualified;
              before varchar(10) inz('');
              after  varchar(10) inz(cgi_LF);
            end-ds;
            if (%Parms() >= %ParmNum(LINEFEEDS));
               // 0 = No LF
               // 1 = LF Before Only
               // 2 = LF After Only  (default)
               // anything else LF Before and After
                select ;
                  when LINEFEEDS = 0;
                    tail.before = '';
                    tail.after  = '';
                  when LINEFEEDS = 1;
                    tail.before = cgi_LF;
                    tail.after  = '';
                  when LINEFEEDS = 2;
                    tail.before = '';
                    tail.after  = cgi_LF;
                  other;
                    tail.before = cgi_LF;
                    tail.after  = cgi_LF;
                  endsl;
            else;
              tail.before = cgi_LF;
            endif;

            return tail.before + tag.start +
                   %trimR( comments ) +
                   tag.end + tail.after;
           end-proc;


               // Usage:
               //    dcl-s cgiBuffer varchar(8000);
               //   cgiBuffer = html_tag('span': 'Hello world' : 'background-color: yellow;');
               //     returns: <span style="background-color: yellow;">Hello world</span>
               //  or
               //   cgiBuffer = html_tag('td': 'Hello world' : 'noWrap boldText');
               //     returns: <td class="noWrap boldText">Hello world</td>

           dcl-proc html_tag export;
             dcl-pi html_tag varchar(cgi_MAXBUFFER) rtnparm; // EXTPROC('html_tag');
                tagName varchar(32)  CONST OPTIONS(*VARSIZE);
                tagData varchar(cgi_MAXBUFFER) CONST OPTIONS(*VARSIZE);
                class_Style varchar(1024) CONST OPTIONS(*VARSIZE:*OMIT:*NOPASS);
                escape  int(10) CONST OPTIONS(*NOPASS);  // DEFAULT(1)
              end-pi;

            dcl-ds tag Qualified;
              start varchar(32) inz('<span');
              end   varchar(32) inz('</span>');
            end-ds;

            dcl-ds ec likeDS(QUSEC_T) inz(*LIKEDS);
            dcl-s  encode ind INZ(*ON);
            dcl-s  classStyle varchar(1024);

            if (%Parms() >= %ParmNum(ESCAPE));
               encode = (ESCAPE <> 0);
            endif;
                  // Change <H1> to <h1
            tag.start =  %trim(%lower(tagName) : '<> ');

                  // Make </h1> from <h1
            if (tag.start = '<!--' OR
                tag.start = '//' OR
                tag.start = 'comment' OR
                tag.start = '/*' OR
                tag.start = '*');

                  tag.start = '<!-- ';  // sneak in a blank
                  tag.end   = ' -->';
            else;
               tag.end = '</' + %trim(tag.start : '</ ') + '>';
            endif;

            if (%Parms() >= %ParmNum(class_Style) and
                %ADDR(class_Style) <> *NULL and
                class_Style <> '');
              classStyle = %lower( %trimR(class_Style) );
              if (%SCAN(':' : classStyle) > 0); // Is style?
                classStyle = ' style="' + %trim(classStyle) + '"';
              else;
                classStyle = ' class="' + %trim(classStyle) + '"';
              endif;
            endif;
            tag.start = '<' + tag.start;
            if (ENCODE);
              return tag.start + classStyle + '>' +
                     %trimR(cgi_encodeURI( tagData ) ) + tag.end;
            endif;
            // Else if NO ENCODING...
              return tag.start + classStyle + '>' +
                     %trimR( tagData ) + tag.end;
           end-proc;

