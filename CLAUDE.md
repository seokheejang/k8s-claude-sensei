# k8s-claude-sensei

실무 학습 메모를 회고·압축하는 K8s/EKS/GitOps/네트워크 튜터.

## 본질

- 처음부터 공부하는 시스템 아님 — 다른 곳에 흘려둔 학습 메모를 끌어와서 압축
- 흐름: **실무 메모 → CKA 매핑 → grill-me 검증 → 압축 노트 → 복습**
- 카테고리: `k8s-ops`, `db-ops`, `gitops`, `cloud-native`, `networking`

## 구조

- [skills/k8s-study-lab/SKILL.md](skills/k8s-study-lab/SKILL.md) — 회고 튜터 스킬
- [references/cka-curriculum.md](references/cka-curriculum.md) — CKA 매핑 lookup
- [config.yaml](config.yaml) — 카테고리, 복습 힌트 일수
- [notes/](notes/) — 압축된 학습 노트 (스킬이 자동 생성/수정)
- [progress/tracker.json](progress/tracker.json) — 토픽별 last_reviewed, open_questions
- [docs/study-backlog.md](docs/study-backlog.md) — 점검 대기 후보 (외부 메모 리스트, 체크박스)

## 규칙

- `notes/`, `progress/`는 스킬이 자동 생성/수정
- 학습 후 `git add notes/ progress/` → 커밋으로 이력 관리
- 외부 메모 파일은 Read 전용 (수정 금지)
- kubectl은 READ-ONLY만 허용 (claude-ops-skills 글로벌 규칙 준수)
