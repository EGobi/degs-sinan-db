# O Alpine tem 12,8 MB.
FROM alpine:3.22

# Um grupo no Linux é um conceito fundamental de segurança e gerenciamento de permissões. Ele
# funciona como uma categoria que pode incluir diversos usuários. Seu principal objetivo é
# simplificar o controle de acesso a arquivos, diretórios e recursos do sistema.
#
# Entretanto, não devemos nos ater a pensar em usuários somente como pessoas reais. Em um servidor,
# cada aplicação que não seja relacionada a uma pessoa em específico (como, por exemplo, um banco
# de dados, que é o nosso caso) também é tratada como um usuário. Podemos distinguir esses usuários
# em "usuários comuns" (pessoas) e "usuários de sistema" (aplicações).
#
# Um "grupo de usuários de sistema" no Linux é um tipo de grupo criado especificamente para que
# serviços (ou processos) do sistema operacional possam ser executados com segurança e permissões
# restritas. Em contraste com os grupos de usuários comuns, que são feitos para pessoas reais, os
# grupos de sistema são feitos para aplicações e serviços. O principal objetivo de um grupo de
# sistema não é permitir que um usuário humano faça login e use os recursos. Ele existe para que um
# serviço (como um servidor da web, um banco de dados ou um servidor de e-mail) possa ter acesso
# apenas aos arquivos e diretórios de que precisa, e executar com o mínimo de privilégios possível
# para aumentar a segurança.
#
# É convenção de boas práticas que especifiquemos um número de identificação para esse grupo. A
# esse número de identificação, chamamos de "group ID", ou "ID de grupo". Quanto mais próximo de 0
# for esse grupo, mais vital ele é. Por isso, grupos de usuários comuns costumam ter um número de
# identificação superior a 1000, enquanto que grupos de sistema possuem um group ID baixo.
#
# Algumas aplicações mais consagradas costumam ter um group ID já definido por convenção, e esse é
# o caso do PostgreSQL no sistema operacional Alpine. Seu ID é 70.
#
# Ao fazer com que um serviço execute como um usuário de sistema (e pertença a um grupo de
# sistema), você aplica o princípio do menor privilégio: Se o serviço for comprometido (hackeado),
# o invasor terá apenas as permissões limitadas desse grupo. Ele não terá acesso a arquivos
# críticos do sistema nem aos arquivos pessoais de usuários comuns.
#
# Agora, vamos adicionar um grupo de sistema (opção "-S") chamado "postgres", com group id ("-g")
# de 70:
RUN addgroup -g 70 -S postgres

# Agora que criamos o grupo de sistema "postgres", vamos criar um usuário também chamado "postgres"
# e adicioná-lo a esse grupo.
#
# Assim como os grupos, os usuários também possuem um número de identificação, o qual chamamos de
# "user ID". Seguindo a convenção já dita anteriormente, vamos identificá-lo com o número 70
# ("-u 70"). Também indicaremos que esse usuário é um usuário de sistema, ou seja, não um humano
# ("-S"). Além disso, vamos usar a opção "-D" para não atribuir uma senha a esse usuário. Usamos
# "-G postgres" para atribuir o novo usuário ao grupo "postgres", o qual criamos acima.
#
# No Linux, quando um usuário é criado, o sistema automaticamente cria também uma pasta para ele
# chamada "/home/<nome do usuário>", semelhante ao Windows, que cria uma pasta "C:\Usuários\<nome
# do usuário>" para que você armazene fotos, downloads, músicas, etc. Como o usuário que estamos
# criando é um usuário de sistema, não precisamos criar isso para ele. Antes, o manual de
# instalação do PostgreSQL sugere que a sua pasta principal seja criada em "/var/lib/postgresql".
# Será nessa pasta em que todos os dados do banco de dados serão armazenados.
#
# A combinação "-H -h /var/lib/postgresql" ajuda-nos a alcançar isso: o "-H" desativa a criação de
# uma pasta para o usuário em "/home/<nome do usuário>", enquanto que com "-h" podemos especificar
# onde sua pasta principal deve ser criada (no caso, "/var/lib/postgresql").
#
# A última parte do comando diz respeito a uma parte mais técnica, na qual definimos qual "shell de
# login" será usado pelo usuário ("-s"). Vamos por partes: um "shell" é onde você pode executar comandos
# dentro de um sistema operacional. No Windows, ele se chama "Prompt de Comando". Quando você faz
# login no Linux, o sistema operacional automaticamente te conecta a um shell, em que você pode
# digitar qualquer comando que quiser.
#
# Quando estamos criando um usuário, podemos definir se ele terá acesso ilimitado ao shell (padrão
# para um usuário humano), limitado (usuários de sistema) ou proibido (programas que exijam alto
# nível de segurança). No nosso caso, um banco de dados não precisa de acesso ilimitado, mas ao
# mesmo tempo não pode ter acesso proibido ao shell, pois todo banco de dados realiza automatica-
# mente tarefas de manutenção usando scripts (scripts são conjuntos de comandos que são enviados ao
# shell para realizar determinada tarefa). Por exemplo, quando o banco de dados é ligado pela
# primeira vez, ele precisa executar um script para se configurar.
#
# Em resumo, a escolha do shell de login define se o usuário pode ou não interagir com o sistema
# através de comandos, sendo uma camada importante para garantir que os usuários do sistema (como o
# PostgreSQL) não sejam usados por hackers para obter acesso de comando ao sistema.
#
# No Linux, o shell considerado "mínimo" ou "básico" é o "/bin/sh", e é ele que vamos conceder ao
# nosso novo usuário "postgres".
RUN adduser -u 70 -S -D -G postgres -H -h /var/lib/postgresql -s /bin/sh postgres

# Lembra que definimos a pasta "/var/lib/postgresql" para conter todos os dados do banco de dados?
# Pois bem, precisamos garantir uma certa segurança a ela, pois se qualquer descuidado apagasse-a
# mesmo que sem querer, iríamos perder todos os nossos dados.
#
# Por isso, iremos usar o comando "install", que nos permite alterar as permissões de uma pasta e
# indicar quem é o "dono" dela. Primeiro, especificamos que vamos alterar as permissões de uma
# pasta, e não de um arquivo ("--directory"). Em seguida, definimos que os donos da pasta são o
# usuário "postgres" ("--owner postgres") e o grupo de usuários "postgres" ("--group postgres").
#
# O "modo" ("--mode") permite-nos especificar as permissões da pasta. Ele tem a seguinte sintaxe:
# - primeiro dígito: define quem pode excluir a pasta
# - segundo dígito: define quem pode ver a pasta
# - terceiro dígito: define quem pode alterar arquivos na pasta
# - quarto dígito: define quem pode executar comandos que estejam armazenados na pasta
#
# Quanto ao primeiro dígito, se ele for "1", significa que somente o dono da pasta pode excluí-la.
# Já aos dígitos restantes, o número "7" significa que o direito é concedido a todos os usuários do
# computador. Portanto, quando escolhemos "1777", queremos dizer que todos os usuários terão acesso
# ao banco de dados, mas somente o usuário "postgres" poderá excluir os dados.
#
# Finalmente, especificamos a qual pasta iremos aplicar essas configurações. No caso, "/var/lib/
# postgresql".
RUN install --directory --owner postgres --group postgres --mode 1777 /var/lib/postgresql

# Perceba que, até agora, rodamos todos os comandos anteriores com o usuário administrador do
# sistema (conhecido como "root"). Entretanto, continuar rodando comandos com usuários com tantos
# privilégios elevados abre uma brecha de segurança. Para contornar isso, vamos passar a rodar os
# comandos passando-se pelo usuário "postgres", que acabamos de criar. Como já definimos quais
# permissões esse usuário tem, teremos a garantia que não haverão possíveis brechas de segurança.
#
# A ferramenta recomendada pelo PostgreSQL para essa finalidade é chamada de "gosu". Ela existe
# para executar comandos como outro usuário (no caso, o usuário "postgres") de forma segura. No
# nosso caso, o gosu será usado para rodar o que o PostgreSQL chama de "script de inicialização"
# (veremos mais sobre isso à frente).
#
# Lembra que nosso sistema operacional é o Linux Alpine, feito para ser o mais enxuto possível?
# Pois bem, isso implica que uma quantidade pequena de ferramentas está instalada por padrão, e o
# gosu não é uma delas. Logo, precisaremos instalá-la manualmente. Isso será uma boa atividade para
# aprender como ferramentas são adicionadas ao Linux.
#
# O link para baixar o gosu é o seguinte: <https://github.com/tianon/gosu/releases/tag/1.19>. Se
# você acessar essa página, verá que existem diversos arquivos listados: "gosu-amd64",
# "gosu-arm64", "gosu-armel", "gosu-armhf", "gosu-i386", e assim por diante. Na verdade, nós só
# precisamos de um deles, pois esse texto após "gosu-" indica a arquitetura do nosso sistema.
#
# Hoje em dia, a arquitetura que predomina entre os computadores é a "amd64", porém não podemos
# ficar supondo qual é a arquitetura do computador que rodará nosso banco de dados. Para determinar
# com exatidão a arquitetura do nosso sistema, existe uma ferramenta chamada "dpkg".
#
# Eita! Percebeu em que pé estamos agora? Precisamos de um programa ("dpgk") para podermos instalar
# outro programa ("gosu")! Quando isso acontece, dizemos que tal programa ("gosu") possui
# dependências. Portanto, é correto dizer que, para a nossa finalidade, o "dpkg" é uma dependência
# do "gosu".
#
# Percebeu também que estamos usando palavras diferentes para nos referirmos ao mesmo conceito? Nos
# dos últimos parágramos, usamos as palavras "ferramenta" e "programa" para nos referirmos ao mesmo
# conceito. É hora de estabelecermos um nome comum para isso, de forma a evitar equívocos.
#
# No Linux, quaisquer ferramentas, programas, softwares, etc. que você pode adicionar ao sistema
# possuem um nome comum: "pacotes". A gigantesca maioria das distribuições do Linux (incluindo o
# Alpine) possuem "gerenciadores de pacotes" (também conhecidos pelo termo inglês "packet manager")
# que facilitam a instalação desses programas: basta digitar o nome do programa que ele já é
# instalado automaticamente.
#
# O gerenciador de pacotes que vem com o Alpine Linux é chamado de APK (Alpine Package Keeper).
# Para instalar um pacote, basta usar o comando "apk add <nome do pacote>". Poderíamos, portanto,
# simplesmente rodar "apk add dpkg" para instalar o pacote "dpkg". Porém, precisamos considerar a
# alternativa que melhor otimize o armazenamento do nosso sistema. Por padrão, o APK, além de
# instalar um pacote, mantém todos os arquivos que foram baixados durante a instalação salvos no
# computador, para que possam ser reutilizados em futuras instalações ou atualizações. Nós não
# precisamos disso, pois o "dpkg" vai ser utilizado somente para permitir a instalação do "gosu".
# Inclusive, assim que instalarmos o "gosu", poderemos desinstalar o "dpkg" para economizar espaço.
# Para evitar que os arquivos de instalação permaneçam salvos no computador, basta acrescentar a
# opção "--no-cache" ao comando, ficando assim: "apk add --no-cache <nome do pacote>". A vantagem
# disso é justamente reduzir ao máximo o tamanho do nosso sistema.
#
# Existe ainda mais uma otimização a esse comando. Conforme veremos um pouco mais para frente, o
# "dpkg" não é a única dependência do "gosu". Não seria bom se pudéssemos agrupar esses pacotes e
# depois simplesmente apagá-los todos de uma só vez? É para isso que serve o conceito de "pacote
# virtual".
#
# Um pacote virtual é um apelido temporário para um grupo de pacotes que você está instalando
# juntos. Sua principal vantagem é poder removê-los todos de uma só vez depois que eles não forem
# mais necessários. Isso é muito útil quando estamos instalando dependências temporárias (como é o
# nosso caso). Por convenção, é comum que esse apelido comece com um "." quando queremos sinalizar
# que aquele grupo de pacotes é temporário. Portanto, podemos chamar esse grupo de ".gosu-deps". A
# opção "--virtual <apelido do grupo de pacotes>" e, quando juntamos ao comando completo, fica:
RUN apk add --no-cache --virtual .gosu-deps dpkg
# Sistema: 16,0 MB.

# Agora que instalamos o "dpkg", temos o comando homônimo à nossa disposição. Utilizaremos ele para
# que nos retorne qual arquitetura está sendo usada pelo sistema operacional, através da opção
# "--print-architecture". Esse comando retorna três informações: a implementação da biblioteca
# padrão do C (linguagem base do sistema operacional), o sistema operacional e a arquitetura.
#
# No caso, quando executamos, o comando retorna "musl-linux-amd64". Musl é a implementação usada em
# distribuições minimalistas do Linux, como o Alpine. Linux é o sistema operacional. AMD64 é a
# arquitetura sendo usada.
#
# Ótimo! Já conseguimos saber qual arquitetura está sendo usada. Agora, precisamos isolar somente
# a última parte, e isso faremos com uma nova ferramenta nativa do sistema operacional: o AWK.
#
# O AWK é uma ferramenta usada para processar e analisar texto. Através do seu parâmetro "-F",
# conseguimos passar qual caractere será o delimitador da string. No nosso caso, o delimitador de
# "musl-linux-amd64" é o hífen, então "-F-" faz com que esse texto seja separado em três campos:
# "musl", "linux" e "amd64". Então, se quiséssemos retornar o primeiro campo ("musl"),
# escreveríamos assim: "dpkg --print-architecture | awk -F- '{ print $1 }'". Se quiséssemos
# retornar "linux", trocaríamos o "$1" por "$2" (por ser o 2º campo) e assim por diante.
# Entretanto, é possível que o comando "dpkg --print-architecture" retorne um texto com 4 campos em
# vez de 3 (como "custom-musl-linux-amd64"), portanto usar "$3" poderia trazer o sistema
# operacional em vez da arquitetura.
#
# Para contornar isso, existe "$NF" (abreviação de Number of Fields), que sempre vai retornar a
# quantidade de campos retornados pela delimitação. Como a arquitetura é sempre o último campo,
# "$NF" sempre coincidirá com o número do último campo. Portanto, podemos salvar a arquitetura em
# uma variável desta maneira:
RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
# Agora que temos nossa arquitetura, podemos usar a ferramenta "wget", que serve para baixar
# arquivos da internet, para obter o arquivo correto. Vamos usar a opção "-O" para especificar onde
# e com que nome ele será baixado. Como é um arquivo binário, a convenção é salvá-lo na pasta
# "/usr/local/bin", com o nome "gosu". Vamos falar um pouco mais sobre essa pasta.
#
# O diretório "/bin" serve para armazenar os binários esseciais do sistema (como os comandos "ls",
# "mv", etc.). Já o diretório "/usr/bin" é onde os programas baixados pelo gerenciador de pacotes
# (como o "dpkg") ficam. Por fim, se o binário é adquirido fora do gerenciador de pacotes,
# convenciona-se que ele fique em "/usr/local/bin". Isso é uma convenção de organização, para
# facilitar saber o que foi instalado manualmente.
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.19/gosu-$dpkgArch"; \
# Não somente precisamos baixar o binário como também devemos verificar sua autenticidade. Isso é
# uma boa prática de segurança. Como lemos no manual do gosu, seu autor optou por gerar uma
# assinatura digital.
#
# Uma assinatura digital é um mecanismo de criptografia que permite verificar a autenticidade de um
# arquivo ou mensagem, garantir que ele não foi alterado desde sua assinatura e confirmar a
# identidade de quem assinou.
#
# Existem diversas formas matemáticas de se obter uma assinatura digital, porém a mais difundida
# hoje é através do algoritmo de Rivest-Shamir-Adleman (RSA), publicado em 1977, que se baseia em
# um princípio matemático fundamental: É computacionalmente difícil fatorar um número muito grande
# que seja o produto de dois primos grandes. Esse é o problema matemático central que garante a
# segurança do RSA.
# 
# O RSA se baseia na criptografia de chave pública, também chamada de criptografia assimétrica:
# usa um par de chaves, uma pública para criptografar e uma privada para descriptografar.
#
# A segurança depende da dificuldade de fatorar um número grande n = p * q, onde p e q são primos
# grandes. É fácil multiplicar p * q, mas muito difícil descobrir p e q a partir de n.
#
# Para a geração de p e q, é escolhida uma fonte de entropia no sistema (como movimentos do mouse,
# ruído do hardware, etc.). Entropia, em criptografia, representa o grau de aleatoriedade/
# imprevisibilidade de um dado. O número gerado é da ordem de 1024 bits, ou aproximadamente
# 308 casas decimais!
#
# Então, é aplicado um teste de primalidade para ver se aquele número é primo. Testes de
# primalidade existem desde o século XVII, mas o principal usado hoje é o de Miller-Rabin, de 1980.
# Isso é repetido para o segundo número.
#
# Por fim, verifica-se se p e q são números diferentes e distantes (comparando a diferença |p - q|
# com um limite mínimo seguro). Então é obtida a função totiente de Euler (séc. XVIII) a partir de
# n, em que φ(n) = (p - 1) * (q - 1)
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.19/gosu-$dpkgArch.asc"