#!/bin/sh

kubectl delete service nginx-service
kubectl delete deployment nginx-deployment
kubectl delete deployment centos-deployment
