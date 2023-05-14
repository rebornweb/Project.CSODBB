function LinkedList() {

    this.Root = null;
    this.Count = 0;

    this.Push = function (link) {

        var node = this.Root;

        if (!node) {
            this.Root = link;
        } else {
            while (node.Next) {
                node = node.Next;
            }

            node.Next = link;
        }

        this.Count++;
    };

    this.Get = function (index) {

        var node = this.Root;

        if (node) {
            for (var i = 0; i < index; i++) {

                if (!node.Next) {
                    console.log('Linked list not large enough.');
                    break;
                }

                node = node.Next;
            }
        }

        return node;

    };

    this.Last = function () {

        var node = this.Root;

        if (node) {

            while (node.Next) {
                node = node.Next;
            }

        }

        return node;
    };

    this.InsertAt = function (index, link) {

        var node = this.Root;

        if (!node) {
            this.Root = link;
        } else {
            for (var i = 0; i < index; i++) {

                if (node.Next) {
                    node = node.Next;
                }
                else {
                    console.log('Linked list not large enough.');
                    break;
                }
            }

            if (node.Next) {
                var nextNode = node.Next;

                node.Next = link;

                link.Next = nextNode;
            }
            else {
                node.Next = link;
            }

            this.Count++;
        }
    };

    this.RemoveAt = function (index) {
        var node = this.Root;

        if (node) {
            if (index == 0) {
                if (node.Next) {
                    node = node.Next;
                } else {
                    node = null;
                }

                delete this.Root;
                this.Root = node;
            }
            else {
                for (var i = 0; i < index; i++) {

                    if (!node.Next) {
                        console.log('Linked list not large enough.');
                        break;
                    }
                    else if (i == (index - 1)) {
                        var nextNode = node.Next;

                        if (!nextNode.Next) {
                            node.Next = null;
                            delete nextNode;

                        } else {
                            node.Next = nextNode.Next;
                            delete nextNode;

                        }
                        break;
                    }
                    else {
                        node = node.Next;
                    }

                }
            }

            this.Count--;
        }
    };

    this.Shift = function (link) {
        var oldRoot = this.Root;
        this.Root = link;
        this.Root.Next = oldRoot;
        this.Count++;
    };

    this.Clear = function () {

        var node = this.Root;

        if (node) {

            while (node.Next) {

                var nextNode = null;

                if (node.Next.Next) {
                    node.Next = node.Next.Next;
                }

                delete node.Next;
                node.Node = nextNode;
            }

            delete this.Root;

        }
    };

    this.Visit = function (visitor) {
        var node = this.Root;

        if (node) {

            var count = 0;

            while (node.Next) {
                visitor(count, node.Value);
                node = node.Next;
                count++;
            }

            visitor(count, node.Value);

        }
    };
}