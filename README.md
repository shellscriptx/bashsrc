## bashsrc 1.0.0

### Dependências

|Pacote|Versão|Descrição|
|-|-|-|
|bash|4.3 (ou superior)|Interpretador de comandos BASH (Bourne-Again Shell).|
|coreutils|7.0 (ou superior)|Utilitários básicos de arquivo, shell e manipulação de texto do sistema operacional GNU. (GNU core utilities)|


### Documentação

A  documentação  padrão  está disponível no arquivo fonte de cada biblioteca e que pode ser acessada pela utilitário `bashsrc` via linha de comando e distribuída junto ao  projeto.

Para mais informações consulte a documentação: [clique aqui](https://github.com/shellscriptx/bashsrc/wiki) (em construção)

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

### Créditos

* Juliano Santos [SHAMAN]

**Comunidade**

* [Telegram (grupo)](https://t.me/shellscript_x)

* [Facebook (fanpage)](https://fb.com/shellscriptx)

* [Facebook (grupo)](https://fb.com/groups/1849108781988115)
