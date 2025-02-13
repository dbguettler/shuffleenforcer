class Constraint {
  String firstId;
  String secondId;

  Constraint(this.firstId, this.secondId);

  @override
  String toString() {
    return "Constraint[$firstId,$secondId]";
  }
}
