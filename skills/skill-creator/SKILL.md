---
name: skill-creator
description: Crie novas habilidades, modifique e aprimore habilidades existentes, e meça o desempenho das habilidades. Use quando os usuários desejam criar uma habilidade do zero, editar ou otimizar uma habilidade existente, executar avaliações para testar uma habilidade, comparar o desempenho da habilidade com análise de variância ou otimizar a descrição de uma habilidade para maior precisão de acionamento.
---

# Criador de Habilidades

Uma habilidade para criar novas habilidades e aprimorá-las iterativamente.

Em um nível alto, o processo de criação de uma habilidade funciona assim:

-   Decida o que você quer que a habilidade faça e, aproximadamente, como ela deve fazer
-   Escreva um rascunho da habilidade
-   Crie alguns prompts de teste e execute o Claude com acesso à habilidade neles
-   Ajude o usuário a avaliar os resultados de forma qualitativa e quantitativa
    -   Enquanto as execuções acontecem em segundo plano, rascunhe algumas avaliações quantitativas se não houver nenhuma (se houver, você pode usá-las como estão ou modificá-las se sentir que algo precisa mudar). Em seguida, explique-as ao usuário (ou se já existiam, explique as que já existem)
    -   Use o script `eval-viewer/generate_review.py` para mostrar os resultados ao usuário para que ele os examine, e também deixe-o ver as métricas quantitativas
-   Reescreva a habilidade com base no feedback da avaliação dos resultados pelo usuário (e também se houver falhas evidentes que se tornem aparentes a partir dos benchmarks quantitativos)
-   Repita até ficar satisfeito
-   Expanda o conjunto de testes e tente novamente em maior escala

Seu trabalho ao usar esta habilidade é descobrir onde o usuário está neste processo e, em seguida, intervir e ajudá-lo a progredir por essas etapas. Por exemplo, talvez eles digam "Eu quero criar uma habilidade para X". Você pode ajudar a refinar o que eles querem dizer, escrever um rascunho, escrever os casos de teste, descobrir como eles querem avaliar, executar todos os prompts e repetir.

Por outro lado, talvez eles já tenham um rascunho da habilidade. Neste caso, você pode ir direto para a parte de avaliação/iteração do loop.

Claro, você deve ser sempre flexível e, se o usuário disser "Não preciso fazer um monte de avaliações, apenas me ajude", você pode fazer isso.

Então, depois que a habilidade estiver pronta (mas, novamente, a ordem é flexível), você também pode executar o aprimorador de descrição da habilidade, para o qual temos um script separado, a fim de otimizar o acionamento da habilidade.

Legal? Legal.

## Comunicação com o usuário

O criador de habilidades é propenso a ser usado por pessoas com uma ampla gama de familiaridade com o jargão de codificação. Se você não ouviu (e como poderia, é só muito recentemente que começou), há uma tendência agora onde o poder do Claude está inspirando encanadores a abrir seus terminais, pais e avós a procurar "como instalar npm". Por outro lado, a maioria dos usuários provavelmente é bastante familiarizada com computadores.

Portanto, preste atenção às pistas de contexto para entender como deve formular sua comunicação! No caso padrão, apenas para lhe dar uma ideia:

-   "avaliação" e "benchmark" são limítrofes, mas OK
-   para "JSON" e "asserção", você deve ver pistas sérias do usuário de que ele sabe o que são essas coisas antes de usá-las sem explicá-las

É OK explicar brevemente os termos se você estiver em dúvida, e sinta-se à vontade para esclarecer os termos com uma breve definição se não tiver certeza se o usuário vai entender.

---

## Criando uma habilidade

### Capture a Intenção

Comece entendendo a intenção do usuário. A conversa atual pode já conter um fluxo de trabalho que o usuário deseja capturar (por exemplo, ele diz "transforme isso em uma habilidade"). Se for o caso, extraia as respostas do histórico da conversa primeiro — as ferramentas usadas, a sequência de etapas, as correções que o usuário fez, os formatos de entrada/saída observados. O usuário pode precisar preencher as lacunas e deve confirmar antes de prosseguir para a próxima etapa.

1.  O que esta habilidade deve permitir que o Claude faça?
2.  Quando esta habilidade deve ser acionada? (quais frases/contextos do usuário)
3.  Qual é o formato de saída esperado?
4.  Devemos configurar casos de teste para verificar se a habilidade funciona? Habilidades com saídas objetivamente verificáveis (transformações de arquivos, extração de dados, geração de código, etapas de fluxo de trabalho fixas) se beneficiam de casos de teste. Habilidades com saídas subjetivas (estilo de escrita, arte) geralmente não precisam. Sugira o padrão apropriado com base no tipo de habilidade, mas deixe o usuário decidir.

### Entrevista e Pesquisa

Faça proativamente perguntas sobre casos extremos, formatos de entrada/saída, arquivos de exemplo, critérios de sucesso e dependências. Espere para escrever os prompts de teste até que você tenha essa parte resolvida.

Verifique os MCPs disponíveis - se úteis para pesquisa (pesquisar documentos, encontrar habilidades semelhantes, procurar as melhores práticas), pesquise em paralelo via subagentes, se disponíveis, caso contrário, em linha. Venha preparado com o contexto para reduzir a carga sobre o usuário.

### Escreva o SKILL.md

Com base na entrevista com o usuário, preencha estes componentes:

-   **name**: Identificador da habilidade
-   **description**: Quando acionar, o que faz. Este é o principal mecanismo de acionamento - inclua tanto o que a habilidade faz QUANTO contextos específicos para quando usá-la. Todas as informações "quando usar" vão aqui, não no corpo. Nota: atualmente, o Claude tem uma tendência a "subacionar" habilidades - a não usá-las quando seriam úteis. Para combater isso, torne as descrições das habilidades um pouco "agressivas". Por exemplo, em vez de "Como construir um painel simples e rápido para exibir dados internos da Anthropic.", você pode escrever "Como construir um painel simples e rápido para exibir dados internos da Anthropic. Certifique-se de usar esta habilidade sempre que o usuário mencionar painéis, visualização de dados, métricas internas ou quiser exibir qualquer tipo de dados da empresa, mesmo que não peça explicitamente por um 'painel'."
-   **compatibility**: Ferramentas necessárias, dependências (opcional, raramente necessário)
-   **o resto da habilidade :)**

### Guia de Escrita de Habilidades

#### Anatomia de uma Habilidade

```
nome-da-habilidade/
├── SKILL.md (obrigatório)
│   ├── YAML frontmatter (nome, descrição obrigatórios)
│   └── Instruções Markdown
└── Recursos Agrupados (opcional)
    ├── scripts/    - Código executável para tarefas determinísticas/repetitivas
    ├── references/ - Documentos carregados no contexto conforme necessário
    └── assets/     - Arquivos usados na saída (modelos, ícones, fontes)
```

#### Divulgação Progressiva

As habilidades usam um sistema de carregamento de três níveis:
1.  **Metadados** (nome + descrição) - Sempre em contexto (~100 palavras)
2.  **Corpo do SKILL.md** - Em contexto sempre que a habilidade é acionada (idealmente <500 linhas)
3.  **Recursos agrupados** - Conforme necessário (ilimitado, scripts podem ser executados sem carregamento)

Essas contagens de palavras são aproximadas e você pode estender se necessário.

**Padrões chave:**
-   Mantenha o SKILL.md com menos de 500 linhas; se você estiver se aproximando desse limite, adicione uma camada adicional de hierarquia junto com ponteiros claros sobre onde o modelo que usa a habilidade deve ir em seguida para dar seguimento.
-   Referencie arquivos claramente do SKILL.md com orientação sobre quando lê-los
-   Para arquivos de referência grandes (>300 linhas), inclua um índice

**Organização por domínio**: Quando uma habilidade suporta vários domínios/frameworks, organize por variante:
```
implantar-na-nuvem/
├── SKILL.md (fluxo de trabalho + seleção)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```
Claude lê apenas o arquivo de referência relevante.

#### Princípio da Ausência de Surpresa

Isso nem precisa ser dito, mas as habilidades não devem conter malware, código de exploração ou qualquer conteúdo que possa comprometer a segurança do sistema. O conteúdo de uma habilidade não deve surpreender o usuário em sua intenção se descrito. Não concorde com solicitações para criar habilidades enganosas ou habilidades projetadas para facilitar acesso não autorizado, exfiltração de dados ou outras atividades maliciosas. Coisas como um "roleplay como um XYZ" são OK.

#### Padrões de Escrita

Prefira usar a forma imperativa nas instruções.

**Definindo formatos de saída** - Você pode fazer assim:
```markdown
## Estrutura do relatório
SEMPRE use este modelo exato:
# [Título]
## Resumo executivo
## Principais descobertas
## Recomendações
```

**Padrão de exemplos** - É útil incluir exemplos. Você pode formatá-los assim (mas se "Entrada" e "Saída" estiverem nos exemplos, talvez você queira desviar um pouco):
```markdown
## Formato da mensagem de commit
**Exemplo 1:**
Entrada: Adicionada autenticação de usuário com tokens JWT
Saída: feat(auth): implementar autenticação baseada em JWT
```

### Estilo de Escrita

Tente explicar ao modelo por que as coisas são importantes em vez de "DEVE"s pesados e rígidos. Use a teoria da mente e tente tornar a habilidade geral e não super-restrita a exemplos específicos. Comece escrevendo um rascunho e, em seguida, olhe para ele com novos olhos e melhore-o. Faça o seu melhor para entrar na cabeça do usuário e entender o que ele quer e precisa.

### Casos de Teste

Depois de escrever o rascunho da habilidade, crie 2-3 prompts de teste realistas - o tipo de coisa que um usuário real realmente diria. Compartilhe-os com o usuário: [você não precisa usar esta linguagem exata] "Aqui estão alguns casos de teste que eu gostaria de experimentar. Eles parecem corretos, ou você gostaria de adicionar mais?" Em seguida, execute-os.

Salve os casos de teste em `evals/evals.json`. Não escreva as asserções ainda - apenas os prompts. Você rascunhará as asserções na próxima etapa enquanto as execuções estiverem em andamento.

```json
{
  "skill_name": "habilidade-exemplo",
  "evals": [
    {
      "id": 1,
      "prompt": "Prompt da tarefa do usuário",
      "expected_output": "Descrição do resultado esperado",
      "files": []
    }
  ]
}
```

Veja `references/schemas.md` para o esquema completo (incluindo o campo `assertions`, que você adicionará mais tarde).

## Executando e avaliando casos de teste

Esta seção é uma sequência contínua - não pare no meio. NÃO use `/skill-test` ou qualquer outra habilidade de teste.

Coloque os resultados em `<nome-da-habilidade>-workspace/` como um irmão do diretório da habilidade. Dentro do workspace, organize os resultados por iteração (`iteracao-1/`, `iteracao-2/`, etc.) e, dentro disso, cada caso de teste obtém um diretório (`aval-0/`, `aval-1/`, etc.). Não crie tudo isso de uma vez - apenas crie diretórios à medida que avança.

### Passo 1: Inicie todas as execuções (com-habilidade E linha de base) na mesma vez

Para cada caso de teste, inicie dois subagentes na mesma vez - um com a habilidade, outro sem. Isso é importante: não inicie as execuções com a habilidade primeiro e depois volte para as linhas de base mais tarde. Inicie tudo de uma vez para que tudo termine aproximadamente ao mesmo tempo.

**Execução com a habilidade:**

```
Execute esta tarefa:
- Caminho da habilidade: <caminho-para-habilidade>
- Tarefa: <prompt de avaliação>
- Arquivos de entrada: <arquivos de avaliação, se houver, ou "nenhum">
- Salvar saídas em: <workspace>/iteracao-<N>/aval-<ID>/com_habilidade/outputs/
- Saídas a serem salvas: <o que o usuário se importa - por exemplo, "o arquivo .docx", "o CSV final">
```

**Execução de linha de base** (mesmo prompt, mas a linha de base depende do contexto):
-   **Criando uma nova habilidade**: nenhuma habilidade. Mesmo prompt, sem caminho da habilidade, salve em `sem_habilidade/outputs/`.
-   **Melhorando uma habilidade existente**: a versão antiga. Antes de editar, faça um snapshot da habilidade (`cp -r <caminho-da-habilidade> <workspace>/skill-snapshot/`), então aponte o subagente da linha de base para o snapshot. Salve em `habilidade_antiga/outputs/`.

Escreva um `eval_metadata.json` para cada caso de teste (as asserções podem estar vazias por enquanto). Dê a cada avaliação um nome descritivo com base no que está sendo testado - não apenas "aval-0". Use este nome também para o diretório. Se esta iteração usar prompts de avaliação novos ou modificados, crie esses arquivos para cada novo diretório de avaliação - não presuma que eles são transferidos de iterações anteriores.

```json
{
  "eval_id": 0,
  "eval_name": "nome-descritivo-aqui",
  "prompt": "Prompt da tarefa do usuário",
  "assertions": []
}
```

### Passo 2: Enquanto as execuções estão em andamento, rascunhe as asserções

Não espere apenas as execuções terminarem - você pode usar esse tempo de forma produtiva. Rascunhe asserções quantitativas para cada caso de teste e explique-as ao usuário. Se as asserções já existirem em `evals/evals.json`, revise-as e explique o que elas verificam.

Boas asserções são objetivamente verificáveis e têm nomes descritivos - elas devem ser lidas claramente no visualizador de benchmark para que alguém que examine os resultados entenda imediatamente o que cada uma verifica. Habilidades subjetivas (estilo de escrita, qualidade de design) são melhor avaliadas qualitativamente - não force asserções em coisas que precisam de julgamento humano.

Atualize os arquivos `eval_metadata.json` e `evals/evals.json` com as asserções assim que rascunhadas. Também explique ao usuário o que ele verá no visualizador - tanto as saídas qualitativas quanto o benchmark quantitativo.

### Passo 3: Conforme as execuções são concluídas, capture os dados de tempo

Quando cada tarefa do subagente é concluída, você recebe uma notificação contendo `total_tokens` e `duration_ms`. Salve esses dados imediatamente em `timing.json` no diretório de execução:

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

Esta é a única oportunidade de capturar esses dados - eles chegam através da notificação da tarefa e não são persistidos em outro lugar. Processe cada notificação conforme ela chega, em vez de tentar agrupá-las.

### Passo 4: Classifique, agregue e inicie o visualizador

Uma vez que todas as execuções estejam concluídas:

1.  **Classifique cada execução** - inicie um subagente classificador (ou classifique em linha) que lê `agents/grader.md` e avalia cada asserção em relação às saídas. Salve os resultados em `grading.json` em cada diretório de execução. O array de expectativas em `grading.json` deve usar os campos `text`, `passed` e `evidence` (não `name`/`met`/`details` ou outras variantes) - o visualizador depende desses nomes de campo exatos. Para asserções que podem ser verificadas programaticamente, escreva e execute um script em vez de fazer uma verificação visual - scripts são mais rápidos, mais confiáveis e podem ser reutilizados em várias iterações.

2.  **Agregue em benchmark** - execute o script de agregação do diretório do criador de habilidades:
    ```bash
    python -m scripts.aggregate_benchmark <workspace>/iteracao-N --skill-name <nome>
    ```
    Isso produz `benchmark.json` e `benchmark.md` com a taxa de aprovação, tempo e tokens para cada configuração, com média ± desvio padrão e o delta. Se estiver gerando `benchmark.json` manualmente, veja `references/schemas.md` para o esquema exato que o visualizador espera.
    Coloque cada versão `com_habilidade` antes de sua contraparte `linha_de_base`.

3.  **Faça uma análise** - leia os dados do benchmark e identifique padrões que as estatísticas agregadas podem esconder. Veja `agents/analyzer.md` (a seção "Analisando Resultados de Benchmark") para saber o que procurar - coisas como asserções que sempre passam independentemente da habilidade (não discriminatórias), avaliações de alta variância (possivelmente instáveis) e compensações de tempo/token.

4.  **Inicie o visualizador** com as saídas qualitativas e os dados quantitativos:
    ```bash
    nohup python <caminho-do-criador-de-habilidades>/eval-viewer/generate_review.py \
      <workspace>/iteracao-N \
      --skill-name "minha-habilidade" \
      --benchmark <workspace>/iteracao-N/benchmark.json \
      > /dev/null 2>&1 &
    VIEWER_PID=$!
    ```
    Para a iteração 2+, também passe `--previous-workspace <workspace>/iteracao-<N-1>`.

    **Ambientes de Cowork / sem tela:** Se `webbrowser.open()` não estiver disponível ou o ambiente não tiver tela, use `--static <output_path>` para escrever um arquivo HTML autônomo em vez de iniciar um servidor. O feedback será baixado como um arquivo `feedback.json` quando o usuário clicar em "Submit All Reviews". Após o download, copie `feedback.json` para o diretório do workspace para que a próxima iteração o use.

    Nota: por favor, use `generate_review.py` para criar o visualizador; não há necessidade de escrever HTML personalizado.

5.  **Diga ao usuário** algo como: "Abri os resultados no seu navegador. Há duas abas - 'Saídas' permite que você clique em cada caso de teste e deixe feedback, 'Benchmark' mostra a comparação quantitativa. Quando terminar, volte aqui e me avise."

### O que o usuário vê no visualizador

A aba "Saídas" mostra um caso de teste por vez:
-   **Prompt**: a tarefa que foi dada
-   **Saída**: os arquivos que a habilidade produziu, renderizados em linha quando possível
-   **Saída Anterior** (iteração 2+): seção recolhida mostrando a saída da última iteração
-   **Notas Formais** (se a classificação foi executada): seção recolhida mostrando aprovação/reprovação da asserção
-   **Feedback**: uma caixa de texto que salva automaticamente conforme o usuário digita
-   **Feedback Anterior** (iteração 2+): seus comentários da última vez, mostrados abaixo da caixa de texto

A aba "Benchmark" mostra o resumo das estatísticas: taxas de aprovação, tempo e uso de tokens para cada configuração, com detalhamentos por avaliação e observações do analista.

A navegação é feita pelos botões anterior/próximo ou pelas teclas de seta. Quando terminam, eles clicam em "Enviar Todas as Avaliações", o que salva todo o feedback em `feedback.json`.

### Passo 5: Leia o feedback

Quando o usuário disser que terminou, leia `feedback.json`:

```json
{
  "reviews": [
    {"run_id": "aval-0-com_habilidade", "feedback": "o gráfico está sem rótulos de eixo", "timestamp": "..."},
    {"run_id": "aval-1-com_habilidade", "feedback": "", "timestamp": "..."},
    {"run_id": "aval-2-com_habilidade", "feedback": "perfeito, adorei", "timestamp": "..."}
  ],
  "status": "completo"
}
```

Feedback vazio significa que o usuário achou que estava tudo bem. Concentre suas melhorias nos casos de teste onde o usuário teve reclamações específicas.

Desligue o servidor do visualizador quando terminar de usá-lo:

```bash
kill $VIEWER_PID 2>/dev/null
```

---

## Melhorando a habilidade

Este é o cerne do loop. Você executou os casos de teste, o usuário revisou os resultados e agora você precisa melhorar a habilidade com base no feedback dele.

### Como pensar sobre melhorias

1.  **Generalize a partir do feedback.** O panorama geral aqui é que estamos tentando criar habilidades que podem ser usadas um milhão de vezes (talvez literalmente, talvez até mais, quem sabe) em muitos prompts diferentes. Aqui, você e o usuário estão iterando sobre apenas alguns exemplos repetidamente porque isso ajuda a acelerar. O usuário conhece esses exemplos de dentro para fora e é rápido para ele avaliar novas saídas. Mas se a habilidade que você e o usuário estão co-desenvolvendo funcionar apenas para esses exemplos, ela é inútil. Em vez de fazer mudanças excessivamente detalhistas, ou "DEVE"s opressivamente restritivos, se houver algum problema teimoso, você pode tentar ramificar e usar metáforas diferentes, ou recomendar diferentes padrões de trabalho. É relativamente barato tentar e talvez você encontre algo ótimo.

2.  **Mantenha o prompt conciso.** Remova coisas que não estão agregando valor. Certifique-se de ler as transcrições, não apenas as saídas finais - se parece que a habilidade está fazendo o modelo perder muito tempo fazendo coisas improdutivas, você pode tentar se livrar das partes da habilidade que estão fazendo isso e ver o que acontece.

3.  **Explique o porquê.** Esforce-se para explicar o **porquê** por trás de tudo o que você está pedindo para o modelo fazer. Os LLMs de hoje são *inteligentes*. Eles têm uma boa teoria da mente e, quando recebem uma boa estrutura, podem ir além das instruções básicas e realmente fazer as coisas acontecerem. Mesmo que o feedback do usuário seja conciso ou frustrado, tente realmente entender a tarefa e por que o usuário está escrevendo o que escreveu, e o que ele realmente escreveu, e então transmita esse entendimento para as instruções. Se você se pegar escrevendo SEMPRE ou NUNCA em letras maiúsculas, ou usando estruturas super rígidas, isso é uma bandeela amarela - se possível, reformule e explique o raciocínio para que o modelo entenda por que o que você está pedindo é importante. Essa é uma abordagem mais humana, poderosa, e eficaz.

4.  **Procure por trabalho repetido em casos de teste.** Leia as transcrições das execuções de teste e observe se todos os subagentes escreveram scripts auxiliares semelhantes de forma independente ou adotaram a mesma abordagem de várias etapas para algo. Se todos os 3 casos de teste resultaram no subagente escrevendo um `create_docx.py` ou um `build_chart.py`, isso é um forte sinal de que a habilidade deve agrupar esse script. Escreva-o uma vez, coloque-o em `scripts/` e diga à habilidade para usá-lo. Isso evita que cada invocação futura reinvente a roda.

Esta tarefa é bastante importante (estamos tentando criar bilhões de valor econômico por ano aqui!) e seu tempo de raciocínio não é o bloqueador; reserve um tempo e realmente reflita sobre as coisas. Eu sugiro escrever um rascunho da revisão e, em seguida, olhá-lo novamente e fazer melhorias. Realmente faça o seu melhor para se colocar no lugar do usuário e entender o que ele quer e precisa.

### O loop de iteração

Depois de melhorar a habilidade:

1.  Aplique suas melhorias à habilidade
2.  Execute novamente todos os casos de teste em um novo diretório `iteracao-<N+1>/`, incluindo as execuções de linha de base. Se você estiver criando uma nova habilidade, a linha de base é sempre `sem_habilidade` (nenhuma habilidade) - isso permanece o mesmo em todas as iterações. Se você estiver melhorando uma habilidade existente, use seu julgamento sobre o que faz sentido como linha de base: a versão original com a qual o usuário chegou ou a iteração anterior.
3.  Inicie o revisor com `--previous-workspace` apontando para a iteração anterior
4.  Espere o usuário revisar e dizer que terminou
5.  Leia o novo feedback, melhore novamente, repita

Continue até:
-   O usuário diz que está satisfeito
-   Todo o feedback está vazio (tudo parece bom)
-   Você não está fazendo progresso significativo

---

## Avançado: Comparação cega

Para situações em que você deseja uma comparação mais rigorosa entre duas versões de uma habilidade (por exemplo, o usuário pergunta "a nova versão é realmente melhor?"), existe um sistema de comparação cega. Leia `agents/comparator.md` e `agents/analyzer.md` para obter os detalhes. A ideia básica é: dar duas saídas a um agente independente sem dizer qual é qual, e deixá-lo julgar a qualidade. Em seguida, analise por que o vencedor venceu.

Isso é opcional, requer subagentes, e a maioria dos usuários não precisará. O loop de revisão humana geralmente é suficiente.

---

## Otimização da Descrição

O campo de descrição no frontmatter do SKILL.md é o principal mecanismo que determina se o Claude invoca uma habilidade. Após criar ou aprimorar uma habilidade, ofereça otimizar a descrição para uma melhor precisão de acionamento.

### Passo 1: Gerar consultas de avaliação de acionamento

Crie 20 consultas de avaliação - uma mistura de "deve acionar" e "não deve acionar". Salve como JSON:

```json
[
  {"query": "o prompt do usuário", "should_trigger": true},
  {"query": "outro prompt", "should_trigger": false}
]
```

As consultas devem ser realistas e algo que um usuário do Claude Code ou Claude.ai realmente digitaria. Não solicitações abstratas, mas solicitações concretas e específicas e com uma boa quantidade de detalhes. Por exemplo, caminhos de arquivo, contexto pessoal sobre o trabalho ou situação do usuário, nomes e valores de colunas, nomes de empresas, URLs. Um pouco de história. Algumas podem estar em minúsculas ou conter abreviações ou erros de digitação ou fala casual. Use uma mistura de diferentes comprimentos e concentre-se em casos extremos, em vez de torná-los claros (o usuário terá a chance de aprová-los).

Ruim: `"Formate estes dados"`, `"Extraia texto de PDF"`, `"Crie um gráfico"`

Bom: `"ok, então meu chefe acabou de me enviar este arquivo xlsx (está nos meus downloads, chamado algo como 'vendas Q4 final FINAL v2.xlsx') e ele quer que eu adicione uma coluna que mostre a margem de lucro como uma porcentagem. A receita está na coluna C e os custos estão na coluna D, eu acho"`

Para as consultas **deve-acionar** (8-10), pense na cobertura. Você quer diferentes frases da mesma intenção - algumas formais, algumas casuais. Inclua casos em que o usuário não nomeia explicitamente a habilidade ou o tipo de arquivo, mas claramente precisa dela. Inclua alguns casos de uso incomuns e casos em que esta habilidade compete com outra, mas deve vencer.

Para as consultas **não-deve-acionar** (8-10), as mais valiosas são as "quase-perdas" - consultas que compartilham palavras-chave ou conceitos com a habilidade, mas na verdade precisam de algo diferente. Pense em domínios adjacentes, frases ambíguas onde uma correspondência de palavra-chave ingênua acionaria, mas não deveria, e casos em que a consulta aborda algo que a habilidade faz, mas em um contexto onde outra ferramenta é mais apropriada.

A coisa fundamental a evitar: não torne as consultas não-deve-acionar obviamente irrelevantes. "Escreva uma função fibonacci" como um teste negativo para uma habilidade de PDF é muito fácil - não testa nada. Os casos negativos devem ser genuinamente complicados.

### Passo 2: Revisar com o usuário

Apresente o conjunto de avaliação ao usuário para revisão usando o modelo HTML:

1.  Leia o modelo de `assets/eval_review.html`
2.  Substitua os placeholders:
    -   `__EVAL_DATA_PLACEHOLDER__` → o array JSON de itens de avaliação (sem aspas - é uma atribuição de variável JS)
    -   `__SKILL_NAME_PLACEHOLDER__` → o nome da habilidade
    -   `__SKILL_DESCRIPTION_PLACEHOLDER__` → a descrição atual da habilidade
3.  Escreva em um arquivo temporário (por exemplo, `/tmp/eval_review_<nome-da-habilidade>.html`) e abra-o: `open /tmp/eval_review_<nome-da-habilidade>.html`
4.  O usuário pode editar consultas, alternar `should-trigger`, adicionar/remover entradas, e então clicar em "Exportar Conjunto de Avaliação"
5.  O arquivo é baixado para `~/Downloads/eval_set.json` - verifique a pasta Downloads para a versão mais recente, caso haja várias (por exemplo, `eval_set (1).json`)

Esta etapa é importante - consultas de avaliação ruins levam a descrições ruins.

### Passo 3: Execute o loop de otimização

Diga ao usuário: "Isso levará algum tempo - executarei o loop de otimização em segundo plano e verificarei periodicamente."

Salve o conjunto de avaliação no workspace e, em seguida, execute em segundo plano:

```bash
python -m scripts.run_loop \
  --eval-set <caminho-para-trigger-eval.json> \
  --skill-path <caminho-para-habilidade> \
  --model <id-do-modelo-que-alimenta-esta-sessao> \
  --max-iterations 5 \
  --verbose
```

Use o ID do modelo do seu prompt de sistema (aquele que alimenta a sessão atual) para que o teste de acionamento corresponda ao que o usuário realmente experimenta.

Enquanto ele é executado, visualize periodicamente a saída para dar atualizações ao usuário sobre em qual iteração está e como estão as pontuações.

Isso lida com o loop de otimização completo automaticamente. Ele divide o conjunto de avaliação em 60% de treino e 40% de teste retido, avalia a descrição atual (executando cada consulta 3 vezes para obter uma taxa de acionamento confiável), e então chama o Claude para propor melhorias com base no que falhou. Ele reavalia cada nova descrição tanto no treino quanto no teste, iterando até 5 vezes. Quando termina, ele abre um relatório HTML no navegador mostrando os resultados por iteração e retorna JSON com `best_description` - selecionado pela pontuação do teste, em vez da pontuação do treino, para evitar overfitting.

### Como funciona o acionamento de habilidades

Entender o mecanismo de acionamento ajuda a projetar melhores consultas de avaliação. As habilidades aparecem na lista `available_skills` do Claude com seu nome + descrição, e o Claude decide se consulta uma habilidade com base nessa descrição. O importante a saber é que o Claude consulta as habilidades apenas para tarefas que ele não consegue lidar facilmente sozinho - consultas simples e de uma única etapa, como "ler este PDF", podem não acionar uma habilidade mesmo que a descrição corresponda perfeitamente, porque o Claude pode lidar com elas diretamente com ferramentas básicas. Consultas complexas, de várias etapas ou especializadas acionam habilidades de forma confiável quando a descrição corresponde.

Isso significa que suas consultas de avaliação devem ser substanciais o suficiente para que o Claude realmente se beneficie da consulta a uma habilidade. Consultas simples como "ler arquivo X" são casos de teste ruins - elas não acionarão habilidades, independentemente da qualidade da descrição.

### Passo 4: Aplique o resultado

Pegue `best_description` da saída JSON e atualize o frontmatter do SKILL.md da habilidade. Mostre ao usuário o antes/depois e relate as pontuações.

---

### Empacote e Apresente (somente se a ferramenta `present_files` estiver disponível)

Verifique se você tem acesso à ferramenta `present_files`. Se não tiver, pule esta etapa. Se tiver, empacote a habilidade e apresente o arquivo `.skill` ao usuário:

```bash
python -m scripts.package_skill <caminho/para/pasta-da-habilidade>
```

Após o empacotamento, direcione o usuário para o caminho do arquivo `.skill` resultante para que ele possa instalá-lo.

---

## Instruções específicas do Claude.ai

No Claude.ai, o fluxo de trabalho principal é o mesmo (rascunho → teste → revisão → melhoria → repetição), mas como o Claude.ai não tem subagentes, algumas mecânicas mudam. Veja o que adaptar:

**Executando casos de teste**: Nenhum subagente significa nenhuma execução paralela. Para cada caso de teste, leia o SKILL.md da habilidade e siga suas instruções para realizar o prompt de teste você mesmo. Faça-os um de cada vez. Isso é menos rigoroso do que subagentes independentes (você escreveu a habilidade e também a está executando, então você tem todo o contexto), mas é uma verificação útil - e a etapa de revisão humana compensa. Pule as execuções de linha de base - apenas use a habilidade para completar a tarefa conforme solicitado.

**Revisando resultados**: Se você não conseguir abrir um navegador (por exemplo, a VM do Claude.ai não tem tela, ou você está em um servidor remoto), pule o revisor do navegador completamente. Em vez disso, apresente os resultados diretamente na conversa. Para cada caso de teste, mostre o prompt e a saída. Se a saída for um arquivo que o usuário precisa ver (como um .docx ou .xlsx), salve-o no sistema de arquivos e diga a ele onde está para que ele possa baixar e inspecionar. Peça feedback em linha: "Como isso parece? Algo que você mudaria?"

**Benchmarking**: Pule o benchmarking quantitativo - ele depende de comparações de linha de base que não são significativas sem subagentes. Concentre-se no feedback qualitativo do usuário.

**O loop de iteração**: O mesmo de antes - melhore a habilidade, execute novamente os casos de teste, peça feedback - apenas sem o revisor do navegador no meio. Você ainda pode organizar os resultados em diretórios de iteração no sistema de arquivos, se tiver um.

**Otimização da descrição**: Esta seção requer a ferramenta CLI `claude` (especificamente `claude -p`), que está disponível apenas no Claude Code. Pule-a se você estiver no Claude.ai.

**Comparação cega**: Requer subagentes. Pule-a.

**Empacotamento**: O script `package_skill.py` funciona em qualquer lugar com Python e um sistema de arquivos. No Claude.ai, você pode executá-lo e o usuário pode baixar o arquivo `.skill` resultante.

**Atualizando uma habilidade existente**: O usuário pode estar pedindo para você atualizar uma habilidade existente, não criar uma nova. Neste caso:
-   **Preserve o nome original.** Observe o nome do diretório da habilidade e o campo `name` do frontmatter - use-os inalterados. Por exemplo, se a habilidade instalada for `research-helper`, a saída será `research-helper.skill` (não `research-helper-v2`).
-   **Copie para um local gravável antes de editar.** O caminho da habilidade instalada pode ser somente leitura. Copie para `/tmp/nome-da-habilidade/`, edite lá e empacote a partir da cópia.
-   **Se estiver empacotando manualmente, prepare em `/tmp/` primeiro**, e depois copie para o diretório de saída - gravações diretas podem falhar devido a permissões.

---

## Instruções específicas para Cowork

Se você estiver no Cowork, as principais coisas a saber são:

-   Você tem subagentes, então o fluxo de trabalho principal (iniciar casos de teste em paralelo, executar linhas de base, classificar, etc.) funciona. (No entanto, se você encontrar problemas graves com timeouts, é OK executar os prompts de teste em série em vez de em paralelo.)
-   Você não tem um navegador ou tela, então ao gerar o visualizador de avaliação, use `--static <output_path>` para escrever um arquivo HTML autônomo em vez de iniciar um servidor. Em seguida, ofereça um link que o usuário possa clicar para abrir o HTML em seu navegador.
-   Por algum motivo, a configuração do Cowork parece desincentivar o Claude a gerar o visualizador de avaliação depois de executar os testes, então, apenas para reiterar: esteja você no Cowork ou no Claude Code, depois de executar os testes, você deve sempre gerar o visualizador de avaliação para o humano examinar os exemplos antes de revisar a habilidade você mesmo e tentar fazer correções, usando `generate_review.py` (não escrevendo seu próprio código HTML). Desculpe antecipadamente, mas vou usar letras maiúsculas aqui: GERE O VISUALIZADOR DE AVALIAÇÃO *ANTES* de avaliar as entradas você mesmo. Você quer colocá-los na frente do humano o mais rápido possível!
-   O feedback funciona de forma diferente: como não há servidor em execução, o botão "Enviar Todas as Avaliações" do visualizador fará o download de `feedback.json` como um arquivo. Você poderá então lê-lo de lá (pode ser necessário solicitar acesso primeiro).
-   O empacotamento funciona - `package_skill.py` só precisa de Python e um sistema de arquivos.
-   A otimização da descrição (`run_loop.py` / `run_eval.py`) deve funcionar bem no Cowork, pois usa `claude -p` via subprocesso, não um navegador, mas guarde-a até que você tenha terminado completamente de fazer a habilidade e o usuário concorde que ela está em boas condições.
-   **Atualizando uma habilidade existente**: O usuário pode estar pedindo para você atualizar uma habilidade existente, não criar uma nova. Siga as orientações de atualização na seção `claude.ai` acima.

---

## Arquivos de referência

O diretório `agents/` contém instruções para subagentes especializados. Leia-os quando precisar iniciar o subagente relevante.

-   `agents/grader.md` - Como avaliar asserções em relação às saídas
-   `agents/comparator.md` - Como fazer comparação cega A/B entre duas saídas
-   `agents/analyzer.md` - Como analisar por que uma versão venceu a outra

O diretório `references/` contém documentação adicional:
-   `references/schemas.md` - Estruturas JSON para `evals.json`, `grading.json`, etc.

---

Repetindo mais uma vez o loop principal aqui para ênfase:

-   Descubra do que se trata a habilidade
-   Rascunhe ou edite a habilidade
-   Execute o Claude com acesso à habilidade em prompts de teste
-   Com o usuário, avalie as saídas:
    -   Crie `benchmark.json` e execute `eval-viewer/generate_review.py` para ajudar o usuário a revisá-los
    -   Execute avaliações quantitativas
-   Repita até que você e o usuário estejam satisfeitos
-   Empacote a habilidade final e retorne-a ao usuário. 

Por favor, adicione etapas à sua lista de tarefas, se você tiver uma, para garantir que não se esqueça. Se você estiver no Cowork, por favor, coloque especificamente "Criar JSON de avaliações e executar `eval-viewer/generate_review.py` para que o humano possa revisar os casos de teste" em sua lista de tarefas para garantir que isso aconteça.

Boa sorte!