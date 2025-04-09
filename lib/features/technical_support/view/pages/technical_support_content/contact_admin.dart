import 'package:driver_app/features/ride_history/view/widgets/circle_button.dart';
import 'package:driver_app/features/ride_history/view/widgets/custom_devider.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';


class ContactAdmin extends StatefulWidget {
  const ContactAdmin({super.key});

  @override
  State<ContactAdmin> createState() =>
      _ContactAdminState();
}

class _ContactAdminState extends State<ContactAdmin> {
  TextEditingController _messageController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  String _selectedQueryType = 'Problema técnico';
  final sharedUtil = SharedUtil();

  void _sendMessage() {
    String message = _messageController.text.trim();
    String email = _emailController.text.trim();

    if (email.isEmpty || message.isEmpty) {
      _showErrorDialog("Todos los campos son obligatorios.");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Mensaje Enviado"),
          content: const Text(
              "Tu mensaje ha sido enviado al administrador. ¡Gracias por contactarnos!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _messageController.clear();
                _emailController.clear();
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .inversePrimary
                    .withOpacity(0.2),
                blurRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            title: const Text(
              'Contacto con el Administrador',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
              maxLines: 2,
            ),
            iconTheme: const IconThemeData(color: Colors.purple),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿No encontraste lo que buscabas? Contáctanos:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Si tienes alguna duda o comentario, por favor, envíalo ya sea por whatsapp o email, y nos pondremos en contacto contigo.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // TextField(
              //   controller: _emailController,
              //   keyboardType: TextInputType.emailAddress,
              //   decoration: InputDecoration(
              //     labelText: 'Correo electrónico',
              //     hintText: 'Ingresa tu correo electrónico',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8.0),
              //     ),
              //     prefixIcon: const Icon(Icons.email),
              //   ),
              // ),
              // const SizedBox(height: 16),
              // DropdownButtonFormField<String>(
              //   value: _selectedQueryType,
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       _selectedQueryType = newValue!;
              //     });
              //   },
              //   items: <String>[
              //     'Problema técnico',
              //     'Dudas generales',
              //     'Comentarios sobre el servicio',
              //     'Otros',
              //   ].map<DropdownMenuItem<String>>((String value) {
              //     return DropdownMenuItem<String>(
              //       value: value,
              //       child: Text(value),
              //     );
              //   }).toList(),
              //   decoration: InputDecoration(
              //     labelText: 'Tipo de consulta',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8.0),
              //     ),
              //     prefixIcon: const Icon(Icons.category),
              //   ),
              // ),
              // const SizedBox(height: 16),
              // TextField(
              //   controller: _messageController,
              //   maxLines: 4,
              //   decoration: InputDecoration(
              //     labelText: 'Escribe tu mensaje',
              //     hintText: 'Escribe el detalle de tu consulta...',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8.0),
              //     ),
              //     prefixIcon: const Icon(Icons.message),
              //   ),
              // ),
              // const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: _sendMessage,
              //   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              //   child: const Text('Enviar Mensaje',
              //       style: TextStyle(color: Colors.white)),
              // ),

              //Whatsapp
              const CustomDevider(),
              Row(
                children: [
                  //Whatsapp
                  CircleButton(
                    icon: Ionicons.logo_whatsapp,
                    label: "Whatsapp",
                    onPressed: () {
                      sharedUtil.launchWhatsApp("+593998309858");
                    },
                  ),
                  //Email
                  const SizedBox(width: 20),
                  CircleButton(
                    icon: Ionicons.mail_outline,
                    label: "Email",
                    onPressed: () {
                      sharedUtil.openEmailApp();
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
