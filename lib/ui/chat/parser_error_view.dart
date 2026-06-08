// parser_error_view.dart

import 'package:flutter/material.dart';

import '../../models/validation_error.dart';

class ParserErrorView extends StatelessWidget {

  final List<ValidationError> errors;

  const ParserErrorView({
    super.key,
    required this.errors,
  });

  @override
  Widget build(BuildContext context) {

    return ListView.builder(

      padding: const EdgeInsets.all(16),

      itemCount: errors.length,

      itemBuilder: (_, index) {

        final err = errors[index];

        return Card(

          color: Colors.red.withOpacity(0.08),

          child: Padding(

            padding: const EdgeInsets.all(16),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(

                  'Transaction ${err.transactionIndex}',

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(err.message),
              ],
            ),
          ),
        );
      },
    );
  }
}