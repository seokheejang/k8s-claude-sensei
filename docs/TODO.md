# TODO / Future Improvements

## Practice Cluster Environment

CKA 시험은 실제 클러스터에서 kubectl을 사용하는 실습 시험이므로, 유사한 환경 구성이 필수.

### Priority

1. **CKA 유사 환경** — kubeadm 기반 멀티노드 클러스터
   - CKA 시험은 kubeadm으로 구성된 클러스터에서 진행
   - Control Plane + Worker 2~3대 구성
   - 옵션: Vagrant + VirtualBox, EC2 spot instances
   - etcd 백업/복원, 노드 drain/cordon 등 실습 가능

2. **kind (Kubernetes IN Docker)** — 로컬 경량 대안
   - kubeadm 환경 구성이 어려울 때 fallback
   - 멀티노드 시뮬레이션 가능 (kind config로 worker 추가)
   - 제약: etcd 직접 관리, kubelet 트러블슈팅 등 일부 실습 불가
   - 장점: 빠른 생성/삭제, CI 연동 용이

### Notes

- EKS는 이미 운영 환경이 있으므로 EKS 특화 실습은 기존 클러스터 활용
- CKA 시험 환경과 EKS는 다르므로 (kubeadm vs managed), 별도 연습 환경 필요
- killer.sh (CKA 시뮬레이터) 활용도 고려
