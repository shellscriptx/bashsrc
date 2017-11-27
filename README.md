
# bashsrc
sources 0.1.0-alpha (builtin/coreutils)

```
NOME
       bashsrc - utilitário para consulta de documentações sources.

DESCRIÇÃO
       O  bashsrc  é  um  projeto open source distribuído em uma coleção de bibliotecas desen‐
       volvidas em shell script contendo um conjunto de funções úteis que  oferece  ao  desen‐
       volvedor  uma  alternativa de programação ao padrão PIPE do shell. O foco principal é a
       compatibilidade com o interpretador de comandos BASH 4.0.0 (ou superior), cuja  funções
       são  desenvolvidas  utilizando  apenas  recursos  built-in e coreutils, evitando a uti‐
       lização de dependências de pacotes externos que geram  ‘coprocs’  durante  a  execução.
       Porém  alguns  critérios  serão levados em consideração para tal aplicação: desempenho,
       viabilidade, compatibilidade, distribuição da  dependência  entre  outros.  Ficando  de
       responsabilidade do desenvolvedor verificar/reportar tais dependências se houverem.

DOCUMENTAÇÃO
       A  documentação  padrão  está disponível no arquivo fonte de cada biblioteca e que pode
       ser acessada pela utilitário ‘bashsrc’ via linha de comando, distribuída junto ao  pro‐
       jeto.  No  momento a documentação oficial está em construção e reformulação para melhor
       didática e entendimento que em breve estará disponível no Github do projeto.

AMBIENTE
       Para utilizar quaisquer bibliotecas é necessário configurar previamente o  ambiente.  O
       bashsrc  utiliza  a variável 'BASHSRC_PATH' onde é definido o diretório padrão contendo
       as bibliotecas/binários.

       Configurando

       Após realizar o download copie a pasta do projeto para o diretório de sua  preferência.
       Por padrão utilize o ‘$HOME’ do seu usuário.

       $ cp -r bashsrc/ ~

       Defina  as  variáveis de ambiente inserindo no final do arquivo ~/.bashrc ou ~/.profile
       as linhas abaixo:

       export BASHSRC_PATH=$HOME/bashsrc
       export PATH=$PATH:$BASHSRC_PATH/src
       export PATH=$PATH:$BASHSRC_PATH/bin

       Carregando as configurações:

       $ . ~/.bashrc
       ou
       $ . ~/.profile

       Obs: Se estiver ok nenhuma mensagem é retornada.

BASHSRC
       Desenvolvida em shell script, o ‘bashsrc’ é um utilitário para consulta rápida de docu‐
       mentações  via  linha de comando, cuja opções podem ser facilmente acessadas através do
       comando:

       $ bashsrc --help
       Uso: bashsrc [OPÇÕES]

       Argumentos obrigatórios para opções longas também são para opções curtas.

       -l, --list                  - Lista os sources disponíveis em '$BASHSRC_PATH'
       -e, --env                   - Exibe o ambiente configurado em '$BASHSRC_PATH'.
       -d, --doc <src>[.funcname]  - Exibe a documentação do source ou função.
                                    'src' refere-se ao nome da biblioteca a ser consultada,
                                     omitindo a extensão '.sh' do arquivo.  Se '.funcname'
                                     for omitido é retornado o protótipo de todas as funções
                                     disponíveis em 'src'.
       -h, --help                    Exibe ajuda e sai.
       -v, --version                 Exibe a versão e sai.

       Utilize o parâmetro [-d, --doc] para listar a documentação  de  uma  função  específica
       cuja  informações  descrevem  o protótipo de declaração, argumentos, tipos e retorno da
       função. Exemplos simples e práticos também estão presentes para melhor  entendimento  e
       aplicação.

       Sintaxe: bashsrc --doc <srcname>.<funcname>

       Exemplo:

       Exibindo a documentação da função ‘ismatch’ na biblioteca ‘regex’.

       $ bashsrc --doc regex.ismatch
        func regex.ismatch <[str]pattern> <[str]exp> <[uint]flag> => [bool]
            Retorna 'true' se o padrão coincidir em 'exp', caso contrário retorna 'false'.

       Se  ‘funcname’  for  omitida,  é  exibido  o  protótipo de todas as funções e variáveis
       disponíveis.

       Exemplo:

       $ bashsrc --doc regex
       readonly regex_case=1 # [flag] - considera a diferença entre caracteres  maiúsuculos  e
       minúsculos.
       readonly regex_ignorecase=2 # [flag] - ignora a diferença entre caracteres maiúsculos e
       minúsculos.
       func regex.findall <[str]pattern> <[str]exp> <[uint]flag> => [str]
       func regex.fullmatch <[str]pattern> <[str]exp> <[uint]flag> => [uint|uint|str]
       func regex.match <[str]pattern> <[str]exp> [uint]flag => [str]
       func regex.search <[str]pattern> <[str]exp> <[uint]flag> => [uint|uint|str]
       func regex.split <[str]pattern> <[str]exp> <[uint]flag> => [str]
       func regex.ismatch <[str]pattern> <[str]exp> <[uint]flag> => [bool]
       func regex.groups <[str]pattern> <[str]exp> <[uint]flag> => [str]
       func regex.savegroups <[str]pattern> <[str]exp> <[uint]flag> <[array]name>
       func regex.replace <[str]pattern> <[str]exp> <[str]new>  <[int]count>  <[uint]flag>  =>
       [str]
       func  regex.nreplace <[str]pattern> <[str]exp> <[str]new> <[uint]match> <[uint]flag> =>
       [str]
       func   regex.fnreplace   <[str]pattern>   <[str]exp>   <[func]funcname>    <[int]count>
       <[uint]flag> => [str]
       func   regex.fnnreplace   <[str]pattern>   <[str]exp>   <[func]funcname>  <[uint]match>
       <[uint]flag> => [str]

FUNÇÕES
       A biblioteca contém um conjunto de funções que  realizam  tarefas  especificas  onde  a
       nomenclatura  de  cada  função  é  prefixada  pela  'biblioteca' a que pertence (exceto
       builtin.sh).

       O protótipo de declaração determina a ordem e o tipo de cada argumento. Todos  argumen‐
       tos  que compõe a função são obrigatórios e suporta um tipo especifico de dado, gerando
       uma mensagem de erro caso seja omitido ou inválido.

       funcao <[tipo1]arg1> <[tipo2]arg2> ... => [tipo]
         |        |     |                  |       |
         |        |     |                  |       |___ Tipo do dado de retorno da função.
         |        |     |                  |
         |        |     |                  |__ Aceita um ou mais argumentos.
         |        |     |
         |        |     |__ Nome do argumento posicional.
         |        |
         |        |__ Tipo do dado suportado pelo argumento.
         |
         |__ Identificador válido da função.

       O 'bashsrc' utiliza expressões regulares para validar os tipos de dados dos  argumentos
       posicionais passados na chamada da função, são eles:

       int        - Inteiro com sinal
       uint       - Inteiro sem sinal
       char       - Um caractere
       str        - Um caractere ou mais
       bool       - 0 (verdadeiro) ou 1 (falso).
       array      - Variável do tipo array indexado.
       map        - Variável do tipo array associativo.
       func       - Função válida.
       funcname   - Nomenclatura de função válida.
       bin        - Notação binária (base 2).
       hex        - Notação hexadecimal (base 16).
       oct        - Notação octal (base 8).
       size       - Represetanção de capacidade de armazenamento: 1k, 2M, 10G e etc..
       12h        - 12 horas (HH:MM).
       24h        - 24 horas (HH:MM).
       date       - Data (DD/MM/YYYY).
       hour       - Inteiro sem sinal entre 1..23 que representa a hora.
       sec        - Inteiro sem sinal entre 1..59 que representa os segundos.
       mday       - Inteiro sem sinal entre 1..31 que representa o dia do mês.
       mon        - Inteiro sem sinal entre 1..12 que representa o mês.
       year       - Inteiro sem sinal que representa o ano.
       yday       - Inteiro sem sinal entre 1..366 que representa o dia do ano.
       wday       - Inteiro sem sinal entre 1..7 que representa o dia da semana.
       url        - Uma cadeia de caracteres que representa uma url válida.
       email      - Uma cadeia de caracteres que representa um endereço e-amil válido.
       ipv4       - Protocolo IPV4.
       ipv6       - Protocolo IPV6.
       mac        - MAC address.
       slice      - Conjunto que representa um intervalo ([min:max]).
       keyword    - Argumento posicional nomeado.
       var        - Variiável, array ou map válido.

       Retorno [bool]

       Diferentemente  dos  demais  tipos  de  retorno,  o 'bool' não retorna explicitamente o
       valor, mas define o código de status da função após a execução, sendo '0'  (verdadeiro)
       ou  '!= 0' (falso) e que pode ser acessado através da variável '$?' ou validada direta‐
       mente em um bloco condicional 'if'.

       Exemplo:

       Utilizando a função 'str.compare' para comparar duas strings e que retorna '0' se forem
       iguais ou '1' para diferentes.

       # Variável '$?'
       $ str.compare "shell script" "SHELL SCRIPT"
       $ echo $?
       1

       # Validando diretamente o retorno.
       $ if str.compare "shell" "shell"; then
            echo "Iguais"
         else
            echo "Diferentes"
         fi
       Iguais

       ou

       $ str.compare "shell" "shell" && echo "Iguais" || echo "Diferentes"
       Iguais

       Argumentos (var, array, map e func)

       Os  argumentos  do  tipo  var, array, map ou func são ponteiros para objetos existentes
       associados ao seu identificador (nome) para acesso direto e que deve ser informado  sem
       o caractere de expansão '$' (somente variáveis).

       Considere  o  protótipo  da função 'swap' abaixo que troca os valores entre variáveis e
       recebe dois argumentos do tipo var.

       func swap <[var]name1> <[var]name2>

       valor1=10
       valor2=20

       // * INCORRETO * //
       swap $valor1 $valor2

       // * CORRETO * //
       swap valor1 valor2

IMPORTANDO SOURCES
       A importação é realizada através do comando ‘source’ ou ‘.’ que carrega as  definições,
       variáveis e funções contidas na biblioteca para o projeto atual. Por padrão as entradas
       em '$PATH' não usadas para localizar o diretório contendo o arquivo.

       Sintaxe: source srcname.sh

       ‘srcname’ é o nome biblioteca seguido de sua extensão.

       Exemplo:

       Importando a biblioteca ‘str’ e chamando a função ‘toupper’ que converte os  caracteres
       da expressão para maiúsculo.

       #!/bin/bash
       # script: upper.sh

       # Importando
       source str.sh

       # Executando função
       str.toupper “linux”

       # FIM

       Executando:

       $ ./upper.sh
       LINUX

BUILTIN
       O  'bashsrc' dispõe de uma biblioteca padrão chamada 'builtin.sh' que é carregada auto‐
       maticamente pelas demais bibliotecas quando importadas,  caso  contrário  é  necessário
       importá-la  manual. A diferenciar dos outros sources a nomenclatura de suas funções não
       possui uma composição 'source.function', sendo chamadas utilizando  apenas  o  nome  da
       função. Somente na consulta da documentação o prefixo é requerido.

       Exemplo:

       Utilizando uma função builtin para converter um número inteiro para binário (base 2).

       #!/bin/bash
       # script: bin.sh

       # Importando
       $ source builtin.sh

       # Função builtin
       bin 255

       # FIM

       Executando:

       $ ./bin.sh
       11111111

REPORTANDO FALHAS
       E-mail: shellscriptx@gmail.com

AUTOR
       Juliano Santos <juliano.santos.bm@gmail.com>

COMUNIDADE
       Telegram (grupo): t.me/shellscript_x
       Facebook (fanpage) : fb.com/shellscriptx
       Facebook (grupo): fb.com/groups/1849108781988115
```
