rem cleanup previous instalations
kubectl delete deployments my-app-deployment

IF "%1"=="CLEAN" exit /B 0

rem create the containers
rem use jenkins pipeline to build the container

rem create new resources
kubectl create -f %~dp0my-app-deployment.yaml

exit /B 0