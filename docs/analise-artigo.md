# Análise do Artigo — Liu et al. SISSA (2024)

**Referência:** Q. Liu, X. Li, K. Sun, Y. Li, Y. Liu, *SISSA: Real-Time Monitoring of Hardware
Functional Safety and Cybersecurity With In-Vehicle SOME/IP Ethernet Traffic*,
IEEE Internet of Things Journal, vol. 11, no. 16, 2024. DOI 10.1109/JIOT.2024.3397665.
Repo: https://github.com/jamesnulliu/SISSA · **Texto-fonte:** [../sissa_article.txt](../sissa_article.txt)

## É ML ou regras?
**100% deep learning** (CNN/RNN/LSTM + self-attention). Não usa regras.

## O que faz (7 classes)
Monitora tráfego SOME/IP e classifica janelas em **7 classes**, unificando **safety** e **security**:
`Normal · DDoS · Fake Interface (FI) · Fake Source (FS) · Request-without-Response (ReqNoRes)
· Response-without-Request (ResNoReq) · Random Hardware Failure`

- **Security:** DDoS, MITM (FI/FS), processos de comunicação anormais (ReqNoRes/ResNoReq).
- **Safety:** falha aleatória de hardware modelada por **distribuição de Weibull** (efeito banheira).

## Pipeline
1. **Geração de dados** — SOME/IP Generator (Egomania, o MESMO do Alkhatib), estendido com
   scripts de ataque (`preprocess/manipulator/attacks/`) e falhas Weibull (`hardware_failures/`).
2. **Pré-processamento** — janela de *n* pacotes; campos categóricos (Message Type, Return Code)
   em **one-hot**; demais via **PMB (Packet Mapping Block)** = transformação afim aprendível
   `A(m)=Wm+b` para dimensão *d*. Janela vira matriz *n×d*.
3. **Backbones (6 modelos)** — CNN, RNN, LSTM, cada um **com/sem Residual Self-Attention (RSAB)**:
   SISSA-C/-C-A, -R/-R-A, -L/-L-A. RSAB = atenção `softmax(QKᵀ/√dk)V` + conexão residual.
4. **Saída** — MLP → softmax 7 classes.

## Resultados (paper)
- **Melhor: SISSA-L-A (LSTM + atenção) — 99,7% val acc**; F1 médio 99,2% (safety) / 99,86% (security).
- **CNN é o pior** (val ~72%): não captura a dinâmica temporal.
- RSAB estabiliza o treino e melhora a acurácia (mas precisa de mais épocas).
- Inferência <1 ms/janela (RTX3090); ~80 ms/janela (Raspberry Pi).
- Treino: AdamW, lr 1e-4, weight_decay 1e-4, batch 128, até 150–200 épocas, CrossEntropy.

## Relação com Luo e Alkhatib (é a síntese dos dois + safety)
| | Alkhatib 2021 | Luo 2023 | **SISSA 2024** |
|---|---|---|---|
| Abordagem | RNN | Regras + multi-GRU | **CNN/RNN/LSTM + atenção** |
| Req/Resp anomalies | ✅ | ✅ (regras) | ✅ (ReqNoRes/ResNoReq) |
| DDoS/DoS | — | ✅ | ✅ |
| MITM/Spoof | — | ✅ | ✅ (FI/FS) |
| **Falha de hardware (safety)** | — | — | ✅ **(inédito)** |
| Gerador de dados | Egomania | Prescan/CANoe | Egomania (estendido) |
| Código + dados | ✅ | só dataset | ✅ |

➡️ SISSA **unifica** as anomalias de comunicação do Alkhatib + os ataques do Luo num framework
multi-classe de DL com atenção, e **adiciona a dimensão de safety (Weibull)**. Os três formam
uma progressão: Alkhatib (RNN, comm-anomalies) → Luo (multicamada, regras+GRU) → SISSA (DL+atenção, safety+security).

## Reprodutibilidade
- **Código + dataset locais** (dataset em `C:/Mestrado/SISSA/data`, já preparado em train/val).
- Dados: train (14406, 128, 25) / val (3605, 128, 25), **7 classes balanceadas**.
  (window_height efetivo = 64 no `basic.yml`; pack_dim = 25.)
- Adaptação necessária: `device: cuda → cpu` (sem GPU aqui). Foco no **SISSA-L-A** (o melhor).
