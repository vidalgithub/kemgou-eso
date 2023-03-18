#!/bin/bash
kubectl get secret kemgou-external-secret -o jsonpath='{.data.first}' | base64 --decode
echo
kubectl get secret kemgou-external-secret -o jsonpath='{.data.second}' | base64 --decode
