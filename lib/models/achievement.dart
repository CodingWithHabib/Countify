class Achievement {
  final int milestone;
  final String title;
  final String description;

  const Achievement({
    required this.milestone,
    required this.title,
    required this.description,
  });
}

const List<Achievement> achievements = [
  Achievement(
    milestone: 10,
    title: "Getting Started",
    description: "Reached 10 Counts",
  ),

  Achievement(
    milestone: 25,
    title: "Keep Going",
    description: "Reached 25 Counts",
  ),

  Achievement(
    milestone: 50,
    title: "Half Century",
    description: "Reached 50 Counts",
  ),

  Achievement(
    milestone: 100,
    title: "Century",
    description: "Reached 100 Counts",
  ),

  Achievement(
    milestone: 250,
    title: "Dedicated",
    description: "Reached 250 Counts",
  ),

  Achievement(
    milestone: 500,
    title: "Master Counter",
    description: "Reached 500 Counts",
  ),

  Achievement(
    milestone: 1000,
    title: "Legend",
    description: "Reached 1000 Counts",
  ),
];