import 'package:flutter/material.dart';
import '../theme.dart';

/// 📍 Step Indicator - Visual progress for multi-step flows
class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final List<String>? labels;
  final Color? activeColor;
  final Color? inactiveColor;

  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.labels,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.primary;
    final inactive = inactiveColor ?? AppColors.textMuted;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps * 2 - 1, (index) {
            if (index.isOdd) {
              // Connector line
              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex < currentStep;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: isCompleted
                        ? LinearGradient(colors: [active, active.withOpacity(0.7)])
                        : null,
                    color: isCompleted ? null : inactive.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            } else {
              // Step circle
              final stepIndex = index ~/ 2;
              final isActive = stepIndex == currentStep;
              final isCompleted = stepIndex < currentStep;

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: isActive ? 1 : 0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Container(
                    width: 32 + (value * 4),
                    height: 32 + (value * 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isActive
                          ? active.withOpacity(0.15)
                          : inactive.withOpacity(0.1),
                      border: Border.all(
                        color: isCompleted || isActive ? active : inactive.withOpacity(0.5),
                        width: isActive ? 2.5 : 2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: active.withOpacity(0.4 * value),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(Icons.check, color: active, size: 18)
                          : Text(
                              '${stepIndex + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isActive ? active : inactive,
                              ),
                            ),
                    ),
                  );
                },
              );
            }
          }),
        ),
        if (labels != null && labels!.length == totalSteps) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels!.asMap().entries.map((entry) {
              final isActive = entry.key == currentStep;
              final isCompleted = entry.key < currentStep;
              return Expanded(
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isCompleted || isActive
                        ? (activeColor ?? AppColors.primary)
                        : AppColors.textMuted,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
