// lib/widgets/kpi_card.dart
import 'package:flutter/material.dart';

class KPICard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final Map<String, int>? breakdown;
  final bool inlineBreakdown;

  const KPICard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.breakdown,
    this.inlineBreakdown = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate if there is any extra content (for spacing alignment)
    bool hasExtraContent = (subtitle != null) || (breakdown != null && breakdown!.isNotEmpty);
    
    return Container(
      height: 100,  // Fixed height for all cards
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon and Title (top section)
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          // Value and extra content (bottom section)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Value - always visible
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              
              // Subtitle (if any)
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[500],
                  ),
                ),
              ],
              
              // Breakdown (if any)
              if (breakdown != null && breakdown!.isNotEmpty) ...[
                const SizedBox(height: 4),
                if (inlineBreakdown)
                  Text(
                    breakdown!.entries.map((e) => '${e.key}: ${e.value}').join(' | '),
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Column(
                    children: breakdown!.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            entry.value.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
              ],
              
              // EMPTY SPACE for cards without extra content (to align numbers)
              if (!hasExtraContent) ...[
                const SizedBox(height: 20),  // Reserved space for alignment
              ],
            ],
          ),
        ],
      ),
    );
  }
}