# Miniprojeto de Inteligência Computacional — SVM Satimage e algoritmos de otimização

**Implementação executável, testada e documentada** do estudo de Rizkallah (2025) com extensão experimental própria.

> **Estado da validação:** todos os 21 testes `pytest` passaram; os oito algoritmos do artigo foram executados em uma base **sintética, exclusivamente para verificar a integração**. **A base real Satimage não pôde ser baixada no ambiente de criação**. Portanto, arquivos em `results/verificacao_*` NÃO são resultados da pesquisa e NÃO devem ser apresentados como tais. A reprodução real pode ser iniciada com os comandos abaixo, em máquina com acesso à base PMLB.

## NOVA EXTENSÃO — F1-macro e balanceamento de classes (versão 2)

**Problema observado:** a Satimage possui classes de tamanhos diferentes (valores publicados em estudos sobre Satimage: 1533/703/1358/626/707/1508; razão 2,45). Otimizar apenas a acurácia pode privilegiar acertos das classes maiores. A comparação usa métricas por classe, não apenas acurácia agregada. O artigo não conduz essa análise fatorial.

**Mudança efetivamente implementada:** o mecanismo de avaliação da SVM passou a aceitar `fitness_metric` (`accuracy` ou `f1_macro`) e `class_weight` (`none` ou `balanced`). Na opção balanced, o próprio SVC atribui pesos inversamente proporcionais às frequências **somente no fold de treinamento**. Não se cria dado sintético e não se altera validação nem teste. O PSO adaptativo preexistente e o PSO clássico são usados como dois otimizadores independentes para verificar a robustez do efeito.

| Braço | fitness da validação | class_weight da SVM |
|---|---|---|
| A (controle) | accuracy | none |
| B | f1_macro | none |
| C | accuracy | balanced |
| D | f1_macro | balanced |

**Hipótese pré-definida:** D pode melhorar F1-macro e menor recall individual em relação a A; registrar também qualquer queda de acurácia ou aumento de tempo. Como não há garantia de melhora, evitar escrever "D foi melhor" antes de analisar Satimage real. Como métrica principal, relatar diferença de **F1-macro (D−A)**, médias e desvios por semente, por otimizador e orçamento; de forma secundária, menor recall por classe, balanced accuracy, acurácia global e tempo.

**Execução em Codespaces/Linux (terminal pode estar em qualquer diretório):**

```bash
python -m pip install -r requirements.txt
python -m pytest -q
python main.py --mode imbalance --dry-run
# verificação rápida, dados ARTIFICIAIS:
python main.py --mode imbalance --smoke --budgets 10 --seeds 0
# execução científica: Satimage REAL, 2 PSOs × 4 braços × 2 orçamentos × 5 sementes:
python main.py --mode imbalance
# execução real mais curta para validação preliminar:
python main.py --mode imbalance --budgets 20 --seeds 0 1 2
```

Se executar de fora da pasta, use `python /caminho/para/miniprojeto_enxames/main.py --mode imbalance`. O caminho-padrão de configuração e base é relativo ao projeto, corrigindo o problema de execução visto anteriormente. `--out` permite escolher a pasta dos resultados.

**Novos arquivos de resultados:** `statistics/ablation_summary.csv` (média/DP das quatro condições), `statistics/ablation_paired_deltas.csv` (efeitos variante − controle A com sementes pareadas), `per_class/*.csv` (precisão, recall, F1 e suporte por classe), gráficos `figures/ablation_*.png`, histórico das avaliações com `val_accuracy`, `val_f1_macro` e `best_val_score`. Nos arquivos CSV, `best_val_score` é a métrica selecionada na validação; `best_val_accuracy` é a acurácia de validação da solução selecionada (não necessariamente a métrica otimizada).

**Salvaguardas:** a reprodução do artigo continua obrigatoriamente `accuracy+none`. Para as novas experiências, nenhum valor do teste entra na função objetivo. Os resultados do modo `--smoke` são apenas de funcionamento, nunca evidência científica. Para interpretar a Satimage use `runs.csv` (filtre `status==ok`, `smoke==False`, `quick==False`) e o `dataset_report.json`. A comparação A×D faz análise exploratória sobre uma única divisão fixa; evitar testes de significância como prova de superioridade geral.

**Nota:** SMOTE/Tomek NÃO foram implementados: `class_weight=balanced` é uma alternativa simples, parametrizada e sem geração ou exclusão de amostras, mais adequada a esta extensão controlada. Dropout e transfer learning continuam não aplicáveis à SVM-RBF.

## 1. Artigo (aplicação de inteligência computacional)

- **Título:** Optimizing SVM hyperparameters for satellite imagery classification using metaheuristic and statistical techniques.
- **Autora:** Lydia Wahid Rizkallah.
- **Periódico:** *International Journal of Data Science and Analytics* — Springer, volume 20, páginas 4945–4962.
- **Publicação:** 17 de abril de 2025.
- **DOI:** https://doi.org/10.1007/s41060-025-00762-7
- **Fator de impacto informado pela Springer:** **Journal Impact Factor de 2,9 (2025)**, periódico indexado no **Emerging Sources Citation Index (ESCI / Web of Science)**. Fonte: https://link.springer.com/journal/41060 . Se for exigida comprovação formal no JCR, apresentar a página/consulta do JCR da instituição.

**Objetivo:** encontrar os melhores hiperparâmetros da SVM com kernel RBF: penalidade de regularização `C` e largura do kernel `gamma`, maximizando a acurácia de classificação Satimage. A pesquisa compara oito métodos: PSO, SA, GA, CS, BO, SHA, TPE e MCMC-MH.

## 2. Executar em Windows / Linux / Codespaces

Recomendado: Python 3.10–3.12, pelo menos 8 GB de RAM para execuções longas.

Abra o terminal **na pasta do projeto** e execute:

```bash
python -m pip install -r requirements.txt
python -m pytest -q
python main.py --mode reproduction --dry-run
python main.py --mode extension --smoke --methods pso adaptive_pso --spaces wide --scales log --budgets 20 --seeds 0
```

O último comando usa dados gerados artificialmente e serve **somente como teste funcional**.

### Obter os dados reais

Dataset: `294_satellite_image` (Satimage), Penn Machine Learning Benchmarks (PMLB), 6.435 linhas, 36 atributos, seis classes.

1. Em uma máquina com internet, simplesmente execute o comando real abaixo: o programa tenta baixar automaticamente `data/294_satellite_image.tsv.gz` de uma rota de mídia Git LFS.
2. Se o download não funcionar, abra a [página oficial do dataset](https://github.com/EpistasisLab/pmlb/tree/master/datasets/294_satellite_image), baixe o arquivo **comprimido real** `294_satellite_image.tsv.gz` (não o ponteiro Git LFS) e coloque-o em `data/`.
3. Ou indique o caminho manual: `--data-path "C:\\dados\\294_satellite_image.tsv.gz"`.

O programa **confere 6.435 × 36, seis classes e gzip válido**; se o arquivo não é autêntico/compatível, falha de forma explícita.

### Rodar reprodução real do artigo

```bash
# Experimento muito curto para conferir processamento COM SATIMAGE REAL (ainda não é completo)
python main.py --mode reproduction --quick --methods pso tpe --spaces narrow --budgets 20 --seeds 0

# Experimento do artigo: 8 algoritmos, espaços narrow/wide, 20/50/100, 3 sementes (144 execuções)
python main.py --mode reproduction

# Versão curta para a demonstração com base real
python main.py --mode reproduction --methods pso ga tpe sha --spaces narrow --budgets 20 --seeds 0
```

**Importante:** a execução completa pode consumir muito tempo de CPU (são milhares de ajustes SVM). Use `--dry-run` para ver o volume antes. O SHA usa **30/62/126 avaliações reais** quando os demais usam **20/50/100**, porque os valores 4/5/6 informados pelo artigo se referem a estágios; isso fica registrado em `n_evals` e `equivalent_full_evals`. Portanto, não afirme que o tempo e orçamento de SHA são rigorosamente iguais aos demais.

### Rodar extensão original (questão dos 2 pontos)

```bash
# Todos os métodos configurados para extensão, 5 sementes, busca linear vs log, orçamento controlado
python main.py --mode extension

# A principal hipótese de modificação é comparar PSO e PSO adaptativo, na MESMA escala
python main.py --mode extension --methods pso adaptive_pso --scales log --spaces wide --budgets 20 50 --seeds 0 1 2 3 4

# Validação cruzada como análise de sensibilidade (maior custo)
python main.py --mode extension --methods pso adaptive_pso --validation cv --scales log --spaces wide --budgets 20 --seeds 0 1 2
```

A opção `--mode extension` possui cinco algoritmos: PSO original, **PSO adaptativo (modificação implementada)**, TPE (referência do artigo), Random Search e Grid Search (baselines). Analisa adicionalmente linear versus log no espaço amplo. Ambos os PSOs usam **10 partículas** e o **mesmo número de chamadas da função objetivo** (20/50) — comparação de orçamento controlado. Sem resultados reais, **não se pode afirmar que o PSO adaptativo melhorou a acurácia**.

### Outras opções

```bash
python main.py --help
python main.py --mode reproduction --validation cv --spaces wide --budgets 20 --seeds 0
python main.py --mode extension --out results/minha_rodada
```

Nunca misture `--smoke` (sintético), `--quick` (subamostra real) e execução completa ao formular conclusões científicas.

## 3. O que cada arquivo entrega

- `src/data.py`: download/checagem do PMLB, SHA256, descrição das classes e divisão estratificada.
- `src/objective.py`: busca em `[0,1]²` convertida em `C, gamma`, validação holdout ou CV, normalização sem vazamento do teste, fitness igual a **menos acurácia**.
- `src/optimizers.py`: oito métodos do artigo e três métodos extras, implementação explícita sem dependência de Optuna.
- `src/runner.py`: execução, rastreamento de sementes, tempos, CSVs, testes exploratórios e gráficos.
- `main.py`: interface por terminal.
- `config/experiments.json`: todos os parâmetros e cenários reproduzíveis.
- `tests/test_miniprojeto.py`: 16 testes de integridade da implementação.
- `results/<execução>/`: `experiment_manifest.json`, `dataset_report.json`, `runs.csv`, `aggregated.csv`, `evaluations/`, `confusion/`, `statistics/`, `figures/`.
- `docs/`: relatório editável, slides e roteiro de apresentação.

Em `runs.csv`, **`best_val_accuracy`** serve à seleção do método durante o treinamento; **`test_accuracy`** é produzido apenas no teste final, após escolher `C` e `gamma`. A escolha do MELHOR algoritmo para fins de resultado científico deve usar comparação de médias e dispersões dentro do mesmo espaço/escala/orçamento, não escolher um resultado isolado do teste por conveniência.

## 4. Exigências do professor (atendidas ou justificadas)

| Exigência | Resposta metodológica e local |
|---|---|
| Base | Satimage PMLB, 6.435 amostras, 36 atributos numéricos, 6 classes; `dataset_report.json` valida a integridade e a distribuição real quando baixada. |
| População de inteligência de enxames | **PSO: 10 partículas**; CS: 10 ninhos; GA: 10 indivíduos. `config/experiments.json`. |
| Treinamento e teste | **80% / 20%** estratificado; dentro dos 80% de treino, **20% para validação**. Em 6.435 registros: 5.148 treino, 1.287 teste; aproximadamente 4.118 para ajuste e 1.030 para validação. |
| Validação cruzada | Artigo: não esclarece. Implementação: padrão **holdout estratificado**; opção **3-fold CV** com `--validation cv`. |
| Algoritmos | Os 8 do artigo (PSO, SA, GA, CS, BO, SHA, TPE, MCMC) + PSO adaptativo, Random Search, Grid Search. |
| Hiperparâmetros | Busca de `C` e `gamma` com faixas estreita/ampla do artigo, nas escalas linear e log. Parâmetros internos fixados/registrados no JSON (não é correto dizer que usamos grid search para escolher esses parâmetros internos). |
| Transfer learning | Não empregado: não há redes pré-treinadas; SVM tabular do zero. |
| Regularização | SVM usa **C** como penalização; dropout não se aplica a SVC-RBF. |
| Aumento de dados | Não usado; haveria risco de alterar a distribuição de referência. |
| Desbalanceamento | Classes contadas; métricas **macro e weighted**. Não foi empregado SMOTE/Tomek por padrão. Se fosse adicionado, teria de ser aplicado somente aos folds de treinamento, nunca sobre validação/teste. |
| Métricas | Acurácia, precisão/recall/F1 micro/macro/weighted, matrizes de confusão, tempo de otimização, avaliações da função objetivo e custo de SHA. |
| Implementação/fontes | Python, NumPy, scikit-learn, SciPy, pandas e Matplotlib. Fonte primária artigo e PMLB. |
| Alteração original de 2 pontos | **Adaptive PSO**: inércia varia linearmente de 0,9 a 0,4; reinicialização gaussiana de uma partícula ao estagnar por 2 gerações. Ablation contra PSO com mesmas sementes e orçamento; mais comparação linear vs log. |
| Trabalho individual | Preencher nomes e contribuições **reais** no relatório (não há como inferi-las). |
| Slides / tempo | Apresentação editável e roteiro para **seis blocos de aproximadamente 10 min**; inserir resultados reais antes de apresentar. |

## 5. Limitações e escolhas conscientes

**Reprodução metodológica aproximada, não reimplementação bit a bit:** o artigo não documenta escala das variáveis, conjunto de validação, parâmetros detalhados dos otimizadores nem todas as sementes. Adotamos `StandardScaler` treinado separadamente dentro de cada fold, split 80/20, holdout interno e limites publicados. O PSO e os outros algoritmos usam orçamento de **avaliações**, enquanto o artigo usa a palavra 'iterações' sem esclarecer equivalência; registramos a diferença. Os métodos BO, TPE, CS e SHA são variantes próprias e podem diferir de pacotes de terceiros.

**Sobre inferência estatística:** Friedman/Wilcoxon são **exploratórios**; blocos criados de uma mesma base e sementes compartilhadas não são estudos independentes, e os p-valores sem ajuste múltiplo não devem fundamentar afirmações gerais de superioridade. Observar acurácia de teste para escolher hiperparâmetros também seria vazamento: aqui isso foi evitado.

**Sobre resultados:** executar o código é parte obrigatória da atividade. Não basta apresentar o artigo, o script ou os dados sintéticos. Use os dados reais antes da apresentação, registre as falhas e apresente os próprios resultados.

## 6. Fontes usadas

1. Rizkallah, Lydia Wahid. (2025). *Optimizing SVM hyperparameters for satellite imagery classification using metaheuristic and statistical techniques*. https://doi.org/10.1007/s41060-025-00762-7
2. Springer Nature. *International Journal of Data Science and Analytics*: JIF 2,9 (2025) e indexação ESCI. https://link.springer.com/journal/41060
3. Penn Machine Learning Benchmarks, EpistasisLab. *294_satellite_image*. https://github.com/EpistasisLab/pmlb/tree/master/datasets/294_satellite_image
4. Scikit-learn developers. *SVC*, *StratifiedKFold*, *StandardScaler* e métricas. https://scikit-learn.org/stable/
5. SciPy developers. Distribuições e testes não paramétricos. https://docs.scipy.org/doc/scipy/

### Checklist de entrega

- [x] Implementação dos 8 algoritmos do artigo com API unificada.
- [x] Implementação real da modificação do PSO e comparação controlada.
- [x] Testes automatizados e execução integrada em base sintética.
- [x] Documento editável e apresentação inicial.
- [ ] Obter/rodar a base Satimage real e apresentar `runs.csv` / `aggregated.csv` reais.
- [ ] Preencher nomes e contribuições verificadas de cada integrante.
- [ ] Substituir slides de resultados pendentes por tabelas/gráficos da execução real.

### Preencher Word e PowerPoint automaticamente DEPOIS da execução real

Depois de executar `python main.py --mode imbalance`, localize a pasta recém-criada em `results/` e execute, por exemplo:

```bash
python gerar_documentos_com_resultados.py --results results/imbalance_20261027_120000 --budget 20
```

Substitua o nome da pasta pelo valor real gerado. O programa exige que ambos os PSOs tenham executado **A, B, C e D com as mesmas sementes**, recusa resultados de `--smoke` e de `--quick`, verifica o formato e o hash da Satimage e gera cópias preenchidas em `<resultados>/documentos_preenchidos/`, sem modificar os modelos originais. O slide 29 exibe os efeitos B−A, C−A e D−A em F1-macro. O relatório recebe médias e desvios de F1-macro, acurácia, pior recall por classe e tempo. Confira os gráficos e análise de classes antes de submeter ao professor.

**Não invente nem substitua números dos experimentos.** Caso o gerador recuse uma execução incompleta, conclua os experimentos faltantes em vez de preencher os campos manualmente com valores não verificados.
