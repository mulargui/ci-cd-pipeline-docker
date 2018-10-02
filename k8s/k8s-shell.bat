kubectl run -i --tty busybox --image=busybox --restart=Never -- sh  
kubectl delete pod busybox --now