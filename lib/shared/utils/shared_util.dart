import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class SharedUtil {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();
  final logger = Logger();

  //Open Options like whatsapp and SMS
  void sendSMS(String phoneNumber, String message) async {
    final logger = Logger();
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );
    logger.i("send sms : $phoneNumber");
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw 'Could not launch SMS: $smsUri';
      }
    } catch (e) {
      logger.e('Error sending SMS: $e');
    }
  }

// lauch whatsapp
  void launchWhatsApp(String phoneNumber, {String message = ''}) async {
    final Uri whatsappUri = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  //Play audio
  Future<void> playAudioOnce(String filePath) async {
    bool? response = await Vibration.hasVibrator();
    if (response) {
      Vibration.vibrate();
    }
    if (filePath.isEmpty) {
      logger.e("Audio URL is empty: $filePath.aac");
      return;
    }
    try {
      await _audioPlayer.play(AssetSource(filePath), volume: 1);
    } catch (e) {
      logger.e("Error trying to play audio: $e");
    }
  }

  //Make vibrate
  Future<void> makePhoneVibrate() async {
    bool? response = await Vibration.hasVibrator();
    if (response) {
      Vibration.vibrate();
    } else {
      logger.e("Vibration is not available.");
    }
  }

  /// Cola de habla
  Future _speechQueue = Future.value();
//Text to speech
  Future<void> speakSectorName(String name) {
    // Añadimos a la cola de habla
    _speechQueue = _speechQueue.then((_) async {
      try {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.setLanguage("es-ES");
        await flutterTts.setSpeechRate(0.5);
        await flutterTts.setPitch(1.0);
        await flutterTts.speak(name);
      } catch (e) {
        logger.e('Error en speakSectorName: $e');
      }
    });

    // Devolvemos el nuevo estado de la cola
    return _speechQueue;
  }

//
  Future<void> openEmailApp() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'taxigo11032025@gmail.com', // Cambia al email del administrador
      queryParameters: {
        'subject': 'Consulta desde la app',
        'body': 'Hola, me gustaría hacer una consulta sobre...'
      },
    );
    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      logger.e('No se pudo abrir la aplicación de correo, $e');
    }
  }
}
