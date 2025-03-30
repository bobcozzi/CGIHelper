      /IF NOT DEFINED(rpg_IFSAPI)
      /DEFINE rpg_IFSAPI

        /IF NOT DEFINED(IFS_PROTOS)
        /DEFINE IFS_PROTOS

          //  Native IFS file I/O API Prototypes

         DCL-S S_IXOTH   INT(10) INZ(1);
         DCL-S S_IWOTH   INT(10) INZ(2);
         DCL-S S_IROTH   INT(10) INZ(4);
         DCL-S S_IRWXO   INT(10) INZ(7);

         DCL-S S_IXGRP   INT(10) INZ(8);
         DCL-S S_IWGRP   INT(10) INZ(16);
         DCL-S S_IRGRP   INT(10) INZ(32);
         DCL-S S_IRWXG   INT(10) INZ(56);

         DCL-S S_IXUSR   INT(10) INZ(64);
         DCL-S S_IWUSR   INT(10) INZ(128);
         DCL-S S_IRUSR   INT(10) INZ(256);
         DCL-S S_IRWXU   INT(10) INZ(448);

         DCL-S S_ISVTX   INT(10) INZ(512);
         DCL-S S_ISGID   INT(10) INZ(1024);
         DCL-S S_ISUID   INT(10) INZ(2048);

       /IF NOT DEFINED(QIBM_UNISTD_INCLUDED)
       /IF NOT DEFINED(MKDIR)
       /DEFINE MKDIR
          dcl-pr md INT(10) extProc(*CWIDEN :'mkdir');
              path_name pointer value OPTIONS(*STRING:*TRIM);
              mode_authority UNS(10) VALUE;
          end-pr;
       /endif

       /IF NOT DEFINED(CHDIR)
       /DEFINE CHDIR
          dcl-pr cd INT(10) extProc(*CWIDEN :'chdir');
              path_name pointer value OPTIONS(*STRING:*TRIM);
          end-pr;
       /endif

       /IF NOT DEFINED(CHMOD)
       /DEFINE CHMOD
          dcl-pr chmod INT(10) extProc(*CWIDEN :'chmod');
             path_name pointer value OPTIONS(*STRING:*TRIM);
             mode_authority UNS(10) VALUE;
          end-pr;
       /endif
       /endif

       /endif
       /endif
