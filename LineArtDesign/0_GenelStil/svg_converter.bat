@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"

set "INKSCAPE=C:\Program Files\Inkscape\bin\inkscape.com"
if not exist "%INKSCAPE%" (
    set "INKSCAPE=inkscape"
    where inkscape >nul 2>&1 || (
        echo ERROR: Inkscape bulunamadi. INKSCAPE yolunu duzenleyin.
        pause
        exit /b 1
    )
)

if not "%~1"=="" (
    for %%F in ("%~1") do set "NAME=%%~nF"
) else (
    set /p "NAME=PNG dosya adi (uzantisiz): "
)
if not defined NAME (
    echo ERROR: Dosya adi bos olamaz.
    pause
    exit /b 1
)

set "PNG=%~dp0%NAME%.png"
set "SVG=%~dp0%NAME%.svg"
if not exist "%PNG%" (
    echo ERROR: PNG bulunamadi: "%PNG%"
    pause
    exit /b 1
)
if exist "%SVG%" (
    echo ERROR: SVG zaten var. Uzerine yazilmadi: "%SVG%"
    pause
    exit /b 1
)

echo Trace basliyor: "%NAME%.png"
"%INKSCAPE%" "%PNG%" --actions="select-all;object-trace:3,true,true,true,2,1,0.2;export-filename:%SVG%;export-do"
if not exist "%SVG%" (
    echo ERROR: SVG olusturulamadi. Inkscape 1.4+ ve object-trace destegi gerekli.
    pause
    exit /b 1
)

rem SVG icindeki kaynak PNG'yi kaldir; trace vektorlerini koru.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:SVG; $x=New-Object System.Xml.XmlDocument; $x.PreserveWhitespace=$true; $x.Load($p); $paths=$x.SelectNodes('//*[local-name()=''path'']'); if($paths.Count -eq 0){Write-Error 'SVG icinde vektor path bulunamadi; PNG silinmedi.'; exit 1}; $imgs=@($x.SelectNodes('//*[local-name()=''image'']')); foreach($i in $imgs){[void]$i.ParentNode.RemoveChild($i)}; $x.Save($p); Write-Host ('Temizlendi: '+$imgs.Count+' raster image')"
if errorlevel 1 (
    echo UYARI: SVG olustu ama vektor temizligi dogrulanamadi.
    pause
    exit /b 1
)
echo.
echo TAMAMLANDI: "%SVG%"
pause