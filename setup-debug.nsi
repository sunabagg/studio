; Script generated by the HM NIS Edit Script Wizard.
RequestExecutionLevel user
!define WIN64

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "Sunaba Studio"
!define PRODUCT_VERSION "0.7.0"
!define PRODUCT_PUBLISHER "sunaba.gg"
!define PRODUCT_WEB_SITE "http://www.sunaba.gg"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\SunabaStudio.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "template\sunaba.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "wizard.bmp"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "LICENSE"
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Start menu page
var ICONS_GROUP
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Sunaba"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\SunabaStudio.exe"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "bin\windows-amd64-debug-nsis\SunabaStudioSetupDebug.exe"
InstallDir "$LOCALAPPDATA\Programs\Sunaba\Studio"
InstallDirRegKey HKCU "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

!include "x64.nsh"

Section "Studio" SEC01
${If} ${RunningX64}
  SetRegView 64
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  File "bin\windows-amd64-debug\SunabaStudio.exe"
  File "bin\windows-amd64-debug\legacy.dll"
  File "bin\windows-amd64-debug\libcrypto-3-x64.dll"
  File "bin\windows-amd64-debug\libssl-3-x64.dll"
  File "bin\windows-amd64-debug\lua51.dll"
  File "bin\windows-amd64-debug\luv.dll"
  File "bin\windows-amd64-debug\sunaba-d.dll"
  File "bin\windows-amd64-debug\msvcp140.dll"
  File "bin\windows-amd64-debug\vcruntime140.dll"
  File "bin\windows-amd64-debug\mobdebug.lua"
  File "bin\windows-amd64-release\player.sbx"
  File "bin\windows-amd64-release\editor.sbx"
  File "bin\windows-amd64-release\project-manager.sbx"

  ; Associate .snbproj files with SunabaStudio.exe (per-user)
  WriteRegStr HKCU "Software\Classes\.snbproj" "" "Sunaba.Project"
  WriteRegStr HKCU "Software\Classes\Sunaba.Project" "" "Sunaba Project"
  WriteRegStr HKCU "Software\Classes\Sunaba.Project\DefaultIcon" "" "$INSTDIR\SunabaStudio.exe,0"
  WriteRegStr HKCU "Software\Classes\Sunaba.Project\shell\open\command" "" '"$INSTDIR\SunabaStudio.exe" "%1"'

  ; Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Sunaba Studio.lnk" "$INSTDIR\SunabaStudio.exe"
  CreateShortCut "$DESKTOP\Sunaba Studio.lnk" "$INSTDIR\SunabaStudio.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
${Else}
  MessageBox MB_ICONSTOP|MB_OK "This installer is for 64-bit systems only. Please install Sunaba Studio on a 64-bit system."
  Abort ; This will indicate failure and stop the install
${EndIf}
SectionEnd

Section -AdditionalIcons
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "$INSTDIR\uninst.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKCU "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\SunabaStudio.exe"
  WriteRegStr HKCU "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr HKCU "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr HKCU "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\SunabaStudio.exe"
  WriteRegStr HKCU "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr HKCU "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr HKCU "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  ; Removed system PATH modification and WM_SETTINGCHANGE notification
SectionEnd


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  !insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\editor.sbx"
  Delete "$INSTDIR\player.sbx"
  Delete "$INSTDIR\project-manager.sbx"
  Delete "$INSTDIR\mobdebug.lua"
  Delete "$INSTDIR\vcruntime140.dll"
  Delete "$INSTDIR\msvcp140.dll"
  Delete "$INSTDIR\sunaba-d.dll"
  Delete "$INSTDIR\luv.dll"
  Delete "$INSTDIR\lua51.dll"
  Delete "$INSTDIR\libssl-3-x64.dll"
  Delete "$INSTDIR\libcrypto-3-x64.dll"
  Delete "$INSTDIR\legacy.dll"
  Delete "$INSTDIR\SunabaStudio.exe"

  Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Website.lnk"
  Delete "$DESKTOP\Sunaba Studio.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Sunaba Studio.lnk"

  RMDir "$SMPROGRAMS\$ICONS_GROUP"
  RMDir "$INSTDIR"

  DeleteRegKey HKCU "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKCU "${PRODUCT_DIR_REGKEY}"

  DeleteRegKey HKCU "Software\Classes\.snbproj"
  DeleteRegKey HKCU "Software\Classes\Sunaba.Project"
  SetAutoClose true
SectionEnd