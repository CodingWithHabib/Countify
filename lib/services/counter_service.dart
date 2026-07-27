class CounterService {
  static int increase(int count) {
    return count + 1;
  }

  static int decrease(int count) {
    if (count <= 0) return 0;
    return count - 1;
  }

  static int reset() {
    return 0;
  }
}