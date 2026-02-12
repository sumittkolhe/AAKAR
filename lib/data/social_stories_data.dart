import '../models/social_story.dart';

class SocialStoriesData {
  static final List<SocialStory> stories = [
    // Story 1: The New Student
    SocialStory(
      id: 's1',
      title: 'The New Student',
      description: 'Learn how to make a new friend at school.',
      icon: '🏫',
      segments: [
        StorySegment(
          id: 'start',
          text: "A new student named Alex joins your class. He looks a bit shy and is sitting alone at lunch.",
          choices: [
            StoryChoice(text: "Go sit with him", nextSegmentId: 'sit_with', xpReward: 10),
            StoryChoice(text: "Ignore him", nextSegmentId: 'ignore'),
          ],
        ),
        StorySegment(
          id: 'sit_with',
          text: "You sit next to Alex and say 'Hi'. He smiles and says 'Hello'. What do you ask him?",
          choices: [
            StoryChoice(text: "Do you like video games?", nextSegmentId: 'games', xpReward: 10),
            StoryChoice(text: "Why are you so quiet?", nextSegmentId: 'quiet'),
          ],
        ),
        StorySegment(
          id: 'ignore',
          text: "You stay at your table. Alex eats alone and looks sad. Later, you feel like you missed a chance to make a friend.",
          choices: [
            StoryChoice(text: "Try again tomorrow", nextSegmentId: 'end_retry'),
          ],
        ),
        StorySegment(
          id: 'games',
          text: "Alex's eyes light up! 'Yes! I love Minecraft!' he says. You talk about games for the whole lunch. You made a new friend!",
          choices: [
            StoryChoice(text: "Great job! (Finish)", nextSegmentId: null, xpReward: 50),
          ],
        ),
        StorySegment(
          id: 'quiet',
          text: "Alex looks down. 'I don't know anyone here,' he whispers. He seems uncomfortable.",
          choices: [
            StoryChoice(text: "Apologize and change topic", nextSegmentId: 'apologize', xpReward: 5),
            StoryChoice(text: "Leave him alone", nextSegmentId: 'end_sad'),
          ],
        ),
        StorySegment(
          id: 'apologize',
          text: "You say sorry and ask about his lunch instead. He relaxes and starts talking. It was a rocky start, but you're trying!",
          choices: [
            StoryChoice(text: "Good effort (Finish)", nextSegmentId: null, xpReward: 30),
          ],
        ),
        StorySegment(
          id: 'end_retry',
          text: "Tomorrow is a new day. Being kind takes courage!",
          choices: [
            StoryChoice(text: "Finish", nextSegmentId: null, xpReward: 5),
          ],
        ),
        StorySegment(
          id: 'end_sad',
          text: "It's hard to know what to say sometimes. Keep practicing empathy.",
          choices: [
            StoryChoice(text: "Finish", nextSegmentId: null, xpReward: 5),
          ],
        ),
      ],
    ),

    // Story 2: Sharing Toys
    SocialStory(
      id: 's2',
      title: 'Sharing Toys',
      description: 'Handling conflict when playing.',
      icon: '🧸',
      segments: [
        StorySegment(
          id: 'start',
          text: "You are building a huge tower with blocks. Your friend comes over and grabs a block you were about to use.",
          choices: [
            StoryChoice(text: "Yell 'STOP!'", nextSegmentId: 'yell'),
            StoryChoice(text: "Ask nicely for it back", nextSegmentId: 'ask', xpReward: 10),
          ],
        ),
        StorySegment(
          id: 'yell',
          text: "Your friend gets scared and drops the block. The tower falls over! Now everyone is upset.",
          choices: [
            StoryChoice(text: "Take a deep breath", nextSegmentId: 'calm_down', xpReward: 5),
          ],
        ),
        StorySegment(
          id: 'ask',
          text: "You say, 'Hey, I was using that. Can I have it back please?' Your friend says, 'Oh, sorry! I wanted to help.'",
          choices: [
            StoryChoice(text: "Let them help", nextSegmentId: 'team', xpReward: 20),
            StoryChoice(text: "Play alone", nextSegmentId: 'alone'),
          ],
        ),
        StorySegment(
          id: 'team',
          text: "You work together and build an even bigger tower! Building together is fun.",
          choices: [
            StoryChoice(text: "High Five! (Finish)", nextSegmentId: null, xpReward: 50),
          ],
        ),
        StorySegment(
          id: 'alone',
          text: "You build alone. It's safe, but kind of lonely.",
          choices: [
            StoryChoice(text: "Finish", nextSegmentId: null, xpReward: 10),
          ],
        ),
        StorySegment(
          id: 'calm_down',
          text: "You breathe in and out. You apologize for yelling, and your friend apologizes for grabbing. You restart the tower together.",
          choices: [
            StoryChoice(text: "Nice recovery (Finish)", nextSegmentId: null, xpReward: 30),
          ],
        ),
      ],
    ),
  ];
}
