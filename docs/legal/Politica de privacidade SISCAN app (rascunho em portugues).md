# Política de tratamento de dados — App SISCAN (Android)

> **Rascunho técnico**, versão 0.3 · vigente desde 9 de novembro de 2026. Tradução para o português do Brasil de
> `politica-datos-app-siscan.md`; prevalece o texto em espanhol. Um advogado deve revisá-la antes de publicá-la para
> terceiros, e uma pessoa nativa deve revisar esta tradução. O mesmo texto aparece dentro do app em
> **Mais → Seus dados e privacidade** quando o app está em português.

- **Controlador:** projeto SISCAN (Secado Inteligente de Café), Gobernación de Nariño · CISNA. Contato: o que o
  controlador definir antes de publicar (pendente).
- **O que o app guarda no celular:**
  1. O **último estado do secador** (leituras, lote, aparelhos, alertas) para mostrá-lo sem sinal. Não são dados
     pessoais.
  2. Se a pessoa entrar como Gestor do secador: seu **usuário** e sua **senha de aplicativo** do WordPress,
     criptografados no armazenamento seguro do celular (Android Keystore), para enviar comandos e registrar pesagens.
  3. Suas escolhas de **tema**, **idioma**, **notificações** e **entrada com digital**. A preferência de idioma
     (`siscan_idioma`) também pode ficar no idioma por app do Android. Não identificam a pessoa e são apagadas com
     "Apagar os dados deste celular".
- **Digital (opcional):** o sensor do celular a verifica; o app nunca recebe nem guarda a digital, só desbloqueia a
  credencial criptografada. É ativada em Mais → Entrada com digital, depois de confirmar a digital uma vez.
- **Localização (opcional, só quando pedida):** usada apenas quando um administrador toca em "Usar minha localização
  atual" em Mais → Localização do secador. É enviada ao servidor do CISNA como localização **do secador**, não da pessoa.
  Não é guardada no celular nem usada em segundo plano. O Android pede a permissão nesse momento.
- **Notificações (opcional):** se ativadas, o app consulta o servidor a cada 15 minutos (só leitura) para avisar
  alertas, hora de pesar e lote pronto, e mostra o progresso do lote na tela de bloqueio. O Android pede a permissão ao
  ativá-las.
- **Relógio inteligente:** se a pessoa entrar com "Lembrar de mim", o celular guarda o cabeçalho da sua sessão
  criptografado com uma chave do Android Keystore para que o SISCAN no relógio peça comandos e pesagens pela conexão entre
  relógio e celular (camada de dados do Wear OS). O relógio não guarda senhas: só lê o estado público do secador. É
  apagado ao sair ou ao apagar os dados do celular.
- **Inteligência artificial:** a previsão da tese e a rede neural rodam no servidor do CISNA. A "segunda opinião" é
  gerada pelo Groq a partir desse servidor com dados do lote e do secador; não recebe dados pessoais.
- **O que NÃO faz:** não usa câmera nem contatos; não tem publicidade, análise nem rastreamento; não compartilha dados
  com terceiros. O único servidor com que se comunica é `cisna.narino.gov.co` por HTTPS.
- **Finalidade:** mostrar o estado da secagem e permitir que o pessoal autorizado registre pesagens e opere os
  aparelhos.
- **Conservação:** até a pessoa sair (o que apaga a credencial), usar "Apagar os dados deste celular" ou desinstalar o
  app.
- **Segurança:** credencial criptografada; HTTPS; a senha de aplicativo pode ser revogada no WordPress a qualquer
  momento (Mais → Seus dados → Revogar a senha de aplicativo).
- **Direitos do titular** (Lei colombiana 1581 de 2012, Decreto 1377 de 2013 compilado no Decreto 1074 de 2015; para
  pessoas no Brasil, também a LGPD, Lei 13.709 de 2018): conhecer, atualizar, corrigir e excluir seus dados e revogar a
  autorização. No app: **Sair**, **Apagar os dados deste celular** e **Revogar a senha de aplicativo**. Os dados da conta
  do WordPress são geridos pelo administrador do site.
- **Menores:** o app é para o pessoal de operação do secador; não é dirigido a menores.
- **Mudanças:** uma nova versão aparecerá no app com sua data e, se mudar o que é tratado, a autorização será pedida de
  novo. A versão 0.3 só nomeia a preferência de idioma, que não é um dado pessoal, e por isso não pede nova autorização.

## Pendente antes de publicar nas lojas
- Contato do controlador e URL pública desta política.
- Google Play: formulário de Segurança dos dados e divulgação destacada da localização antes da permissão.
- Revisão por um advogado e por uma pessoa nativa de português.
