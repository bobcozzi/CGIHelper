**FREE
        /IF NOT DEFINED(CGI_HELPER)
        /DEFINE CGI_HELPER

                /include cgihelper/QCPYSRC,QUSEC
                /include cgihelper/QCPYSRC,IFSAPI
                /include cgihelper/QCPYSRC,QCMDAPI
                /include cgihelper/QCPYSRC,QSYSAPI
                /include cgihelper/QCPYsrc,QTMHAPI

                /include cgihelper/QCPYSRC,cgiLIB
                /include cgihelper/QCPYSRC,htmlLIB
                /include cgihelper/QCPYSRC,rpgLIB

        /ENDIF

