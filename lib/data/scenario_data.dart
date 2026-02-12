import '../models/scenario_question.dart';

class ScenarioData {
  static final List<ScenarioQuestion> allQuestions = [
    // -------------------------------------------------------------------------
    // SCHOOL SCENARIOS (20)
    // -------------------------------------------------------------------------
    ScenarioQuestion(
      id: 's1',
      scenario: "Your teacher praises your artwork in front of the class.",
      emotion: 'Proud',
      options: ['Proud', 'Sad', 'Angry', 'Disgust'],
      explanation: "It feels great to be recognized for your hard work! 🏆",
    ),
    ScenarioQuestion(
      id: 's2',
      scenario: "You forgot your homework at home.",
      emotion: 'Fear', // or Nervous
      options: ['Happy', 'Fear', 'Excited', 'Proud'],
      explanation: "It's normal to feel worried about forgetting things. 😟",
    ),
    ScenarioQuestion(
      id: 's3',
      scenario: "A classmate pushes you in the hallway.",
      emotion: 'Angry',
      options: ['Happy', 'Angry', 'Excited', 'Proud'],
      explanation: "Getting pushed is not nice and can make you feel mad. 😠",
    ),
    ScenarioQuestion(
      id: 's4',
      scenario: "You have to give a speech in front of the class.",
      emotion: 'Nervous',
      options: ['Bored', 'Nervous', 'Disgust', 'Happy'],
      explanation: "Public speaking gives many people butterflies! 🦋",
    ),
    ScenarioQuestion(
      id: 's5',
      scenario: "You got an A+ on a difficult test.",
      emotion: 'Excited', // or Happy/Proud
      options: ['Sad', 'Excited', 'Fear', 'Disgust'],
      explanation: "Hard work pays off! Keeping that energy up is awesome! 🤩",
    ),
    ScenarioQuestion(
      id: 's6',
      scenario: "Your best friend sits with someone else at lunch.",
      emotion: 'Sad', // or Jealous (complex) -> Sad for now
      options: ['Happy', 'Sad', 'Excited', 'Proud'],
      explanation: "It can hurt feelings when friends change routines. 😢",
    ),
    ScenarioQuestion(
      id: 's7',
      scenario: "The teacher calls on you but you don't know the answer.",
      emotion: 'Shy', // or Embarrassed -> use Shy/Nervous
      options: ['Proud', 'Shy', 'Happy', 'Excited'],
      explanation: "It's okay not to know everything. Everyone is learning! 😳",
    ),
    ScenarioQuestion(
      id: 's8',
      scenario: "You win the school spelling bee!",
      emotion: 'Happy',
      options: ['Happy', 'Sad', 'Angry', 'Disgust'],
      explanation: "Winning is a joyful moment! Celebrate yourself! 🎉",
    ),
    ScenarioQuestion(
      id: 's9',
      scenario: "You see someone bullying a younger student.",
      emotion: 'Angry', // or Disgust/Concern
      options: ['Happy', 'Angry', 'Excited', 'Proud'],
      explanation: "Seeing unfair things can make us angry and want to help. 🛡️",
    ),
    ScenarioQuestion(
      id: 's10',
      scenario: "The class moves to a boring chapter in history.",
      emotion: 'Bored',
      options: ['Excited', 'Bored', 'Fear', 'Surprise'],
      explanation: "Not everything is fun all the time, and that's okay. 🥱",
    ),
     ScenarioQuestion(
      id: 's11',
      scenario: "You are picked last for the kickball team.",
      emotion: 'Sad',
      options: ['Happy', 'Sad', 'Excited', 'Surprise'],
      explanation: "Being left out can make anyone feel small and sad. 💙",
    ),
    ScenarioQuestion(
      id: 's12',
      scenario: "Your project partner refuses to do any work.",
      emotion: 'Frustrated', // map to Angry
      options: ['Happy', 'Angry', 'Proud', 'Excited'],
      explanation: "It's frustrating when things aren't fair. 😤",
    ),
    ScenarioQuestion(
      id: 's13',
      scenario: "The fire alarm goes off loudly and unexpectedly.",
      emotion: 'Surprise', // or Fear
      options: ['Bored', 'Surprise', 'Happy', 'Sad'],
      explanation: "Loud, sudden noises are startling! 😲",
    ),
    ScenarioQuestion(
      id: 's14',
      scenario: "You find a cool rock on the playground.",
      emotion: 'Happy', // or Excited
      options: ['Happy', 'Sad', 'Fear', 'Angry'],
      explanation: "Small discoveries can bring big joy! 🪨",
    ),
    ScenarioQuestion(
      id: 's15',
      scenario: "Someone spills milk all over your new shirt.",
      emotion: 'Disgust', // or Angry/Sad
      options: ['Happy', 'Disgust', 'Proud', 'Excited'],
      explanation: "Being wet and messy feels yucky! 🤢",
    ),
    ScenarioQuestion(
      id: 's16',
      scenario: "You volunteer to lead the line.",
      emotion: 'Proud',
      options: ['Sad', 'Proud', 'Fear', 'Disgust'],
      explanation: "Taking responsibility feels good! 🫡",
    ),
    ScenarioQuestion(
      id: 's17',
      scenario: "You don't understand the math lesson at all.",
      emotion: 'Confused',
      options: ['Happy', 'Confused', 'Proud', 'Excited'],
      explanation: "It's normal to be confused when learning something new. ❓",
    ),
    ScenarioQuestion(
      id: 's18',
      scenario: "Your friend tells you a big secret.",
      emotion: 'Surprise', // or Honored (complex) -> Surprise/Happy
      options: ['Bored', 'Surprise', 'Disgust', 'Sad'],
      explanation: "Secrets can be surprising and special! 🤫",
    ),
     ScenarioQuestion(
      id: 's19',
      scenario: "The school trip gets cancelled due to rain.",
      emotion: 'Sad', // Disappointed
      options: ['Happy', 'Sad', 'Excited', 'Proud'],
      explanation: "It's disappointing when fun plans change. 🌧️",
    ),
    ScenarioQuestion(
      id: 's20',
      scenario: "You finish a really hard puzzle.",
      emotion: 'Proud',
      options: ['Sad', 'Proud', 'Fear', 'Angry'],
      explanation: "Overcoming a challenge makes you feel accomplished! 🧩",
    ),

    // -------------------------------------------------------------------------
    // HOME & FAMILY SCENARIOS (20)
    // -------------------------------------------------------------------------
    ScenarioQuestion(
      id: 'h1',
      scenario: "Your parents surprise you with a puppy!",
      emotion: 'Excited',
      options: ['Sad', 'Excited', 'Bored', 'Angry'],
      explanation: "A new furry friend?! That's super exciting! 🐶",
    ),
    ScenarioQuestion(
      id: 'h2',
      scenario: "Your sibling breaks your favorite toy on purpose.",
      emotion: 'Angry',
      options: ['Happy', 'Angry', 'Proud', 'Surprise'],
      explanation: "It hurts when things you love are broken. 😡",
    ),
    ScenarioQuestion(
      id: 'h3',
      scenario: "Grandma brings your favorite cookies.",
      emotion: 'Happy',
      options: ['Sad', 'Happy', 'Fear', 'Disgust'],
      explanation: "Tasty treats and family love are the best! 🍪",
    ),
    ScenarioQuestion(
      id: 'h4',
      scenario: "You hear a strange noise in the dark basement.",
      emotion: 'Fear',
      options: ['Happy', 'Fear', 'Proud', 'Bored'],
      explanation: "The unknown can be scary sometimes. 🔦",
    ),
    ScenarioQuestion(
      id: 'h5',
      scenario: "You have to clean your room instead of playing.",
      emotion: 'Bored', // or Annoyed
      options: ['Excited', 'Bored', 'Happy', 'Surprise'],
      explanation: "Chores aren't always fun, but they are important. 🧹",
    ),
    ScenarioQuestion(
      id: 'h6',
      scenario: "You accidentally drop a glass and it shatters.",
      emotion: 'Fear', // or Surprise/Guilt
      options: ['Happy', 'Fear', 'Proud', 'Bored'],
      explanation: "Accidents happen, but the crash can be scary! 💥",
    ),
    ScenarioQuestion(
      id: 'h7',
      scenario: "Your family cheers for you during a game.",
      emotion: 'Proud', // or Happy
      options: ['Sad', 'Proud', 'Angry', 'Disgust'],
      explanation: "Support from family makes you feel strong! 💪",
    ),
    ScenarioQuestion(
      id: 'h8',
      scenario: "You find a spider in your shoe.",
      emotion: 'Fear', // or Disgust
      options: ['Happy', 'Fear', 'Proud', 'Sad'],
      explanation: "Unexpected creepy crawlies can be frightening! 🕷️",
    ),
    ScenarioQuestion(
      id: 'h9',
      scenario: "Dinner is a vegetable you really dislike.",
      emotion: 'Disgust',
      options: ['Happy', 'Disgust', 'Excited', 'Proud'],
      explanation: "Yuck! Everyone has foods they don't like. 🥦",
    ),
    ScenarioQuestion(
      id: 'h10',
      scenario: "Your cousin comes to visit unexpectedly.",
      emotion: 'Surprise', // or Excited
      options: ['Bored', 'Surprise', 'Sad', 'Disgust'],
      explanation: "Surprise visitors can be fun! 👋",
    ),
    ScenarioQuestion(
      id: 'h11',
      scenario: "You lose a board game against your sister.",
      emotion: 'Sad', // or Angry (Sore loser)
      options: ['Happy', 'Sad', 'Excited', 'Proud'],
      explanation: "Losing isn't fun, but it's part of playing. 🎲",
    ),
    ScenarioQuestion(
      id: 'h12',
      scenario: "You help cook dinner and it tastes great.",
      emotion: 'Proud',
      options: ['Sad', 'Proud', 'Fear', 'Disgust'],
      explanation: "Making something yourself feels like an achievement! 🍳",
    ),
    ScenarioQuestion(
      id: 'h13',
      scenario: "The power goes out during a storm.",
      emotion: 'Fear', // or Surprise
      options: ['Happy', 'Fear', 'Proud', 'Excited'],
      explanation: "Darkness and thunder can be spooky. ⚡",
    ),
    ScenarioQuestion(
      id: 'h14',
      scenario: "You get to stay up late for a movie.",
      emotion: 'Excited',
      options: ['Sad', 'Excited', 'Angry', 'Disgust'],
      explanation: "Breaking routine for fun is exciting! 🍿",
    ),
    ScenarioQuestion(
      id: 'h15',
      scenario: "Your pet fish looks sick.",
      emotion: 'Sad', // or Worried
      options: ['Happy', 'Sad', 'Excited', 'Proud'],
      explanation: "We care about our pets, so we feel sad when they are unwell. 🐟",
    ),
    ScenarioQuestion(
      id: 'h16',
      scenario: "You step in a wet puddle with socks on.",
      emotion: 'Disgust',
      options: ['Happy', 'Disgust', 'Proud', 'Excited'],
      explanation: "Ew, wet socks feel gross! 🧦",
    ),
    ScenarioQuestion(
      id: 'h17',
      scenario: "You can't find your favorite blanket.",
      emotion: 'Sad', // or Frustrated/Anxious
      options: ['Happy', 'Sad', 'Excited', 'Proud'],
      explanation: "Losing comfort items is upsetting. 🧸",
    ),
    ScenarioQuestion(
      id: 'h18',
      scenario: "Your parents misunderstand what you said.",
      emotion: 'Frustrated', // map to Angry/Confused
      options: ['Happy', 'Angry', 'Proud', 'Excited'],
      explanation: "It's hard when people don't understand you. 🗣️",
    ),
    ScenarioQuestion(
      id: 'h19',
      scenario: "You wake up and it's your birthday!",
      emotion: 'Excited', // or Happy
      options: ['Sad', 'Excited', 'Bored', 'Disgust'],
      explanation: "Birthdays are special days full of joy! 🎂",
    ),
    ScenarioQuestion(
      id: 'h20',
      scenario: "Nothing interesting is on TV.",
      emotion: 'Bored',
      options: ['Excited', 'Bored', 'Fear', 'Surprise'],
      explanation: "Sometimes there's just nothing to do. 📺",
    ),

    // -------------------------------------------------------------------------
    // FRIENDS & SOCIAL SCENARIOS (20)
    // -------------------------------------------------------------------------
    ScenarioQuestion(
      id: 'f1',
      scenario: "Your friend shares their snack with you.",
      emotion: 'Happy',
      options: ['Sad', 'Happy', 'Angry', 'Fear'],
      explanation: "Sharing is caring and makes us feel loved! 🍎",
    ),
    ScenarioQuestion(
      id: 'f2',
      scenario: "A friend tells a lie about you.",
      emotion: 'Angry', // or Sad/Betrayed
      options: ['Happy', 'Angry', 'Excited', 'Proud'],
      explanation: "Lies can hurt and make us feel betrayed. 🤥",
    ),
    ScenarioQuestion(
      id: 'f3',
      scenario: "You are invited to a cool party.",
      emotion: 'Excited',
      options: ['Sad', 'Excited', 'Bored', 'Disgust'],
      explanation: "Parties are fun events to look forward to! 🎈",
    ),
    ScenarioQuestion(
      id: 'f4',
      scenario: "You introduce yourself to a new kid.",
      emotion: 'Shy', // or Nervous/Brave
      options: ['Angry', 'Shy', 'Disgust', 'Bored'],
      explanation: "Meeting new people takes courage! 👋",
    ),
    ScenarioQuestion(
      id: 'f5',
      scenario: "Your friend trips and falls.",
      emotion: 'Concerned', // Map to Sad or Fear -> Empathy
      options: ['Happy', 'Sad', 'Proud', 'Excited'],
      explanation: "We feel bad when our friends get hurt. 🩹",
    ),
    ScenarioQuestion(
      id: 'f6',
      scenario: "You and a friend argue over a game.",
      emotion: 'Angry',
      options: ['Happy', 'Angry', 'Excited', 'Proud'],
      explanation: "Disagreements can happen, but you can solve them! 🤝",
    ),
    ScenarioQuestion(
      id: 'f7',
      scenario: "Someone compliments your shoes.",
      emotion: 'Happy', // or Proud
      options: ['Sad', 'Happy', 'Fear', 'Disgust'],
      explanation: "Compliments make us feel noticed and good! 👟",
    ),
    ScenarioQuestion(
      id: 'f8',
      scenario: "Everyone is laughing at a joke you didn't hear.",
      emotion: 'Confused', // or Left out
      options: ['Proud', 'Confused', 'Excited', 'Happy'],
      explanation: "It's confusing when you miss the punchline. 🤷",
    ),
    ScenarioQuestion(
      id: 'f9',
      scenario: "A friend moves away to another city.",
      emotion: 'Sad',
      options: ['Happy', 'Sad', 'Excited', 'Surprise'],
      explanation: "Saying goodbye is very hard. 📦",
    ),
    ScenarioQuestion(
      id: 'f10',
      scenario: "You are chosen as team captain.",
      emotion: 'Proud',
      options: ['Sad', 'Proud', 'Fear', 'Disgust'],
      explanation: "Being a leader is a big responsibility and honor! 🏅",
    ),
    // ... adding more for variety
     ScenarioQuestion(
      id: 'f11',
      scenario: "A friend plays a prank on you.",
      emotion: 'Surprise', // or Angry depending on prank
      options: ['Bored', 'Surprise', 'Sad', 'Proud'],
      explanation: "Pranks can be shocking! 🃏",
    ),
    ScenarioQuestion(
      id: 'f12',
      scenario: "You have no one to play with at the park.",
      emotion: 'Sad', // Lonely
      options: ['Happy', 'Sad', 'Excited', 'Surprise'],
      explanation: "Being alone when you want to play is lonely. 🎠",
    ),
    ScenarioQuestion(
      id: 'f13',
      scenario: "Someone new asks to be your friend.",
      emotion: 'Happy', // or Excited
      options: ['Sad', 'Happy', 'Angry', 'Disgust'],
      explanation: "New friendships are wonderful gifts! 🎁",
    ),
    ScenarioQuestion(
      id: 'f14',
      scenario: "Your friend breaks a promise.",
      emotion: 'Sad', // Disappointed
      options: ['Happy', 'Sad', 'Excited', 'Proud'],
      explanation: "Broken promises hurt our trust. 💔",
    ),
    ScenarioQuestion(
      id: 'f15',
      scenario: "You see a friend eat a worm on a dare.",
      emotion: 'Disgust',
      options: ['Happy', 'Disgust', 'Sad', 'Fear'],
      explanation: "Eww! That's gross! 🐛",
    ),

    // -------------------------------------------------------------------------
    // PUBLIC & WORLD SCENARIOS (15)
    // -------------------------------------------------------------------------
    ScenarioQuestion(
      id: 'p1',
      scenario: "A clown pops out of a box.",
      emotion: 'Surprise', // or Peer
      options: ['Bored', 'Surprise', 'Sad', 'Proud'],
      explanation: "Jack-in-the-boxes are made to startle! 🤡",
    ),
    ScenarioQuestion(
      id: 'p2',
      scenario: "You smell a garbage truck passing by.",
      emotion: 'Disgust',
      options: ['Happy', 'Disgust', 'Excited', 'Proud'],
      explanation: "Bad smells make us wrinkle our noses! 🚛",
    ),
    ScenarioQuestion(
      id: 'p3',
      scenario: "You are lost in a big supermarket.",
      emotion: 'Fear',
      options: ['Happy', 'Fear', 'Proud', 'Bored'],
      explanation: "Being lost is a scary feeling. Stay where you are! 🛒",
    ),
    ScenarioQuestion(
      id: 'p4',
      scenario: "You see a beautiful rainbow.",
      emotion: 'Happy', // Awe
      options: ['Sad', 'Happy', 'Angry', 'Disgust'],
      explanation: "Nature's beauty makes us smile. 🌈",
    ),
    ScenarioQuestion(
      id: 'p5',
      scenario: "You wait in a really long line.",
      emotion: 'Bored', // Impatient
      options: ['Excited', 'Bored', 'Fear', 'Surprise'],
      explanation: "Waiting without anything to do is dull. ⏳",
    ),
    ScenarioQuestion(
      id: 'p6',
      scenario: "A dog runs up to you barking happily.",
      emotion: 'Surprise', // or Happy/Fear
      options: ['Bored', 'Surprise', 'Disgust', 'Sad'],
      explanation: "Sudden animals can be surprising! 🐕",
    ),
    ScenarioQuestion(
      id: 'p7',
      scenario: "You touch a slimy frog.",
      emotion: 'Disgust', // or Surprise
      options: ['Happy', 'Disgust', 'Proud', 'Sad'],
      explanation: "Slimy textures can feel gross! 🐸",
    ),
    ScenarioQuestion(
      id: 'p8',
      scenario: "You find money on the ground.",
      emotion: 'Excited', // or Surprise
      options: ['Sad', 'Excited', 'Angry', 'Bored'],
      explanation: "Finding treasure is exciting! 💰",
    ),
    ScenarioQuestion(
      id: 'p9',
      scenario: "You trip in front of a crowd.",
      emotion: 'Embarrassed', // map to Shy
      options: ['Proud', 'Shy', 'Happy', 'Excited'],
      explanation: "Tripping can make your face feel hot! 😳",
    ),
    ScenarioQuestion(
      id: 'p10',
      scenario: "A stranger yells at you.",
      emotion: 'Fear',
      options: ['Happy', 'Fear', 'Excited', 'Proud'],
      explanation: "Yelling is scary, especially from strangers. 🗣️",
    ),
    // -------------------------------------------------------------------------
    // MORE SCENARIOS (45+)
    // -------------------------------------------------------------------------
    ScenarioQuestion(
      id: 'm1',
      scenario: "You accidentally rip your favorite drawing.",
      emotion: 'Sad',
      options: ['Happy', 'Sad', 'Excited', 'Proud'],
      explanation: "It's sad when our hard work gets ruined. 😢",
    ),
    ScenarioQuestion(
      id: 'm2',
      scenario: "You find out you are going to Disney World!",
      emotion: 'Excited',
      options: ['Bored', 'Excited', 'Sad', 'Angry'],
      explanation: "That's a huge, exciting adventure! 🏰",
    ),
    ScenarioQuestion(
      id: 'm3',
      scenario: "You lose your first tooth.",
      emotion: 'Surprise', // or Excited/Fear mix
      options: ['Bored', 'Surprise', 'Angry', 'Disgust'],
      explanation: "It feels strange and surprising when a tooth falls out! 🦷",
    ),
    ScenarioQuestion(
      id: 'm4',
      scenario: "Someone calls you a mean name.",
      emotion: 'Angry', // or Sad
      options: ['Happy', 'Angry', 'Proud', 'Excited'],
      explanation: "Mean words hurt and can make us feel angry. 😠",
    ),
    ScenarioQuestion(
      id: 'm5',
      scenario: "You perform in a school play.",
      emotion: 'Nervous', // or Proud/Excited
      options: ['Bored', 'Nervous', 'Sad', 'Disgust'],
      explanation: "Being on stage can make you feel jittery! 🎭",
    ),
    ScenarioQuestion(
      id: 'm6',
      scenario: "You finish reading a long book.",
      emotion: 'Proud',
      options: ['Sad', 'Proud', 'Fear', 'Angry'],
      explanation: "Finish a big book is a great accomplishment! 📚",
    ),
    ScenarioQuestion(
      id: 'm7',
      scenario: "You drop your ice cream cone.",
      emotion: 'Sad',
      options: ['Happy', 'Sad', 'Excited', 'Proud'],
      explanation: "It's heartbreaking to lose a treat! 🍦",
    ),
    ScenarioQuestion(
      id: 'm8',
      scenario: "You see a scary movie scene.",
      emotion: 'Fear',
      options: ['Happy', 'Fear', 'Excited', 'Proud'],
      explanation: "Scary movies are designed to make you jump! 👻",
    ),
    ScenarioQuestion(
      id: 'm9',
      scenario: "You smell skunk spray.",
      emotion: 'Disgust',
      options: ['Happy', 'Disgust', 'Proud', 'Excited'],
      explanation: "Phew! That is a very bad smell! 🦨",
    ),
    ScenarioQuestion(
      id: 'm10',
      scenario: "You get a gold star on your homework.",
      emotion: 'Happy', // or Proud
      options: ['Sad', 'Happy', 'Angry', 'Fear'],
      explanation: "Gold stars are a nice reward for good work! ⭐",
    ),
    ScenarioQuestion(
      id: 'm11',
      scenario: "Your friend moves away.",
      emotion: 'Sad',
      options: ['Happy', 'Sad', 'Excited', 'Suprise'],
      explanation: "Missing a friend is very hard. 💔",
    ),
    ScenarioQuestion(
      id: 'm12',
      scenario: "You learn to ride a bike without training wheels.",
      emotion: 'Proud', // or Excited
      options: ['Sad', 'Proud', 'Bored', 'Disgust'],
      explanation: "Learning a new skill makes you feel strong! 🚲",
    ),
    ScenarioQuestion(
      id: 'm13',
      scenario: "It starts raining during your recess.",
      emotion: 'Sad', // Disappointed
      options: ['Happy', 'Sad', 'Excited', 'Proud'],
      explanation: "Rain can wash away outdoor fun. ☔",
    ),
    ScenarioQuestion(
      id: 'm14',
      scenario: "You find a bug in your salad.",
      emotion: 'Disgust',
      options: ['Happy', 'Disgust', 'Proud', 'Excited'],
      explanation: "Yuck! Bugs don't belong in food! 🥗",
    ),
    ScenarioQuestion(
      id: 'm15',
      scenario: "You hear a loud thunderclap.",
      emotion: 'Fear', // or Surprise
      options: ['Happy', 'Fear', 'Bored', 'Sad'],
      explanation: "Thunder can be very loud and scary! ⚡",
    ),
    ScenarioQuestion(
      id: 'm16',
      scenario: "You solve a tricky riddle.",
      emotion: 'Proud', // or Happy
      options: ['Sad', 'Proud', 'Fear', 'Disgust'],
      explanation: "Being smart feels good! 🧠",
    ),
    ScenarioQuestion(
      id: 'm17',
      scenario: "You have to eat brussels sprouts.",
      emotion: 'Disgust', // typically
      options: ['Happy', 'Disgust', 'Excited', 'Proud'],
      explanation: "Not everyone likes the taste of green veggies! 🥬",
    ),
    ScenarioQuestion(
      id: 'm18',
      scenario: "You get a surprise gift.",
      emotion: 'Surprise', // or Happy/Excited
      options: ['Bored', 'Surprise', 'Sad', 'Angry'],
      explanation: "Unexpected gifts are startling and fun! 🎁",
    ),
    ScenarioQuestion(
      id: 'm19',
      scenario: "You are stuck in traffic for hours.",
      emotion: 'Bored', // or Frustrated
      options: ['Excited', 'Bored', 'Happy', 'Surprise'],
      explanation: "Waiting in a car is very dull. 🚗",
    ),
    ScenarioQuestion(
      id: 'm20',
      scenario: "You help an old lady cross the street.",
      emotion: 'Proud', // or Happy
      options: ['Sad', 'Proud', 'Angry', 'Fear'],
      explanation: "Helping others makes your heart feel full. 👵",
    ),
    ScenarioQuestion(
      id: 'm21',
      scenario: "You break your arm and have to wear a cast.",
      emotion: 'Sad', // or Frustrated/Pain
      options: ['Happy', 'Sad', 'Excited', 'Proud'],
      explanation: "Being hurt and limited is no fun. 🤕",
    ),
    ScenarioQuestion(
      id: 'm22',
      scenario: "You see a magic trick.",
      emotion: 'Surprise', // or Confused/Excited
      options: ['Bored', 'Surprise', 'Sad', 'Disgust'],
      explanation: "Magic tricks are amazing and puzzling! 🎩",
    ),
    ScenarioQuestion(
      id: 'm23',
      scenario: "You have to clean the toilet.",
      emotion: 'Disgust',
      options: ['Happy', 'Disgust', 'Excited', 'Proud'],
      explanation: "Cleaning bathrooms is a dirty job! 🚽",
    ),
    ScenarioQuestion(
      id: 'm24',
      scenario: "You win a race.",
      emotion: 'Excited', // or Proud
      options: ['Sad', 'Excited', 'Bored', 'Fear'],
      explanation: "Running fast and winning is thrilling! 🏃",
    ),
    ScenarioQuestion(
      id: 'm25',
      scenario: "You are alone in a dark room.",
      emotion: 'Fear',
      options: ['Happy', 'Fear', 'Proud', 'Excited'],
      explanation: "The dark can hide things, which is scary. 🌑",
    ),
    ScenarioQuestion(
      id: 'm26',
      scenario: "You get caught in a lie.",
      emotion: 'Embarrassed', // map to Shy/Fear
      options: ['Proud', 'Shy', 'Happy', 'Excited'],
      explanation: "It feels bad to be caught doing something wrong. 🤥",
    ),
    ScenarioQuestion(
      id: 'm27',
      scenario: "You build a huge lego tower.",
      emotion: 'Proud',
      options: ['Sad', 'Proud', 'Fear', 'Disgust'],
      explanation: "Creating something big takes patience! 🏗️",
    ),
    ScenarioQuestion(
      id: 'm28',
      scenario: "You taste a lemon.",
      emotion: 'Disgust', // Sour face
      options: ['Happy', 'Disgust', 'Sad', 'Fear'],
      explanation: "Sour things make our faces pucker! 🍋",
    ),
    ScenarioQuestion(
      id: 'm29',
      scenario: "Your balloon pops loudly.",
      emotion: 'Surprise', // or Fear
      options: ['Bored', 'Surprise', 'Happy', 'Proud'],
      explanation: "Pop! It happens so fast! 🎈",
    ),
    ScenarioQuestion(
      id: 'm30',
      scenario: "You have nothing to do on a rainy day.",
      emotion: 'Bored',
      options: ['Excited', 'Bored', 'Fear', 'Surprise'],
      explanation: "Rainy days can feel very long. 🌧️",
    ),
    ScenarioQuestion(
      id: 'm31',
      scenario: "You see a spider web on your face.",
      emotion: 'Fear', // or Disgust
      options: ['Happy', 'Fear', 'Proud', 'Sad'],
      explanation: "Walking into a web is creepy! 🕸️",
    ),
    ScenarioQuestion(
      id: 'm32',
      scenario: "You learn how to whistle.",
      emotion: 'Proud', // or Excited
      options: ['Sad', 'Proud', 'Fear', 'Disgust'],
      explanation: "New talents are cool to show off! 😗",
    ),
    ScenarioQuestion(
      id: 'm33',
      scenario: "Your friend doesn't invite you to their party.",
      emotion: 'Sad', // or Angry/Jealous
      options: ['Happy', 'Sad', 'Excited', 'Surprise'],
      explanation: "Being left out hurts our feelings. 💌",
    ),
    ScenarioQuestion(
      id: 'm34',
      scenario: "You see your favorite celebrity.",
      emotion: 'Excited',
      options: ['Bored', 'Excited', 'Sad', 'Disgust'],
      explanation: "Meeting a hero is a huge moment! 🤩",
    ),
    ScenarioQuestion(
      id: 'm35',
      scenario: "You step in dog poop.",
      emotion: 'Disgust', // and Angry
      options: ['Happy', 'Disgust', 'Proud', 'Excited'],
      explanation: "Oh no! That is gross and smelly! 💩",
    ),
    ScenarioQuestion(
      id: 'm36',
      scenario: "You get lost in a book.",
      emotion: 'Happy', // or Interested/Calm
      options: ['Angry', 'Happy', 'Fear', 'Disgust'],
      explanation: "Good stories make us feel good. 📖",
    ),
    ScenarioQuestion(
      id: 'm37',
      scenario: "You have to wait for your birthday cake.",
      emotion: 'Impatien', // map to Bored/Excited mix -> Bored/Frustrated
      options: ['Excited', 'Bored', 'Fear', 'Sad'],
      explanation: "Waiting for good things is hard! 🍰",
    ),
    ScenarioQuestion(
      id: 'm38',
      scenario: "You see a ghost costume.",
      emotion: 'Fear', // or Surprise
      options: ['Happy', 'Fear', 'Proud', 'Bored'],
      explanation: "Costumes can be spooky! 👻",
    ),
    ScenarioQuestion(
      id: 'm39',
      scenario: "You make a mess with paint.",
      emotion: 'Happy', // or Worried depending heavily on context
      options: ['Sad', 'Happy', 'Fear', 'Disgust'],
      explanation: "Messy art is the best kind of fun! 🎨",
    ),
    ScenarioQuestion(
      id: 'm40',
      scenario: "You can't tie your shoes.",
      emotion: 'Frustrated', // map to Angry/Sad
      options: ['Happy', 'Angry', 'Proud', 'Excited'],
      explanation: "Learning takes practice and patience. 👟",
    ),
    ScenarioQuestion(
      id: 'm41',
      scenario: "You find money in your pocket.",
      emotion: 'Surprise', // or Happy
      options: ['Bored', 'Surprise', 'Sad', 'Fear'],
      explanation: "A surprise bonus is always nice! 💵",
    ),
    ScenarioQuestion(
      id: 'm42',
      scenario: "You have to eat cold soup.",
      emotion: 'Disgust',
      options: ['Happy', 'Disgust', 'Excited', 'Proud'],
      explanation: "Soup is meant to be hot! 🥣",
    ),
    ScenarioQuestion(
      id: 'm43',
      scenario: "You win a stuffed animal.",
      emotion: 'Happy', // or Excited
      options: ['Sad', 'Happy', 'Angry', 'Fear'],
      explanation: "Prizes make us smile! 🧸",
    ),
    ScenarioQuestion(
      id: 'm44',
      scenario: "You see a car crash.",
      emotion: 'Fear', // or Shock/Surprise
      options: ['Happy', 'Fear', 'Proud', 'Bored'],
      explanation: "Accidents are scary and dangerous. 🚗",
    ),
    ScenarioQuestion(
      id: 'm45',
      scenario: "You finish all your chores.",
      emotion: 'Relieved', // map to Happy/Proud
      options: ['Sad', 'Happy', 'Angry', 'Fear'],
      explanation: "Done! Now it's time to play! ✅",
    ),
  ];
}
