import 'package:vocario/core/constants/prompts.dart';

enum AudioSummarizationContext {
  doctorVisit(doctorVisitPrompt),
  meetingMinutes(meetingMinutesPrompt),
  lectureSummary(lectureSummaryPrompt),
  cookingInstructions(cookingInstructionsPrompt);

  const AudioSummarizationContext(this.prompt);

  final String prompt;

  String get displayName {
    switch (this) {
      case AudioSummarizationContext.doctorVisit:
        return 'Doctor Consultation';
      case AudioSummarizationContext.meetingMinutes:
        return 'Meeting Minutes';
      case AudioSummarizationContext.lectureSummary:
        return 'Lecture Summary';
      case AudioSummarizationContext.cookingInstructions:
        return 'Cooking Instructions';
    }
  }

  String get description {
    switch (this) {
      case AudioSummarizationContext.doctorVisit:
        return 'Summarize medical consultations with structured clinical information';
      case AudioSummarizationContext.meetingMinutes:
        return 'Create professional meeting minutes with action items and decisions';
      case AudioSummarizationContext.lectureSummary:
        return 'Generate comprehensive study notes from educational content';
      case AudioSummarizationContext.cookingInstructions:
        return 'Convert cooking demonstrations into detailed recipes';
    }
  }
}