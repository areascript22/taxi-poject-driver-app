import 'package:driver_app/features/technical_support/view/pages/technical_support_content/contact_admin.dart';
import 'package:driver_app/features/technical_support/view/widgets/option_button.dart';
import 'package:flutter/material.dart';

class TechnicalSupportContent extends StatefulWidget {
  const TechnicalSupportContent({super.key});

  @override
  State<TechnicalSupportContent> createState() =>
      _TechnicalSupportContentState();
}

class _TechnicalSupportContentState extends State<TechnicalSupportContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .inversePrimary
                    .withValues(alpha: 0.2),
                blurRadius: 1,
                offset: const Offset(0, 5), // creates the soft blur effect
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Soporte técnico',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
              maxLines: 2,
            ),
            iconTheme: const IconThemeData(color: Colors.purple),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // OptionButton(
            //   onTap: () {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(
            //     //       builder: (context) => const SolicitudTaxi()),
            //     // );
            //   },
            //   title: '¿Cómo solicitar una carrera en taxi?',
            // ),
            // OptionButton(
            //   onTap: () {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(
            //     //       builder: (context) => const SolicitudEncomienda()),
            //     // );
            //   },
            //   title: '¿Cómo solicitar una encomienda?',
            // ),
            // OptionButton(
            //   onTap: () {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(
            //     //       builder: (context) => const CancelarSolicitud()),
            //     // );
            //   },
            //   title: '¿Cómo puedo cancelar una carrera o encomienda?',
            // ),
            // OptionButton(
            //   onTap: () {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(
            //     //       builder: (context) => const HistorialDeCarreras()),
            //     // );
            //   },
            //   title: '¿Cómo puedo ver mi hitorial de carreras?',
            // ),
            OptionButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactAdmin()),
                );
              },
              title:
                  '¿Tienes alguna duda específica? Comunicate con el administrador',
            ),
          ],
        ),
      ),
    );
  }
}
