**FREE

         ctl-opt  NOMAIN
                 ALWNULL(*USRCTL) OPTION(*NODEBUGIO:*SRCSTMT) ;


            /include cgiHelper/qcpysrc,rpgLib
            /include cgiHelper/qcpysrc,cgiCONST
            /include cgiHelper/qcpysrc,htmlLIB
            /include cgiHelper/qcpysrc,QtmhAPI
            /include cgiHelper/qcpysrc,QsysAPI

        dcl-proc html_getStyleLink EXPORT;
        dcl-pi html_getStyleLink varchar(720) rtnparm;
            cssFile varchar(640) const options(*VARSIZE);
            ver   varchar(10)  const options(*NOPASS:*OMIT);
        end-pi;

        dcl-s version varchar(10);
        if (%Parms() >= %ParmNum(VER) and %addr(VER) <> *NULL and VER <> '');
            version = '?v=' + %trim(ver);
        else;
            clear version;
        endif;
        return '<link rel="stylesheet" href="' +
                %trim(cssFile) + version+ '">';
        end-proc;


        dcl-proc html_getStart EXPORT;
            dcl-pi html_getStart varchar(4096) rtnparm;
                title varchar(256)  const options(*VARSIZE: *NOPASS: *OMIT);
                body  varchar(1024) const options(*VARSIZE: *NOPASS: *OMIT);
                jsFile varchar(640) const options(*VARSIZE: *NOPASS: *OMIT);
                jsVer   varchar(10)  const options(*NOPASS : *OMIT);
                cssFile varchar(640) const options(*VARSIZE: *NOPASS :*OMIT);
                cssVer   varchar(10)  const options(*NOPASS: *OMIT);
            end-pi;

            dcl-s cssV varchar(10);
            dcl-s jsV  varchar(10);
            dcl-s htmlStart varchar(4096);
            if (%Parms() >= %ParmNum(cssVer) and %ADDR(cssVer) <> *NULL);
                cssV = '?v=' + %trim(cssVer);
            else;
                clear cssV;
            endif;
            if (%Parms() >= %ParmNum(jsVer) and %ADDR(jsVer) <> *NULL);
                jsV = '?v=' + %trim(jsVer);
            else;
                clear jsV;
            endif;
            htmlStart = cgi_HTTPHEADER + cgi_LF + cgi_LF;
            htmlStart += cgi_DOCTYPE + cgi_LF;
            htmlStart += '<html lang="en">' + cgi_LF;
            htmlStart += '<head>' + cgi_LF;
            htmlStart += '<meta charset="UTF-8">' + cgi_LF;
            htmlStart += '<meta name="viewport" +
                                content="width=device-width, +
                                initial-scale=1.0">' + cgi_LF;
            htmlStart += '<meta http-equiv="Content-Type;" +
                                content="text/html;">' + cgi_LF;

            if (%Parms() >= %parmNum(title) and
                    %ADDR(TITLE) <> *NULL and title <> ' ');
                htmlStart += '<title>' + %trim(TITLE) + '</title>' + cgi_LF;
            endif;
            if (%Parms() >= %ParmNum(cssFile) and
                    %Addr(cssFile) <> *NULL and cssFile <> '');
                htmlStart += html_getStyleLink(cssFile : cssVer) + cgi_LF;
            endif;
            if (%Parms() >= %ParmNum(jsFile) and
                        %Addr(JSFile) <> *NULL and jsFile <> '');
                htmlStart += '<script type="text/javascript" src="' +
                            %trim(jsFile) + jsV;
                htmlStart +='">';  // Close the <script tag
                htmlStart +='</script>' + cgi_LF;
            endif;
            htmlStart += '</head>' + cgi_LF;

            if (%Parms() >= %ParmNum(BODY) and
                        %Addr(BODY) <> *NULL);
                if (%upper(BODY) IN %LIST('*NONE':'NONE':
                                          '*OMIT':'OMIT':
                                          '*NOBODY':'NOBODY'));
                   htmlStart += '<body>' + cgi_LF;
                else;
                   htmlStart += '<body ' + %trimR(body) + '>' + cgi_LF;
                endif;
            else;
                htmlStart += '<body>' + cgi_LF;
            endif;
            return  htmlStart;
        end-proc;

        dcl-proc html_getEnd EXPORT;
          dcl-pi html_getEnd varchar(128) rtnparm end-pi;
          return '</body>' + cgi_LF + '</html>' + cgi_LF;
        end-proc;



