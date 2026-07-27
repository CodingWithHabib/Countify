import 'package:flutter/material.dart';

Future<void> showHistoryDialog({
  required BuildContext context,
  required List<String> history,
  required VoidCallback onClearHistory,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      return Dialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.65,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
               Text(
                "History",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: history.isEmpty
                    ? Center(
                  child: Text(
                    "No History Available",
                    style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                 )
                )
                    : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item =
                    history[history.length - 1 - index];

                    Color borderColor = Colors.blue;

                    if (item.contains("Increased")) {
                      borderColor = Colors.green;
                    } else if (item.contains("Decreased")) {
                      borderColor = Colors.red;
                    } else if (item.contains("Reset")) {
                      borderColor = Colors.orange;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(18),
                        border: Border(
                          left: BorderSide(
                            color: borderColor,
                            width: 5,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: borderColor.withOpacity(.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          item,
                          style:  TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      onClearHistory();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Clear",
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Close",
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}