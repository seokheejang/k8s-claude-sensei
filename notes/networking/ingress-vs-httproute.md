---
topic: Ingress vs Cilium HTTPRoute
category: networking
source: direct
cka_mapping: ["Domain 2.3 Ingress / Gateway API", "Domain 2.5 CNI"]
last_reviewed: 2026-03-26
review_density: default
---

# Ingress vs Cilium HTTPRoute

## 핵심 (한 달 뒤에 5분이면 다시 머리에 들어오는 압축본)

### 아키텍처 차이
- Nginx Ingress: 외부 요청 → LB Service → Nginx Pod(별도 리버스 프록시) → 백엔드 Pod
- Cilium HTTPRoute: 외부 요청 → LB Service → Cilium Agent(각 노드 eBPF + Envoy 내장) → 백엔드 Pod
- Cilium은 별도 프록시 Pod 없이 DaemonSet Agent 안의 Envoy가 처리 → 네트워크 홉 감소

### Ingress 리소스의 역할
- Ingress YAML은 Ingress Controller에게 주는 라우팅 규칙표
- "이 호스트/경로 조합이면 이 Service로 보내라"는 설정

### Envoy vs Nginx
- Nginx: 설정 파일 수정 후 reload 필요
- Envoy: API로 동적 설정 변경 가능 (재시작/reload 없이 즉시 반영)
- Cilium이 Envoy를 선택한 이유: HTTPRoute 변경 시 API로 즉시 전달

### eBPF
- 커널 안에 작은 프로그램을 직접 삽입하는 기술
- iptables 순차 매칭 대신 커널 레벨에서 바로 패킷 라우팅 판단 → 빠르고 효율적
- Cilium은 kube-proxy(iptables)도 대체 가능

### L2 Announcement (Cilium Speaker)
- LoadBalancer Service IP를 ARP로 광고하는 기능
- Ingress 단계 이전, 트래픽이 클러스터에 진입하는 방법에 해당

## 왜 이게 중요한가 (실무 관점)
- dev 환경에 Cilium CNI 구축 + kube-proxy 제거를 진행 중 — 라우팅 경로가 통째로 바뀜
- Nginx Ingress 시절의 "리버스 프록시 Pod 모니터링/스케일링" 운영 패턴이 더 이상 필요 없어짐
- L2 Announcement로 LB IP를 광고하므로, 외부 LB가 없는 온프레/dev 환경에서도 LoadBalancer 타입 Service 가능

## CKA 연결
- **Domain 2.3 Ingress / Gateway API**: Ingress 리소스 정의와 Controller의 관계, HTTPRoute는 Ingress의 차세대 표준 (Gateway API)
- **Domain 2.5 CNI**: Cilium은 CNI 플러그인이자 kube-proxy 대체 — eBPF 기반 데이터플레인 이해 필요
- 시험 관점: HTTPRoute 자체는 v1.34 시점 출제 비중 작지만, Ingress 동작 원리는 매번 출제

## 미해결 의문점
- Ingress YAML의 한계 (annotation 의존) vs HTTPRoute의 명시적 스펙 — 구체 사례
- Gateway API 구조 (Gateway, GatewayClass, HTTPRoute 역할 분리)
- 헤더 기반 라우팅, 트래픽 가중치 분배 등 고급 라우팅 패턴

## 출처
- 직접 학습 (실무 dev 환경 구축 과정)

## 세션 이력
- 2026-03-26: Ingress vs Cilium HTTPRoute 아키텍처 차이 학습. Envoy/eBPF 개념 정리. 다음 시간에 Ingress 스펙 한계와 Gateway API 구조 이어서 진행 예정.
