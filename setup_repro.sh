#!/usr/bin/env bash
# Prepara a reprodução local do SISSA: clona o repo dos autores e aplica nossos configs.
# Uso: bash setup_repro.sh
set -e

REPO_DIR="SISSA"

if [ ! -d "$REPO_DIR" ]; then
  echo ">>> Clonando o repositório oficial dos autores..."
  git clone https://github.com/jamesnulliu/SISSA.git "$REPO_DIR"
fi

echo ">>> Aplicando nossos configs (janela 128 + variantes CPU)..."
cp configs/basic-window128.yml      "$REPO_DIR/config/basic.yml"
cp configs/SISSA-L-A-cpu.yml        "$REPO_DIR/config/"
cp configs/SISSA-L-A-cpu-w128.yml   "$REPO_DIR/config/"

echo ">>> Instalando dependências..."
pip install -q ruamel.yaml torchinfo concurrent_log_handler gdown py7zr
pip install -q -r "$REPO_DIR/requirements.txt" || true

cat <<'EOF'

>>> Pronto. Falta baixar o dataset:
    1) Baixe data.7z do Google Drive (ver docs/Prepare_for_Dataset.md do repo dos autores)
       para dentro de ./SISSA/
    2) cd SISSA && 7z x data.7z
    3) Treinar:  python train.py --model_config config/SISSA-L-A.yml
       Avaliar:  python test.py  --model_config config/SISSA-L-A.yml --weights results/weights/SISSA-L-A/<melhor>.pt

    (Sem GPU? use config/SISSA-L-A-cpu.yml. Recomendado: GPU.)
EOF
