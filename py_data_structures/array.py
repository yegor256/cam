from typing import Any, List


class Array:
    """
    ru: Класс для реализации массива как структуры данных.
    en: A class for implementing an array as a data structure.
    """

    def __init__(self, initial_capacity: int = 10):
        """
        Инициализация массива с заданной емкостью. | Initialization of an array with a specified capacity.
        :param initial_capacity: начальный размер массива | The initial size of the array
        """
        self.capacity = initial_capacity     # Максимальная емкость / Maximum capacity
        self.size = 0                        # Текущий размер (количество элементов) | Current size (number of elements)
        self.array = [None] * self.capacity  # Массив фиксированной длины | Fixed-length array

    def __check_index(self, index: int):
        """
        Проверяет, является ли индекс допустимым. | Checks whether the index is valid.
        """
        if index < 0 or index >= self.size:
            raise IndexError("Индекс вне диапазона | The index is out of range")

    def add(self, value: Any) -> None:
        """
        Добавляет элемент в массив. Если массив заполнен, увеличивает емкость. |
        Adds an element to the array. If the array is full, it increases the capacity.
        """
        if self.size == self.capacity:
            self.__resize()

        self.array[self.size] = value
        self.size += 1

    def insert(self, index: int, value: Any) -> None:
        """
        Вставляет элемент в заданную позицию. | Inserts the element into the specified position.
        :param index: Позиция для вставки | Insertion position
        :param value: Значение для вставки | Value to insert
        """
        if self.size == self.capacity:
            self.__resize()

        if index < 0 or index > self.size:
            raise IndexError("Индекс вне диапазона | The index is out of range")

        # Сдвигаем элементы вправо / Moving the elements to the right
        for i in range(self.size, index, -1):
            self.array[i] = self.array[i - 1]

        self.array[index] = value
        self.size += 1

    def remove(self, index: int) -> None:
        """
        Удаляет элемент по индексу. | Deletes an element by index.
        """
        self.__check_index(index)

        # Сдвигаем элементы влево | Moving the elements to the left
        for i in range(index, self.size - 1):
            self.array[i] = self.array[i + 1]

        self.array[self.size - 1] = None
        self.size -= 1

    def get(self, index: int) -> Any:
        """
        Возвращает элемент по индексу. | Returns the element by index.
        """
        self.__check_index(index)
        return self.array[index]

    def set(self, index: int, value: Any) -> None:
        """
        Обновляет значение элемента по индексу. | Updates the value of the element by index.
        """
        self.__check_index(index)
        self.array[index] = value

    def find(self, value: Any) -> int:
        """
        Возвращает индекс первого вхождения значения в массиве. Если значение не найдено, возвращает -1. |
        Returns the index of the first occurrence of the value in the array.
        If the value is not found, it returns -1.
        """
        for i in range(self.size):
            if self.array[i] == value:
                return i
        return -1

    def traverse(self) -> List[Any]:
        """
        Перебирает все элементы массива и возвращает их в виде списка. |
        Iterates through all the elements of the array and returns them as a list.
        """
        return [self.array[i] for i in range(self.size)]

    def __resize(self) -> None:
        """
        Увеличивает емкость массива в два раза. |
        Increases the capacity of the array by two times.
        """
        self.capacity *= 2
        new_array = [None] * self.capacity
        for i in range(self.size):
            new_array[i] = self.array[i]
        self.array = new_array

    def __len__(self) -> int:
        """
        Возвращает текущий размер массива. |
        Returns the current size of the array.
        """
        return self.size

    def __str__(self) -> str:
        """
        Возвращает строковое представление массива. |
        Returns the string representation of an array.
        """
        return f"Array({self.traverse()})"
