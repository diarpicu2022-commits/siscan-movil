// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get navInicio => 'Início';

  @override
  String get navLotes => 'Lotes';

  @override
  String get navPesaje => 'Pesagem';

  @override
  String get navEquipo => 'Aparelhos';

  @override
  String get navMas => 'Mais';

  @override
  String navInicioConAlertas(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Início, $cantidad alertas',
      one: 'Início, 1 alerta',
    );
    return '$_temp0';
  }

  @override
  String get idioma => 'Idioma';

  @override
  String get idiomaComoElTelefono => 'Igual ao celular';

  @override
  String idiomaAhora(String idioma) {
    return 'Agora: $idioma';
  }

  @override
  String get hoy => 'Hoje';

  @override
  String get ayer => 'Ontem';

  @override
  String get volver => 'Voltar';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get cargando => 'Carregando…';

  @override
  String get masVistaPublica => 'Visualização pública';

  @override
  String get masSinCuenta => 'Sem conta · somente leitura';

  @override
  String masSesionGestor(String usuario) {
    return 'Gestor do secador · $usuario';
  }

  @override
  String masSesionSinPermiso(String usuario) {
    return 'Sem permissão de controle · $usuario';
  }

  @override
  String get masCalibracion => 'Calibração';

  @override
  String get masCalibracionSub => 'Gravimet e sensores';

  @override
  String get masMapa => 'Mapa de secadores';

  @override
  String masMapaSub(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad secadores em Nariño',
      one: '1 secador em Nariño',
    );
    return '$_temp0';
  }

  @override
  String get masHistorial => 'Histórico dos aparelhos';

  @override
  String get masHistorialSub => 'Comandos e energia';

  @override
  String get masUbicacion => 'Localização do secador';

  @override
  String get masUbicacionFijada => 'fixada à mão';

  @override
  String get masUbicacionPorIp => 'pelo IP do ESP32';

  @override
  String get masReloj => 'Relógio inteligente';

  @override
  String get masRelojSub =>
      'SISCAN para Wear OS · lê o secador e, com sua sessão, envia comandos';

  @override
  String get masNotificaciones => 'Notificações';

  @override
  String get masNotificacionesSub => 'Alertas, hora de pesar e lote pronto';

  @override
  String get masHuella => 'Entrada com digital';

  @override
  String get masHuellaSinCuenta => 'Primeiro entre com sua conta';

  @override
  String get masHuellaSub => 'Entre rápido sem digitar a senha';

  @override
  String get masTema => 'Tema';

  @override
  String get masAcerca => 'Sobre e licenças';

  @override
  String get masAcercaSub => 'Ícones Lucide e software de terceiros';

  @override
  String get masPrivacidad => 'Seus dados e privacidade';

  @override
  String get masPrivacidadSub => 'Política, exportar e apagar';

  @override
  String get masIngresar => 'Entrar';

  @override
  String get masIngresarSub => 'Para registrar pesagens e enviar comandos';

  @override
  String get masCerrarSesion => 'Sair';

  @override
  String get temaClaro => 'Claro';

  @override
  String get temaClaroSub => 'Sempre claro';

  @override
  String get temaOscuro => 'Escuro';

  @override
  String get temaOscuroSub => 'Sempre escuro';

  @override
  String get temaHora => 'Conforme a hora';

  @override
  String get temaHoraSub =>
      'Claro das 6h às 19h, escuro à noite (horário da Colômbia)';

  @override
  String get temaComoElTelefono => 'Igual ao celular';

  @override
  String get temaSistemaSub => 'Segue o ajuste do sistema';

  @override
  String get calQueCalibrar => 'O que calibrar';

  @override
  String get calSensores => 'Sensores';

  @override
  String get calSinLotes => 'Nenhum lote para calibrar';

  @override
  String get calSinLotesTexto =>
      'A calibração do Gravimet é feita sobre um lote com pesagens.';

  @override
  String calForma(String lote) {
    return 'Forma de calibrar · $lote';
  }

  @override
  String get calConPuntos => 'Com pontos';

  @override
  String get calReferencia => 'Referência Cenicafé (53 %)';

  @override
  String get calLecturaMedidor => 'Leitura do medidor';

  @override
  String get calPesoMuestra => 'Peso da amostra';

  @override
  String get calPesoPista => 'Usa o peso da última pesagem.';

  @override
  String get calCalibrar => 'Calibrar e recalcular';

  @override
  String get calReferenciaAplicada => 'Referência Cenicafé aplicada';

  @override
  String get calErrorDatos =>
      'Digite a leitura do medidor (0–99,9 %) e o peso em gramas.';

  @override
  String get calPuntoAgregado => 'Ponto medido adicionado';

  @override
  String get calLoteRecalculado => 'O lote foi recalculado.';

  @override
  String get calPuntosMedidos => 'Pontos medidos';

  @override
  String calPunto(String fecha, String peso, String lectura) {
    return '$fecha · $peso g · medidor $lectura %';
  }

  @override
  String get calCargandoSensores => 'Carregando a correção dos sensores…';

  @override
  String calGanancia(String ganancia, String desplazamiento) {
    return 'Ganho $ganancia · deslocamento $desplazamiento';
  }

  @override
  String get calCalibrado => 'Calibrado';

  @override
  String get calSinCalibrar => 'Sem ajuste';

  @override
  String get calPie =>
      'Toque em um sensor para corrigi-lo com um ponto: digite o valor real medido com seu instrumento.';

  @override
  String calCorregir(String sensor) {
    return 'Corrigir $sensor';
  }

  @override
  String calLecturaActual(String valor, String unidad) {
    return 'Leitura atual do sensor: $valor $unidad';
  }

  @override
  String calValorReal(String unidad) {
    return 'Valor real ($unidad)';
  }

  @override
  String get calAplicar => 'Aplicar';

  @override
  String calCalibradoSensor(String sensor) {
    return 'Calibrado: $sensor';
  }

  @override
  String get mapaTitulo => 'Mapa';

  @override
  String mapaFotoDe(String secador) {
    return 'Foto de $secador';
  }

  @override
  String get mapaFoto => 'Foto do secador';

  @override
  String get mapaSinFoto => 'Ainda sem foto';

  @override
  String get mapaSinCoordenadas => 'Sem coordenadas';

  @override
  String get histPeriodo => 'Período';

  @override
  String get hist24h => 'Últimas 24 h';

  @override
  String get hist7d => 'Últimos 7 dias';

  @override
  String get histCalculando => 'Calculando a energia…';

  @override
  String get histEnergia24h => 'Energia · últimas 24 h';

  @override
  String get histEnergia7d => 'Energia · últimos 7 dias';

  @override
  String get histRedSinLecturas => 'Rede sem leituras';

  @override
  String get histEstimado => 'Estimado';

  @override
  String histNota(String solar, String red) {
    return 'Solar: $solar. Rede: $red.';
  }

  @override
  String get histOrdenes => 'Comandos aos aparelhos';

  @override
  String get histCargandoOrdenes => 'Carregando os comandos…';

  @override
  String get histEncender => 'Ligar';

  @override
  String get histApagar => 'Desligar';

  @override
  String get histOrigenPanel => 'Pelo painel';

  @override
  String get histOrigenApp => 'Pelo app';

  @override
  String get histOrigenReloj => 'Pelo relógio';

  @override
  String get histOrigenEsp32 => 'O ESP32';

  @override
  String get histOrigenProtocolo => 'Protocolo';

  @override
  String get histOrigenSinRegistro => 'Origem não registrada';

  @override
  String get ubicTarjeta => 'Localização';

  @override
  String get ubicFijada => 'Fixada à mão';

  @override
  String get ubicPorIp => 'Pelo IP do ESP32';

  @override
  String get ubicLatitud => 'Latitude';

  @override
  String get ubicLongitud => 'Longitude';

  @override
  String get ubicSitio => 'Nome do local (opcional)';

  @override
  String get ubicBloquear =>
      'Travar a localização (ignorar a geolocalização pelo IP do ESP32)';

  @override
  String get ubicUsarMia => 'Usar minha localização atual';

  @override
  String get ubicDivulgacion =>
      'O SISCAN vai usar a localização deste celular uma única vez para definir onde está o secador e consultar o clima. Ela é enviada ao servidor do CISNA como localização do equipamento; não fica salva no celular nem é usada em segundo plano.';

  @override
  String get ubicAhoraNo => 'Agora não';

  @override
  String get ubicContinuar => 'Continuar';

  @override
  String get ubicTomada => 'Localização obtida do celular';

  @override
  String get ubicRevisaGuarda => 'Confira e salve.';

  @override
  String get ubicError =>
      'Não foi possível obter sua localização. Verifique a permissão de localização.';

  @override
  String get ubicGuardar => 'Salvar localização e atualizar o clima';

  @override
  String get ubicRevisaCoordenadas => 'Confira a latitude e a longitude.';

  @override
  String get ubicGuardada => 'Localização salva';

  @override
  String get ubicGuardadaDetalle => 'O clima é consultado com o local correto.';

  @override
  String get ubicPie =>
      'A localização do celular só é usada quando você toca em “Usar minha localização atual”; não fica salva no celular.';

  @override
  String get relojTarjeta => 'SISCAN no Wear OS';

  @override
  String get relojTexto =>
      'O relógio mostra o monitoramento do lote, as leituras, os aparelhos, a previsão e os alertas. Com a sessão iniciada neste celular, também pode ligar ou desligar atuadores e registrar pesagens: o relógio pede o comando ao celular e o celular o envia com sua conta (entre com “Lembrar de mim”).';

  @override
  String get relojPie =>
      'Instale o SISCAN no relógio pelo mesmo pacote do app. Sem sessão no celular, o relógio só lê.';

  @override
  String get licIconos => 'Ícones';

  @override
  String get licIconosTexto =>
      'Os ícones do SISCAN vêm do Lucide (lucide.dev), com traço próprio de 1,75. Estes são seus avisos de licença.';

  @override
  String get licErrorAviso => 'Não foi possível ler o aviso de licença.';

  @override
  String get licTerceros => 'Software de terceiros';

  @override
  String get licTercerosTexto =>
      'O Flutter e os pacotes que o app usa, cada um com sua licença.';

  @override
  String get licVerTodas => 'Ver todas as licenças';

  @override
  String get privTitulo => 'Seus dados';

  @override
  String get privPolitica => 'Política de tratamento de dados';

  @override
  String get privDerechos => 'Seus direitos no app';

  @override
  String get privRevocar => 'Revogar a senha de aplicativo';

  @override
  String get privBorrar => 'Apagar os dados deste celular';

  @override
  String get privBorrarTexto =>
      'A sessão é encerrada e são apagados a credencial, a cópia do secador e suas preferências. O servidor do CISNA não muda.';

  @override
  String get privBorrarConfirmar => 'Apagar';

  @override
  String get privBorrados => 'Dados deste celular apagados';

  @override
  String get prefSinPermisoNotif =>
      'O Android não permitiu notificações. Ative nas configurações do celular.';

  @override
  String get prefSinHuella => 'Este celular não tem digital cadastrada.';

  @override
  String get prefConfirmaHuella =>
      'Confirme sua digital para ativar a entrada rápida';

  @override
  String get variedadSinRegistrar => 'Variedade não registrada';

  @override
  String get sitioAireLibre => 'Ar livre';

  @override
  String get sitioSecador => 'Secador';

  @override
  String get predCalculando => 'Calculando a previsão…';

  @override
  String predListoEn(String tiempo) {
    return 'Pronto em ~$tiempo';
  }

  @override
  String get predRetiralo => 'Pronto: pode retirar';

  @override
  String get predTermino => 'Terminou no objetivo';

  @override
  String get predSobresecado => 'Passou do ponto: secagem excessiva';

  @override
  String get predNoAlcanza => 'Com este ar não chega ao objetivo';

  @override
  String get predPocosPesajes => 'Poucas pesagens para prever';

  @override
  String get estadoAlerta => 'Alerta';

  @override
  String get saludRedSinFallas => 'A rede neural não vê falhas';

  @override
  String get saludRedConFallas => 'A rede neural vê falhas';

  @override
  String saludSensoresNormales(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad sensores com sinal normal',
      one: '1 sensor com sinal normal',
    );
    return '$_temp0';
  }

  @override
  String get saludEspConectado => 'ESP32 conectado';

  @override
  String get saludEspSinConexion => 'ESP32 sem conexão';

  @override
  String saludUltimoReporte(String cuando) {
    return 'Último envio $cuando';
  }

  @override
  String get saludNoReporta => 'Ainda não enviou dados';

  @override
  String saludSensoresReportando(int vivos, int total) {
    return '$vivos de $total sensores enviando dados';
  }

  @override
  String get saludActCopias => 'Atuadores com cópias';

  @override
  String get saludActRegistrados => 'Atuadores registrados';

  @override
  String saludActCuenta(int cantidad) {
    return '$cantidad registrados';
  }

  @override
  String saludActCopiasGpio(int cantidad) {
    return ' · $cantidad cópias por GPIO';
  }

  @override
  String get saludUltimoEstado => ' · último estado conhecido';

  @override
  String get redNormal => 'Normal';

  @override
  String get redPegado => 'Travado';

  @override
  String get redSaturado => 'Saturado';

  @override
  String get redDeriva => 'Deriva';

  @override
  String get redSalto => 'Salto de degrau';

  @override
  String get redRuido => 'Ruído';

  @override
  String get redPicos => 'Picos';

  @override
  String get redSinDatos => 'Sem dados';

  @override
  String get soloLecturaTitulo => 'Somente leitura';

  @override
  String inicioHola(String nombre) {
    return 'Olá, $nombre!';
  }

  @override
  String get inicioHolaSinNombre => 'Olá!';

  @override
  String get inicioNoSeLeyo => 'Não foi possível ler o secador';

  @override
  String get inicioLeyendo => 'Lendo o secador…';

  @override
  String inicioSubSinLotes(String secador) {
    return '$secador · sem lotes';
  }

  @override
  String inicioSubSecando(String secador, String lote) {
    return '$secador · $lote secando';
  }

  @override
  String inicioSubTerminado(String secador, String lote) {
    return '$secador · $lote terminado';
  }

  @override
  String get sinLecturas => 'Sem leituras';

  @override
  String ultimoDato(String cuando) {
    return 'Último dado $cuando';
  }

  @override
  String get inicioSinLotes => 'Nenhum lote registrado';

  @override
  String get inicioSinLotesTexto =>
      'Quando você colocar café no secador, o registro aparecerá aqui.';

  @override
  String get inicioTempInterior => 'Temp. interna';

  @override
  String get inicioHumedadRelativa => 'Umidade relativa';

  @override
  String get inicioExterior => 'Externa';

  @override
  String get inicioPotenciaTotal => 'Potência total';

  @override
  String get actEnFuncionamiento => 'Em funcionamento';

  @override
  String get actDetenidos => 'Parados';

  @override
  String actEncendiendo(String nombre) {
    return '$nombre · Ligando…';
  }

  @override
  String actApagando(String nombre) {
    return '$nombre · Desligando…';
  }

  @override
  String get ordenSeCumple => 'Vale quando o ESP32 enviar dados.';

  @override
  String get inicioSoloLectura =>
      'Somente leitura: entre com sua conta para enviar comandos.';

  @override
  String get alertas => 'Alertas';

  @override
  String get loteSecando => 'Secando';

  @override
  String get loteTerminado => 'Terminado';

  @override
  String get humedadGrano => 'Umidade do grão';

  @override
  String humedadGranoLector(String valor) {
    return 'Umidade do grão $valor';
  }

  @override
  String get sinDato => 'sem dado';

  @override
  String get objetivoPrefijo => 'Objetivo 10 – 12 % · ';

  @override
  String get predNoDisponible => 'previsão indisponível';

  @override
  String predFaltan(String tiempo) {
    return 'faltam ~$tiempo';
  }

  @override
  String ultimoPesaje(String cuando) {
    return 'Última pesagem $cuando';
  }

  @override
  String get avanceObjetivo => 'Progresso até o objetivo';

  @override
  String get confianzaAlta => 'Confiança alta';

  @override
  String get confianzaMedia => 'Confiança média';

  @override
  String get confianzaBaja => 'Confiança baixa';

  @override
  String get magTempInterior => 'Temperatura interna';

  @override
  String get magHumInterior => 'Umidade relativa interna';

  @override
  String get magTempExterior => 'Temperatura externa';

  @override
  String get magHumExterior => 'Umidade relativa externa';

  @override
  String get magHumGrano => 'Umidade do grão (sensor)';

  @override
  String get magCorriente => 'Corrente';

  @override
  String get magPotControlador => 'Potência do controlador';

  @override
  String get magPotActuadores => 'Potência dos atuadores';

  @override
  String get metaTope => 'Topo da câmara';

  @override
  String get metaCamara => 'Câmara';

  @override
  String get metaAmbiente => 'Ambiente';

  @override
  String get metaCapacitivo => 'Capacitivo';

  @override
  String get metaLineaAc => 'Linha CA';

  @override
  String get metaEspSensores => 'ESP32 e sensores';

  @override
  String get metaVentResist => 'Ventiladores e resistências';

  @override
  String get metaCtrlAct => 'Controlador e atuadores';

  @override
  String sinConexionUltimoDato(String cuando) {
    return 'Sem conexão · último dado $cuando';
  }

  @override
  String get sinConexionNoReporta => 'Sem conexão · ainda não enviou dados';

  @override
  String get estadoEnOperacion => 'Em operação';

  @override
  String get estadoEnPausa => 'Em pausa';

  @override
  String get estadoSinConexion => 'Sem conexão';

  @override
  String get estadoPausaSinLote => 'Em pausa · sem lote ativo';

  @override
  String get errorConexion => 'Não conseguimos conectar ao secador.';

  @override
  String get haceSinDato => 'Sem dado';

  @override
  String get haceInstantes => 'Agora há pouco';

  @override
  String haceMin(int minutos) {
    return 'Há $minutos min';
  }

  @override
  String haceH(int horas) {
    return 'Há $horas h';
  }

  @override
  String get claveOcultar => 'Ocultar senha';

  @override
  String get claveMostrar => 'Mostrar senha';

  @override
  String get curvaSinPesajes =>
      'Nenhuma pesagem ainda: a curva aparece com a primeira amostra gravimétrica.';

  @override
  String get curvaUnPesaje => 'Só uma pesagem: a curva aparece com a segunda.';

  @override
  String curvaResumen(String desde, String hasta) {
    return 'A umidade do grão caiu de $desde % para $hasta %. Objetivo 10 – 12 %.';
  }

  @override
  String get leyendaGravimetrico => 'Umidade do grão (gravimétrica)';

  @override
  String get leyendaPrediccionIa => 'Previsão IA';

  @override
  String get leyendaObjetivo => 'Objetivo';

  @override
  String get objetivoRango => 'Objetivo 10 – 12 %';

  @override
  String get energiaTitulo => 'Consumo de energia e custo';

  @override
  String get energiaSolar => 'Solar';

  @override
  String get energiaRed => 'Rede elétrica';

  @override
  String get energiaCosto => 'Custo';

  @override
  String get energiaGraficoLector =>
      'Energia por período: solar embaixo, rede elétrica em cima';

  @override
  String energiaTarifa(String tarifa) {
    return 'Tarifa $tarifa/kWh';
  }

  @override
  String get predModeloTesis => 'Modelo da tese';

  @override
  String get predTitulo => 'Previsão de IA';

  @override
  String get predTiempoRestante => 'Tempo restante estimado';

  @override
  String get predConfianzaRotulo => 'Confiança da previsão';

  @override
  String get predDatosConsiderados => 'Dados considerados';

  @override
  String get procesoLote => 'Processo do lote';

  @override
  String get zonaHumedo => 'Úmido';

  @override
  String get zonaOreado => 'Pré-seco';

  @override
  String get zonaObjetivo => 'Objetivo alcançado';

  @override
  String get zonaSobresecado => 'Secagem excessiva';

  @override
  String get zonaHumedo53 => 'Úmido 53 %';

  @override
  String get zonaActual => 'Zona atual: ';

  @override
  String escalaLector(String valor, String zona) {
    return 'Escala de umidade: $valor %, zona $zona';
  }

  @override
  String get actEncendido => 'Ligado';

  @override
  String get actApagado => 'Desligado';

  @override
  String get actBloqueado => 'Bloqueado';

  @override
  String get actEncendiendoSolo => 'Ligando…';

  @override
  String get actApagandoSolo => 'Desligando…';

  @override
  String actBloqueadoSeguridad(String motivo) {
    return 'Bloqueado por segurança · $motivo';
  }

  @override
  String get actPorProtocolo => 'Controlado pelo protocolo';

  @override
  String actNominal(String vatios) {
    return 'Nominal $vatios W';
  }

  @override
  String get ordenEnviada => 'Comando enviado';

  @override
  String get mantenerHint =>
      'Mantenha pressionado. Com leitor de tela, toque duas vezes e mantenha.';

  @override
  String get alertasRecientes => 'Alertas recentes';

  @override
  String get verTodas => 'Ver todas';

  @override
  String get sinAlertas => 'Nenhum alerta ativo';

  @override
  String get todoEnOrden => 'Tudo certo.';

  @override
  String get saludTitulo => 'Os aparelhos estão funcionando?';

  @override
  String get saludSi => 'Sim, tudo certo';

  @override
  String get saludRevisa => 'Verifique os aparelhos';

  @override
  String mapaLector(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Mapa esquemático de Nariño com $cantidad secadores',
      one: 'Mapa esquemático de Nariño com 1 secador',
    );
    return '$_temp0';
  }

  @override
  String get sinOrdenes => 'Nenhum comando registrado ainda.';

  @override
  String get ingresaParaCambios => 'Entre com sua conta para fazer alterações';

  @override
  String get cargandoSecador => 'Carregando o estado do secador…';

  @override
  String errorServidorCodigo(String codigo) {
    return 'O servidor respondeu com um erro (código $codigo).';
  }

  @override
  String get errorSinRespuesta => 'O servidor não respondeu.';

  @override
  String get errorReintentaSolo => ' Tenta de novo sozinho a cada 30 s.';

  @override
  String get errorCargaTitulo => 'Não foi possível carregar estes dados';

  @override
  String get reintentar => 'Tentar de novo';

  @override
  String avisoCopiaGuardada(String cuando) {
    return 'Sem sinal: você está vendo a cópia salva ($cuando).';
  }

  @override
  String avisoNoReportaDesde(String cuando) {
    return 'O secador não envia dados desde $cuando. Você vê o último dado com a hora.';
  }

  @override
  String get avisoSuInstalacion => 'a instalação';

  @override
  String get actualizar => 'Atualizar';

  @override
  String get filtro => 'Filtro';

  @override
  String get filtroTodos => 'Todos';

  @override
  String get lotesSinFiltro => 'Nenhum lote com este filtro.';

  @override
  String get nuevoLote => 'Novo lote';

  @override
  String get loteTitulo => 'Lote';

  @override
  String get cargandoLote => 'Carregando o lote…';

  @override
  String get curvaHumedad => 'Curva de umidade';

  @override
  String get proceso => 'Processo';

  @override
  String get faseInicio => 'Início';

  @override
  String get faseCalentamiento => 'Aquecimento';

  @override
  String get faseSecadoActivo => 'Secagem ativa';

  @override
  String get faseReduccion => 'Redução de umidade';

  @override
  String get faseAjustes => 'Ajustes';

  @override
  String get faseFinalizacion => 'Finalização';

  @override
  String faseEnCursoDesde(String cuando) {
    return 'Em andamento · desde $cuando';
  }

  @override
  String get faseSinRegistro => 'Sem registro';

  @override
  String get faseEnCurso => 'Em andamento';

  @override
  String get fasePendiente => 'Pendente';

  @override
  String get predEntre => 'Entre ';

  @override
  String get predY => ' e ';

  @override
  String get predListoCerca => ' · pronto por volta de ';

  @override
  String predPesajes(String cantidad) {
    return '$cantidad pesagens';
  }

  @override
  String predAjustesBootstrap(String cantidad) {
    return '$cantidad ajustes bootstrap';
  }

  @override
  String predOrientativo(String cantidad, String minimo) {
    return 'Só $cantidad pesagens: abaixo de $minimo a tese a considera apenas indicativa.';
  }

  @override
  String get predAjustando => 'Ajustando os modelos da tese…';

  @override
  String get predNoCalculo => 'Não foi possível calcular a previsão.';

  @override
  String get predListo => 'Pronto';

  @override
  String predListoTexto(String valor) {
    return 'A amostra está em $valor %: dentro da faixa comercial. Pode retirar.';
  }

  @override
  String get predPasado => 'Passou';

  @override
  String predPasadoTexto(String valor) {
    return 'A amostra está em $valor %, abaixo de 10 %: secagem excessiva.';
  }

  @override
  String get predNoLlega => 'Não chega';

  @override
  String get predPocosPesajesPunto => 'Poucas pesagens para prever.';

  @override
  String predPuntoRetiro(String lista) {
    return 'Ponto de retirada por modelo: $lista desde a primeira pesagem.';
  }

  @override
  String get predNoLlegaMin => 'não chega';

  @override
  String get redTitulo => 'Rede neural · sensores';

  @override
  String redConFalla(int cantidad) {
    return '$cantidad com falha';
  }

  @override
  String get redSinFallas => 'Sem falhas';

  @override
  String red2hHasta(String cuando) {
    return '2 h até $cuando';
  }

  @override
  String redPie(String f1) {
    return 'MLP (32, 16) da tese, F1 $f1 no teste. Classifica a forma do sinal: normal, travado, deriva, salto de degrau, ruído, picos ou saturado.';
  }

  @override
  String iaError(String error) {
    return 'Não foi possível consultar a IA. ($error)';
  }

  @override
  String get iaTitulo => 'Segunda opinião de IA';

  @override
  String iaPie(String cuando) {
    return 'Texto gerado por IA com os dados do lote, a previsão da tese, a rede neural e o clima · $cuando. Não substitui a medição.';
  }

  @override
  String get iaExplica =>
      'Um modelo de linguagem lê os dados do lote e a previsão da tese e dá sua estimativa com uma recomendação.';

  @override
  String get iaVolver => 'Consultar de novo';

  @override
  String get iaConsultar => 'Consultar a IA';

  @override
  String get nombreLote => 'Nome do lote';

  @override
  String get nombreLoteEjemplo => 'Lote C · Castillo';

  @override
  String get nombreLotePista =>
      'Assim aparecerá no painel, no app e no relógio.';

  @override
  String get dondeSeSeca => 'Onde seca?';

  @override
  String get variedad => 'Variedade';

  @override
  String get sinEspecificar => 'Não especificada';

  @override
  String get protocolo => 'Protocolo';

  @override
  String get muestra => 'Amostra';

  @override
  String get humedadInicial => 'Umidade inicial';

  @override
  String get humedadObjetivo => 'Umidade objetivo';

  @override
  String get pesoRetiro => 'Peso de retirada calculado';

  @override
  String materiaSeca(String gramos) {
    return 'com $gramos g de matéria seca';
  }

  @override
  String get iniciarLote => 'Iniciar lote';

  @override
  String get escribeNombre => 'Escreva o nome do lote.';

  @override
  String get loteIniciado => 'Lote iniciado';

  @override
  String get sinLoteActivo => 'Nenhum lote ativo';

  @override
  String get sinLoteActivoTexto =>
      'Inicie um lote para começar a pesar a amostra toda manhã.';

  @override
  String get cargandoPesajes => 'Carregando as pesagens…';

  @override
  String get pesoMuestra => 'Peso da amostra';

  @override
  String get hecho => 'Pronto';

  @override
  String corregirPesaje(String cuando) {
    return 'Corrigir pesagem · $cuando';
  }

  @override
  String get pesoCorregido => 'Peso corrigido';

  @override
  String get guardar => 'Salvar';

  @override
  String get eliminarPesaje => 'Excluir pesagem';

  @override
  String get escribePesoCorregido => 'Escreva o peso corrigido em gramas.';

  @override
  String get pesajeCorregido => 'Pesagem corrigida';

  @override
  String get pesajeEliminado => 'Pesagem excluída';

  @override
  String get faltaSecar => 'Ainda falta secar';

  @override
  String get rangoComercial => 'Está na faixa comercial: pode retirar';

  @override
  String get yaPaso => 'Passou do ponto: secagem excessiva';

  @override
  String pesoMuestraDe(String lote) {
    return 'Peso da amostra · $lote';
  }

  @override
  String get restarDecima => 'Diminuir 0,1 g';

  @override
  String get sumarDecima => 'Aumentar 0,1 g';

  @override
  String pesoLector(String gramos) {
    return 'Peso $gramos gramas. Toque para digitar.';
  }

  @override
  String get retiraEntre => 'Retire entre ';

  @override
  String rangoGramos(String desde, String hasta) {
    return '$desde e $hasta g';
  }

  @override
  String get registrarPesaje => 'Registrar pesagem';

  @override
  String get pesajeRegistrado => 'Pesagem registrada';

  @override
  String pesajeDetalle(String gramos, String humedad) {
    return '$gramos g · $humedad % de umidade';
  }

  @override
  String get ingresaParaPesar =>
      'Para registrar pesagens, entre com sua conta.';

  @override
  String pesajesDe(String lote) {
    return 'Pesagens de $lote';
  }

  @override
  String get sinPesajesLote => 'Este lote ainda não tem pesagens.';

  @override
  String pesajePie(String ajuste, String gramos) {
    return 'Umidade por conservação de matéria seca (Cenicafé)$ajuste: $gramos g de matéria seca. Toque numa pesagem para corrigi-la.';
  }

  @override
  String get ajustadaPuntos => ', ajustada com pontos medidos';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');
}
