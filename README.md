# k8s-claude-sensei

실무에서 만난 K8s/EKS/GitOps/네트워크 학습 메모를 압축·정리해서 내 것으로 만드는 회고 튜터.

## 본질

**다른 곳에 흘려둔 학습 메모를 → 내 것으로 압축하는 회고 사이클**

- 다른 프로젝트의 docs(learning, plans 등)에는 그때그때 알게 된 내용을 적어두지만, 거기서 끝나버리는 일이 많음
- 따로 학습할 시간/에너지는 없지만, 한 번은 머리에 다시 되새기고 압축해서 복습 가능한 형태로 남기고 싶음
- 주 1회, 못해도 월 1회 이 repo에서 회고하는 흐름

### 학습 카테고리

| 카테고리 | 범위 |
|---|---|
| `k8s-ops` | K8s 운영 필수 (RBAC, etcd, 업그레이드, 워크로드 트러블슈팅) |
| `db-ops` | DB 운영 전반 — Operator(CNPG, clickhouse-operator), 토폴로지 변환, 백업/복원, 쿼리 튜닝 |
| `gitops` | ArgoCD, Helm 문법/설계 |
| `cloud-native` | 서비스 a~z 아키텍처 설계 |
| `networking` | CS 기초 → K8s 연동 → 모니터링/장애 대응 |

## 워크플로우

```
실무에서 메모 작성 (다른 repo) → /k8s-study-lab 호출 → CKA 매핑 → grill-me 검증 → 압축 노트 → 복습
```

### 모드 3가지

```bash
# A. 외부 메모 정리 (메인)
/k8s-study-lab /path/to/other-repo/docs/learning-2025-w20.md

# B. 토픽 시작 (메모 경로를 먼저 묻고 모드 A로 전환)
/k8s-study-lab "argocd helm chart hooks"

# C. 복습 후보 제시 (인자 없음)
/k8s-study-lab
```

## CKA 처리

CKA는 **추가 설명 레이어**로 동작:
- 실무 메모를 받으면 `references/cka-curriculum.md`를 lookup 해서 관련 도메인/토픽을 자동 매핑
- "이건 Domain 2.3과 직결, 옆에 2.5도 같이 봐두면 좋아요" 식으로 안내
- 시험 자체가 목적이 아니라 **실무 학습의 연장선** — 놓치는 영역을 찾는 용도

## 디렉토리 구조

```
k8s-claude-sensei/
├── skills/k8s-study-lab/SKILL.md   # 회고 튜터 스킬
├── references/cka-curriculum.md    # CKA 매핑 lookup
├── config.yaml                     # 카테고리, 복습 힌트 일수
├── notes/                          # 압축된 학습 노트
│   ├── k8s-ops/
│   ├── db-ops/
│   ├── gitops/
│   ├── cloud-native/
│   └── networking/
├── docs/study-backlog.md           # 점검 대기 후보 (외부 메모 리스트)
├── progress/tracker.json           # 토픽별 last_reviewed, open_questions
├── scripts/install.sh
├── CLAUDE.md
└── .claude/settings.json           # kubectl 변경 명령 deny
```

## 노트 형식

```markdown
---
topic: <토픽명>
category: <k8s-ops|db-ops|gitops|cloud-native|networking>
source: <외부 메모 절대경로 또는 "direct">
cka_mapping: ["Domain 2.3 Ingress / Gateway API"]
last_reviewed: YYYY-MM-DD
review_density: default  # default(14d) | dense(7d) | light(30d)
---

## 핵심 (한 달 뒤 5분이면 다시 머리에 들어오는 압축본)
## 왜 이게 중요한가 (실무 관점)
## CKA 연결
## 미해결 의문점       # grill-me에서 끝까지 못 푼 분기
## 출처
## 세션 이력
```

## 설치

```bash
git clone <repo-url> ~/k8s-claude-sensei
cd ~/k8s-claude-sensei
./scripts/install.sh
```

`install.sh`가 하는 일:
1. `notes/`, `progress/` 초기화
2. `skills/k8s-study-lab` → `~/.claude/skills/k8s-study-lab` 심링크
3. `~/.claude/settings.json` 머지
4. `~/.claude/CLAUDE.md`에 마커 블록 추가

### 의존성
- [Claude Code](https://claude.ai/code)
- `jq`, `python3`

## 사용 예시

```bash
# 학습 후 커밋
git add notes/ progress/
git commit -m "study: <topic>"
```

## 안전 규칙

- kubectl은 READ-ONLY만 허용 (claude-ops-skills 글로벌 규칙)
- 외부 메모 파일은 Read 전용 — 정리 결과는 이 repo의 `notes/`에만 저장

## 참조

- [CKA Curriculum v1.34](https://github.com/cncf/curriculum)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
