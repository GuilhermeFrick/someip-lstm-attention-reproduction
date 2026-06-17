# MEMORY — Reprodução SISSA (Liu et al. 2024)

Terceiro sub-projeto (autor **distinto**; memória mantida aqui, separada de LUO e Alkhatib).
Liu, Li, Sun, Li, Liu, *SISSA: Real-Time Monitoring of Hardware Functional Safety and
Cybersecurity With In-Vehicle SOME/IP Ethernet Traffic*, IEEE IoT Journal 2024.
Repo: github.com/jamesnulliu/SISSA.

## Natureza
- **Deep learning** (CNN/RNN/LSTM + Residual Self-Attention). NÃO usa regras.
- Classificação **7 classes**: Normal, DDoS, FI, FS, ReqNoRes, ResNoReq, Random HW Failure.
- **Unifica/estende Luo + Alkhatib** e adiciona **safety (falha de hardware via Weibull)**.
  Usa o mesmo SOME/IP Generator (Egomania) do Alkhatib.
- Melhor modelo do paper: **SISSA-L-A (LSTM+atenção), 99,7% val acc**. CNN é o pior (~72%).

## Localização e dados
- Repo: `C:/Mestrado/SISSA/SISSA-main` · Artigo+extração: `C:/Mestrado/SISSA/`
- **Dataset: `C:/Mestrado/SISSA/data`** (FORA do repo). Já preparado:
  train (14406, 128, 25) / val (3605, 128, 25), 7 classes balanceadas; window efetivo=64.
  Criada **junção** `SISSA-main/data` → `../data` para os caminhos relativos do repo funcionarem.

## Setup feito
- Deps instaladas: ruamel.yaml, torchinfo, concurrent_log_handler (rede via
  dangerouslyDisableSandbox; pip falha no sandbox padrão).
- **Adaptação CPU:** `config/SISSA-L-A-cpu.yml` (device: cpu, n_workers: 0). O original usa
  `device: cuda` (sem GPU aqui).
- Entrada: `python train.py --model_config config/SISSA-L-A-cpu.yml` (rodar de SISSA-main).
  `train.py` salva pesos só após época 69 (a cada 5). Teste: `test.py`.
- Smoke (3 ép): val acc 51→69% — pipeline OK, aprendizado rápido.

## Status / Resultados
- CPU / janela 64 / 100 épocas: SISSA-L-A = **94,1%** val acc.
- **GPU (Colab Tesla T4) / janela 128 / 200 épocas: SISSA-L-A = 99,39%, SISSA-L = 99,42%**
  (paper 99,7%). **Reprodução bem-sucedida** — a janela 128 era o fator decisivo (94%→99,4%).
  Achado: a atenção (RSAB) quase não ajudou (L ≈ L-A); RNN < LSTM (R-A ~95%). CNN e test.py
  (matriz de confusão por classe) ficaram pendentes (output do Colab truncado).
  Detalhes em docs/resultados-gpu.md.

## Detalhes não óbvios
- `sissautils.update_model_config()` REESCREVE o YAML passado (sincroniza n_pack/pack_dim/
  n_classes/train_dir/val_dir do basic.yml). window_height=64 em basic.yml trunca os 128→64.
- O ponto de entrada constrói o modelo via registry `SISSA_MODELS[type]` (models/__init__.py).
