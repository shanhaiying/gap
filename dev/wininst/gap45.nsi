# GAP 4.5 Installer for Windows
#
# Script written by Alexander Konovalov 
#
# Based on the previous NSIS script by A.Konovalov for GAP 4.4
# 
# Updated to use NSISModern User Interface using example scripts 
# from "NSIS\Examples\Modern UI" of NSIS 2.46 by Joost Verburg
#
# To make the GAP installer for Windows:
# - put gapicon.ico in the same folder with this script
# - unpack GAP source distribution to the subdirectory 'gap4r5'
#   in the place where this script is located
# - remove bin/regtool.exe and bin/usemem.bat
# - compile the script
# - perform test installation with various components and compare it 
#   with the content of source directories
#
# TO-DO: 
# - improve icons (and add another one for mintty) and place them in 
#   'bin' to get from there instead of copying them to the script folder
# - suggest user feedback
# - suggest to remove manually GAP root directory after uninstall
# - trace dependencies between packages?
# - add to packages descriptions whether they work under Windows
# - detect Cygwin installation and at least display a warning?
# - check user's permissions?
# - cleanup start menu and desktop shortcuts during uninstall

#######################################################################
#
# include headers
#
!include "WordFunc.nsh"
!insertmacro WordReplace
!include Sections.nsh

# Include Modern UI

  !include "MUI2.nsh"

#######################################################################
#
# Declaring user variables - 
#
var GAP_VER       # GAP version in format 4.5.2
var RXVT_PATH     # Install path in the form C/gap4r5
var GAP_BAT       # to write gap.bat file
var GAPRXVT_BAT   # to write gaprxvt.bat file
var GAPCMD_BAT   # to write gapmintty.bat file
var IndependentSectionState
var StartMenuFolder

#######################################################################
#
# User variables and other general settings: adjust them here as needed
# 
Section
StrCpy $GAP_VER "4.5.4"
SectionEnd

#Name and file
Name "GAP 4.5.4"
OutFile "gap4r5p4_2012_06_04-23_02.exe"

#Default installation folder
InstallDir "C:\gap4r5"

#######################################################################
# Get installation folder from registry if available
InstallDirRegKey HKCU "Software\GAP" ""

# Request application privileges for Windows Vista
RequestExecutionLevel user

# Set compressing method (for test compiling may be commented out)
# and /SOLID can be removed (The best ratio is with /SOLID lzma,
# but it takes several times more to pack it, so we may be happy
# with the default compressor)
# SetCompressor /SOLID lzma
# SetCompressor lzma
# SetCompressor /SOLID zlib
# SetCompressor bzip2

#######################################################################
# Interface Settings

  !define MUI_ABORTWARNING

#######################################################################
# Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "copyright.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY

  ;Start Menu Folder Page Configuration
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\GAP" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
  
  !insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder

  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

#######################################################################
# Languages

  !insertmacro MUI_LANGUAGE "English"

#######################################################################
#
# Installer Sections
#

#######################################################################
#
# The core GAP system - required component
#
Section "Core GAP system" SecGAPcore

  SectionIn RO

  # Set output path to the installation directory
  SetOutPath $INSTDIR
  # Put files there
  File gap4r5\*.*

  SetOutPath $INSTDIR\bin
  File /r gap4r5\bin\*.*
  File gapicon.ico

  SetOutPath $INSTDIR\cnf
  File /r gap4r5\cnf\*.*

  SetOutPath $INSTDIR\doc
  File /r gap4r5\doc\*.*

  SetOutPath $INSTDIR\etc
  File /r gap4r5\etc\*.*

  SetOutPath $INSTDIR\extern
  File /r gap4r5\extern\*.*

  SetOutPath $INSTDIR\grp
  File /r gap4r5\grp\*.*

  SetOutPath $INSTDIR\lib
  File /r gap4r5\lib\*.*

  SetOutPath $INSTDIR\prim
  File /r gap4r5\prim\*.*

  SetOutPath $INSTDIR\small
  File /r gap4r5\small\*.*

  SetOutPath $INSTDIR\src
  File /r gap4r5\src\*.*

  SetOutPath $INSTDIR\trans
  File /r gap4r5\trans\*.*

  SetOutPath $INSTDIR\terminfo
  File /r gap4r5\terminfo\*.*

  SetOutPath $INSTDIR\tst
  File /r gap4r5\tst\*.*

  # restore initial output path
  SetOutPath $INSTDIR 

  # Store installation folder
  WriteRegStr HKCU "Software\GAP" "" $INSTDIR

  # Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  # rewriting install path in format /cygdrive/c/gap4r5
  StrCpy $RXVT_PATH $INSTDIR
  ${WordReplace} $RXVT_PATH ":" ""  "+" $RXVT_PATH
  ${WordReplace} $RXVT_PATH "\" "/" "+" $RXVT_PATH

  # Write gap.bat file as follows:
  # set TERMINFO=/cygdrive/c/GAP4R5/terminfo
  # set CYGWIN=nodosfilewarning
  # set LANG=en_US.UTF-8
  # set HOME=%HOMEDRIVE%%HOMEPATH%
  # cd %HOME%
  # start "GAP" C:\GAP4R5\bin\mintty.exe -s 120,40 /cygdrive/c/gap4r5/bin/gapw95.exe -l /cygdrive/c/GAP4R5 %*
  # exit

  FileOpen $GAP_BAT $INSTDIR\bin\gap.bat w
  FileWrite $GAP_BAT "set TERMINFO=/cygdrive/"
  FileWrite $GAP_BAT $RXVT_PATH
  FileWrite $GAP_BAT "/terminfo"
    FileWriteByte $GAP_BAT "13"
    FileWriteByte $GAP_BAT "10"
  FileWrite $GAP_BAT "set CYGWIN=nodosfilewarning"
    FileWriteByte $GAP_BAT "13"
    FileWriteByte $GAP_BAT "10"
  FileWrite $GAP_BAT "set LANG=en_US.UTF-8"
    FileWriteByte $GAP_BAT "13"
    FileWriteByte $GAP_BAT "10"    
  FileWrite $GAP_BAT "set HOME=%HOMEDRIVE%%HOMEPATH%"
    FileWriteByte $GAP_BAT "13"
    FileWriteByte $GAP_BAT "10"
  FileWrite $GAP_BAT "cd %HOME%"
    FileWriteByte $GAP_BAT "13"
    FileWriteByte $GAP_BAT "10"
  FileWrite $GAP_BAT "start $\"GAP$\" " 
  FileWrite $GAP_BAT $INSTDIR
  FileWrite $GAP_BAT "\bin\mintty.exe -s 120,40 /cygdrive/"
  FileWrite $GAP_BAT $RXVT_PATH
  FileWrite $GAP_BAT "/bin/gapw95.exe -l /cygdrive/"
  FileWrite $GAP_BAT $RXVT_PATH
  FileWrite $GAP_BAT " %*"
    FileWriteByte $GAP_BAT "13"
    FileWriteByte $GAP_BAT "10"
  FileWrite $GAP_BAT "exit"
    FileWriteByte $GAP_BAT "13"
    FileWriteByte $GAP_BAT "10"
  FileClose $GAP_BAT


  # Write gaprxvt.bat file as follows:
  # set TERMINFO=/cygdrive/c/GAP4R5/terminfo
  # set CYGWIN=nodosfilewarning
  # set LANG=en_US.ISO-8859-1
  # set HOME=%HOMEDRIVE%%HOMEPATH%
  # cd %HOME%
  # start "GAP" C:\GAP4R5\bin\rxvt.exe -fn fixedsys -sl 1000 -e /cygdrive/c/gap4r5/bin/gapw95.exe -l /cygdrive/c/GAP4R5 %*
  # exit

  FileOpen $GAPRXVT_BAT $INSTDIR\bin\gaprxvt.bat w
  FileWrite $GAPRXVT_BAT "set TERMINFO=/cygdrive/"
  FileWrite $GAPRXVT_BAT $RXVT_PATH
  FileWrite $GAPRXVT_BAT "/terminfo"
    FileWriteByte $GAPRXVT_BAT "13"
    FileWriteByte $GAPRXVT_BAT "10"
  FileWrite $GAPRXVT_BAT "set CYGWIN=nodosfilewarning"
    FileWriteByte $GAPRXVT_BAT "13"
    FileWriteByte $GAPRXVT_BAT "10"
  FileWrite $GAP_BAT "set LANG=en_US.ISO-8859-1"
    FileWriteByte $GAP_BAT "13"
    FileWriteByte $GAP_BAT "10"     
  FileWrite $GAPRXVT_BAT "set HOME=%HOMEDRIVE%%HOMEPATH%"
    FileWriteByte $GAPRXVT_BAT "13"
    FileWriteByte $GAPRXVT_BAT "10"
  FileWrite $GAPRXVT_BAT "cd %HOME%"
    FileWriteByte $GAPRXVT_BAT "13"
    FileWriteByte $GAPRXVT_BAT "10"
  FileWrite $GAPRXVT_BAT "start $\"GAP$\" " 
  FileWrite $GAPRXVT_BAT $INSTDIR
  FileWrite $GAPRXVT_BAT "\bin\rxvt.exe -fn fixedsys -sl 1000 -e /cygdrive/"
  FileWrite $GAPRXVT_BAT $RXVT_PATH
  FileWrite $GAPRXVT_BAT "/BIN/gapw95.exe -l /cygdrive/"
  FileWrite $GAPRXVT_BAT $RXVT_PATH
  FileWrite $GAPRXVT_BAT " %*"
    FileWriteByte $GAPRXVT_BAT "13"
    FileWriteByte $GAPRXVT_BAT "10"
  FileWrite $GAPRXVT_BAT "exit"
    FileWriteByte $GAPRXVT_BAT "13"
    FileWriteByte $GAPRXVT_BAT "10"
  FileClose $GAPRXVT_BAT


  # Write gapcmd.bat file as follows:
  # set TERMINFO=/cygdrive/c/GAP4R5/terminfo
  # set CYGWIN=nodosfilewarning
  # set LANG=en_US.UTF-8
  # set HOME=%HOMEDRIVE%%HOMEPATH%
  # cd %HOME%
  # C:\GAP4R5\bin\gapw95.exe -l /cygdrive/c/GAP4R5 %*
  # exit

  FileOpen $GAPCMD_BAT $INSTDIR\bin\gapcmd.bat w
  FileWrite $GAPCMD_BAT "set TERMINFO=/cygdrive/"
  FileWrite $GAPCMD_BAT $RXVT_PATH
  FileWrite $GAPCMD_BAT "/terminfo"
    FileWriteByte $GAPCMD_BAT "13"
    FileWriteByte $GAPCMD_BAT "10"
  FileWrite $GAPCMD_BAT "set CYGWIN=nodosfilewarning"
    FileWriteByte $GAPCMD_BAT "13"
    FileWriteByte $GAPCMD_BAT "10"
  FileWrite $GAP_BAT "set LANG=en_US.UTF-8"
    FileWriteByte $GAP_BAT "13"
    FileWriteByte $GAP_BAT "10"   
  FileWrite $GAPCMD_BAT "set HOME=%HOMEDRIVE%%HOMEPATH%"
    FileWriteByte $GAPCMD_BAT "13"
    FileWriteByte $GAPCMD_BAT "10"
  FileWrite $GAPCMD_BAT "cd %HOME%"
    FileWriteByte $GAPCMD_BAT "13"
    FileWriteByte $GAPCMD_BAT "10"
  FileWrite $GAPCMD_BAT $INSTDIR
  FileWrite $GAPCMD_BAT "\bin\gapw95.exe -l /cygdrive/"
  FileWrite $GAPCMD_BAT $RXVT_PATH 
  FileWrite $GAPCMD_BAT " %*"
    FileWriteByte $GAPCMD_BAT "13"
    FileWriteByte $GAPCMD_BAT "10"
  FileWrite $GAPCMD_BAT "exit"
    FileWriteByte $GAPCMD_BAT "13"
    FileWriteByte $GAPCMD_BAT "10"
  FileClose $GAPCMD_BAT


  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    
  CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\GAP $GAP_VER.lnk" "$INSTDIR\bin\gap.bat" "" "$INSTDIR\bin\gapicon.ico" 0
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\GAP Tutorial.lnk" "$INSTDIR\doc\tut\chap0.html" "" "$INSTDIR\doc\tut\chap0.html" 0
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\GAP Reference Manual.lnk" "$INSTDIR\doc\ref\chap0.html" "" "$INSTDIR\doc\ref\chap0.html" 0
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall GAP $GAP_VER.lnk" "$INSTDIR\Uninstall.exe"

  !insertmacro MUI_STARTMENU_WRITE_END

SectionEnd


#######################################################################
#
# Needed packages
#
SectionGroup "Needed packages" SecGAPpkgsNeeded

#######################################################################
#
# GAPDoc
#
Section "GAPDoc" SecGAPpkg_gapdoc 
SectionIn RO 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.gapdoc
SetOutPath $INSTDIR\pkg\GAPDoc-1.5.1
File /r gap4r5\pkg\GAPDoc-1.5.1\*.* 
SetOutPath $INSTDIR 
SectionEnd 

SectionGroupEnd 
# Needed packages end here

#######################################################################
#
# Default packages
#
SectionGroup "Default packages" SecGAPpkgsDefault

#######################################################################
#
# AClib
#
Section "AClib" SecGAPpkg_aclib 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.aclib
SetOutPath $INSTDIR\pkg\aclib
File /r gap4r5\pkg\aclib\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Alnuth
#
Section "Alnuth" SecGAPpkg_alnuth 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.alnuth
SetOutPath $INSTDIR\pkg\Alnuth-3.0.0
File /r gap4r5\pkg\Alnuth-3.0.0\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# AtlasRep
#
Section "AtlasRep" SecGAPpkg_atlasrep 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.atlasrep
SetOutPath $INSTDIR\pkg\atlasrep
File /r gap4r5\pkg\atlasrep\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# AutPGrp
#
Section "AutPGrp" SecGAPpkg_autpgrp 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.autpgrp
SetOutPath $INSTDIR\pkg\autpgrp
File /r gap4r5\pkg\autpgrp\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Browse
#
Section "Browse" SecGAPpkg_browse 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.browse
SetOutPath $INSTDIR\pkg\Browse
File /r gap4r5\pkg\Browse\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# CRISP
#
Section "CRISP" SecGAPpkg_crisp 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.crisp
SetOutPath $INSTDIR\pkg\crisp
File /r gap4r5\pkg\crisp\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Cryst
#
Section "Cryst" SecGAPpkg_cryst 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.cryst
SetOutPath $INSTDIR\pkg\cryst
File /r gap4r5\pkg\cryst\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# CrystCat
#
Section "CrystCat" SecGAPpkg_crystcat 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.crystcat
SetOutPath $INSTDIR\pkg\crystcat
File /r gap4r5\pkg\crystcat\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# CTblLib
#
Section "CTblLib" SecGAPpkg_ctbllib 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.ctbllib
SetOutPath $INSTDIR\pkg\ctbllib
File /r gap4r5\pkg\ctbllib\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# DESIGN
#
Section "DESIGN" SecGAPpkg_design 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.design
SetOutPath $INSTDIR\pkg\design
File /r gap4r5\pkg\design\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Example
#
Section "Example" SecGAPpkg_example 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.example
SetOutPath $INSTDIR\pkg\example
File /r gap4r5\pkg\example\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# FactInt
#
Section "FactInt" SecGAPpkg_factint 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.factint
SetOutPath $INSTDIR\pkg\factint
File /r gap4r5\pkg\factint\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# FGA
#
Section "FGA" SecGAPpkg_fga 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.fga
SetOutPath $INSTDIR\pkg\fga
File /r gap4r5\pkg\fga\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# GRAPE
#
Section "GRAPE" SecGAPpkg_grape 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.grape
SetOutPath $INSTDIR\pkg\grape
File /r gap4r5\pkg\grape\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# GUAVA
#
Section "GUAVA" SecGAPpkg_guava 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.guava
SetOutPath $INSTDIR\pkg\guava-3.12
File /r gap4r5\pkg\guava-3.12\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# IO
#
Section "IO" SecGAPpkg_io 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.io
SetOutPath $INSTDIR\pkg\io
File /r gap4r5\pkg\io\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# IRREDSOL
#
Section "IRREDSOL" SecGAPpkg_irredsol 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.irredsol
SetOutPath $INSTDIR\pkg\irredsol
File /r gap4r5\pkg\irredsol\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# LAGUNA
#
Section "LAGUNA" SecGAPpkg_laguna 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.laguna
SetOutPath $INSTDIR\pkg\laguna
File /r gap4r5\pkg\laguna\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Polenta
#
Section "Polenta" SecGAPpkg_polenta 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.polenta
SetOutPath $INSTDIR\pkg\polenta-1.3.1
File /r gap4r5\pkg\polenta-1.3.1\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Polycyclic
#
Section "Polycyclic" SecGAPpkg_polycyclic 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.polycyclic
SetOutPath $INSTDIR\pkg\polycyclic-2.10.1
File /r gap4r5\pkg\polycyclic-2.10.1\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# RadiRoot
#
Section "RadiRoot" SecGAPpkg_radiroot 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.radiroot
SetOutPath $INSTDIR\pkg\radiroot
File /r gap4r5\pkg\radiroot\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# ResClasses
#
Section "ResClasses" SecGAPpkg_resclasses 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.resclasses
SetOutPath $INSTDIR\pkg\resclasses
File /r gap4r5\pkg\resclasses\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# SONATA
#
Section "SONATA" SecGAPpkg_sonata 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.sonata
SetOutPath $INSTDIR\pkg\sonata
File /r gap4r5\pkg\sonata\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Sophus
#
Section "Sophus" SecGAPpkg_sophus 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.sophus
SetOutPath $INSTDIR\pkg\sophus
File /r gap4r5\pkg\sophus\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# TomLib
#
Section "TomLib" SecGAPpkg_tomlib 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.tomlib
SetOutPath $INSTDIR\pkg\tomlib
File /r gap4r5\pkg\tomlib\*.* 
SetOutPath $INSTDIR 
SectionEnd 

SectionGroupEnd 
# Default packages end here

#######################################################################
#
# Specialised  packages
#
SectionGroup "Specialised  packages" SecGAPpkgsSpecial

#######################################################################
#
# Automata
#
Section "Automata" SecGAPpkg_automata 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.automata
SetOutPath $INSTDIR\pkg\automata
File /r gap4r5\pkg\automata\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# AutomGrp
#
Section "AutomGrp" SecGAPpkg_automgrp 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.automgrp
SetOutPath $INSTDIR\pkg\automgrp
File /r gap4r5\pkg\automgrp\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Circle
#
Section "Circle" SecGAPpkg_circle 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.circle
SetOutPath $INSTDIR\pkg\circle
File /r gap4r5\pkg\circle\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Citrus
#
Section "Citrus" SecGAPpkg_citrus 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.citrus
SetOutPath $INSTDIR\pkg\citrus-0.9
File /r gap4r5\pkg\citrus-0.9\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Crime
#
Section "Crime" SecGAPpkg_crime 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.crime
SetOutPath $INSTDIR\pkg\crime
File /r gap4r5\pkg\crime\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Cubefree
#
Section "Cubefree" SecGAPpkg_cubefree 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.cubefree
SetOutPath $INSTDIR\pkg\cubefree
File /r gap4r5\pkg\cubefree\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# cvec
#
Section "cvec" SecGAPpkg_cvec 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.cvec
SetOutPath $INSTDIR\pkg\cvec
File /r gap4r5\pkg\cvec\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# EDIM
#
Section "EDIM" SecGAPpkg_edim 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.edim
SetOutPath $INSTDIR\pkg\edim
File /r gap4r5\pkg\edim\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# ExamplesForHomalg
#
Section "ExamplesForHomalg" SecGAPpkg_examplesforhomalg 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.examplesforhomalg
SetOutPath $INSTDIR\pkg\ExamplesForHomalg
File /r gap4r5\pkg\ExamplesForHomalg\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# FORMAT
#
Section "FORMAT" SecGAPpkg_format 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.format
SetOutPath $INSTDIR\pkg\format
File /r gap4r5\pkg\format\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Forms
#
Section "Forms" SecGAPpkg_forms 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.forms
SetOutPath $INSTDIR\pkg\forms
File /r gap4r5\pkg\forms\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# FR
#
Section "FR" SecGAPpkg_fr 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.fr
SetOutPath $INSTDIR\pkg\fr
File /r gap4r5\pkg\fr\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# GBNP
#
Section "GBNP" SecGAPpkg_gbnp 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.gbnp
SetOutPath $INSTDIR\pkg\gbnp
File /r gap4r5\pkg\gbnp\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# genss
#
Section "genss" SecGAPpkg_genss 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.genss
SetOutPath $INSTDIR\pkg\genss
File /r gap4r5\pkg\genss\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# gpd
#
Section "gpd" SecGAPpkg_gpd 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.gpd
SetOutPath $INSTDIR\pkg\gpd-1.14
File /r gap4r5\pkg\gpd-1.14\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# GradedModules
#
Section "GradedModules" SecGAPpkg_gradedmodules 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.gradedmodules
SetOutPath $INSTDIR\pkg\GradedModules
File /r gap4r5\pkg\GradedModules\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# GradedRingForHomalg
#
Section "GradedRingForHomalg" SecGAPpkg_gradedringforhomalg 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.gradedringforhomalg
SetOutPath $INSTDIR\pkg\GradedRingForHomalg
File /r gap4r5\pkg\GradedRingForHomalg\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# GrpConst
#
Section "GrpConst" SecGAPpkg_grpconst 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.grpconst
SetOutPath $INSTDIR\pkg\grpconst
File /r gap4r5\pkg\grpconst\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Guarana
#
Section "Guarana" SecGAPpkg_guarana 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.guarana
SetOutPath $INSTDIR\pkg\guarana
File /r gap4r5\pkg\guarana\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# HAP
#
Section "HAP" SecGAPpkg_hap 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.hap
SetOutPath $INSTDIR\pkg\Hap1.10
File /r gap4r5\pkg\Hap1.10\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# HAPcryst
#
Section "HAPcryst" SecGAPpkg_hapcryst 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.hapcryst
SetOutPath $INSTDIR\pkg\HAPcryst
File /r gap4r5\pkg\HAPcryst\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# HAPprime
#
Section "HAPprime" SecGAPpkg_happrime 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.happrime
SetOutPath $INSTDIR\pkg\happrime
File /r gap4r5\pkg\happrime\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# hecke
#
Section "hecke" SecGAPpkg_hecke 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.hecke
SetOutPath $INSTDIR\pkg\hecke
File /r gap4r5\pkg\hecke\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# homalg
#
Section "homalg" SecGAPpkg_homalg 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.homalg
SetOutPath $INSTDIR\pkg\homalg
File /r gap4r5\pkg\homalg\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# HomalgToCAS
#
Section "HomalgToCAS" SecGAPpkg_homalgtocas 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.homalgtocas
SetOutPath $INSTDIR\pkg\HomalgToCAS
File /r gap4r5\pkg\HomalgToCAS\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# idrel
#
Section "idrel" SecGAPpkg_idrel 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.idrel
SetOutPath $INSTDIR\pkg\idrel-2.12
File /r gap4r5\pkg\idrel-2.12\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# IO_ForHomalg
#
Section "IO_ForHomalg" SecGAPpkg_io_forhomalg 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.io_forhomalg
SetOutPath $INSTDIR\pkg\IO_ForHomalg
File /r gap4r5\pkg\IO_ForHomalg\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# kan
#
Section "kan" SecGAPpkg_kan 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.kan
SetOutPath $INSTDIR\pkg\kan-1.05
File /r gap4r5\pkg\kan-1.05\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# liealgdb
#
Section "liealgdb" SecGAPpkg_liealgdb 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.liealgdb
SetOutPath $INSTDIR\pkg\liealgdb
File /r gap4r5\pkg\liealgdb\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# LocalizeRingForHomalg
#
Section "LocalizeRingForHomalg" SecGAPpkg_localizeringforhomalg 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.localizeringforhomalg
SetOutPath $INSTDIR\pkg\LocalizeRingForHomalg
File /r gap4r5\pkg\LocalizeRingForHomalg\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# loops
#
Section "loops" SecGAPpkg_loops 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.loops
SetOutPath $INSTDIR\pkg\loops
File /r gap4r5\pkg\loops\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# MapClass
#
Section "MapClass" SecGAPpkg_mapclass 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.mapclass
SetOutPath $INSTDIR\pkg\mapclass
File /r gap4r5\pkg\mapclass\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# MatricesForHomalg
#
Section "MatricesForHomalg" SecGAPpkg_matricesforhomalg 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.matricesforhomalg
SetOutPath $INSTDIR\pkg\MatricesForHomalg
File /r gap4r5\pkg\MatricesForHomalg\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Modules
#
Section "Modules" SecGAPpkg_modules 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.modules
SetOutPath $INSTDIR\pkg\Modules
File /r gap4r5\pkg\Modules\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Nilmat
#
Section "Nilmat" SecGAPpkg_nilmat 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.nilmat
SetOutPath $INSTDIR\pkg\nilmat
File /r gap4r5\pkg\nilmat\*.* 
SetOutPath $INSTDIR 
SectionEnd 


#######################################################################
#
# NumericalSgps
#
Section "NumericalSgps" SecGAPpkg_numericalsgps 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.numericalsgps
SetOutPath $INSTDIR\pkg\numericalsgps
File /r gap4r5\pkg\numericalsgps\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# OpenMath
#
Section "OpenMath" SecGAPpkg_openmath 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.openmath
SetOutPath $INSTDIR\pkg\openmath
File /r gap4r5\pkg\openmath\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# orb
#
Section "orb" SecGAPpkg_orb 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.orb
SetOutPath $INSTDIR\pkg\orb
File /r gap4r5\pkg\orb\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# polymaking
#
Section "polymaking" SecGAPpkg_polymaking 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.polymaking
SetOutPath $INSTDIR\pkg\polymaking
File /r gap4r5\pkg\polymaking\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# qaos
#
Section "qaos" SecGAPpkg_qaos 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.qaos
SetOutPath $INSTDIR\pkg\qaos
File /r gap4r5\pkg\qaos\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# QuaGroup
#
Section "QuaGroup" SecGAPpkg_quagroup 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.quagroup
SetOutPath $INSTDIR\pkg\quagroup
File /r gap4r5\pkg\quagroup\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# RCWA
#
Section "RCWA" SecGAPpkg_rcwa 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.rcwa
SetOutPath $INSTDIR\pkg\rcwa
File /r gap4r5\pkg\rcwa\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# RDS
#
Section "RDS" SecGAPpkg_rds 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.rds
SetOutPath $INSTDIR\pkg\rds
File /r gap4r5\pkg\rds\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# recog
#
Section "recog" SecGAPpkg_recog 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.recog
SetOutPath $INSTDIR\pkg\recog
File /r gap4r5\pkg\recog\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# recogbase
#
Section "recogbase" SecGAPpkg_recogbase 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.recogbase
SetOutPath $INSTDIR\pkg\recogbase
File /r gap4r5\pkg\recogbase\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Repsn
#
Section "Repsn" SecGAPpkg_repsn 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.repsn
SetOutPath $INSTDIR\pkg\repsn
File /r gap4r5\pkg\repsn\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# RingsForHomalg
#
Section "RingsForHomalg" SecGAPpkg_ringsforhomalg 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.ringsforhomalg
SetOutPath $INSTDIR\pkg\RingsForHomalg
File /r gap4r5\pkg\RingsForHomalg\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# SCO
#
Section "SCO" SecGAPpkg_sco 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.sco
SetOutPath $INSTDIR\pkg\SCO
File /r gap4r5\pkg\SCO\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# SCSCP
#
Section "SCSCP" SecGAPpkg_scscp 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.scscp
SetOutPath $INSTDIR\pkg\scscp
File /r gap4r5\pkg\scscp\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# SgpViz
#
Section "SgpViz" SecGAPpkg_sgpviz 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.sgpviz
SetOutPath $INSTDIR\pkg\sgpviz
File /r gap4r5\pkg\sgpviz\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# simpcomp
#
Section "simpcomp" SecGAPpkg_simpcomp 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.simpcomp
SetOutPath $INSTDIR\pkg\simpcomp
File /r gap4r5\pkg\simpcomp\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# singular
#
Section "singular" SecGAPpkg_singular 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.singular
SetOutPath $INSTDIR\pkg\singular
File /r gap4r5\pkg\singular\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Smallsemi
#
Section "Smallsemi" SecGAPpkg_smallsemi 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.smallsemi
SetOutPath $INSTDIR\pkg\smallsemi-0.6.5
File /r gap4r5\pkg\smallsemi-0.6.5\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# SymbCompCC
#
Section "SymbCompCC" SecGAPpkg_symbcompcc 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.symbcompcc
SetOutPath $INSTDIR\pkg\SymbCompCC-1.2
File /r gap4r5\pkg\SymbCompCC-1.2\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# toric
#
Section "toric" SecGAPpkg_toric 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.toric
SetOutPath $INSTDIR\pkg\toric1.8
File /r gap4r5\pkg\toric1.8\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# unipot
#
Section "unipot" SecGAPpkg_unipot 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.unipot
SetOutPath $INSTDIR\pkg\unipot-1.2
File /r gap4r5\pkg\unipot-1.2\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# UnitLib
#
Section "UnitLib" SecGAPpkg_unitlib 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.unitlib
SetOutPath $INSTDIR\pkg\unitlib
File /r gap4r5\pkg\unitlib\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Wedderga
#
Section "Wedderga" SecGAPpkg_wedderga 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.wedderga
SetOutPath $INSTDIR\pkg\wedderga
File /r gap4r5\pkg\wedderga\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# XMod
#
Section "XMod" SecGAPpkg_xmod 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.xmod
SetOutPath $INSTDIR\pkg\xmod-2.18
File /r gap4r5\pkg\xmod-2.18\*.* 
SetOutPath $INSTDIR 
SectionEnd 

SectionGroupEnd 
# Specialised packages end here

#######################################################################
#
# Packages that do not work under Windows
#
SectionGroup "Packages requiring UNIX/Linux" SecGAPpkgsNoWindows

#######################################################################
#
# ACE
#
Section "ACE" SecGAPpkg_ace 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.ace
SetOutPath $INSTDIR\pkg\ace
File /r gap4r5\pkg\ace\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# ANUPQ
#
Section "ANUPQ" SecGAPpkg_anupq 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.anupq
SetOutPath $INSTDIR\pkg\anupq
File /r gap4r5\pkg\anupq\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Carat
#
Section "Carat" SecGAPpkg_carat 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.carat
SetOutPath $INSTDIR\pkg\carat
File /r gap4r5\pkg\carat\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# cohomolo
#
Section "cohomolo" SecGAPpkg_cohomolo 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.cohomolo
SetOutPath $INSTDIR\pkg\cohomolo
File /r gap4r5\pkg\cohomolo\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# FPLSA
#
Section "FPLSA" SecGAPpkg_fplsa 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.fplsa
SetOutPath $INSTDIR\pkg\fplsa
File /r gap4r5\pkg\fplsa\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# fwtree
#
Section "fwtree" SecGAPpkg_fwtree 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.fwtree
SetOutPath $INSTDIR\pkg\fwtree
File /r gap4r5\pkg\fwtree\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# Gauss
#
Section "Gauss" SecGAPpkg_gauss 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.gauss
SetOutPath $INSTDIR\pkg\Gauss
File /r gap4r5\pkg\Gauss\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# GaussForHomalg
#
Section "GaussForHomalg" SecGAPpkg_gaussforhomalg 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.gaussforhomalg
SetOutPath $INSTDIR\pkg\GaussForHomalg
File /r gap4r5\pkg\GaussForHomalg\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# ITC
#
Section "ITC" SecGAPpkg_itc 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.itc
SetOutPath $INSTDIR\pkg\itc
File /r gap4r5\pkg\itc\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# kbmag
#
Section "kbmag" SecGAPpkg_kbmag 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.kbmag
SetOutPath $INSTDIR\pkg\kbmag
File /r gap4r5\pkg\kbmag\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# linboxing
#
Section "linboxing" SecGAPpkg_linboxing 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.linboxing
SetOutPath $INSTDIR\pkg\linboxing
File /r gap4r5\pkg\linboxing\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# nq
#
Section "nq" SecGAPpkg_nq 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.nq
SetOutPath $INSTDIR\pkg\nq-2.4
File /r gap4r5\pkg\nq-2.4\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# ParGAP
#
Section "ParGAP" SecGAPpkg_pargap 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.pargap
SetOutPath $INSTDIR\pkg\pargap
File /r gap4r5\pkg\pargap\*.* 
SetOutPath $INSTDIR 
SectionEnd 

#######################################################################
#
# XGAP
#
Section "XGAP" SecGAPpkg_xgap 
SetOutPath $INSTDIR\pkg 
File gap4r5\pkg\README.xgap
SetOutPath $INSTDIR\pkg\xgap
File /r gap4r5\pkg\xgap\*.* 
SetOutPath $INSTDIR 
SectionEnd 

SectionGroupEnd 
# Packages that do not work under Windows end here


#######################################################################
# Descriptions

# Language strings
LangString DESC_SecGAPcore ${LANG_ENGLISH} "The core GAP system (GAP kernel, GAP library, data libraries, manuals and tests)"

LangString DESC_SecGAPpkgsNeeded ${LANG_ENGLISH} "Packages needed to run GAP (in addition to these we advise to install also at least all default packages, some of which extend the GAP functionality quite substantially)"
LangString DESC_SecGAPpkgsDefault ${LANG_ENGLISH} "Default packages (loaded by default when GAP starts), and a selection of other packages and data libraries. We advise to select the whole group since dependencies between individual packages are not traced"
LangString DESC_SecGAPpkgsSpecial ${LANG_ENGLISH} "Optional packages (some of these are for an expert installation; we advise to select the whole group since dependencies between individual packages are not traced)"
LangString DESC_SecGAPpkgsNoWindows ${LANG_ENGLISH} "Packages that do not work under Windows (install them if you wish to be able to access their code and documentation)"

LangString DESC_SecGAPpkg_ace ${LANG_ENGLISH} "Advanced Coset Enumerator"
LangString DESC_SecGAPpkg_aclib ${LANG_ENGLISH} "Almost Crystallographic Groups - A Library and Algorithms"
LangString DESC_SecGAPpkg_alnuth ${LANG_ENGLISH} "Algebraic number theory and an interface to PARI/GP"
LangString DESC_SecGAPpkg_anupq ${LANG_ENGLISH} "ANU p-Quotient"
LangString DESC_SecGAPpkg_atlasrep ${LANG_ENGLISH} "A GAP Interface to the Atlas of Group Representations"
LangString DESC_SecGAPpkg_automata ${LANG_ENGLISH} "A package on automata"
LangString DESC_SecGAPpkg_automgrp ${LANG_ENGLISH} "Automata groups"
LangString DESC_SecGAPpkg_autpgrp ${LANG_ENGLISH} "Computing the Automorphism Group of a p-Group"
LangString DESC_SecGAPpkg_browse ${LANG_ENGLISH} "browsing applications and ncurses interface"
LangString DESC_SecGAPpkg_carat ${LANG_ENGLISH} "Interface to CARAT, a crystallographic groups package"
LangString DESC_SecGAPpkg_circle ${LANG_ENGLISH} "Adjoint groups of finite rings"
LangString DESC_SecGAPpkg_citrus ${LANG_ENGLISH} "ComputIng wiTh semigRoUps and monoidS"
LangString DESC_SecGAPpkg_cohomolo ${LANG_ENGLISH} "Cohomology groups of finite groups on finite modules"
LangString DESC_SecGAPpkg_crime ${LANG_ENGLISH} "A GAP Package to Calculate Group Cohomology and Massey Products"
LangString DESC_SecGAPpkg_crisp ${LANG_ENGLISH} "Computing with Radicals, Injectors, Schunck classes and Projectors"
LangString DESC_SecGAPpkg_cryst ${LANG_ENGLISH} "Computing with crystallographic groups"
LangString DESC_SecGAPpkg_crystcat ${LANG_ENGLISH} "The crystallographic groups catalog"
LangString DESC_SecGAPpkg_ctbllib ${LANG_ENGLISH} "The GAP Character Table Library"
LangString DESC_SecGAPpkg_cubefree ${LANG_ENGLISH} "Constructing the Groups of a Given Cubefree Order"
LangString DESC_SecGAPpkg_cvec ${LANG_ENGLISH} "Compact vectors over finite fields"
LangString DESC_SecGAPpkg_design ${LANG_ENGLISH} "The Design Package for GAP"
LangString DESC_SecGAPpkg_edim ${LANG_ENGLISH} "Elementary Divisors of Integer Matrices"
LangString DESC_SecGAPpkg_example ${LANG_ENGLISH} "Example/Template of a GAP Package and Guidelines for Package Authors"
LangString DESC_SecGAPpkg_examplesforhomalg ${LANG_ENGLISH} "Examples for the GAP Package homalg"
LangString DESC_SecGAPpkg_factint ${LANG_ENGLISH} "Advanced Methods for Factoring Integers"
LangString DESC_SecGAPpkg_fga ${LANG_ENGLISH} "Free Group Algorithms"
LangString DESC_SecGAPpkg_format ${LANG_ENGLISH} "Computing with formations of finite solvable groups."
LangString DESC_SecGAPpkg_forms ${LANG_ENGLISH} "Sesquilinear and Quadratic"
LangString DESC_SecGAPpkg_fplsa ${LANG_ENGLISH} "Finitely Presented Lie Algebras"
LangString DESC_SecGAPpkg_fr ${LANG_ENGLISH} "Computations with functionally recursive groups"
LangString DESC_SecGAPpkg_fwtree ${LANG_ENGLISH} "Computing trees related to some pro-p-groups of finite width"
LangString DESC_SecGAPpkg_gapdoc ${LANG_ENGLISH} "A Meta Package for GAP Documentation"
LangString DESC_SecGAPpkg_gauss ${LANG_ENGLISH} "Gauss - Extended Gauss Functionality for GAP"
LangString DESC_SecGAPpkg_gaussforhomalg ${LANG_ENGLISH} "GaussForHomalg - Gauss Functionality for homalg"
LangString DESC_SecGAPpkg_gbnp ${LANG_ENGLISH} "computing Gröbner bases of noncommutative polynomials"
LangString DESC_SecGAPpkg_genss ${LANG_ENGLISH} "genss - generic Schreier-Sims"
LangString DESC_SecGAPpkg_gpd ${LANG_ENGLISH} "Groupoids, graphs of groups, and graphs of groupoids"
LangString DESC_SecGAPpkg_gradedmodules ${LANG_ENGLISH} "A homalg based package for the Abelian category of finitely presented graded modules over a computable graded ring"
LangString DESC_SecGAPpkg_gradedringforhomalg ${LANG_ENGLISH} "Endow Commutative Rings with an Abelian Grading"
LangString DESC_SecGAPpkg_grape ${LANG_ENGLISH} "GRaph Algorithms using PErmutation groups"
LangString DESC_SecGAPpkg_grpconst ${LANG_ENGLISH} "Constructing the Groups of a Given Order"
LangString DESC_SecGAPpkg_guarana ${LANG_ENGLISH} "Applications of Lie methods for computations with infinite polycyclic  groups"
LangString DESC_SecGAPpkg_guava ${LANG_ENGLISH} "a GAP package for computing with error-correcting codes"
LangString DESC_SecGAPpkg_hap ${LANG_ENGLISH} "Homological Algebra Programming"
LangString DESC_SecGAPpkg_hapcryst ${LANG_ENGLISH} "A HAP extension for crytallographic groups"
LangString DESC_SecGAPpkg_happrime ${LANG_ENGLISH} "a HAP extension for small prime power groups"
LangString DESC_SecGAPpkg_hecke ${LANG_ENGLISH} "Hecke - Specht 2.4 ported to GAP 4"
LangString DESC_SecGAPpkg_homalg ${LANG_ENGLISH} "A homological algebra meta-package for computable Abelian categories"
LangString DESC_SecGAPpkg_homalgtocas ${LANG_ENGLISH} "A window to the outer world"
LangString DESC_SecGAPpkg_idrel ${LANG_ENGLISH} "Identities among relations"
LangString DESC_SecGAPpkg_io ${LANG_ENGLISH} "Bindings for low level C library IO"
LangString DESC_SecGAPpkg_io_forhomalg ${LANG_ENGLISH} "IO Capabilities for the homalg Project"
LangString DESC_SecGAPpkg_irredsol ${LANG_ENGLISH} "A Library of irreducible solvable linear groups over finite fields           and of finite primivite soluble groups"
LangString DESC_SecGAPpkg_itc ${LANG_ENGLISH} "Interactive Todd-Coxeter"
LangString DESC_SecGAPpkg_kan ${LANG_ENGLISH} "including double coset rewriting systems"
LangString DESC_SecGAPpkg_kbmag ${LANG_ENGLISH} "Knuth-Bendix on Monoids and Automatic Groups"
LangString DESC_SecGAPpkg_laguna ${LANG_ENGLISH} "Lie AlGebras and UNits of group Algebras"
LangString DESC_SecGAPpkg_liealgdb ${LANG_ENGLISH} "A database of Lie algebras"
LangString DESC_SecGAPpkg_linboxing ${LANG_ENGLISH} "access to LinBox linear algebra functions from GAP"
LangString DESC_SecGAPpkg_localizeringforhomalg ${LANG_ENGLISH} "A Package for Localization of Polynomial Rings"
LangString DESC_SecGAPpkg_loops ${LANG_ENGLISH} "Computing with quasigroups and loops in GAP"
LangString DESC_SecGAPpkg_mapclass ${LANG_ENGLISH} "A Package For Mapping Class Orbit Computation"
LangString DESC_SecGAPpkg_matricesforhomalg ${LANG_ENGLISH} "Matrices for the homalg project"
LangString DESC_SecGAPpkg_modules ${LANG_ENGLISH} "A homalg based Package for the Abelian Category of Finitely Presented Modules over Computable Rings"
LangString DESC_SecGAPpkg_nilmat ${LANG_ENGLISH} "Computing with nilpotent matrix groups"
LangString DESC_SecGAPpkg_nq ${LANG_ENGLISH} "Nilpotent Quotients of Finitely Presented Groups"
LangString DESC_SecGAPpkg_numericalsgps ${LANG_ENGLISH} "A package for numerical semigroups"
LangString DESC_SecGAPpkg_openmath ${LANG_ENGLISH} "OpenMath functionality in GAP"
LangString DESC_SecGAPpkg_orb ${LANG_ENGLISH} "orb - Methods to enumerate Orbits"
LangString DESC_SecGAPpkg_pargap ${LANG_ENGLISH} "Parallel GAP"
LangString DESC_SecGAPpkg_polenta ${LANG_ENGLISH} "Polycyclic presentations for matrix groups"
LangString DESC_SecGAPpkg_polycyclic ${LANG_ENGLISH} "Computation with polycyclic groups"
LangString DESC_SecGAPpkg_polymaking ${LANG_ENGLISH} "Interfacing the geometry software polymake"
LangString DESC_SecGAPpkg_qaos ${LANG_ENGLISH} "Interfacing the QaoS database from GAP"
LangString DESC_SecGAPpkg_quagroup ${LANG_ENGLISH} "a package for doing computations with quantum groups"
LangString DESC_SecGAPpkg_radiroot ${LANG_ENGLISH} "Roots of a Polynomial as Radicals"
LangString DESC_SecGAPpkg_rcwa ${LANG_ENGLISH} "Residue-Class-Wise Affine Groups"
LangString DESC_SecGAPpkg_rds ${LANG_ENGLISH} "A package for searching relative difference sets"
LangString DESC_SecGAPpkg_recog ${LANG_ENGLISH} "A collection of group recognition methods"
LangString DESC_SecGAPpkg_recogbase ${LANG_ENGLISH} "A framework for group recognition"
LangString DESC_SecGAPpkg_repsn ${LANG_ENGLISH} "A GAP4 Package for constructing representations of finite groups"
LangString DESC_SecGAPpkg_resclasses ${LANG_ENGLISH} "Set-Theoretic Computations with Residue Classes"
LangString DESC_SecGAPpkg_ringsforhomalg ${LANG_ENGLISH} "Dictionaries of External Rings"
LangString DESC_SecGAPpkg_sco ${LANG_ENGLISH} "SCO - Simplicial Cohomology of Orbifolds"
LangString DESC_SecGAPpkg_scscp ${LANG_ENGLISH} "Symbolic Computation Software Composability Protocol in GAP"
LangString DESC_SecGAPpkg_sgpviz ${LANG_ENGLISH} "A package for semigroup visualization"
LangString DESC_SecGAPpkg_simpcomp ${LANG_ENGLISH} "A GAP toolbox for simplicial complexes"
LangString DESC_SecGAPpkg_singular ${LANG_ENGLISH} "The GAP interface to Singular"
LangString DESC_SecGAPpkg_smallsemi ${LANG_ENGLISH} "A library of small semigroups"
LangString DESC_SecGAPpkg_sonata ${LANG_ENGLISH} "System of nearrings and their applications"
LangString DESC_SecGAPpkg_sophus ${LANG_ENGLISH} "Computing in nilpotent Lie algebras"
LangString DESC_SecGAPpkg_symbcompcc ${LANG_ENGLISH} "Computing with parametrised presentations for p-groups of fixed coclass"
LangString DESC_SecGAPpkg_tomlib ${LANG_ENGLISH} "The GAP Library of Tables of Marks"
LangString DESC_SecGAPpkg_toric ${LANG_ENGLISH} "toric varieties and some combinatorial geometry computations"
LangString DESC_SecGAPpkg_unipot ${LANG_ENGLISH} "Computing with elements of unipotent subgroups of Chevalley groups"
LangString DESC_SecGAPpkg_unitlib ${LANG_ENGLISH} "Library of normalized unit groups of modular group algebras"
LangString DESC_SecGAPpkg_wedderga ${LANG_ENGLISH} "Wedderburn Decomposition of Group Algebras"
LangString DESC_SecGAPpkg_xgap ${LANG_ENGLISH} "a graphical user interface for GAP"
LangString DESC_SecGAPpkg_xmod ${LANG_ENGLISH} "Crossed Modules and Cat1-Groups"

# Assign language strings to sections
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPcore} $(DESC_SecGAPcore)

!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkgsNeeded} $(DESC_SecGAPpkgsNeeded)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkgsDefault} $(DESC_SecGAPpkgsDefault)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkgsSpecial} $(DESC_SecGAPpkgsSpecial)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkgsNoWindows} $(DESC_SecGAPpkgsNoWindows)

!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_ace} $(DESC_SecGAPpkg_ace)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_aclib} $(DESC_SecGAPpkg_aclib)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_alnuth} $(DESC_SecGAPpkg_alnuth)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_anupq} $(DESC_SecGAPpkg_anupq)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_atlasrep} $(DESC_SecGAPpkg_atlasrep)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_automata} $(DESC_SecGAPpkg_automata)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_automgrp} $(DESC_SecGAPpkg_automgrp)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_autpgrp} $(DESC_SecGAPpkg_autpgrp)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_browse} $(DESC_SecGAPpkg_browse)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_carat} $(DESC_SecGAPpkg_carat)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_circle} $(DESC_SecGAPpkg_circle)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_citrus} $(DESC_SecGAPpkg_citrus)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_cohomolo} $(DESC_SecGAPpkg_cohomolo)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_crime} $(DESC_SecGAPpkg_crime)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_crisp} $(DESC_SecGAPpkg_crisp)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_cryst} $(DESC_SecGAPpkg_cryst)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_crystcat} $(DESC_SecGAPpkg_crystcat)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_ctbllib} $(DESC_SecGAPpkg_ctbllib)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_cubefree} $(DESC_SecGAPpkg_cubefree)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_cvec} $(DESC_SecGAPpkg_cvec)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_design} $(DESC_SecGAPpkg_design)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_edim} $(DESC_SecGAPpkg_edim)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_example} $(DESC_SecGAPpkg_example)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_examplesforhomalg} $(DESC_SecGAPpkg_examplesforhomalg)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_factint} $(DESC_SecGAPpkg_factint)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_fga} $(DESC_SecGAPpkg_fga)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_format} $(DESC_SecGAPpkg_format)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_forms} $(DESC_SecGAPpkg_forms)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_fplsa} $(DESC_SecGAPpkg_fplsa)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_fr} $(DESC_SecGAPpkg_fr)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_fwtree} $(DESC_SecGAPpkg_fwtree)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_gapdoc} $(DESC_SecGAPpkg_gapdoc)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_gauss} $(DESC_SecGAPpkg_gauss)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_gaussforhomalg} $(DESC_SecGAPpkg_gaussforhomalg)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_gbnp} $(DESC_SecGAPpkg_gbnp)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_genss} $(DESC_SecGAPpkg_genss)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_gpd} $(DESC_SecGAPpkg_gpd)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_gradedmodules} $(DESC_SecGAPpkg_gradedmodules)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_gradedringforhomalg} $(DESC_SecGAPpkg_gradedringforhomalg)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_grape} $(DESC_SecGAPpkg_grape)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_grpconst} $(DESC_SecGAPpkg_grpconst)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_guarana} $(DESC_SecGAPpkg_guarana)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_guava} $(DESC_SecGAPpkg_guava)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_hap} $(DESC_SecGAPpkg_hap)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_hapcryst} $(DESC_SecGAPpkg_hapcryst)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_happrime} $(DESC_SecGAPpkg_happrime)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_hecke} $(DESC_SecGAPpkg_hecke)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_homalg} $(DESC_SecGAPpkg_homalg)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_homalgtocas} $(DESC_SecGAPpkg_homalgtocas)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_idrel} $(DESC_SecGAPpkg_idrel)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_io} $(DESC_SecGAPpkg_io)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_io_forhomalg} $(DESC_SecGAPpkg_io_forhomalg)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_irredsol} $(DESC_SecGAPpkg_irredsol)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_itc} $(DESC_SecGAPpkg_itc)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_kan} $(DESC_SecGAPpkg_kan)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_kbmag} $(DESC_SecGAPpkg_kbmag)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_laguna} $(DESC_SecGAPpkg_laguna)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_liealgdb} $(DESC_SecGAPpkg_liealgdb)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_linboxing} $(DESC_SecGAPpkg_linboxing)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_localizeringforhomalg} $(DESC_SecGAPpkg_localizeringforhomalg)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_loops} $(DESC_SecGAPpkg_loops)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_mapclass} $(DESC_SecGAPpkg_mapclass)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_matricesforhomalg} $(DESC_SecGAPpkg_matricesforhomalg)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_modules} $(DESC_SecGAPpkg_modules)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_nilmat} $(DESC_SecGAPpkg_nilmat)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_nq} $(DESC_SecGAPpkg_nq)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_numericalsgps} $(DESC_SecGAPpkg_numericalsgps)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_openmath} $(DESC_SecGAPpkg_openmath)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_orb} $(DESC_SecGAPpkg_orb)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_pargap} $(DESC_SecGAPpkg_pargap)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_polenta} $(DESC_SecGAPpkg_polenta)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_polycyclic} $(DESC_SecGAPpkg_polycyclic)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_polymaking} $(DESC_SecGAPpkg_polymaking)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_qaos} $(DESC_SecGAPpkg_qaos)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_quagroup} $(DESC_SecGAPpkg_quagroup)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_radiroot} $(DESC_SecGAPpkg_radiroot)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_rcwa} $(DESC_SecGAPpkg_rcwa)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_rds} $(DESC_SecGAPpkg_rds)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_recog} $(DESC_SecGAPpkg_recog)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_recogbase} $(DESC_SecGAPpkg_recogbase)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_repsn} $(DESC_SecGAPpkg_repsn)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_resclasses} $(DESC_SecGAPpkg_resclasses)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_ringsforhomalg} $(DESC_SecGAPpkg_ringsforhomalg)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_sco} $(DESC_SecGAPpkg_sco)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_scscp} $(DESC_SecGAPpkg_scscp)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_sgpviz} $(DESC_SecGAPpkg_sgpviz)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_simpcomp} $(DESC_SecGAPpkg_simpcomp)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_singular} $(DESC_SecGAPpkg_singular)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_smallsemi} $(DESC_SecGAPpkg_smallsemi)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_sonata} $(DESC_SecGAPpkg_sonata)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_sophus} $(DESC_SecGAPpkg_sophus)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_symbcompcc} $(DESC_SecGAPpkg_symbcompcc)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_tomlib} $(DESC_SecGAPpkg_tomlib)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_toric} $(DESC_SecGAPpkg_toric)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_unipot} $(DESC_SecGAPpkg_unipot)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_unitlib} $(DESC_SecGAPpkg_unitlib)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_wedderga} $(DESC_SecGAPpkg_wedderga)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_xgap} $(DESC_SecGAPpkg_xgap)
!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_xmod} $(DESC_SecGAPpkg_xmod)

!insertmacro MUI_FUNCTION_DESCRIPTION_END


#######################################################################
#
# Make impossible installing special packages without default packages
#
Function .onInit
 
  # This is necessary otherwise Sec3 won't be selectable for the first time you click it.
  SectionGetFlags ${SecGAPpkgsDefault} $R0
  IntOp $R0 $R0 & ${SF_SELECTED}
  StrCpy $IndependentSectionState $R0
 
FunctionEnd
 
Function .onSelChange
Push $R0
Push $R1
 
  # Check if SecGAPpkgsDefault was just selected then select SecGAPpkgsSpecial
  SectionGetFlags ${SecGAPpkgsDefault} $R0
  IntOp $R0 $R0 & ${SF_SELECTED}
  StrCmp $R0 $IndependentSectionState +3
    StrCpy $IndependentSectionState $R0
  Goto UnselectDependentSections
    StrCpy $IndependentSectionState $R0
 
  Goto CheckDependentSections
 
  # Select SecGAPpkgsDefault if SecGAPpkgsSpecial was selected.
  SelectIndependentSection:
 
    SectionGetFlags ${SecGAPpkgsDefault} $R0
    IntOp $R1 $R0 & ${SF_SELECTED}
    StrCmp $R1 ${SF_SELECTED} +3
 
    IntOp $R0 $R0 | ${SF_SELECTED}
    SectionSetFlags ${SecGAPpkgsDefault} $R0
 
    StrCpy $IndependentSectionState ${SF_SELECTED}
 
  Goto End
 
  # Were SecGAPpkgsSpecial just unselected?
  CheckDependentSections:
 
  SectionGetFlags ${SecGAPpkgsSpecial} $R0
  IntOp $R0 $R0 & ${SF_SELECTED}
  StrCmp $R0 ${SF_SELECTED} SelectIndependentSection
  
  Goto End
 
  # Unselect SecGAPpkgsSpecial if SecGAPpkgsDefault was unselected.
  UnselectDependentSections:
 
    SectionGetFlags ${SecGAPpkgsSpecial} $R0
    IntOp $R1 $R0 & ${SF_SELECTED}
    StrCmp $R1 ${SF_SELECTED} 0 +3
 
    IntOp $R0 $R0 ^ ${SF_SELECTED}
    SectionSetFlags ${SecGAPpkgsSpecial} $R0
 
  End:
 
Pop $R1
Pop $R0
FunctionEnd


#######################################################################
#
# Uninstaller Section
#
Section "Uninstall"

  RMDir /r "$INSTDIR"

  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
  Delete "$SMPROGRAMS\$StartMenuFolder\*.*"
  RMDir /r "$SMPROGRAMS\$StartMenuFolder"

  DeleteRegKey /ifempty HKCU "Software\GAP"

SectionEnd