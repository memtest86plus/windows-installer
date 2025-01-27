; Memtest 86+ USB Installer (v6+) by Samuel DEMEULEMEESTER, adapted from original
; Memtest 86+ USB Installer (v5 and previous) created by Lance http://www.pendrivelinux.com
; Syslinux 1994-2014 H. Peter Anvin https://wiki.syslinux.org/ (unmodified binary used)
; Memtest86+ 2004-2025 https://memtest.org (unmodified binary image used)
; NSIS Installer 1995-2022 Contributors https://nsis.sourceforge.io/
; You need to install NSIS to compile this script.

!define VERSION "8.00"
!define NAME "Memtest86+ ${VERSION} USB Installer"
!define DISTRO "Memtest86+ Boot Files"
!define FILENAME "MT86Plus USB Installer"
!define MUI_ICON "mt86plus.ico"

Unicode True
RequestExecutionLevel highest
SetCompressor /SOLID LZMA
CRCCheck On
XPStyle On
ShowInstDetails show
BrandingText "Memtest86+ ${VERSION} USB Installer https://memtest.org/"
CompletedText "Installation Done, Your USB Drive should be able to boot on CSM or UEFI 32/64 bits!"
InstallButtonText Create

Name "${NAME}"
OutFile "${FILENAME}.exe"

!include "MUI2.nsh"
!include "FileFunc.nsh"

; Interface settings
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "mt86plus-logo.bmp"
!define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
!define MUI_HEADERIMAGE_RIGHT

; License page
!define MUI_TEXT_LICENSE_SUBTITLE $(License_Subtitle)
!define MUI_LICENSEPAGE_TEXT_TOP $(License_Text_Top)
!define MUI_LICENSEPAGE_TEXT_BOTTOM $(License_Text_Bottom)
!insertmacro MUI_PAGE_LICENSE "license.txt"

; Drive page
Var DestDriveTxt
Var DestDrive
Var DestDisk
Var LabelDrivePageText
Var LabelDriveSelect
Var Format
Var FormatMe
Var Warning
Page custom drivePage

; Instfiles page
!define MUI_INSTFILESPAGE_COLORS "00FF00 000000" ;Green and Black
!define MUI_TEXT_INSTALLING_TITLE $(Install_Title)
!define MUI_TEXT_INSTALLING_SUBTITLE $(Install_SubTitle)
!define MUI_TEXT_FINISH_SUBTITLE $(Install_Finish_Sucess)
!insertmacro MUI_PAGE_INSTFILES

; Finish page
!define MUI_FINISHPAGE_TITLE $(Finish_Title)
!define MUI_FINISHPAGE_TEXT $(Finish_Text)
!define MUI_FINISHPAGE_LINK $(Finish_Link)
!define MUI_FINISHPAGE_LINK_LOCATION "https://memtest.org/"
!insertmacro MUI_PAGE_FINISH

; Language files
!insertmacro MUI_LANGUAGE "English" ;first language is the default language

; English
LangString License_Subtitle ${LANG_ENGLISH} "Please review the license terms before running ${NAME}."
LangString License_Text_Top ${LANG_ENGLISH} "The software within this program falls under the following License."
LangString License_Text_Bottom ${LANG_ENGLISH} "You must accept the terms of this License agreement to run ${NAME}. If you agree, Click I Agree to Continue."
LangString Finish_Title ${LANG_ENGLISH} "Memtest86+ ${VERSION} installed on USB Drive."
LangString Finish_Text ${LANG_ENGLISH} "The necessary files are installed on your USB drive and the drive is now bootable.$\r$\n$\r$\nWARNING: Memtest86+ ${VERSION} is not signed by Microsoft for Secure Boot. Disable it from your BIOS options before trying to boot on this USB Drive"
LangString Finish_Link ${LANG_ENGLISH} "Visit the Official Memtest86+ Site"
LangString DrivePage_Title ${LANG_ENGLISH} "Choose USB drive location"
LangString DrivePage_Title2 ${LANG_ENGLISH} "Choose the USB drive in which to make bootable."
LangString DrivePage_Text ${LANG_ENGLISH} "Please select your USB Flash Drive and Format option. ${NAME} will proceed to make this drive Bootable and install the Memtest86+ tool on it."
LangString DrivePage_Input ${LANG_ENGLISH} "Select your USB Flash Drive"
LangString WarningPage_Text ${LANG_ENGLISH} "WARNING! All Datas on this Drive will be deleted. Any exisiting MBR WILL be overwritten. Make sure you have backed up any important content!$\r$\n$\r$\nWhen you are sure, click Create to proceed."
LangString Syslinux_Creation ${LANG_ENGLISH} "Create syslinux configuration and moving files to $DestDrive"
LangString Syslinux_Execution ${LANG_ENGLISH} "Execute syslinux on $R0"
LangString Syslinux_Warning ${LANG_ENGLISH} "An error ($R8) occurred while executing syslinux.$\r$\nYour USB drive won't be bootable..."
LangString Install_Title ${LANG_ENGLISH} "Installing ${DISTRO}"
LangString Install_SubTitle ${LANG_ENGLISH} "Please wait while ${NAME} installs ${DISTRO} on $0"
LangString Install_Finish_Sucess ${LANG_ENGLISH} "${NAME} sucessfully installed ${DISTRO} on $0"

Function drivePage
  !insertmacro MUI_HEADER_TEXT $(DrivePage_Title) $(DrivePage_Title2)
  nsDialogs::Create 1018
  ${If} $DestDrive == ""
  GetDlgItem $6 $HWNDPARENT 1 ; Get next control handle
  EnableWindow $6 0 ; disable next
  ${EndIf}
  ${NSD_CreateLabel} 0 0 100% 30 $(DrivePage_Text)
  Pop $LabelDrivePageText
  ${NSD_CreateLabel} 0 50 100% 15 $(DrivePage_Input)
  Pop $LabelDriveSelect
  ${NSD_CreateDroplist} 0 68 23% 20 ""
  Pop $DestDriveTxt
  ${NSD_OnChange} $DestDriveTxt db_select.onchange
  ${GetDrives} "FDD" driveList
  ${If} $DestDrive != ""
  ${NSD_CB_SelectString} $DestDriveTxt $DestDrive
  ${EndIf}
; Format Drive Option
  ${NSD_CreateCheckBox} 25% 68 75% 15 "Check this box if you want to format the Drive."
  Pop $Format
  ${NSD_OnClick} $Format FormatIt
; Warning Label
  ${NSD_CreateLabel} 0 120 100% 60 $(WarningPage_Text)
  Pop $Warning
  EnableWindow $Format 0
  ShowWindow $Warning 0
  GetDlgItem $6 $HWNDPARENT 3
  ShowWindow $6 0 ; Disable Back
  nsDialogs::Show
FunctionEnd

Function db_select.onchange
  Pop $DestDriveTxt
  ${NSD_GetText} $DestDriveTxt $0
  StrCpy $DestDrive "$0"
  StrCpy $DestDisk $DestDrive -1
  GetDlgItem $6 $HWNDPARENT 1 ; Get "Next" control handle
  EnableWindow $6 1 ; enable "Next" control
  EnableWindow $Format 1
  ShowWindow $Warning 1
  SetCtlColors $Warning /Branding FF0000
  Call FormatIt
FunctionEnd

Function driveList
	SendMessage $DestDriveTxt ${CB_ADDSTRING} 0 "STR:$9"
	Push 1
FunctionEnd

Function FormatIt ; Set Format Option
  ${NSD_GetState} $Format $FormatMe
  ${If} $FormatMe == ${BST_CHECKED}
  ${NSD_Check} $Format
  StrCpy $FormatMe "Yes"
  ${NSD_SetText} $Format "We will format $DestDrive as Fat32."
  ${ElseIf} $FormatMe == ${BST_UNCHECKED}
  ${NSD_Uncheck} $Format
  ${NSD_SetText} $Format "(Recommended) Check this box if you want to format Drive $DestDrive"
  ${EndIf}
FunctionEnd

Function FormatYes ; If Format is checked, do something
  ${If} $FormatMe == "Yes"
  DetailPrint "Formatting $DestDisk"
  nsExec::ExecToLog '"cmd" /c "format $DestDisk /FS:Fat32 /V:MT86PLUS /Q /y"'
  ${EndIf}
FunctionEnd

Section "Copyfiles" main
  Call FormatYes ; Format the Drive?
  InitPluginsDir
  File /oname=$PLUGINSDIR\mt86plus32 "mt86plus32"
  File /oname=$PLUGINSDIR\mt86plus64 "mt86plus64"
  File /oname=$PLUGINSDIR\mt86plusla64.efi "mt86plusla64.efi"
  File /oname=$PLUGINSDIR\Readme.txt "Readme.txt"
  File /oname=$PLUGINSDIR\license.txt "license.txt"
  File /oname=$PLUGINSDIR\syslinux.exe "syslinux.exe"
  File /oname=$PLUGINSDIR\syslinux.cfg "syslinux.cfg"
  SetShellVarContext all

; Execute syslinux on the drive
  StrCpy $R0 $DestDrive -1 ; remove \ for syslinux
  ClearErrors
  DetailPrint $(Syslinux_Execution)
   	ExecWait '$PLUGINSDIR\syslinux.exe -maf $R0' $R8
  	DetailPrint "Return $R8"
    Banner::destroy
	${If} $R8 != 0
    MessageBox MB_ICONEXCLAMATION|MB_OK $(Syslinux_Warning)
  ${EndIf}

; Create files
  Var /GLOBAL BootDir
  StrCpy $BootDir $DestDrive -1
  StrCpy $BootDir "$BootDir"

  DetailPrint $(Syslinux_Creation)
  CopyFiles "$PLUGINSDIR\syslinux.cfg" "$BootDir\syslinux.cfg"
  CopyFiles "$PLUGINSDIR\mt86plus32" "$BootDir\mt86plus"
  CopyFiles "$PLUGINSDIR\Readme.txt" "$BootDir\Readme.txt"
  CopyFiles "$PLUGINSDIR\license.txt" "$BootDir\license.txt"
  CopyFiles "$PLUGINSDIR\mt86plus32" "$BootDir\EFI\BOOT\BOOTIA32.EFI"
  CopyFiles "$PLUGINSDIR\mt86plus64" "$BootDir\EFI\BOOT\BOOTx64.EFI"
  CopyFiles "$PLUGINSDIR\mt86plusla64.efi" "$BootDir\EFI\BOOT\BOOTLOONGARCH64.efi"
SectionEnd