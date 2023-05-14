$.fn.caret = function(begin, end) {
    if (this.length == 0) return { begin: 0, end: 0 };
    if (typeof begin == 'number') {
        end = (typeof end == 'number') ? end : begin;
        return this.each(function() {
            if (this.setSelectionRange) {
                this.setSelectionRange(begin, end);
            } else if (this.createTextRange) {
                var numberRange = this.createTextRange();
                numberRange.collapse(true);
                numberRange.moveEnd('character', end);
                numberRange.moveStart('character', begin);
                try {
                    numberRange.select();
                } catch (ex) {
                }
            }
        });
    } else {
        if (this[0].setSelectionRange) {
            begin = this[0].selectionStart;
            end = this[0].selectionEnd;
        } else if (document.selection && document.selection.createRange) {
            var otherRange = document.selection.createRange();
            begin = 0 - otherRange.duplicate().moveStart('character', -100000);
            end = begin + otherRange.text.length;
        }
        return { begin: begin, end: end };
    }
};

function DistinguishedNameTemplate(configuration) {
    var components = new LinkedList();
    
    var formatText = configuration.formatText;
    var formatDisplay = configuration.formatDisplay;

    var onConfigurationChange = configuration.onConfigurationChange;

    var name = configuration.name;

    // Adds a component to the collection.
    this.AddComponent = function (component) {
        components.Push({ Next: null, Value: component });
    };

    this.DeleteComponent = function (index) {
        var currentSeparator = components.Get(index).Value.separator;

        components.RemoveAt(index);

        if (components.Count > 0 && components.Root != null && typeof components.Root.Value !== 'undefined') {
            if (index == 0) {
                components.Root.Value.separator = '';
            } else if (index > 1) {
                var next = components.Get(index);
                if (next) {
                    next.Value.separator = currentSeparator;
                }
            }
        }
        
        this.Commit();
        onConfigurationChange();
    };

    this.Value = function () {
        var value = '';

        components.Visit(
            function (count, component) {
                value += component.separator;

                if (component.attribute != '') {
                    value += component.attribute;
                }

                if (component.attribute != '' && component.value != '') {
                    value += '=';
                }

                if (component.value != '') {

                    if (component.escapedStart) {
                        value += '\\';
                    }

                    value += component.value.replace(/\,/g, '\\,').replace(/\+/g, '\\+');
                }
            }
        );

        return value;
    };

    this.Commit = function () {
        formatText.val(this.Value());
        this.Render();
    };

    this.Accept = function (text) {
        components.Clear();

        var writeToAttribute = true;
        var escaped = false;
        var currentComponent = { Next: null, Value: { separator: '', attribute: '', value: '', escapedStart: false} };

        var write = function (c) {
            if (writeToAttribute)
                currentComponent.Value.attribute += c;
            else
                currentComponent.Value.value += c;

            escaped = false;
        };

        for (var i = 0; i < text.length; i++) {
            var character = text[i];

            switch (character) {
                case '\\':
                    if (escaped)
                        write(character);
                    else
                        escaped = true;
                    break;
                case '=':
                    if (escaped)
                        write(character);
                    else
                        writeToAttribute = false;
                    break;
                case ',':
                    if (!escaped) {
                        components.Push(currentComponent);
                        currentComponent = { Next: null, Value: { separator: ',', attribute: '', value: '', escapedStart: false} };
                        writeToAttribute = true;
                    } else {
                        write(character);
                    }
                    break;
                case '+':
                    if (!escaped) {
                        components.Push(currentComponent);
                        currentComponent = { Next: null, Value: { separator: '+', attribute: '', value: '', escapedStart: false} };
                        writeToAttribute = true;
                    } else {
                        write(character);
                    }
                    break;
                case '@':
                    if (escaped) {
                        currentComponent.Value.escapedStart = true;
                    }

                    write(character);

                    break;
                case '[':
                    if (escaped) {
                        currentComponent.Value.escapedStart = true;
                    }

                    write(character);

                    break;
                default:
                    write(character);
                    break;
            }
        }

        components.Push(currentComponent);

        this.Render();
        return true;
    };
    
    this.Move = function (fromIndex, toIndex) {
        var fromComponent = components.Get(fromIndex);

        components.RemoveAt(fromIndex);

        if (toIndex == 0) {
            fromComponent.Value.separator = '';
            
            if (components.Root) {
                components.Root.Value.separator = ',';
            }

            components.Shift(fromComponent);
            
        } else {
            fromComponent.Value.separator = ',';
            components.InsertAt(toIndex - 1, fromComponent);
        }
    };

    this.Render = function () {
        formatDisplay.html('');

        components.Visit(
            function (count, component) {

                var value =
                    '<span class="DnComponent">' +
                        '<label>' + component.separator + '</label>' +
                            '&nbsp';

                if (component.attribute != '') {
                    value += '<label>' + component.attribute + '</label>';
                }

                if (component.attribute != '' && component.value != '') {
                    value += '=';
                }

                if (component.value != '') {
                    if (component.escapedStart) {
                        value += '\\';
                    }

                    value += '<label>' + component.value + '</label>';
                }

                value += '<button onclick="' + name + '.DeleteComponent(' + count + ');return false;">x</button>' + '</span>';

                formatDisplay.append(value);
            }
        );
    };
}
