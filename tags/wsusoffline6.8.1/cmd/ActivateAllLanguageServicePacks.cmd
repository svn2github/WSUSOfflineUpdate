@echo off
%~d0
cd "%~p0"
if exist ..\static\StaticDownloadLinks-w60-x86-alg.txt (
  if exist ..\static\StaticDownloadLinks-w60-x86-glb.txt del ..\static\StaticDownloadLinks-w60-x86-glb.txt
  ren ..\static\StaticDownloadLinks-w60-x86-alg.txt StaticDownloadLinks-w60-x86-glb.txt
)
if exist ..\static\StaticDownloadLinks-w60-x64-alg.txt (
  if exist ..\static\StaticDownloadLinks-w60-x64-glb.txt del ..\static\StaticDownloadLinks-w60-x64-glb.txt
  ren ..\static\StaticDownloadLinks-w60-x64-alg.txt StaticDownloadLinks-w60-x64-glb.txt
)
if exist ..\static\StaticDownloadLinks-w61-x86-alg.txt (
  if exist ..\static\StaticDownloadLinks-w61-x86-glb.txt del ..\static\StaticDownloadLinks-w61-x86-glb.txt
  ren ..\static\StaticDownloadLinks-w61-x86-alg.txt StaticDownloadLinks-w61-x86-glb.txt
)
if exist ..\static\StaticDownloadLinks-w61-x64-alg.txt (
  if exist ..\static\StaticDownloadLinks-w61-x64-glb.txt del ..\static\StaticDownloadLinks-w61-x64-glb.txt
  ren ..\static\StaticDownloadLinks-w61-x64-alg.txt StaticDownloadLinks-w61-x64-glb.txt
)
