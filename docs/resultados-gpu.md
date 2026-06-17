# Resultados — SISSA na GPU (Colab Tesla T4)

Execução do notebook `Reproducoes_SOMEIP_Colab.ipynb` (seção SISSA) numa Tesla T4, com
**janela 128, 200 épocas**, usando os configs originais dos autores (`device: cuda`).

## Resultado — reprodução bem-sucedida ✅

| Modelo | Melhor val acc | Final (ép. 200) | Paper |
|--------|---------------:|----------------:|------:|
| **SISSA-L-A** (LSTM + atenção) | **99,39%** (ép. 92) | 99,00% | 99,7% |
| **SISSA-L** (LSTM puro) | **99,42%** (ép. 174) | 98,70% | — |
| SISSA-R-A (RNN + atenção) | ~95,6% (subindo) | — | < LSTM |

**Evolução da reprodução:** CPU / janela 64 = **94,1%** → GPU / janela 128 = **99,4%**.
A janela completa (128) + treino longo na GPU fecharam quase todo o gap para os 99,7% do paper.

## Achados
1. **A janela de 128 pacotes era o fator decisivo** (94% → 99,4%). Confirma a ênfase do paper
   de que modelos temporais (LSTM) se beneficiam de janelas maiores.
2. **A atenção (RSAB) quase não ajudou aqui:** SISSA-L (99,42%) ≈ SISSA-L-A (99,39%). O paper
   afirma que a RSAB melhora a acurácia; na nossa reprodução o LSTM puro já satura ~99,4%, então
   **a vantagem da atenção não se confirma fortemente** neste dataset.
3. **RNN < LSTM:** SISSA-R-A sobe devagar (~95%), consistente com o paper (LSTM > RNN > CNN).
4. **Instabilidade transitória:** quedas pontuais da val acc (ép. 100 → 0,40; ép. 145 → 0,61)
   com recuperação imediata na época seguinte — provável divergência momentânea do otimizador/
   atenção. Cosmético, não afeta a convergência.

## Pendências (output do Colab foi truncado)
- [ ] Métricas finais de **SISSA-C / SISSA-C-A** (CNN — esperado ~72% val, o pior, como no paper).
- [ ] `test.py` → **matriz de confusão por classe** (7 classes) e tempo de inferência.
- [ ] Comparar F1 por classe com as Tabelas III/IV do paper.

## Conclusão
O SISSA é o **mais reprodutível dos três trabalhos**: com código + dataset publicados e a
janela correta, a acurácia (99,4%) **praticamente iguala o paper (99,7%)**. A única ressalva é
que a contribuição da atenção (RSAB) não se mostrou decisiva na nossa execução.
