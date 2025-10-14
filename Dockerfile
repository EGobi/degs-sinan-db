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
# DISCORRER SOBRE DEPENDÊNCIAS. ========================
#
# No Linux, quaisquer ferramentas, programas, softwares, etc. que você pode adicionar ao sistema
# possuem um nome comum: "pacotes". A gigantesca maioria das distribuições do Linux (incluindo o
# Alpine) possuem "gerenciadores de pacotes" (também conhecidos pelo termo inglês "packet manager")
# que facilitam a instalação desses programas: basta digitar o nome do programa que ele já é
# instalado automaticamente.
RUN apk add --no-cache --virtual .gosu-deps ca-certificates dpkg gnupg