# CKA Curriculum (v1.34) — Mapping Reference

> 실무 메모를 받았을 때 "이건 CKA의 어떤 토픽과 연결되는지" 매핑하기 위한 lookup.
> 1차 소스: https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_v1.34.pdf
>
> 사용법:
> - 외부 메모의 키워드/주제를 이 파일과 매칭
> - 매칭된 토픽의 `related` 필드를 함께 제시 ("이것도 옆에 같이 봐두면 좋음")
> - 공식 문서 링크는 학습자가 더 깊게 파고들고 싶을 때만 안내

---

## Domain 1: Cluster Architecture, Installation & Configuration (25%)

### 1.1 RBAC
- **키워드**: Role, ClusterRole, RoleBinding, ClusterRoleBinding, ServiceAccount, IRSA, aws-auth, EKS Access Entries
- **EKS 특화**: aws-auth ConfigMap, IRSA, EKS Access Entries
- **related**: 1.4 (인증→인가 체인)
- **docs**: kubernetes.io/docs/reference/access-authn-authz/rbac/, docs.aws.amazon.com/eks/latest/userguide/security-iam.html

### 1.2 kubeadm 클러스터 설치/업그레이드
- **키워드**: kubeadm init, kubeadm join, 인증서 관리, 버전 업그레이드, drain, cordon, kubelet 업그레이드
- **EKS 특화**: 노드 그룹 업그레이드 전략 (Control Plane은 관리형)
- **related**: 5.4 (노드 트러블슈팅)
- **docs**: kubernetes.io/docs/setup/production-environment/tools/kubeadm/, docs.aws.amazon.com/eks/latest/userguide/update-cluster.html

### 1.3 etcd HA / 백업·복원
- **키워드**: etcdctl, etcdutl, snapshot, Raft, 쿼럼, 멤버 관리
- **EKS 특화**: EKS는 etcd 완전 관리 — 직접 접근 불가, 원리만 이해
- **related**: 5.1 (Control Plane 트러블슈팅)
- **docs**: kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/

### 1.4 Kubernetes API
- **키워드**: kube-apiserver, Admission Controller, API Priority and Fairness, 인증→인가→Admission
- **EKS 특화**: EKS API 엔드포인트 public/private 설정
- **related**: 1.1 (RBAC)
- **docs**: kubernetes.io/docs/concepts/overview/kubernetes-api/, docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html

---

## Domain 2: Services & Networking (20%)

### 2.1 노드 네트워킹
- **키워드**: Pod 네트워킹 모델, bridge, veth, 노드 간 통신
- **EKS 특화**: VPC CNI, Pod별 ENI/IP, 서브넷 설계
- **related**: 2.5 (CNI)
- **docs**: docs.aws.amazon.com/eks/latest/userguide/pod-networking.html

### 2.2 Service
- **키워드**: ClusterIP, NodePort, LoadBalancer, ExternalName, kube-proxy, iptables, IPVS, 서비스 디스커버리
- **EKS 특화**: AWS Load Balancer Controller, NLB/ALB
- **related**: 2.3 (Ingress), 2.4 (CoreDNS)
- **docs**: kubernetes.io/docs/concepts/services-networking/service/, docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html

### 2.3 Ingress / Gateway API
- **키워드**: Ingress, IngressClass, Ingress Controller, HTTPRoute, Gateway, GatewayClass, Nginx Ingress, ALB Ingress, Cilium HTTPRoute, Envoy
- **EKS 특화**: AWS ALB Ingress, Nginx Ingress on EKS
- **related**: 2.2 (Service), 2.5 (CNI — eBPF/Cilium 연계)
- **docs**: kubernetes.io/docs/concepts/services-networking/ingress/, gateway-api.sigs.k8s.io/, docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html

### 2.4 CoreDNS
- **키워드**: Corefile, 포워딩, 서비스 디스커버리, 커스텀 DNS
- **EKS 특화**: EKS CoreDNS 애드온
- **related**: 2.2 (Service)
- **docs**: kubernetes.io/docs/tasks/administer-cluster/coredns/, docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html

### 2.5 CNI
- **키워드**: CNI 스펙, 플러그인 체이닝, IP 할당, eBPF, Cilium, Calico, VPC CNI, Prefix Delegation
- **EKS 특화**: Amazon VPC CNI, Secondary IP, Prefix Delegation
- **related**: 2.1 (노드 네트워킹), 2.6 (NetworkPolicy)
- **docs**: github.com/containernetworking/cni, docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html

### 2.6 NetworkPolicy
- **키워드**: NetworkPolicy, Ingress/Egress, 기본 Deny, 네임스페이스 격리, Pod 셀렉터, Calico, Security Group for Pods
- **EKS 특화**: Calico on EKS, Security Group for Pods
- **related**: 2.5 (CNI)
- **docs**: kubernetes.io/docs/concepts/services-networking/network-policies/, docs.aws.amazon.com/eks/latest/userguide/calico.html

---

## Domain 3: Workloads & Scheduling (15%)

### 3.1 Deployment & 롤링 업데이트
- **키워드**: Deployment, ReplicaSet, maxSurge, maxUnavailable, Revision, rollout, pause, resume
- **related**: 3.5 (StatefulSet 비교)
- **docs**: kubernetes.io/docs/concepts/workloads/controllers/deployment/

### 3.2 Pod 스케줄링
- **키워드**: nodeSelector, Affinity, Anti-Affinity, Taints, Tolerations, Scheduling Framework (Filter/Score/Bind), 커스텀 스케줄러
- **EKS 특화**: Managed Node Group 라벨, Fargate 프로파일
- **related**: 3.3 (리소스), 5.2 (Pending 트러블슈팅)
- **docs**: kubernetes.io/docs/concepts/scheduling-eviction/

### 3.3 리소스 관리
- **키워드**: requests, limits, LimitRange, ResourceQuota, QoS (Guaranteed/Burstable/BestEffort), OOM
- **related**: 3.2 (스케줄링), 3.4 (HPA)
- **docs**: kubernetes.io/docs/concepts/configuration/manage-resources-containers/

### 3.4 HPA / VPA / KEDA / 오토스케일링
- **키워드**: HPA, VPA, KEDA, Metrics Server, Cluster Autoscaler, Karpenter, 커스텀 메트릭, 외부 메트릭, 안정화 윈도우
- **EKS 특화**: KEDA on EKS, Karpenter, Cluster Autoscaler
- **related**: 3.3 (리소스)
- **docs**: kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/, keda.sh/, karpenter.sh/, docs.aws.amazon.com/eks/latest/userguide/autoscaling.html

### 3.5 StatefulSet / DaemonSet / Job / CronJob
- **키워드**: StatefulSet, 헤드리스 서비스, 순서 보장, DaemonSet 업데이트 전략, Job, CronJob, parallelism, completions
- **related**: 3.1 (Deployment 비교), 4.1 (PV/PVC — StatefulSet 연계)
- **docs**: kubernetes.io/docs/concepts/workloads/controllers/

---

## Domain 4: Storage (10%)

### 4.1 PV / PVC / StorageClass
- **키워드**: PersistentVolume, PersistentVolumeClaim, StorageClass, Reclaim Policy, Access Modes, Volume Expansion, 동적 프로비저닝
- **EKS 특화**: EBS CSI Driver, EFS CSI Driver
- **related**: 4.2 (CSI)
- **docs**: kubernetes.io/docs/concepts/storage/persistent-volumes/, docs.aws.amazon.com/eks/latest/userguide/storage.html

### 4.2 CSI
- **키워드**: CSI 드라이버, VolumeSnapshot, VolumeSnapshotContent, 토폴로지, ZFS-LocalPV, OpenEBS
- **EKS 특화**: Amazon EBS CSI, ZFS-LocalPV on EKS
- **related**: 4.1 (PV/PVC)
- **docs**: kubernetes-csi.github.io/

### 4.3 Volume Types
- **키워드**: emptyDir, hostPath, configMap, secret, projected, downwardAPI
- **related**: 4.1 (PV/PVC)
- **docs**: kubernetes.io/docs/concepts/storage/volumes/

---

## Domain 5: Troubleshooting (30%) — 최대 비중

### 5.1 클러스터 컴포넌트 트러블슈팅
- **키워드**: kubelet, kube-apiserver, etcd, scheduler, controller-manager 로그
- **EKS 특화**: CloudWatch Logs, EKS Control Plane 로깅
- **related**: 1.3 (etcd), 1.4 (API)
- **docs**: kubernetes.io/docs/tasks/debug/debug-cluster/, docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html

### 5.2 워크로드 트러블슈팅
- **키워드**: Pending, CrashLoopBackOff, ImagePullBackOff, ErrImagePull, OOMKilled, init container, kubectl describe, kubectl logs, kubectl exec, 이벤트
- **related**: 3.2 (스케줄링 — Pending), 3.3 (리소스 — OOM)
- **docs**: kubernetes.io/docs/tasks/debug/debug-application/

### 5.3 네트워크 트러블슈팅
- **키워드**: Service 연결 실패, DNS 해석, NetworkPolicy 차단, nslookup, dig, tcpdump, 엔드포인트
- **EKS 특화**: VPC CNI 트러블슈팅, Pod 통신 장애
- **related**: 2.2 (Service), 2.4 (CoreDNS), 2.6 (NetworkPolicy)
- **docs**: kubernetes.io/docs/tasks/debug/debug-cluster/dns-debugging-resolution/, docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html

### 5.4 노드 트러블슈팅
- **키워드**: NotReady, kubelet 진단, Eviction, 디스크 압력, 메모리 압력, 노드 Condition
- **EKS 특화**: Managed Node Group 헬스 체크, ASG 연동
- **related**: 1.2 (kubeadm — drain/cordon)
- **docs**: kubernetes.io/docs/tasks/debug/debug-cluster/

---

## 사용자 학습 카테고리 ↔ CKA 매핑 힌트

| 사용자 카테고리 | 자주 매칭되는 CKA 토픽 |
|---|---|
| `k8s-ops` | 1.1 RBAC, 1.2 kubeadm, 1.3 etcd, 5.1~5.4 트러블슈팅 |
| `db-ops` | (대부분 CKA 범위 외 — DB Operator/토폴로지) 옆 참고: 3.5 StatefulSet, 4.1 PV/PVC, 4.2 CSI |
| `gitops` | (CKA 직접 매핑 적음 — Helm/ArgoCD는 시험 범위 외) 3.1 Deployment, 1.1 RBAC |
| `cloud-native` | 3.1~3.5 워크로드, 4.1~4.3 스토리지 |
| `networking` | 2.1~2.6 전체, 5.3 네트워크 트러블슈팅 |

> **db-ops 노트**: CRD/Reconciler/Finalizer 등 Operator 패턴은 CKA 시험 범위 외 (K8s API 확장 메커니즘 — Custom Controller). 다만 operator가 관리하는 리소스(PVC/StatefulSet/Service)와 토폴로지/백업·복원의 K8s primitives는 CKA 범위. "DB 운영 도메인 + 그 안의 K8s primitives" 두 층으로 학습.
