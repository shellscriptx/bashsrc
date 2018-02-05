## bashsrc 1.0.0

### Sobre

O  **bashsrc**  é  um  projeto open source distribuído em uma coleção de bibliotecas desenvolvidas em shell script contendo um conjunto de funções úteis que  oferece  ao  desenvolvedor um estilo de programação funcional com implementação de tipos. 

O foco principal é a compatibilidade com o interpretador de comandos **BASH 4.3.0 (ou superior)**, cuja  funções
são  desenvolvidas  utilizando  apenas  recursos  `built-in` e `coreutils`, evitando a utilização de dependências de pacotes externos que geram ‘coprocs’ durante a execução. Porém  alguns  critérios  serão levados em consideração para tal aplicação: _desempenho, viabilidade, compatibilidade, distribuição da  dependência_ entre outros, ficando  de responsabilidade do desenvolvedor verificar e reportar tais dependências se houverem.

### Dependências

|Pacote|Versão|Descrição|
|-|-|-|
|bash|4.3 (ou superior)|Interpretador de comandos BASH (Bourne-Again Shell).|
|coreutils|7.0 (ou superior)|Utilitários básicos de arquivo, shell e manipulação de texto do sistema operacional GNU. (GNU core utilities)|


### Documentação

A  documentação  padrão  está disponível no arquivo fonte de cada biblioteca e que pode ser acessada pela utilitário `bashsrc` via linha de comando e distribuída junto ao  projeto.

### Ambiente

Para utilizar quaisquer bibliotecas é necessário configurar previamente o  ambiente.  O bashsrc  utiliza  a variável `BASHSRC_PATH` onde é definido o diretório padrão contendo as bibliotecas/binários.

### Configuração

Realizando download do projeto:

```
$ git clone git@github.com:shellscriptx/bashsrc.git
```

Após o download copie a pasta do projeto para o diretório de sua preferência.

Por padrão utilize o `$HOME` do seu usuário.
```
$ cp -r bashsrc/ ~
```
Defina  as  variáveis de ambiente inserindo-as no arquivo `~/.bashrc` ou `~/.profile`
as linhas abaixo:
```
export BASHSRC_PATH=$HOME/bashsrc
export PATH=$PATH:$BASHSRC_PATH/src
export PATH=$PATH:$BASHSRC_PATH/bin
```
Carregando as configurações:
```
$ . ~/.bashrc
```
ou
```
$ . ~/.profile
```
> Obs: se tudo estiver 'ok' nenhuma mensagem de erro é apresentada.


### Reportando falhas

* E-mail: shellscriptx@gmail.com

**Autor**

* Juliano Santos [SHAMAN]

**Comunidade**

* [Telegram (grupo)](https://t.me/shellscript_x)

* [Facebook (fanpage)](https://fb.com/shellscriptx)

* [Facebook (grupo)](https://fb.com/groups/1849108781988115)
