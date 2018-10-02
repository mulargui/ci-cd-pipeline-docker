rem you need to run this shellscript as an administrator

rem install minikube
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.11.2/bin/windows/amd64/kubectl.exe
move kubectl.exe %systemroot%\system32
curl -LO https://storage.googleapis.com/minikube/releases/v0.29.0/minikube-windows-amd64.exe
ren minikube-windows-amd64.exe minikube.exe
move minikube.exe %systemroot%\system32

minikube version
minikube start
minikube status

rem install helm
curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v2.10.0-windows-amd64.zip
unzip -j helm-v2.10.0-windows-amd64.zip "windows-amd64/helm.exe"
del helm-v2.10.0-windows-amd64.zip
move helm.exe %systemroot%\system32
helm init

rem wait till everything is up and running
sleep 120

rem install jenkins using helm
helm install --name jenkins -f %~dp0jenkins.yaml stable/jenkins

rem enable the defailt account to deploy services
rem the rigth way is to set an account for jenkins and give permission to deploy in a specific namespace (use rbac)
kubectl create clusterrolebinding default-admin --clusterrole cluster-admin --serviceaccount=default:default

rem show the dashboard
minikube dashboard

exit /B 0
