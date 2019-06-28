from collections import MutableSet, OrderedDict


class OrderedSet(MutableSet):
    def __init__(self, iterable):
        super(OrderedSet, self).__init__()
        self._map = OrderedDict.fromkeys(iterable, 1)

    def add(self, item):
        self._map[item] = 1

    def discard(self, item):
        self._map.pop(item, None)

    def __len__(self):
        return len(self._map)

    def __contains__(self, item):
        return item in self._map

    def __iter__(self):
        for k in self._map:
            yield k

    def __repr__(self):
        items = ", ".join(map(repr, self._map))
        return 'OrderedSet({{{}}})'.format(items)
