class Node:
    """
    Класс узла связного списка
    Node class for a linked list
    """
    def __init__(self, data):
        self.data = data  # Данные узла / Node data
        self.next = None  # Ссылка на следующий узел / Pointer to the next node


class LinkedList:
    """
    Класс для связного списка
    Class for a linked list
    """
    def __init__(self):
        self.head = None  # Головной узел / Head node

    def is_empty(self):
        """Проверяет, пуст ли список. Checks if the list is empty."""
        return self.head is None

    def add_to_head(self, data):
        """
        Добавляет элемент в начало списка.
        Adds an element to the head of the list.
        """
        new_node = Node(data)
        new_node.next = self.head
        self.head = new_node

    def add_to_tail(self, data):
        """
        Добавляет элемент в конец списка.
        Adds an element to the tail of the list.
        """
        new_node = Node(data)
        if self.is_empty():
            self.head = new_node
        else:
            current = self.head
            while current.next:
                current = current.next
            current.next = new_node

    def remove(self, data):
        """
        Удаляет узел с заданным значением.
        Removes the node with the specified value.
        """
        if self.is_empty():
            return False

        if self.head.data == data:
            self.head = self.head.next
            return True

        current = self.head
        while current.next and current.next.data != data:
            current = current.next

        if current.next:
            current.next = current.next.next
            return True

        return False

    def find(self, data):
        """
        Находит узел с заданным значением.
        Finds a node with the specified value.
        """
        current = self.head
        while current:
            if current.data == data:
                return True
            current = current.next
        return False

    def size(self):
        """
        Возвращает количество элементов в списке.
        Returns the number of elements in the list.
        """
        count = 0
        current = self.head
        while current:
            count += 1
            current = current.next
        return count

    def print_list(self):
        """
        Печатает все элементы списка.
        Prints all elements of the list.
        """
        current = self.head
        while current:
            print(current.data, end=" -> ")
            current = current.next
        print("None")


# Пример работы связного списка
if __name__ == "__main__":
    linked_list = LinkedList()

    # Добавление элементов
    linked_list.add_to_head(3)
    linked_list.add_to_head(2)
    linked_list.add_to_tail(4)

    print("Связный список после добавления элементов:")
    linked_list.print_list()

    # Удаление элемента
    linked_list.remove(2)
    print("Связный список после удаления элемента 2:")
    linked_list.print_list()

    # Поиск элемента
    print("Элемент 3 найден:", linked_list.find(3))
    print("Элемент 5 найден:", linked_list.find(5))

    # Размер списка
    print("Размер связного списка:", linked_list.size())

    # Проверка пустоты
    print("Список пустой?", linked_list.is_empty())