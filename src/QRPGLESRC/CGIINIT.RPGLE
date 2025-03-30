     **Free
           ctl-opt  NOMAIN
                    ALWNULL(*USRCTL) OPTION(*NODEBUGIO:*SRCSTMT) ;

           /include cgiHelper/qcpysrc,cgiGLOBAL
           /include cgiHelper/qcpysrc,cgilib

         dcl-proc cgi_Init EXPORT;
            clear global;
            global.init = *ON;

            global.PC_CCSID = cgi_getCCSID();
            global.cgi_mode = cgi_getMODE();
               // original request_method (before converting POST to GET)
            global.method = cgi_getRequestMethod();
            global.CONTENT_LENGTH = cgi_getContentLength();
            cgi_getQueryString(global.queryString: %size(global.queryString));
         end-proc;


         dcl-proc cgi_Clear EXPORT;
            clear global;
            global.init = *OFF;
         end-proc;
