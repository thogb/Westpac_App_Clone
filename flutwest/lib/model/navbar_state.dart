typedef NavBarStateCallBack<T, G> = void Function(T prevIndex, G currIndex);

class NavbarState {
  late int _prevPageIndex;
  late int _currPageIndex;
  late List<NavBarStateCallBack<int, int>> _observers;

  NavbarState() {
    _prevPageIndex = 0;
    _currPageIndex = 0;
    _observers = [];
  }

  void setPrevPageIndex(int index) {
    _prevPageIndex = index;
  }

  void setCurrPageIndex(int index) {
    _currPageIndex = index;
  }

  void updatePageIndex(int index) {
    _prevPageIndex = _currPageIndex;
    _currPageIndex = index;
  }

  void addObserver(NavBarStateCallBack<int, int> voidCallback) {
    _observers.add(voidCallback);
  }

  void notifyObserver() {
    for (NavBarStateCallBack<int, int> voidCallback in _observers) {
      voidCallback(_prevPageIndex, _currPageIndex);
    }
  }
}
