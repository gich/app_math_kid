/// A single multiplication question: a × b = ?
class Question {
  final int a;
  final int b;

  const Question(this.a, this.b);

  int get answer => a * b;

  @override
  String toString() => '$a × $b';
}
