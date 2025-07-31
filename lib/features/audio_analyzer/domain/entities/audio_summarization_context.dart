import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/constants/prompts.dart';

enum AudioSummarizationContext {
  doctorVisit(doctorVisitPrompt),
  meetingMinutes(meetingMinutesPrompt),
  lectureSummary(lectureSummaryPrompt),
  cookingInstructions(cookingInstructionsPrompt);

  const AudioSummarizationContext(this.prompt);

  final String prompt;

  String displayName(AppLocalizations localizations) {
    switch (this) {
      case AudioSummarizationContext.doctorVisit:
        return localizations.doctorConsultation;
      case AudioSummarizationContext.meetingMinutes:
        return localizations.meetingMinutes;
      case AudioSummarizationContext.lectureSummary:
        return localizations.lectureSummary;
      case AudioSummarizationContext.cookingInstructions:
        return localizations.cookingInstructions;
    }
  }

  String description(AppLocalizations localizations) {
    switch (this) {
      case AudioSummarizationContext.doctorVisit:
        return localizations.doctorConsultationDescription;
      case AudioSummarizationContext.meetingMinutes:
        return localizations.meetingMinutesDescription;
      case AudioSummarizationContext.lectureSummary:
        return localizations.lectureSummaryDescription;
      case AudioSummarizationContext.cookingInstructions:
        return localizations.cookingInstructionsDescription;
    }
  }
}