rem you need to run this shellscript as an administrator

rem install jenkins using helm
helm install --name jenkins -f %~dp0jenkins.yaml stable/jenkins

rem enable the defailt account to deploy services
rem the rigth way is to set an account for jenkins and give permission to deploy in a specific namespace (use rbac)
kubectl create clusterrolebinding default-admin --clusterrole cluster-admin --serviceaccount=default:default

exit /B 0
