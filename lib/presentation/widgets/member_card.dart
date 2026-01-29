
import 'package:flutter/material.dart';
import 'package:digitaledir/core/models/user.dart';
import 'package:digitaledir/core/theme/app_theme.dart';

class MemberCard extends StatelessWidget {
  final User member;
  final Function(bool) onStatusChange;

  const MemberCard({
    super.key,
    required this.member,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Avatar and Status
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    member.name?.substring(0, 1).toUpperCase() ?? 'M',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name ?? 'Unnamed Member',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.phone ?? 'No phone',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.greyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: member.isActive
                        ? AppTheme.secondaryColor.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    member.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: member.isActive ? AppTheme.secondaryColor : Colors.red,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Member Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyColor,
                        ),
                      ),
                      Text(
                        member.email ?? 'No email',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Member Since',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyColor,
                        ),
                      ),
                      Text(
                        _formatDate(member.createdAt),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Groups
            if (member.groupIds != null && member.groupIds!.isNotEmpty) ...[
              Text(
                'Edir Groups (${member.groupIds!.length})',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.greyColor,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: member.groupIds!.map((groupId) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Edir ${groupId.split('_').last}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // View details or edit
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: member.isActive
                      ? OutlinedButton.icon(
                          onPressed: () => onStatusChange(false),
                          icon: const Icon(Icons.block, size: 18),
                          label: const Text('Deactivate'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: Colors.red),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => onStatusChange(true),
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Activate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}