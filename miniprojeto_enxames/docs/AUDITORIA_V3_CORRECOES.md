# Auditoria v3 — Correções aplicadas

**Estado:** código e testes funcionais validados em ambiente Linux com 25 testes aprovados. Teste de integração: 8/8 cenários com dados sintéticos. **Nenhum resultado científico na Satimage foi produzido nesta auditoria.**

## O que foi corrigido

1. **PSO adaptativo:** inércia de 0,9 (primeira geração) a 0,4 (última geração, quando existem várias). A inicialização das dez partículas não consome gerações de movimento. Reinicialização da pior partícula após 2 gerações estagnadas (posição, velocidade, pBest), sem perder gBest. Histórico registra inércia e reinício, com custo contado no orçamento.
2. **Successive Halving:** ordem pseudoaleatória por quantis por classe; qualquer prefixo mantém aproximadamente a distribuição original. Antes havia balanceamento artificial por round-robin.
3. **Avaliação fatorial:** resultados `statistics/ablation_interactions.csv` para I = D−B−C+A e `statistics/adaptive_vs_pso_paired.csv` para diferença PSO adaptativo−PSO, pareados por semente, escala, espaço, orçamento e condição.
4. **Orçamentos:** o modo `imbalance` contempla 20, 50 e 100 avaliações. Com 10 partículas, 20 avaliações só permitem 1 geração de atualização; 100 oferecem 9 gerações.
5. **Documentos:** o gerador de Word preenche a tabela geral para os PSOs (braço A) e marca TPE/Random como não avaliados nesse modo; evita valores fictícios. Slides passam a citar interação e características corrigidas.

## Executar

```bash
cd /workspaces/Seminario-IA/miniprojeto_enxames
python -m pip install -r requirements.txt
python -m pytest -q
python main.py --mode imbalance --dry-run
python main.py --mode imbalance --budgets 100 --seeds 0 --out results/estudo_100_seed0
```

Depois, para execução integral com a Satimage real:

```bash
python main.py --mode imbalance --out results/estudo_completo_v3
python gerar_documentos_com_resultados.py --results results/estudo_completo_v3 --budget 100
```

A execução completa gera até **120 execuções / 6800 avaliações SVM** e pode demorar. O gerador exige ambos os PSOs, braços A–D e sementes correspondentes; não aceita `--smoke`/`--quick`. Conservar resultados antigos em outra pasta; não misturar com a nova versão.

## Pendente da equipe

- Executar a **Satimage real**, conferir `runs.csv` (`status == ok`), manifestos e per_class.
- Revisar Word e slides gerados e inserir os resultados efetivos, gráficos e conclusões.
- Preencher contribuições reais dos seis integrantes; treinar explicação de >= 10 minutos por pessoa.
- Validar bibliografia/JCR segundo exigência institucional.

A análise de interações é exploratória quando todas as sementes compartilham uma única divisão de teste; não atribuir significância externa aos resultados sem estudo adicional.
