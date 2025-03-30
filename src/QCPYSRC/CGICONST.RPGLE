**FREE
          /if NOT DEFINED(CGI_CONST)
          /DEFINE CGI_CONST
             dcl-C CGI_MAXBUFFER  CONST(65530);
             dcl-C CGI_MAXVARNAME CONST(255);
             dcl-C CGI_HTTPHEADER CONST('Content-Type: text/html');
             dcl-C CGI_CONTENTTYPE CONST('Content-Type: text/html');
             dcl-C CGI_DOCTYPE    CONST('<!DOCTYPE html>');
             dcl-C CGI_LF CONST(X'25');
             dcl-C CGI_SYMBOLIC_LF CONST('\n');
          /endif
