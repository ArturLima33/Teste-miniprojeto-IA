# Roteiro de apresentação — 6 integrantes, 10 minutos cada

> Modelo de divisão. Preencher com nomes reais e ajustar os tempos. O professor exige mínimo de **10 minutos individuais**. Total previsto: 60–66 minutos.

| Integrante | Tempo | Conteúdo / como explicar | Evidência demonstrável |
|---|---|---|---|
| 1 — [NOME] | 10–11 min | Contexto de inteligência de enxames, satélite, o artigo (2025), o problema de otimizar C e gamma, por que SVM. | Página do artigo; dados do periódico; objetivo. |
| 2 — [NOME] | 10–11 min | Base PMLB, 6.435×36, 6 classes, divisão 80/20, validação interna, normalização sem vazamento, métricas. | `dataset_report.json`, `src/data.py`, `src/objective.py`. |
| 3 — [NOME] | 10–11 min | PSO, partícula/velocidade/pbest/gbest, tamanho da população 10, comparação com GA/SA/CS. | `src/optimizers.py` e config. |
| 4 — [NOME] | 10–11 min | BO, TPE, MCMC e SHA; papel dos métodos estatísticos; custo diferente do SHA; busca linear versus log. | Arquivos `evaluations`, `runs.csv` e gráficos. |
| 5 — [NOME] | 10–11 min | Implementação, testes de integração, interface e demo; mostrar o comando `--mode imbalance`; distinção smoke/real. | `pytest -q`, `python main.py --help`, execução real previamente concluída. |
| 6 — [NOME] | 10–11 min | Distinguir PSO adaptativo preexistente da NOVA extensão: fitness F1-macro e class_weight balanced. Explicar os quatro braços A–D, contrastes e resultados reais. | `statistics/ablation_summary.csv`, `ablation_paired_deltas.csv`, `per_class/` e gráficos A–D. |

## Perguntas que todos precisam conseguir responder

- **O que uma partícula representa?** Um par candidato `(C, gamma)` para SVM.
- **O que PSO otimiza?** Na reprodução, a acurácia. Na nova extensão, dependendo do braço, acurácia ou F1-macro de validação (fitness é seu negativo).
- **Por que o conjunto de teste fica isolado?** Para estimar generalização sem contaminar a escolha dos hiperparâmetros.
- **Por que normalização?** Distâncias do kernel RBF são sensíveis às escalas dos atributos. O scaler ajusta apenas dados de treinamento.
- **O que significa `C`?** Penalidade de erro/regularização na SVM: controla trade-off margem versus erro.
- **O que é `gamma`?** Controla a escala de influência das observações no kernel RBF.
- **SMOTE e dropout foram usados?** Não. A extensão testa pesos balanceados na SVM sem reamostrar; dropout não se aplica à SVM-RBF.
- **O que muda no novo PSO?** Inércia decrescente e reinicialização uniforme da pior partícula após duas gerações estagnadas (gBest preservado).
- **O SHA usa o mesmo orçamento?** Não no modo reprodução; registra 30/62/126 avaliações para 4/5/6 estágios.
- **Por que usar escala log?** C e gamma variam por múltiplas ordens de grandeza em intervalo amplo.
- **Pode comparar estatisticamente os dados com uma única base?** Apenas de forma exploratória, sem fazer afirmações universais.

- **Por que a melhoria foi implementada?** Satimage é multiclasse e parcialmente desbalanceada (razão ≈2,45); queremos testar se acurácia favorece classes frequentes.
- **O que é F1-macro?** Média aritmética do F1 de cada classe, independentemente do tamanho da classe.
- **Como os pesos são calculados?** Dentro do treino de cada fold, inversamente proporcionais à frequência de cada classe.
- **O que é A/B/C/D?** Quatro combinações de fitness (accuracy/f1_macro) e pesos (none/balanced); ajudam a separar efeitos individuais e combinados.
- **Como saber se deu certo?** Observar F1-macro, menor recall, acurácia e tempo na Satimage real; ganhos podem ter custo.

## Antes de apresentar

1. Rodar experimentos completos na Satimage real e guardar `experiment_manifest.json`.
2. Ler o CSV `runs.csv`, confirmar todos com `status=ok` e as contagens da base.
3. Colocar médias, desvios e gráficos reais nos slides indicados como pendentes.
4. Registrar quem realmente implementou, revisou, escreveu, criou slides e validou.
5. Testar a apresentação e cronometrar 10 min **por integrante**.
