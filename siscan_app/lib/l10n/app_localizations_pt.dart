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
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');
}
