!define PRODUCT_NAME "EditImagesInExcel"
!define PRODUCT_VERSION "1.0"
!define INSTALL_DIR "$PROGRAMFILES64\\EditImagesInExcel"

OutFile "EditImagesInExcel.exe"
InstallDir ${INSTALL_DIR}

Page directory
Page instfiles

Section "MainSection"
  SetOutPath $INSTDIR
  File /r "build\windows\x64\runner\Release\*.*"
SectionEnd
