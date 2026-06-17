# Reprodução — Liu et al. (2024), SISSA (SOME/IP safety + security)

Reprodução organizada de:

> Q. Liu, X. Li, K. Sun, Y. Li, Y. Liu. *SISSA: Real-Time Monitoring of Hardware Functional
> Safety and Cybersecurity With In-Vehicle SOME/IP Ethernet Traffic.* IEEE Internet of Things
> Journal, 11(16):27322–27335, 2024.

Diferente dos outros trabalhos, o SISSA **publica código e dados** (repo oficial
[`jamesnulliu/SISSA`](https://github.com/jamesnulliu/SISSA)). Este repositório reúne os
**artefatos da nossa reprodução** que rodam *sobre* o código dos autores: um **notebook de
GPU** ponta-a-ponta, **configs adaptados**, a **análise do artigo** e os **resultados**.

## O que é o SISSA
Classificador de **7 classes** (`Normal, DDoS, FI, FS, ReqNoRes, ResNoReq, Failure`) sobre
janelas de pacotes SOME/IP, com 3 *backbones* (CNN, RNN, LSTM) ± **autoatenção residual
(RSAB)**. Cobre **cibersegurança** (DDoS, MITM) **e** *safety* (falha de hardware via Weibull).
Ver [docs/analise-artigo.md](docs/analise-artigo.md).

## Estrutura
```
SISSA-repro/
├── README.md
├── requirements.txt
├── setup_repro.sh              # clona o repo dos autores e aplica nossos configs (uso local)
├── notebooks/
│   └── SISSA_Colab.ipynb       # reprodução ponta-a-ponta na GPU (Colab)
├── configs/                    # nossos configs (janela 128 / CPU)
│   ├── basic-window128.yml     # basic.yml com window_height=128
│   ├── SISSA-L-A-cpu.yml
│   └── SISSA-L-A-cpu-w128.yml
└── docs/
    ├── analise-artigo.md       # análise do artigo
    └── resultados-gpu.md       # resultados da nossa reprodução
```

## Como reproduzir

### Opção 1 — Colab (recomendado)
Abra **`notebooks/SISSA_Colab.ipynb`** no Google Colab com **GPU** (Runtime → GPU). O notebook:
1. clona o repo dos autores e instala as dependências;
2. baixa o dataset oficial (`data.7z` do Google Drive) e extrai;
3. ajusta a **janela para 128** (fator decisivo: 64→128 elevou 94%→99%);
4. treina **SISSA-L-A** e **SISSA-L** (configs originais, `device: cuda`);
5. roda o `test.py` e apresenta **matriz de confusão + métricas por classe + curvas ROC**.

### Opção 2 — Local (com GPU)
```bash
bash setup_repro.sh            # clona jamesnulliu/SISSA e aplica os configs
cd SISSA && python train.py --model_config config/SISSA-L-A.yml
python test.py --model_config config/SISSA-L-A.yml --weights results/weights/SISSA-L-A/<melhor>.pt
```
O dataset (`data.7z`) deve ser baixado do Google Drive (link no
[Prepare_for_Dataset](https://github.com/jamesnulliu/SISSA/blob/main/docs/Prepare_for_Dataset.md))
e extraído na raiz do repo dos autores.

> **CPU:** sem GPU, use os configs `configs/SISSA-L-A-cpu*.yml` (`device: cpu`). Em CPU com
> janela 64 chegamos a 94,1%; a janela 128 fica lenta em CPU — prefira a GPU.

## Resultados da nossa reprodução
| Modelo | Val acc (GPU, janela 128) | Artigo |
|--------|--------------------------:|-------:|
| SISSA-L-A (LSTM + atenção) | **99,39%** | 99,7% |
| SISSA-L (LSTM puro) | **99,42%** | — |

**Achado:** a **janela 128** era o fator decisivo; a **autoatenção (RSAB) quase não ajudou**
(LSTM puro empata). Detalhes em [docs/resultados-gpu.md](docs/resultados-gpu.md).
