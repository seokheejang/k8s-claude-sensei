# k8s-claude-sensei

CKA/EKS 소크라틱 튜터 시스템.

## 구조

- `skills/k8s-study-lab/SKILL.md` — 튜터 스킬 정의
- `config.yaml` — 학습 설정 (퀴즈 규칙, 난이도 등)
- `notes/` — 학습 노트 (스킬이 자동 생성/수정)
- `progress/` — 진도 추적 (tracker.json + quiz-history/)

## 규칙

- notes/, progress/ 파일은 스킬이 자동 생성/수정
- 학습 후 `git add notes/ progress/` → 커밋으로 이력 관리
- kubectl은 READ-ONLY만 허용 (claude-ops-skills 규칙 준수)
