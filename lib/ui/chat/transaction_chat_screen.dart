// transaction_chat_screen.dart

import 'package:flutter/material.dart';

import '../../models/parser_result.dart';

import '../../services/chat_parser/transaction_chat_service.dart';

import 'parser_error_view.dart';

import 'transaction_preview_card.dart';

import 'transaction_confirmation_bar.dart';

class TransactionChatScreen extends StatefulWidget {

  const TransactionChatScreen({
    super.key,
  });

  @override
  State<TransactionChatScreen> createState() =>
      _TransactionChatScreenState();
}

class _TransactionChatScreenState
    extends State<TransactionChatScreen> {

  final TextEditingController _controller =
      TextEditingController();

  ParserResult? result;

  bool loading = false;

  Future<void> _send() async {

    final text =
        _controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      loading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 150),
    );

    final parsed =
        TransactionChatService.process(
      text,
    );

    setState(() {
      result = parsed;
      loading = false;
    });
  }

  @override
  void dispose() {

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Transaction Chat',
        ),
      ),

      body: Column(

        children: [

          // ================= HELP BOX =================

          Container(

            width: double.infinity,

            padding: const EdgeInsets.all(16),

            color: Colors.blue.withOpacity(0.08),

            child: const Text(

'''
Please add transactions using this syntax:

2-2-26

salary(income) - 20000tk(ESM)

"""
Monthly salary
Bonus included
"""

market - 2500tk(shopping)
''',

              style: TextStyle(
                fontSize: 13,
              ),
            ),
          ),

          // ================= INPUT =================

          Expanded(

            child: Padding(

              padding: const EdgeInsets.all(16),

              child: Column(

                children: [

                  Expanded(

                    child: TextField(

                      controller: _controller,

                      expands: true,

                      maxLines: null,

                      decoration:
                          const InputDecoration(

                        border:
                            OutlineInputBorder(),

                        hintText:
                            'Paste transaction message...',
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(

                    width: double.infinity,

                    child: ElevatedButton(

                      onPressed:
                          loading
                              ? null
                              : _send,

                      child: Text(

                        loading
                            ? 'Processing...'
                            : 'Send',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= RESULT =================

          if (result != null)

            Expanded(

              child: result!.hasErrors

                  ? ParserErrorView(
                      errors: result!.errors,
                    )

                  : Column(

                      children: [

                        Expanded(

                          child: ListView.builder(

                            itemCount:
                                result!.drafts.length,

                            itemBuilder:
                                (_, index) {

                              final tx =
                                  result!
                                      .drafts[index];

                              return TransactionPreviewCard(
                                draft: tx,
                              );
                            },
                          ),
                        ),

                        TransactionConfirmationBar(
                          drafts: result!.drafts,
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}