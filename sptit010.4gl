#==================================================================================================#
#Programme     : sptit010.4gl                                                                      #                
#Objet         : PROJET : Extraction des données DELTA vers BFI VOLUME_OPERATIONS_FIXING           #
#==================================================================================================#  
#Périodité     : Quotidienne                                                                                                                     #    
#==================================================================================================#                 
#Editeur       : NOUR OUSSAMA                               ===  DATE     : 29/04/2011  ===        #                   
#==================================================================================================#
#==================================================================================================#    
SCHEMA bank
#==================================================================================================#
GLOBALS
DEFINE g_hndlog0        base.channel
DEFINE g_hndp2          base.channel
DEFINE g_hndlog         base.channel
#==================================================================================================#
# Variables utilisées dans la fonction gestion de trace                                            # 
#==================================================================================================#
DEFINE g_uti            LIKE evuti.cuti                    -- Utilisateur ayant lancer le programme
DEFINE g_msgbox         CHAR(70)                           -- Zone pour les messages 
DEFINE g_base           CHAR(50)                           -- Nom de la base de données 
DEFINE g_hhmmss         CHAR(10)                           -- Heure sous format HHMMSS 
DEFINE g_ddmmyy         DATE                               -- Date sous format DDMMYY   
DEFINE g_prgname        CHAR(24)                           -- Nom programme lancé 
DEFINE g_datedeb        DATE                               -- Date debut  
DEFINE g_heurdeb        CHAR(6)                            -- Heure debut 
#==================================================================================================#
# Tables utilisées                                                                                 # 
#==================================================================================================#
DEFINE r_bknom          RECORD LIKE bknom.*
DEFINE r_bkcli          RECORD LIKE bkcli.*
DEFINE r_bkbcc          RECORD LIKE bkbcc.*
DEFINE v_pays           LIKE bknom.lib1
#==================================================================================================# 
DEFINE FileOut          CHAR(100)                          -- Nom fichier à générer
DEFINE g_dco            DATE                               -- Date comptable [778,PARAM1]
DEFINE v_dco            CHAR(10)
DEFINE g_lus            INTEGER                            -- Nombre d''enregistrement lus
DEFINE g_ecr            INTEGER                            -- Nombre d''enregistrement écrits
#==================================================================================================# 
DEFINE r_ligne          CHAR(512) 
DEFINE r_ContrePartie   CHAR(66)
DEFINE PortF            CHAR(2)
DEFINE CatCli           CHAR(1) 
DEFINE natados          CHAR(1)
END GLOBALS
#==================================================================================================#
MAIN

   CALL Write_FTrace("D")
   WHENEVER ERROR CALL F_Erreur 
   SET ISOLATION TO DIRTY READ;
  
   LET g_lus = 0
   LET g_ecr = 0
    
   CALL Parametres()
   CALL EXTRACTION_SLDCL()
    
   LET g_msgbox = "NOMBRE LUS             : ",g_lus USING "<<<<<<<<<&"
   CALL Write_Ftrace("A") 
   LET g_msgbox = "NOMBRE ECRITS          : ",g_ecr USING "<<<<<<<<<&" 
   CALL Write_Ftrace("A")
   CALL Script() 
   CALL Write_FTrace("F") 
    
END MAIN
#==================================================================================================#
FUNCTION Parametres()

   INITIALIZE r_Bknom.* TO NULL
-- Date comptable
######################### modifié par MAKHKHAS YASSINE LE 09/03/2018 #####################################   
   {SELECT * INTO r_bknom.* FROM bknom WHERE ctab = "778" AND age  = "99000" AND cacc = "PARAM1"}
		SELECT * INTO r_Bknom.* FROM bknom WHERE ctab = "001" AND cacc = "99000"     
   IF SQLCA.SQLCODE = 100 THEN
      LET g_msgbox = "DATE COMPTABLE NON DECLAREE [001,99000]."
      CALL Write_Ftrace("E")
   END IF
   LET v_dco = r_bknom.mnt2 USING '&&&&&&&&'
   --DISPLAY"v_dco  : ",v_dco
   
   LET g_dco = MDY(v_dco[3,4],v_dco[1,2],v_dco[5,8])
   DISPLAY"g_dco  : ",g_dco
   IF DATE(g_dco) IS NULL THEN
      LET g_msgbox = "DATE COMPTABLE INVALIDE [001,99000]."
      CALL Write_Ftrace("E")
   END IF
   LET g_msgbox = "DATE COMPTABLE         : ",g_dco
   --DISPLAY"g_dco  : ",g_dco
   CALL Write_Ftrace("A")
###########################################################################################################
-- Nom fichier à générer
   SELECT nvl(trim(lib2),"") INTO FileOut FROM bknom WHERE ctab = '097' AND cacc = 'R1073' AND age = '99000'
   IF SQLCA.SQLCODE = 100 THEN
      LET g_msgbox = "Nom Fichier en sortie inexistant [097,R1073]."
      CALL Write_Ftrace("E")
   END IF
   IF LENGTH(FileOut CLIPPED) = 0 THEN
      LET g_msgbox = "Nom Fichier en sortie non renseigne [097,R1073]."
      CALL Write_Ftrace("E")
   END IF

END FUNCTION
#==================================================================================================# 
FUNCTION EXTRACTION_SLDCL()
DEFINE v_lib2   CHAR(3) 
DEFINE v_lib2c  CHAR(3) 

   LET FileOut = FileOut CLIPPED,".csv"
   LET g_hndlog0 = base.Channel.create()
   CALL g_hndlog0.openfile(FileOut,"w")
   CALL g_hndlog0.setdelimiter("")
   SET ISOLATION TO DIRTY READ;
          
   DECLARE CursP CURSOR FOR SELECT a.* FROM bkbcc a WHERE a.dedb = g_dco;
   LET r_ligne="Date de negociation;Date de valeur;Portefeuille ;Contrepartie;Sens de l'operation;Nature de l'adossement;Détail adossement;Categorie client ;Cours réel;Code devise cotée au certain ;Code devise cotée à l'incertain ;Montant devise cotée au certain;Montant devise cotée à l'incertain;Contrevaleur devise cotée au certain;Contrevaleur devise cotée à l'incertain;Motif de l'opération;"           
   CALL g_hndlog0.write(r_ligne)
   FOREACH CursP INTO r_bkbcc.*	
      LET g_lus = g_lus + 1 
      LET PortF = '' 
      LET r_ContrePartie = ''   
      CALL SelectBkcli(r_bkbcc.cli)
   -- Sens de l''operation 
      IF r_bkbcc.tope = '1' THEN
         LET r_bkbcc.tope = 'V'
      END IF
      IF r_bkbcc.tope = '2' THEN
         LET r_bkbcc.tope = 'A'
      END IF
   -- Nature de l''adossement     
      CALL DefineNatAdos()
   -- Categorie client 
      CALL CatCli()     
      SELECT lib2 INTO v_lib2  FROM bknom WHERE ctab = "005" AND cacc = r_bkbcc.dev;                  
      SELECT lib2 INTO v_lib2c FROM bknom WHERE ctab = "005" AND cacc = r_bkbcc.devc;     
   -- LET r_bkbcc.mnetc = (r_bkbcc.mdev * r_bkbcc.tdev)
   -- Contrepartie :
      CALL ContrePartie()
      LET r_bkbcc.motifd = '' -- ??? Ancien Conception                                 
      LET r_ligne= r_bkbcc.dedb,";",r_bkbcc.dexec,";",PortF,";",r_ContrePartie,";",r_bkbcc.tope,";",NatAdos,";",' ',";",CatCli,";",r_bkbcc.tdev,";",v_lib2,";",v_lib2c,";",r_bkbcc.mdev,";",r_bkbcc.mdev*r_bkbcc.tdev,";",'',";",'',";",r_bkbcc.motifd,";"	
      CALL g_hndlog0.write(r_ligne)
      LET g_ecr = g_ecr + 1
      INITIALIZE r_bkbcc.* TO NULL   
   END FOREACH
   CALL g_hndlog0.CLOSE()

END FUNCTION
#==================================================================================================#
FUNCTION ContrePartie() 
DEFINE v_pays CHAR(30)

-- Contrepartie : 
   IF LENGTH(r_bkcli.cli CLIPPED) = 0 OR r_bkcli.lib = '14' THEN LET r_ContrePartie = 'COMMISSIONS' END IF
   IF PortF = '1' THEN LET r_ContrePartie = r_ContrePartie END IF
   IF PortF = '1X' THEN 
      SELECT b.lib1 INTO v_pays FROM bkcli a,bknom b  
       WHERE a.cli  = r_bkbcc.cli AND b.ctab = '040' AND a.res  = b.cacc;                     
       LET r_ContrePartie = r_ContrePartie CLIPPED," ",v_pays 
   END IF
   IF PortF = '2'  THEN LET r_ContrePartie = 'PM' END IF
   IF PortF = '2X' THEN LET r_ContrePartie = 'PE' END IF

END FUNCTION
#==================================================================================================#
FUNCTION CatCli()      

   LET CatCli = ''
   IF r_ContrePartie = 'COMMISSIONS' THEN LET CatCli = '4' RETURN END IF
   IF (PortF = "1" OR PortF = "2" OR PortF = "1X" OR PortF = "2X" ) AND NatAdos = "1" THEN
      IF r_bkcli.sec = "11"  OR r_bkcli.sec = "12"  OR r_bkcli.sec = "13"
      OR r_bkcli.sec = "14"  OR r_bkcli.sec = "15"  OR r_bkcli.sec = "16"
      OR r_bkcli.sec = "20"  OR r_bkcli.sec = "50"  OR r_bkcli.sec = "151"
      OR r_bkcli.sec = "152" OR r_bkcli.sec = "153" OR r_bkcli.sec = "154"
      OR r_bkcli.sec = "155" OR r_bkcli.sec = "156" OR r_bkcli.sec = "157"
      OR r_bkcli.sec = "158" THEN 
         LET CatCli = "2"	
         RETURN
      END IF 
      IF r_bkcli.sec != "11"  OR r_bkcli.sec != "12"  OR r_bkcli.sec != "13"  
      OR r_bkcli.sec != "14"  OR r_bkcli.sec != "15"  OR r_bkcli.sec != "16"
      OR r_bkcli.sec != "20"  OR r_bkcli.sec != "50"  OR r_bkcli.sec != "151"
      OR r_bkcli.sec != "152" OR r_bkcli.sec != "153" OR r_bkcli.sec != "154"
      OR r_bkcli.sec != "155" OR r_bkcli.sec != "156" OR r_bkcli.sec != "157"
      OR r_bkcli.sec != "158" OR r_bkcli.sec != "131" OR r_bkcli.sec != "132"
      OR r_bkcli.sec != "141" OR r_bkcli.sec != "142" OR r_bkcli.sec != "143"
      OR r_bkcli.sec != "144" OR r_bkcli.sec != "100" OR r_bkcli.sec != "111"
      OR r_bkcli.sec != "112" OR r_bkcli.sec  = "" THEN
         LET CatCli = "4"	
         RETURN
      END IF    
      IF r_bkcli.sec = "131" OR r_bkcli.sec = "132" OR r_bkcli.sec = "141"
      OR r_bkcli.sec = "142" OR r_bkcli.sec = "143" OR r_bkcli.sec = "144" THEN 
         LET CatCli = "3"	
         RETURN
      END IF 
      IF r_bkcli.sec = "100" OR r_bkcli.sec = "111" OR r_bkcli.sec = "112"  THEN 
         LET CatCli = "1"	
         RETURN
      END IF 
   ELSE 
      LET CatCli = "4" -- MAJ A.ELBADAOUI LE 12/03/2012
      RETURN
   END IF 

END FUNCTION
#==================================================================================================#
FUNCTION DefineNatAdos()

   LET NatAdos = "" 
   IF PortF ="1" OR PortF ="2" OR PortF ="1X" OR PortF ="2X" THEN
      IF (r_bkbcc.chor="PTI" AND (r_bkbcc.typ="001" OR r_bkbcc.typ="008")) 
      OR (r_bkbcc.chor="PTE" AND (r_bkbcc.typ="005" OR r_bkbcc.typ="013"))
      OR (r_bkbcc.chor="TRF" AND (r_bkbcc.typ="001" OR r_bkbcc.typ="002"
                               OR r_bkbcc.typ="003" OR r_bkbcc.typ="004"
                               OR r_bkbcc.typ="009" OR r_bkbcc.typ="010" 
                               OR r_bkbcc.typ="015" OR r_bkbcc.typ="016"
                               OR r_bkbcc.typ="021")) 
      OR (r_bkbcc.chor="RPT" AND (r_bkbcc.typ="001" OR r_bkbcc.typ="002" 
   		               OR r_bkbcc.typ="005" OR r_bkbcc.typ="006"
                               OR r_bkbcc.typ="016" OR r_bkbcc.typ="017"
                               OR r_bkbcc.typ="018" OR r_bkbcc.typ="019"
                               OR r_bkbcc.typ="020")) 
      OR (r_bkbcc.chor="PTI" AND (r_bkbcc.typ="002" OR r_bkbcc.typ="003"
                               OR r_bkbcc.typ="009" OR r_bkbcc.typ="010"
                               OR r_bkbcc.typ="011"))
      OR (r_bkbcc.chor="PTE" AND (r_bkbcc.typ="006" OR r_bkbcc.typ="007"))
      OR (r_bkbcc.chor="TRF" AND (r_bkbcc.typ="013" OR r_bkbcc.typ="014"))
      OR  r_bkbcc.chor = "CDI" OR r_bkbcc.chor ="CDE" THEN 	
     	  LET NatAdos="1"
      ELSE
         IF (r_bkbcc.chor="TRF" AND (r_bkbcc.typ="005" OR r_bkbcc.typ="006"
                                  OR r_bkbcc.typ="007" OR r_bkbcc.typ="008"
                                  OR r_bkbcc.typ="017" OR r_bkbcc.typ="018"
       		                  OR r_bkbcc.typ="019" OR r_bkbcc.typ="020"
                                  OR r_bkbcc.typ="022")) 
         OR (r_bkbcc.chor="RPT" AND (r_bkbcc.typ="003" OR r_bkbcc.typ="004"
                                  OR r_bkbcc.typ="012" OR r_bkbcc.typ="013"
                                  OR r_bkbcc.typ="014" OR r_bkbcc.typ="015"
                                  OR r_bkbcc.typ="999"))
         OR (r_bkbcc.chor="TRF" AND (r_bkbcc.typ="011" OR r_bkbcc.typ="012"))
         OR (r_bkbcc.chor="RPT" AND (r_bkbcc.typ="007" OR r_bkbcc.typ="008" OR r_bkbcc.typ="011"))	OR (r_bkbcc.chor="PTE" AND (r_bkbcc.typ="004" OR r_bkbcc.typ="012"))THEN 
       	    LET NatAdos="2"
         ELSE
       	    LET NatAdos="3" 
         END IF   
      END IF  
   END IF

END FUNCTION
#==================================================================================================# 
FUNCTION SelectBkcli(vcli)
DEFINE vcli         LIKE bkcli.cli
	
   INITIALIZE r_bkcli.* TO NULL
   SELECT * INTO r_bkcli.* FROM bkcli WHERE cli = vcli;
   IF LENGTH(r_bkcli.cli CLIPPED) = 0 OR r_bkcli.lib = '14' THEN 
      LET PortF = 1 
      LET r_ContrePartie = 'COMMISSIONS'  
      RETURN 
   END IF
   IF r_bkcli.nat = '900' THEN
      IF r_bkcli.catn = "111" OR r_bkcli.catn = "112" OR r_bkcli.catn = "121" OR r_bkcli.catn = "122" OR r_bkcli.catn = "123" OR r_bkcli.catn = "124"
      OR r_bkcli.catn = "131" OR r_bkcli.catn = "132" OR r_bkcli.catn = "133" OR r_bkcli.catn = "140" OR r_bkcli.catn = "150" OR r_bkcli.catn = "190"
      THEN
         LET PortF = '1'
         LET r_ContrePartie = r_bkcli.nom CLIPPED,' ',r_bkcli.pre CLIPPED
	 RETURN
      ELSE  
         IF r_bkcli.lib = '11' OR r_bkcli.lib = '12' OR r_bkcli.lib = '13' THEN
            LET PortF = '1' 
            LET r_ContrePartie = r_bkcli.nom CLIPPED,' ',r_bkcli.pre CLIPPED
            RETURN
         END IF
	 IF r_bkcli.lib = '01' OR r_bkcli.lib = '02' OR r_bkcli.lib = '03'
         OR r_bkcli.lib = '04' OR r_bkcli.lib = '05' OR r_bkcli.lib = '06'
         OR r_bkcli.lib = '07' OR r_bkcli.lib = '08' OR r_bkcli.lib = '09'
         OR r_bkcli.lib = '10' THEN
	    LET PortF = '2'
	    LET r_ContrePartie = 'PM'
	    RETURN
	 END IF
      END IF   
   ELSE
      IF r_bkcli.catn = "111" OR r_bkcli.catn = "112"
      OR r_bkcli.catn = "121" OR r_bkcli.catn = "122"
      OR r_bkcli.catn = "123" OR r_bkcli.catn = "124"
      OR r_bkcli.catn = "131" OR r_bkcli.catn = "132"
      OR r_bkcli.catn = "133" OR r_bkcli.catn = "140"
      OR r_bkcli.catn = "150" OR r_bkcli.catn = "190" THEN
         LET PortF = '1'
         RETURN
      ELSE  
         IF r_bkcli.lib = '11' OR r_bkcli.lib = '12' OR r_bkcli.lib = '13' THEN
            LET PortF = '1X'
	    SELECT b.lib1 INTO v_pays FROM bkcli a, bknom b  
             WHERE a.cli  = r_bkbcc.cli  AND b.ctab = '040' AND a.res  = b.cacc;                     
            LET r_ContrePartie = r_ContrePartie CLIPPED," ",v_pays 
            RETURN
	 END IF
         IF r_bkcli.lib = '01' OR r_bkcli.lib = '02' OR r_bkcli.lib = '03'
         OR r_bkcli.lib = '04' OR r_bkcli.lib = '05' OR r_bkcli.lib = '06'
         OR r_bkcli.lib = '07' OR r_bkcli.lib = '08' OR r_bkcli.lib = '09'
         OR r_bkcli.lib = '10' THEN
	    LET PortF = '2X'
	    LET r_ContrePartie = 'PE'
	    RETURN
	 END IF
      END IF
   END IF
-- Etablissement de crédit et assimilé Marocain ==> 0
-- Etablissement de crédit et assimilé étranger ==> 0X 
-- Personne morale Marocaine                    ==> 1
-- Personne physique Marocaine                  ==> 2
-- Personne morale Etrangère                    ==> 1X
-- Personne physique Etrangère                  ==> 2X

END FUNCTION
#==================================================================================================# 
FUNCTION F_Erreur()
DEFINE CodeStat      INTEGER

   LET CodeStat = status
   LET g_msgbox = "Erreur: ",CodeStat,". \n",ERR_GET(CodeStat)
   CALL Write_FTrace("E")

END FUNCTION
#==================================================================================================#
FUNCTION Script()
DEFINE vexec       CHAR(200)
DEFINE vrun        SMALLINT
DEFINE name_script CHAR(200)
DEFINE commande    CHAR(200)
DEFINE V_Existe    SMALLINT
DEFINE  ls_l RECORD
        rights CHAR(20),
          nlink  SMALLINT,
          owner  CHAR(20),
          GROUP  CHAR(20),
          SIZE   INTEGER,
          DAY    SMALLINT,
          MONTH  CHAR(10),
          hy     CHAR(10),
          NAME   CHAR(64)
END RECORD

   LET v_existe=0
   WHENEVER ERROR CONTINUE
   LET commande="ls -ltr $BANK/bin/ex-",g_prgname CLIPPED,".ksh  2>/dev/null"
   LET g_hndp2 = base.Channel.create()
   CALL g_hndp2.openpipe(commande,"r")
   CALL g_hndp2.setdelimiter("|")
   WHILE g_hndp2.READ([ls_l.*])
      LET V_Existe=1    
      LET name_script = '$BANK/bin/ex-',g_prgname CLIPPED,".ksh"    
      LET vexec = " ",name_script CLIPPED, " ",FileOut," &" 
      LET vrun = exec_cmd (vexec CLIPPED)
   END WHILE
   IF v_existe=0 THEN
      LET g_msgbox ="le script inexistant"      
      CALL Write_FTrace("A")    
   END IF
END FUNCTION
#==================================================================================================#
FUNCTION Write_Ftrace(v_etat)
DEFINE v_etat        CHAR(1)
DEFINE v_nomfile     CHAR(80)
Define Arg0          CHAR(256)
Define ix            SMALLINT

   LET g_hhmmss = TIME
   LET g_ddmmyy = TODAY
   CASE v_etat
   WHEN "D"
      LET g_base = fgl_GETENV("DATABASE")
      DATABASE g_base

      IF NUM_ARGS() = 0 THEN
         LET g_uti = "XXXX"
      ELSE
        LET g_uti = ARG_VAL(1)
      END IF

      LET ARG0 = ARG_VAL(0)
      FOR IX = LENGTH(ARG0) TO 1 STEP -1
         IF ARG0[IX,IX]= "/" THEN
            EXIT FOR
         END IF
      END FOR
      LET g_prgname = ARG0[IX+1,LENGTH(ARG0)]  
      LET arg0      = g_prgname CLIPPED
      LET g_prgname = ""
      FOR ix = 1 TO LENGTH(arg0)
          IF arg0[ix,ix] = "." THEN EXIT FOR END IF
          LET g_prgname = g_prgname CLIPPED,arg0[ix,ix]
      END FOR
      LET g_prgname = g_prgname CLIPPED
      LET g_datedeb = g_ddmmyy
      LET g_heurdeb = g_hhmmss[1,2],g_hhmmss[4,5],g_hhmmss[7,8]
      LET v_nomfile = "/tmp/trace",g_prgname CLIPPED
      LET g_hndlog = base.Channel.create()
      CALL g_hndlog.openfile(v_nomfile,"w")
      CALL g_hndlog.setdelimiter("")

      LET g_msgbox = "======================================================================"
      CALL g_hndlog.write(g_msgbox[1,70])
      DISPLAY g_msgbox[1,70]
      LET g_msgbox = "DEBUT DU PROGRAMME ",g_prgname[1,24],"        ",g_ddmmyy," ",g_hhmmss
      CALL g_hndlog.write(g_msgbox[1,70])
      DISPLAY g_msgbox[1,70]
      LET g_msgbox = "======================================================================"
      CALL g_hndlog.write(g_msgbox[1,70])
      DISPLAY g_msgbox[1,70]
      LET g_msgbox = "BASE DE DONNEES        : ",g_base
      CALL g_hndlog.write(g_msgbox[1,70])
      DISPLAY g_msgbox[1,70]
      CALL Insert_Sgtrace(v_etat)
   WHEN "F"
      LET g_msgbox = "======================================================================"
      CALL g_hndlog.write(g_msgbox[1,70])
      DISPLAY g_msgbox[1,70]
      LET g_msgbox = "FIN NORMALE DU PROGRAMME ",g_prgname[1,24],"  ",g_ddmmyy," ",g_hhmmss
      CALL g_hndlog.write(g_msgbox[1,70])
      DISPLAY g_msgbox[1,70]
      LET g_msgbox = "======================================================================"
      CALL g_hndlog.write(g_msgbox[1,70])
      DISPLAY g_msgbox[1,70]
      CALL g_hndlog.CLOSE()
      CALL Insert_Sgtrace(v_etat)
      CALL MAJ_Trace_Global()
   WHEN "E"
      IF SQLCA.SQLCODE >= 0 THEN
         CALL Insert_Sgtrace(v_etat)
      END IF
      CALL g_hndlog.write(g_msgbox[1,70])
      DISPLAY g_msgbox[1,70]
      LET g_msgbox = "======================================================================"
      CALL g_hndlog.write(g_msgbox[1,70])
      DISPLAY g_msgbox[1,70]
      LET g_msgbox = "FIN ANORMALE DU PROGRAMME ",g_prgname[1,24]," ",g_ddmmyy," ",g_hhmmss
      CALL g_hndlog.write(g_msgbox[1,70])
      DISPLAY g_msgbox[1,70]
      LET g_msgbox = "======================================================================"
      CALL g_hndlog.write(g_msgbox[1,70])
      DISPLAY g_msgbox[1,70]
      CALL g_hndlog.CLOSE()
      CALL MAJ_Trace_Global()
   WHEN "W"
      CALL g_hndlog.write(g_msgbox[1,70])
      DISPLAY g_msgbox[1,70]
      CALL Insert_Sgtrace(v_etat)
   OTHERWISE
      CALL g_hndlog.write(g_msgbox[1,70])
      DISPLAY g_msgbox[1,70]
   END CASE

   IF v_etat = "E" OR v_etat = "F" THEN
      IF v_etat = "E" THEN
         EXIT PROGRAM(1)
      ELSE
         EXIT PROGRAM(0)
      END IF
   END IF

END FUNCTION
#==================================================================================================# 
FUNCTION Insert_SgTrace(v_etat)
DEFINE v_etat        CHAR(1)
DEFINE v_heurfin     CHAR(6)
DEFINE v_datefin     DATE
DEFINE v_heure       CHAR(10)

   LET v_datefin = TODAY
   LET v_heure   = TIME  
   LET v_heurfin = v_heure[1,2],v_heure[4,5],v_heure[7,8]
   CASE v_etat
   WHEN "D"
      LET g_msgbox = "DEBUT NORMAL"
      LET v_datefin  = ""
      LET v_heurfin  = ""
   WHEN "F"
      LET g_msgbox = "FIN NORMALE"
   END CASE
   INSERT INTO sgtrace VALUES
   (g_prgname,g_datedeb,g_heurdeb,v_datefin,v_heurfin,g_uti,v_etat,g_msgbox)
END FUNCTION
#==================================================================================================#
FUNCTION MAJ_Trace_Global()
DEFINE v_ftrace      CHAR(80)
DEFINE v_gtrace      CHAR(80)
DEFINE v_run         CHAR(250)

   WHENEVER ERROR CONTINUE

   LET v_ftrace = "/tmp/trace",g_prgname CLIPPED
   LET v_gtrace = "XXXXXXXXXX"

   SELECT lib2 INTO v_gtrace FROM bknom
    WHERE ctab = "097" AND age = "99000" AND cacc = "R000"

   IF v_gtrace IS NULL THEN LET v_gtrace = "XXXXXXXXXX" END IF

   IF v_gtrace != "XXXXXXXXXX" THEN
      LET v_run = "cat ",v_ftrace CLIPPED," >> ",v_gtrace CLIPPED," 2>/dev/null"
      run v_run
   END IF

END FUNCTION  
#==================================================================================================#
#                                       FIN PROGRAMME                                              #
#==================================================================================================#
