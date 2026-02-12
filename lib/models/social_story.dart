class SocialStory {
  final String id;
  final String title;
  final String description;
  final String icon;
  final List<StorySegment> segments;

  SocialStory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.segments,
  });
}

class StorySegment {
  final String id;
  final String text;
  final String? imageAsset; // Path to image if any
  final List<StoryChoice> choices;

  StorySegment({
    required this.id,
    required this.text,
    this.imageAsset,
    required this.choices,
  });
}

class StoryChoice {
  final String text;
  final String? nextSegmentId; // null means end of story
  final int? xpReward;

  StoryChoice({
    required this.text,
    this.nextSegmentId,
    this.xpReward,
  });
}
