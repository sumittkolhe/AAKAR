import '../models/quest.dart';

class QuestData {
  static final List<Quest> allQuests = [
    Quest(id: 'q1', title: 'Say Thank You', description: 'Say "Thank You" to 3 people today.', xpReward: 20),
    Quest(id: 'q2', title: 'Help Clean Up', description: 'Put away your toys or help clean the table.', xpReward: 30),
    Quest(id: 'q3', title: 'Share a Smile', description: 'Smile at everyone you see this morning.', xpReward: 10),
    Quest(id: 'q4', title: 'High Five', description: 'Give a high five to a friend or family member.', xpReward: 15),
    Quest(id: 'q5', title: 'Listen Well', description: 'Listen to a story without interrupting.', xpReward: 25),
    Quest(id: 'q6', title: 'Friendly Hello', description: 'Say "Good Morning" to your teacher or parent.', xpReward: 10),
    Quest(id: 'q7', title: 'Share a Toy', description: 'Let a friend play with your favorite toy.', xpReward: 40),
    Quest(id: 'q8', title: 'Draw a Picture', description: 'Draw a picture for someone you love.', xpReward: 30),
    Quest(id: 'q9', title: 'Drink Water', description: 'Drink 3 glasses of water today.', xpReward: 15), // Self-care
    Quest(id: 'q10', title: 'Deep Breath', description: 'Take 5 deep breaths when you feel energetic.', xpReward: 20),
  ];
}
