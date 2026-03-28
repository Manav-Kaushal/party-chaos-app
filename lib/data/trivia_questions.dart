class TriviaQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String category;

  const TriviaQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.category,
  });

  String get correctAnswer => options[correctIndex];
}

class TriviaData {
  static const List<TriviaQuestion> questions = [
    TriviaQuestion(
      question: 'What is the capital of France?',
      options: ['London', 'Berlin', 'Paris', 'Madrid'],
      correctIndex: 2,
      category: 'Geography',
    ),
    TriviaQuestion(
      question: 'Which planet is known as the Red Planet?',
      options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      correctIndex: 1,
      category: 'Science',
    ),
    TriviaQuestion(
      question: 'Who painted the Mona Lisa?',
      options: ['Van Gogh', 'Picasso', 'Da Vinci', 'Michelangelo'],
      correctIndex: 2,
      category: 'Art',
    ),
    TriviaQuestion(
      question: 'What is the largest ocean on Earth?',
      options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
      correctIndex: 3,
      category: 'Geography',
    ),
    TriviaQuestion(
      question: 'In what year did World War II end?',
      options: ['1943', '1944', '1945', '1946'],
      correctIndex: 2,
      category: 'History',
    ),
    TriviaQuestion(
      question: 'What is the chemical symbol for gold?',
      options: ['Go', 'Gd', 'Au', 'Ag'],
      correctIndex: 2,
      category: 'Science',
    ),
    TriviaQuestion(
      question: 'Which country has the largest population?',
      options: ['USA', 'India', 'China', 'Russia'],
      correctIndex: 1,
      category: 'Geography',
    ),
    TriviaQuestion(
      question: 'What is the hardest natural substance on Earth?',
      options: ['Gold', 'Iron', 'Diamond', 'Platinum'],
      correctIndex: 2,
      category: 'Science',
    ),
    TriviaQuestion(
      question: 'Who wrote Romeo and Juliet?',
      options: ['Dickens', 'Shakespeare', 'Austen', 'Hemingway'],
      correctIndex: 1,
      category: 'Literature',
    ),
    TriviaQuestion(
      question: 'What is the smallest country in the world?',
      options: ['Monaco', 'Vatican City', 'San Marino', 'Liechtenstein'],
      correctIndex: 1,
      category: 'Geography',
    ),
    TriviaQuestion(
      question: 'Which element has the atomic number 1?',
      options: ['Helium', 'Hydrogen', 'Oxygen', 'Carbon'],
      correctIndex: 1,
      category: 'Science',
    ),
    TriviaQuestion(
      question: 'In which city is the Eiffel Tower located?',
      options: ['London', 'Rome', 'Paris', 'Berlin'],
      correctIndex: 2,
      category: 'Geography',
    ),
    TriviaQuestion(
      question: 'Who invented the telephone?',
      options: ['Edison', 'Bell', 'Tesla', 'Wright'],
      correctIndex: 1,
      category: 'History',
    ),
    TriviaQuestion(
      question: 'What is the largest mammal in the world?',
      options: ['Elephant', 'Blue Whale', 'Giraffe', 'Hippopotamus'],
      correctIndex: 1,
      category: 'Nature',
    ),
    TriviaQuestion(
      question: 'Which planet is closest to the Sun?',
      options: ['Venus', 'Mercury', 'Mars', 'Earth'],
      correctIndex: 1,
      category: 'Science',
    ),
    TriviaQuestion(
      question: 'What is the currency of Japan?',
      options: ['Yuan', 'Won', 'Yen', 'Ringgit'],
      correctIndex: 2,
      category: 'General',
    ),
    TriviaQuestion(
      question: 'Who discovered penicillin?',
      options: ['Pasteur', 'Fleming', 'Curie', 'Darwin'],
      correctIndex: 1,
      category: 'Science',
    ),
    TriviaQuestion(
      question: 'What is the tallest mountain in the world?',
      options: ['K2', 'Kangchenjunga', 'Mount Everest', 'Lhotse'],
      correctIndex: 2,
      category: 'Geography',
    ),
    TriviaQuestion(
      question: 'In which year did the Titanic sink?',
      options: ['1910', '1912', '1914', '1916'],
      correctIndex: 1,
      category: 'History',
    ),
    TriviaQuestion(
      question: 'What is the main ingredient in guacamole?',
      options: ['Tomato', 'Avocado', 'Onion', 'Pepper'],
      correctIndex: 1,
      category: 'Food',
    ),
  ];
}
