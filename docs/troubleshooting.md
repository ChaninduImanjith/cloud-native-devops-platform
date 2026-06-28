# Troubleshooting Guide

This document outlines common issues encountered during the deployment and operation of the platform and their respective solutions.

> **IMPORTANT NOTICE:** The application was successfully deployed to Amazon EKS. The infrastructure is currently offline due to AWS credit limitations.

## 1. Kubernetes Pods in `CrashLoopBackOff`
**Symptom:** Application pods are repeatedly crashing and restarting.
**Diagnosis:**
1. Describe the pod to check for scheduling or resource issues:
   ```bash
   kubectl describe pod <pod-name>
   ```
2. Check the logs for application-level errors:
   ```bash
   kubectl logs <pod-name> --previous
   ```
**Resolution:** This is often caused by a missing environment variable (e.g., Database connection string), misconfigured probes, or application bugs. Correct the ConfigMap/Secret or fix the application code and push a new image.

## 2. Ingress Returning `502 Bad Gateway`
**Symptom:** Navigating to the application URL returns an NGINX 502 error.
**Diagnosis:**
This indicates the Ingress Controller is receiving the request, but cannot route it to the upstream service.
1. Check if the target Service exists and has endpoints:
   ```bash
   kubectl get endpoints <service-name>
   ```
2. Verify the application pod is healthy and passing its readiness probe.
**Resolution:** Ensure the Service port matches the container port, and the pods are in a `Running` and `Ready` state.

## 3. Terraform `Error: error configuring Terraform AWS Provider: no valid credential sources`
**Symptom:** Terraform cannot authenticate with AWS.
**Diagnosis:** Your local environment lacks AWS credentials.
**Resolution:** Configure the AWS CLI using `aws configure`, or set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

## 4. ImagePullBackOff or ErrImagePull
**Symptom:** Kubernetes cannot pull the Docker image.
**Diagnosis:**
1. Describe the pod to see the exact error.
**Resolution:** 
- Ensure the image tag specified in the deployment exists in Docker Hub.
- If using a private registry, ensure an `imagePullSecret` is configured in the Deployment manifest and linked to a valid Kubernetes Secret containing your Docker credentials.

## 5. Node Resource Starvation (Pending Pods)
**Symptom:** Pods remain in a `Pending` state indefinitely.
**Diagnosis:**
Check events using `kubectl get events`. You may see `FailedScheduling` indicating insufficient CPU or memory on the cluster nodes.
**Resolution:** 
- Increase the Node Group size in Terraform (Auto Scaling Group max capacity).
- Change the instance type to a larger size (e.g., from `t3.medium` to `t3.large`).
- Review and reduce the CPU/Memory requests defined in the Deployment manifests.
