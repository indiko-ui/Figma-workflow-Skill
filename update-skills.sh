#!/bin/bash
# update-skills.sh
# วิธีใช้: bash update-skills.sh <new-upstream.skill> <skill-name>
# ตัวอย่าง: bash update-skills.sh figma-use-v2.skill figma-use

set -e

UPSTREAM_SKILL="$1"   # .skill file ใหม่จาก Figma
SKILL_NAME="$2"       # ชื่อ skill เช่น figma-use

if [ -z "$UPSTREAM_SKILL" ] || [ -z "$SKILL_NAME" ]; then
  echo "Usage: bash update-skills.sh <new-upstream.skill> <skill-name>"
  echo "Example: bash update-skills.sh figma-use-v2.skill figma-use"
  exit 1
fi

WORK_DIR="/tmp/skill-update-$$"
UPSTREAM_DIR="$WORK_DIR/upstream"
TEAM_DIR="$WORK_DIR/team"

mkdir -p "$UPSTREAM_DIR" "$TEAM_DIR"

echo "📦 Extracting upstream skill..."
unzip -q "$UPSTREAM_SKILL" -d "$UPSTREAM_DIR"

echo "📦 Extracting team skill (from skills-team/ folder)..."
# สมมติว่า .skill files อยู่ใน skills-team/
unzip -q "skills-team/$SKILL_NAME.skill" -d "$TEAM_DIR"

echo ""
echo "=== DIFF: upstream vs team version ==="
echo "(- = upstream only, + = team only)"
echo ""

diff -r --unified=3 \
  "$UPSTREAM_DIR/$SKILL_NAME" \
  "$TEAM_DIR/$SKILL_NAME" || true

echo ""
echo "=== สรุป files ที่เปลี่ยน ==="
diff -rq "$UPSTREAM_DIR/$SKILL_NAME" "$TEAM_DIR/$SKILL_NAME" || true

echo ""
echo "Files extracted at:"
echo "  Upstream: $UPSTREAM_DIR/$SKILL_NAME"
echo "  Team:     $TEAM_DIR/$SKILL_NAME"
echo ""
echo "แก้ไขใน $TEAM_DIR/$SKILL_NAME แล้ว repackage:"
echo "  cd /mnt/skills/examples/skill-creator"
echo "  python -m scripts.package_skill $TEAM_DIR/$SKILL_NAME ./skills-team"
