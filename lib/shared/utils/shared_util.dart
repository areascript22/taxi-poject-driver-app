import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class SharedUtil {
  final AudioPlayer _audioPlayer = AudioPlayer();
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
    if (response != null && response) {
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
    if (response != null && response) {
      Vibration.vibrate();
    } else {
      logger.e("Vibration is not available.");
    }
  }
}
