FROM alpine:3.22

# Definindo flags para uma execução e depuração mais rebusta:
# -e: Termina o script imediatamente caso algum comando retorne um status que não zero.
# -u: Trata variáveis não definidas como erro, e, portanto, causa a terminação do script.
# -x: Imprime os comandos e seus argumentos à medida que forem sendo executados.
RUN set -eux;

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
# o caso do PostgreSQL. Seu ID é 70.
#
# Ao fazer com que um serviço execute como um usuário de sistema (e pertença a um grupo de
# sistema), você aplica o princípio do menor privilégio: Se o serviço for comprometido (hackeado),
# o invasor terá apenas as permissões limitadas desse grupo. Ele não terá acesso a arquivos
# críticos do sistema nem aos arquivos pessoais de usuários comuns.
#
# Agora, vamos adicionar um grupo de sistema (opção "-S") chamado "postgres", com group id ("-g")
# de 70:
RUN addgroup -g 70 -S postgres;