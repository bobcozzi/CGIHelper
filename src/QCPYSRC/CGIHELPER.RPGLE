**FREE
        /IF NOT DEFINED(CGI_HELPER)
        /DEFINE CGI_HELPER

                /include cgihelper/QCPYsrc,QUSEC
                /include cgihelper/QCPYsrc,IFSAPI
                /include cgihelper/QCPYsrc,QCMDAPI
                /include cgihelper/QCPYsrc,QSYSAPI
                /include cgihelper/QCPYsrc,QTMHAPI

                /include cgihelper/QCPYsrc,cgiLIB
                /include cgihelper/QCPYsrc,htmlLIB
                /include cgihelper/QCPYsrc,rpgLIB

        /ENDIF

