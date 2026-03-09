#!/usr/bin/env bash
set -euo pipefail

# =========================================
#  k8s-study-lab installer
#  - Skills를 ~/.claude/skills/에 심링크
#  - settings.json allow/deny 규칙 머지
#  - CLAUDE.md 마커 기반 머지
#  - 학습 디렉토리 초기화
#  - settings.local.json은 절대 건드리지 않음
# =========================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
BACKUP_DIR="$CLAUDE_DIR/backups/k8s-study-lab/$(date +%Y%m%d_%H%M%S)"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
CLAUDE_MD_FILE="$CLAUDE_DIR/CLAUDE.md"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()  { echo -e "${BLUE}[STEP]${NC} $1"; }

backed_up=false

# --- 의존성 확인 ---
check_dependencies() {
    local missing=()
    command -v jq &> /dev/null      || missing+=("jq")
    command -v python3 &> /dev/null || missing+=("python3")

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "필수 의존성이 없습니다: ${missing[*]}"
        log_error "설치: brew install ${missing[*]}"
        exit 1
    fi
}

# --- 백업 ---
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/$(basename "$file")"
        backed_up=true
        log_info "  백업: $(basename "$file") → $BACKUP_DIR/"
    fi
}

backup_dir() {
    local dir="$1"
    local name="$2"
    if [ -d "$dir" ]; then
        mkdir -p "$BACKUP_DIR/skills"
        cp -r "$dir" "$BACKUP_DIR/skills/$name"
        backed_up=true
        log_info "  백업: skills/$name/ → $BACKUP_DIR/skills/"
    fi
}

# --- 학습 디렉토리 초기화 ---
init_study_dirs() {
    log_step "학습 디렉토리 초기화 중..."

    # notes 디렉토리
    for i in 1 2 3 4 5; do
        mkdir -p "$REPO_DIR/notes/domain-$i"
    done
    log_info "  notes/domain-{1..5}/ 생성 완료"

    # progress 디렉토리
    mkdir -p "$REPO_DIR/progress/quiz-history"
    log_info "  progress/quiz-history/ 생성 완료"

    # tracker.json 초기화 (없을 때만)
    if [ ! -f "$REPO_DIR/progress/tracker.json" ]; then
        cat > "$REPO_DIR/progress/tracker.json" << 'TRACKER_EOF'
{
  "last_updated": null,
  "overall_progress": 0,
  "modules": {}
}
TRACKER_EOF
        log_info "  tracker.json 초기화 완료"
    else
        log_info "  tracker.json 이미 존재 → 스킵"
    fi
}

# --- .repo-root 파일 생성 ---
write_repo_root() {
    log_step "스킬 경로 설정 중..."
    local repo_root_file="$REPO_DIR/skills/k8s-study-lab/.repo-root"
    echo "$REPO_DIR" > "$repo_root_file"
    log_info "  .repo-root 생성: $REPO_DIR"
}

# --- Skills 심링크 ---
install_skills() {
    log_step "Skills 설치 중..."
    mkdir -p "$SKILLS_DIR"

    for skill_dir in "$REPO_DIR"/skills/*/; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local target="$SKILLS_DIR/$skill_name"
        local source="${skill_dir%/}"

        # 이미 올바른 심링크인 경우
        if [ -L "$target" ]; then
            local current_link
            current_link="$(readlink "$target")"
            if [ "$current_link" = "$source" ]; then
                log_info "  $skill_name: 이미 심링크됨 ✓"
                continue
            else
                log_warn "  $skill_name: 다른 곳을 가리키는 심링크 → 업데이트"
                rm "$target"
            fi
        # 일반 디렉토리인 경우
        elif [ -d "$target" ]; then
            log_warn "  $skill_name: 기존 디렉토리 발견 → 백업 후 교체"
            backup_dir "$target" "$skill_name"
            rm -rf "$target"
        # 일반 파일인 경우
        elif [ -e "$target" ]; then
            log_warn "  $skill_name: 기존 파일 발견 → 백업 후 교체"
            backup_file "$target"
            rm "$target"
        fi

        ln -s "$source" "$target"
        log_info "  $skill_name: 심링크 생성 → $source"
    done
}

# --- settings.json 머지 ---
merge_settings() {
    log_step "settings.json 머지 중..."
    local template="$REPO_DIR/configs/settings.json.template"

    if [ ! -f "$template" ]; then
        log_error "템플릿 없음: $template"
        return 1
    fi

    # settings.json이 없으면 새로 생성
    if [ ! -f "$SETTINGS_FILE" ]; then
        log_warn "기존 settings.json 없음 → 템플릿에서 생성"
        jq 'del(._comment)' "$template" > "$SETTINGS_FILE"
        log_info "  settings.json 생성 완료"
        return
    fi

    backup_file "$SETTINGS_FILE"

    # permissions 머지 (기존 설정 보존)
    local merged
    merged=$(jq -s '
        .[0] as $template | .[1] as $existing |
        ($existing * {
            permissions: {
                allow: (
                    (($existing.permissions.allow // []) + ($template.permissions.allow // []))
                    | unique
                ),
                deny: (
                    (($existing.permissions.deny // []) + ($template.permissions.deny // []))
                    | unique
                )
            }
        })
    ' "$template" "$SETTINGS_FILE")

    # _comment 필드 제거
    echo "$merged" | jq 'del(._comment)' > "$SETTINGS_FILE"
    log_info "  settings.json 머지 완료"
}

# --- CLAUDE.md 머지 ---
merge_claude_md() {
    log_step "CLAUDE.md 머지 중..."
    local template="$REPO_DIR/configs/claude.md.template"
    local start_marker="# === k8s-study-lab:start ==="
    local end_marker="# === k8s-study-lab:end ==="

    if [ ! -f "$template" ]; then
        log_error "템플릿 없음: $template"
        return 1
    fi

    # CLAUDE.md가 없으면 새로 생성
    if [ ! -f "$CLAUDE_MD_FILE" ]; then
        log_warn "기존 CLAUDE.md 없음 → 템플릿에서 생성"
        cp "$template" "$CLAUDE_MD_FILE"
        log_info "  CLAUDE.md 생성 완료"
        return
    fi

    backup_file "$CLAUDE_MD_FILE"

    if grep -qF "$start_marker" "$CLAUDE_MD_FILE"; then
        # 마커 사이 내용 교체
        awk -v start="$start_marker" -v end="$end_marker" -v replacement="TEMPLATE_PLACEHOLDER" '
            index($0, start) { skip=1; print replacement; next }
            index($0, end) { skip=0; next }
            !skip { print }
        ' "$CLAUDE_MD_FILE" > "$CLAUDE_MD_FILE.tmp"

        # placeholder를 실제 내용으로 교체
        python3 -c "
import sys
with open('$CLAUDE_MD_FILE.tmp', 'r') as f:
    content = f.read()
with open('$template', 'r') as f:
    replacement = f.read()
content = content.replace('TEMPLATE_PLACEHOLDER', replacement)
with open('$CLAUDE_MD_FILE.tmp', 'w') as f:
    f.write(content)
"
        mv "$CLAUDE_MD_FILE.tmp" "$CLAUDE_MD_FILE"
        log_info "  CLAUDE.md: 마커 사이 내용 업데이트 완료"
    else
        # 마커가 없으면 기존 내용 뒤에 추가
        echo "" >> "$CLAUDE_MD_FILE"
        cat "$template" >> "$CLAUDE_MD_FILE"
        log_info "  CLAUDE.md: 기존 내용 보존 + 템플릿 추가"
    fi
}

# --- 메인 ---
main() {
    echo ""
    echo "========================================"
    echo "  k8s-study-lab installer"
    echo "========================================"
    echo ""

    check_dependencies

    if [ ! -d "$REPO_DIR/skills" ]; then
        log_error "skills 디렉토리를 찾을 수 없습니다."
        exit 1
    fi

    init_study_dirs
    echo ""
    write_repo_root
    echo ""
    install_skills
    echo ""
    merge_settings
    echo ""
    merge_claude_md

    echo ""
    echo "========================================"
    echo "  설치 완료"
    echo "========================================"
    echo ""

    echo "Skills 설치 위치: $SKILLS_DIR"
    if [ -d "$SKILLS_DIR" ]; then
        for item in "$SKILLS_DIR"/*/; do
            [ -d "$item" ] || continue
            local name
            name="$(basename "$item")"
            if [ -L "$item" ] || [ -L "${item%/}" ]; then
                echo "  /$name → $(readlink "${item%/}" 2>/dev/null || echo "symlink")"
            else
                echo "  /$name (local)"
            fi
        done
    fi

    echo ""
    if [ "$backed_up" = true ]; then
        echo "백업 위치: $BACKUP_DIR"
    else
        echo "백업 불필요 (클린 설치)"
    fi

    echo ""
    echo "⚠️  ~/.claude/settings.local.json은 수정하지 않았습니다."
    echo ""
    log_info "Claude Code를 재시작하면 변경사항이 적용됩니다."
    echo ""
}

main "$@"
