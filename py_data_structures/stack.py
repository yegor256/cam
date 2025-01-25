class Stack:
    """
    Основные операции стека: | Basic stack operations:
    push() — добавление элемента в вершину стека. | adding an element to the top of the stack.
    pop() — удаление и возврат верхнего элемента. | deleting and returning the top element.
    peek() — просмотр верхнего элемента без его удаления. | viewing the top element without deleting it.
    is_empty() — проверка, пуст ли стек. | checking if the stack is empty.
    size() — возвращает количество элементов в стеке. | returns the number of items in the stack.
    """
    def __init__(self):
        """Инициализация пустого стека. | Initializing an empty stack."""
        self.items = []

    def push(self, item):
        """
        Добавляет элемент на вершину стека.
        :param item: Добавляемый элемент |
        Adds an element to the top of the stack.
        :param item: The item to add
        """
        self.items.append(item)

    def pop(self):
        """
        Удаляет и возвращает верхний элемент стека.
        :return: Верхний элемент стека
        :raises IndexError: Если стек пуст |
        Deletes and returns the top element of the stack.
        :return: The top element of the stack
        :raises IndexError: If the stack is empty
        """
        if self.is_empty():
            raise IndexError("pop from empty stack")
        return self.items.pop()

    def peek(self):
        """
        Возвращает верхний элемент стека без его удаления.
        :return: Верхний элемент стека
        :raises IndexError: Если стек пуст
        Returns the top element of the stack without deleting it.
        :return: The top element of the stack
        :raises IndexError: If the stack is empty
        """
        if self.is_empty():
            raise IndexError("peek from empty stack")
        return self.items[-1]

    def is_empty(self):
        """
        Проверяет, пуст ли стек.
        :return: True, если стек пуст; иначе False
        Checks if the stack is empty.
        :return: True if the stack is empty; otherwise False
        """
        return len(self.items) == 0

    def size(self):
        """
        Возвращает количество элементов в стеке.
        :return: Количество элементов
        Returns the number of items in the stack.
        :return: Number of elements
        """
        return len(self.items)

    def clear(self):
        """
        Очищает стек. | Clears the stack.
        """
        self.items = []

    def __str__(self):
        """
        Возвращает строковое представление стека.
        :return: Строка с элементами стека
        Returns the string representation of the stack.
        :return: A string with glass elements
        """
        return f"Stack({self.items})"
