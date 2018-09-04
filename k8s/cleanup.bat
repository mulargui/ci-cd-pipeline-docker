rem you need to run this shellscript as an administrator

rem cleanup minikube 
minikube stop
minikube delete
del %systemroot%\system32\kubectl.exe
del %systemroot%\system32\minikube.exe
rmdir %userprofile%\.minikube /s /q
rmdir %userprofile%\.kube /s /q

rem cleanup helm
del %systemroot%\system32\helm.exe
rmdir %userprofile%\.helm /s /q

exit /B 0
