#!/bin/bash

WORKER1="k8s-worker-01"
WORKER2="k8s-worker-02"
CENTOS="centos-deployment"
#NGINX="nginx-multi"
NGINX="nginx-deployment"
SERVICE="nginx-service"

C1NAME=$(kubectl get pods -n default -o wide | grep ${WORKER1} | grep ${CENTOS} | awk '{print $1}')
C2NAME=$(kubectl get pods -n default -o wide | grep ${WORKER2} | grep ${CENTOS} | awk '{print $1}')
N1IP=$(kubectl get pods -n default -o wide | grep ${WORKER1} | grep ${NGINX} | awk '{print $6}')
N2IP=$(kubectl get pods -n default -o wide | grep ${WORKER2} | grep ${NGINX} | awk '{print $6}')
SIP=$(kubectl get service -n default -o wide | grep ${SERVICE} | awk '{print $3}')

echo "C1NAME = ${C1NAME}"
echo "C2NAME = ${C2NAME}"
echo "N1IP = ${N1IP}"
echo "N2IP = ${N2IP}"
echo "SIP = ${SIP}"
echo "----------------------------"

echo "Testing Worker 1 -> Worker 1"
kubectl exec -it ${C1NAME} -- curl --head http://${N1IP} --connect-timeout 5
echo "----------------------------"
echo "Testing Worker 1 -> Worker 2"
kubectl exec -it ${C1NAME} -- curl --head http://${N2IP} --connect-timeout 5
echo "----------------------------"
echo "Testing Worker 2 -> Worker 2"
kubectl exec -it ${C2NAME} -- curl --head http://${N2IP} --connect-timeout 5 
echo "----------------------------"
echo "Testing Worker 2 -> Worker 1"
kubectl exec -it ${C2NAME} -- curl --head http://${N1IP} --connect-timeout 5 
echo "----------------------------"
if [[ "${SIP}" != "" ]]
then
  echo "Testing Worker 1 -> Service IP"
  kubectl exec -it ${C1NAME} -- curl --head http://${SIP} --connect-timeout 5
  echo "----------------------------"
  echo "Testing Worker 2 -> Service IP"
  kubectl exec -it ${C2NAME} -- curl --head http://${SIP} --connect-timeout 5
  echo "----------------------------"
  echo "Testing Worker 1 -> Service Name"
  kubectl exec -it ${C1NAME} -- curl --head http://nginx-service.default.svc.cluster.local --connect-timeout 5
  echo "----------------------------"
  echo "Testing Worker 2 -> Service Name"
  kubectl exec -it ${C2NAME} -- curl --head http://nginx-service.default.svc.cluster.local --connect-timeout 5
  echo "----------------------------"
  echo "Workstation -> Master 1"
  curl --head http://k8s-master-01:30080 --connect-timeout 5
  echo "----------------------------"
  echo "Workstation -> Worker 1"
  curl --head http://k8s-worker-01:30080 --connect-timeout 5
  echo "----------------------------"
  echo "Workstation -> Worker 2"
  curl --head http://k8s-worker-02:30080 --connect-timeout 5
  echo "----------------------------"
else
  echo "No Service IP found, skipping service tests"
  echo "----------------------------"
fi
