**Free
       /IF DEFINED(*CRTBNDRPG)
         ctl-opt DFTACTGRP(*NO);
      /ENDIF
        ctl-opt
            BNDDIR('RPGHELPER/RPGHELPER')
            ALWNULL(*USRCTL)
            OPTION(*NODEBUGIO:*SRCSTMT)
         MAIN(MAIN);

      /include rpghelper/qcpysrc,rpgHelper

         ///////////////////////////////////////////////////////////////
         // Start the QSYSOPR Monitor programs
         // Cancels any running MONMSGWAIT jobs and the
         // calls PD900P/MONMSGW to start the monitor "fresh"
         // This program is submitted daily via the Job Scheduler
         ///////////////////////////////////////////////////////////////
      dcl-ds psds qualified psds;
         program  *proc;                // This program's name.
         pgmName  char(10) pos(1);      // This program's name.
         pgmLIb   char(10) pos(81);     // This program's runtime library
         jobName  char(10) pos(244);    // Job Name
         jobUser  char(10) pos(254);    // Job's User Profile
         jobNbr   char(6)  pos(264);  // Job Number
         runtimeUser char(10) pos(358); // Runtime user profile
         sysName  char(8)  pos(396);    // System Name (V7R4 feature only)
      end-ds;

         dcl-s JOB           VARCHAR(28);
         dcl-s ENDMONITOR    VARCHAR(2000);

         dcl-ds monmsgW_ENDJOB Qualified inz;
           Name   char(10) INZ('MONMSGWEND');
           Lib    char(10) INZ('QGPL');
           start  int(5);
           length int(5);
           newData char(32);
         end-ds;
         dcl-ds monMSGID_Filter Qualified inz;
           Name   char(10) INZ('MONMSGWFLT');
           Lib    char(10) INZ('QGPL');
         end-ds;

         dcl-s monPGM char(21) INZ('*LIBL/MONMSGW');
         dcl-s freq int(10)  INZ(180);

         dcl-pr startMSGW_Monitor EXTPGM(MONPGM);
            frequency int(10) Const;
            monmsgw_END_DA char(20) Const;
            msgID_filter_DA char(20) Const;
         end-pr;

    EXEC SQL SET OPTION  COMMIT=*NONE, NAMING=*SYS;

   dcl-proc main;
      dcl-pi *n;
         delay int(10) Const;
         monPgmName char(20) Const;
         monmsgw_END_DA char(20) Const;
         monMSGID_FILTER_DA char(20) Const;
      end-pi;
      if (%SUBST(monPgmNAME : 1: 10) <> '*DFT' and
          %SUBST(monPgmNAME : 1: 1)  <> ' ');
         monPGM = %TRIMR(%SUBST(monPgmName : 11 : 10)) +
                     '/' +
                  %TRIM(%SUBST(monPgmName : 1 : 10));
      endif;
      if (%SUBST(monmsgw_END_DA : 1: 10) <> '*DFT' and
          %SUBST(monmsgw_END_DA : 1: 1) <> ' ');
          monmsgW_ENDJOB.name = %SUBST(monmsgw_END_DA : 1 : 10);
          monmsgW_ENDJOB.lib  = %SUBST(monmsgw_END_DA : 11 : 10);
      endif;
      if (%SUBST(monMSGID_FILTER_DA : 1: 10) <> '*DFT' and
          %SUBST(monMSGID_FILTER_DA : 1: 1) <> ' ');
          monMSGID_Filter.name = %SUBST(monMSGID_FILTER_DA : 1 : 10);
          monMSGID_Filter.lib  = %SUBST(monMSGID_FILTER_DA : 11 : 10);
      endif;

      freq = delay;
      createDataAreas();

       // Clear the external *DTAARA so that the
       // new Monitor job doesn't instantly self-terminate.
       EXEC SQL SELECT trim(DATA_AREA_VALUE)
                 INTO :ENDMONITOR
               FROM Table(QSYS2.DATA_AREA_INFO(
                            DATA_AREA_NAME=> :monmsgW_ENDJOB.Name,
                            DATA_AREA_LIBRARY=> :monmsgW_ENDJOB.Lib))
               LIMIT 1;
      if (SQLState < '02000');
         if (ENDMONITOR <> ''); // If not blank. then clear the Data area
           monmsgW_ENDJOB.start = 1;
           monmsgW_ENDJOB.length = %LEN(EndMonitor);
           clear monmsgW_ENDJOB.newData;
           rpg_CHGDTAARA(monmsgW_ENDJOB.Lib :
                         monmsgW_ENDJOB.Name :
                         monmsgW_ENDJOB.newData :
                         monmsgW_ENDJOB.start :
                         monmsgW_ENDJOB.length );
         endif;
      endif;

         EXEC SQL DECLARE CHKMSGW CURSOR FOR
          SELECT JOB_NAME
            FROM TABLE(qsys2.JOB_INFO(
                  JOB_STATUS_FILTER => '*ACTIVE',
                  JOB_TYPE_FILTER => '*BATCH',
                  JOB_USER_FILTER => '*ALL',
                  JOB_SUBSYSTEM_FILTER => 'QUSRWRK') ) MSGWJOBS
               WHERE JOB_NAME_SHORT LIKE 'MONMSGW%'
                     and JOB_NUMBER <> :psds.JobNbr;

         EXEC SQL  OPEN CHKMSGW;
         EXEC SQL  FETCH CHKMSGW INTO :JOB;
         dow (SQLState < '02000');
            // If an existing MONMSGW job exists, terminate it *IMMED
            system('ENDJOB ' + JOB + ' OPTION(*IMMED)');
            EXEC SQL  FETCH CHKMSGW INTO :JOB;
         enddo;

            // CLOSE "this" SQL CURSOR since we're finished using it
         EXEC SQL close CHKMSGW;



            // Start the monitor
         StartMSGW_Monitor(freq : monmsgW_ENDJOB : monMSGID_FILTER );

         return;
         on-exit;
            monitor;
                  // safety close of SQL cursor incase of abnormal end
               EXEC SQL close CHKMSGW;
            on-error; // ignore it
            endmon;
      end-proc;

      dcl-proc createDataAreas;
         // Check if either of the 2 data areas
         // used by the MONMSGW program exist.
         // If the do NOT, then create them automatically.
         // NOTE: if *LIBL is specified, we create
         // them in QGPL.
         EXEC SQL SELECT trim(DATA_AREA_VALUE)
               INTO :ENDMONITOR
               FROM Table(QSYS2.DATA_AREA_INFO(
                     DATA_AREA_NAME=> :monmsgW_ENDJOB.Name,
                     DATA_AREA_LIBRARY=> :monmsgW_ENDJOB.Lib))
               LIMIT 1;
      if (SQLState >= '02000');
         if (monmsgW_ENDJOB.LIB = '*LIBL');
            monmsgW_ENDJOB.LIB = 'QGPL';
         endif;
         system('CRTDTAARA DTAARA(' +
                     %TRIM(monmsgW_ENDJOB.LIB) + '/' +
                     %TRIM(monmsgW_ENDJOB.NAME) + ') ' +
                  ' TYPE(*CHAR) LEN(300)');
      endif;

      EXEC SQL SELECT trim(DATA_AREA_VALUE)
               INTO :ENDMONITOR
               FROM Table(QSYS2.DATA_AREA_INFO(
                     DATA_AREA_NAME=> :monMSGID_Filter.Name,
                     DATA_AREA_LIBRARY=> :monMSGID_Filter.Lib))
               LIMIT 1;
      if (SQLState >= '02000');
         if (monMSGID_Filter.LIB = '*LIBL');
             monMSGID_Filter.LIB = 'QGPL';
         endif;
          // Use the CL command to create the Data area   */
         system('CRTDTAARA DTAARA(' +
                     %TRIM(monMSGID_Filter.LIB) + '/' +
                     %TRIM(monMSGID_Filter.NAME) + ') ' +
                  ' TYPE(*CHAR) LEN(300)');
      endif;
      end-proc;
