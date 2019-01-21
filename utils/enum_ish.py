from collections import Mapping

class Unpackable(type):
    def __iter__(cls):
        for x in cls.VALUES:
            yield x

    def __getitem__(cls, item):
        item = item[1:-1]
        return getattr(cls, item)

    def __len__(cls):
        return len(cls.VALUES)


class UnpackableMapping(Unpackable, Mapping): pass


class Offsets(object, metaclass=UnpackableMapping):
    PAD, GO, EOS, UNK = range(0, 4)
    VALUES = ['<PAD>', '<GO>', '<EOS>', '<UNK>']


if __name__ == "__main__":
    print("Iterate")
    for i, off in enumerate(Offsets):
        print(f"{i}: {off}")
    print("** unpacking")
    print(dict(**Offsets))
    print("* unpacking")
    print(*Offsets)
