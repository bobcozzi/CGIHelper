 BLDCGIHELP: CMD        PROMPT('Create CGIHELPER *SRVPGM')

 /*  CRTCMD CMD(BLDCGIHELP) PGM(CGIHELPER/BLDCGIHELP)   */
 /*          SRCFILE(CGIHELPER/QCMDSRC)  */

             PARM       KWD(OBJLIB) TYPE(*NAME) LEN(10) +
                          DFT(CGIHELPER) EXPR(*YES) PROMPT('Target +
                          object library')
             PARM       KWD(SRCLIB) TYPE(*NAME) LEN(10) +
                          DFT(CGIHELPER) EXPR(*YES) PROMPT('Source +
                          library')
             PARM       KWD(TGTRLS) TYPE(*CHAR) LEN(8) DFT(*CURRENT) +
                          SPCVAL((*PRV) (*CURRENT) (V7R2M0) +
                          (V7R3M0) (V7R4M0) (V7R5M0)) EXPR(*YES) +
                          PROMPT('Target release')
             PARM       KWD(DBGVIEW) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*SOURCE) SPCVAL((*SOURCE) (*LIST) +
                          (*COPY) (*DEBUG *SOURCE) (*YES *SOURCE) +
                          (*ALL) (*NONE) (*NO *NONE)) EXPR(*YES) +
                          PROMPT('Debug view option')
             PARM       KWD(CRTLIB) TYPE(*LGL) RSTD(*YES) DFT(*NO) +
                          SPCVAL((*YES '1') (*NO '0')) EXPR(*YES) +
                          PROMPT('Create Object Library (OBJLIB)')
