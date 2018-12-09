rem you need to run this shellscript as an administrator

rem install minikube
for /f %%i in ('curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt') do set kctlver=%%i
curl -LO https://storage.googleapis.com/kubernetes-release/release/%kctlver%/bin/windows/amd64/kubectl.exe
move kubectl.exe %systemroot%\system32

set k8ver=v0.30.0
curl -LO https://storage.googleapis.com/minikube/releases/%k8ver%/minikube-windows-amd64.exe
ren minikube-windows-amd64.exe minikube.exe
move minikube.exe %systemroot%\system32

minikube version
minikube start
minikube status

rem install helm
set helmver=v2.12.0
curl -LO https://storage.googleapis.com/kubernetes-helm/helm-%helmver%-windows-amd64.zip
powershell -command "Expand-Archive .\helm-%helmver%-windows-amd64.zip .\helm"
move .\helm\windows-amd64\helm.exe %systemroot%\system32
del helm-%helmver%-windows-amd64.zip
rmdir /s /Q .\helm
helm init

rem wait till everything is up and running
timeout 120

rem install jenkins using helm
helm install --name jenkins -f %~dp0jenkins.yaml stable/jenkins

rem enable the defailt account to deploy services
rem the rigth way is to set an account for jenkins and give permission to deploy in a specific namespace (use rbac)
kubectl create clusterrolebinding default-admin --clusterrole cluster-admin --serviceaccount=default:default

rem show the dashboard
minikube dashboard

exit /B 0
