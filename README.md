# k8s-claude-sensei

Claude-driven K8s study system — Socratic tutoring, CKA curriculum, EKS deep dives, spaced repetition

## Overview

CKA 시험 커리큘럼(CNCF 공식 v1.34)과 AWS EKS 공식 문서 기반의 소크라틱 튜터 시스템.
Claude Code의 `/k8s-study-lab` 슬래시 커맨드로 활성화됩니다.

### 주요 기능

- **소크라틱 튜터링** — 답을 바로 주지 않고 질문으로 사고를 유도
- **CKA 5개 도메인** — 시험 비중에 따른 체계적 커리큘럼
- **퀴즈 시스템** — 4문제/라운드, 75% 통과, 85% 마스터리
- **진도 추적** — tracker.json 기반 상태 관리, 스페이스드 리피티션
- **학습 노트** — 세션 종료 시 자동 생성, 커밋으로 이력 관리
- **EKS 특화** — AWS 공식 문서 기반 관리형 환경 차이점

## 설치

### 의존성

- [Claude Code](https://claude.ai/code) (CLI)
- `jq` — JSON 처리
- `python3` — CLAUDE.md 머지

```bash
brew install jq  # macOS
```

### 설치

```bash
git clone <repo-url> ~/k8s-claude-sensei
cd ~/k8s-claude-sensei
./scripts/install.sh
```

install.sh가 수행하는 작업:
1. `notes/`, `progress/` 디렉토리 초기화
2. `skills/k8s-study-lab` → `~/.claude/skills/k8s-study-lab` 심링크
3. `~/.claude/settings.json` 머지
4. `~/.claude/CLAUDE.md`에 마커 블록 추가

## 사용법

> **Note**: `/k8s-study-lab` 스킬은 SKILL.md에 소크라틱 튜터 톤 & 스타일이 내장되어 있어,
> 별도의 output-style 전환 없이 학습 모드로 동작합니다.
> 스킬이 활성화된 세션에서만 적용되며, 다른 Claude 창/세션은 기본 모드로 유지됩니다.

```bash
# Claude Code 실행
claude

# 학습 시작 (도메인/토픽 지정)
/k8s-study-lab CKA Domain 5 Troubleshooting

# 특정 토픽 학습
/k8s-study-lab etcd

# 퀴즈 요청
"etcd 관련 퀴즈 내줘"

# 진도 확인
"현재 학습 현황 보여줘"

# 학습 후 커밋
git add notes/ progress/
git commit -m "study: etcd raft consensus - session 2"
```

## 디렉토리 구조

```
k8s-claude-sensei/
├── skills/
│   └── k8s-study-lab/
│       └── SKILL.md           # 소크라틱 튜터 스킬 정의
├── config.yaml                # 학습 설정 (난이도, 퀴즈 규칙 등)
├── notes/                     # 학습 노트 (자동 생성)
│   ├── domain-1/              # Cluster Architecture (25%)
│   ├── domain-2/              # Services & Networking (20%)
│   ├── domain-3/              # Workloads & Scheduling (15%)
│   ├── domain-4/              # Storage (10%)
│   └── domain-5/              # Troubleshooting (30%)
├── progress/
│   ├── tracker.json           # 진도 데이터
│   └── quiz-history/          # 퀴즈 이력
├── configs/                   # 설치 템플릿
├── scripts/
│   └── install.sh             # 설치 스크립트
├── CLAUDE.md                  # 프로젝트 레벨 규칙
└── .claude/
    └── settings.json          # kubectl deny 규칙
```

## CKA 도메인 (v1.34)

| Domain | 비중 | 주요 토픽 |
|--------|------|----------|
| 1. Cluster Architecture | 25% | RBAC, kubeadm, etcd, K8s API |
| 2. Services & Networking | 20% | Service, Ingress, CoreDNS, CNI, NetworkPolicy |
| 3. Workloads & Scheduling | 15% | Deployment, Scheduling, HPA/KEDA, StatefulSet |
| 4. Storage | 10% | PV/PVC, CSI, Volume Types |
| 5. Troubleshooting | 30% | 클러스터/워크로드/네트워크/노드 진단 |

## 설정 커스터마이징

`config.yaml`을 수정하여 학습 설정을 변경할 수 있습니다:

```yaml
difficulty: advanced          # beginner | intermediate | advanced
socratic_intensity: moderate  # light | moderate | strict
language: ko
quiz:
  questions_per_round: 4
  pass_threshold: 75
  mastery_threshold: 85
  mastery_streak: 3
spaced_repetition:
  intervals: [7, 14, 30]
```

## 참조

### 1차 소스 (개념 학습 근거)
- [CKA Curriculum v1.34](https://github.com/cncf/curriculum)
- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Kubernetes Official Docs](https://kubernetes.io/docs/)

### 실습/시험 대비 보조 참조
퀴즈 통과(`quiz_passed`) 이후 실습 단계 및 시험 직전 복습용. 개념 학습 소스로는 사용하지 않음.
- [techiescamp/cka-certification-guide](https://github.com/techiescamp/cka-certification-guide) — kubectl 치트시트 + 실습 매니페스트 (kind 멀티노드, Ingress, NetworkPolicy, Gateway API 등)
