# Copia la app a una ruta ASCII (el analizador de Dart falla con la «ñ» de la ruta real) y la analiza.
robocopy "C:\dev\siscan\siscan_app" "C:\dev\siscan-build" /MIR /XD build .dart_tool .gradle capturas /NFL /NDL /NJH /NJS /NP | Out-Null
Set-Location C:\dev\siscan-build
& C:\Users\Cisna\flutter\bin\flutter.bat pub get | Out-Null
& C:\Users\Cisna\flutter\bin\flutter.bat analyze --no-fatal-infos 2>$null | Select-String -Pattern " - " | ForEach-Object { $_.Line.Trim() }
