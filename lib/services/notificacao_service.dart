import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificacaoService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> inicializar() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  static Future<void> mostrarNotificacaoStatus(String status) async {
    final mensagem = _mensagemParaStatus(status);
    if (mensagem == null) return;

    const detalhesAndroid = AndroidNotificationDetails(
      'status_pedido',
      'Status do Pedido',
      channelDescription: 'Notificações sobre atualização de status do pedido',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const detalhesIos = DarwinNotificationDetails();

    await _plugin.show(
      0,
      'Pedido Atualizado',
      mensagem,
      const NotificationDetails(android: detalhesAndroid, iOS: detalhesIos),
    );
  }

  static String? _mensagemParaStatus(String status) {
    switch (status.toLowerCase()) {
      case 'em preparo':
        return 'Seu pedido está sendo preparado!';
      case 'pronto':
        return 'Seu pedido está pronto para entrega!';
      case 'entregue':
        return 'Seu pedido foi entregue. Bom apetite!';
      case 'cancelado':
        return 'Seu pedido foi cancelado.';
      default:
        return null;
    }
  }
}
