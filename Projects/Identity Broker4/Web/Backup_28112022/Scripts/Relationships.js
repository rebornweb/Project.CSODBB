function Relationships(configuration) {

    var relationships = new LinkedList();

    var leftSideKeys = configuration.leftSideKeys;
    var rightSideKeys = configuration.rightSideKeys;

    var formatText = configuration.formatText;
    var formatDisplay = configuration.formatDisplay;

    var name = configuration.name;

    // Adds the provided relationship to the relationships.
    this.AddRelationship = function (relationship) {

        relationships.Push({ Next: null, Value: relationship });

    };

    ///Removes the provided relationship from the relationships.
    this.DeleteRelationship = function (index) {

        relationships.RemoveAt(index);
        this.Commit();

    };

    // Returns the relationship at the index.
    this.GetRelationship = function (index) {

        return relationships.Get(index);

    };

    // Returns the plain-text column mappings value.
    this.Value = function () {

        var value = '';

        relationships.Visit(

            function (count, component) {

                value += component.left;
                value += '::';
                value += component.right;
                value += "\n";

            }
        );

        return value;

    };

    // Commits the current value to the underlying textarea.
    this.Commit = function () {

        formatText.val(this.Value());
        this.Render();

    };

    // Accepts a text value, replacing the underlying components.
    this.Accept = function (text) {

        relationships.Clear();

        var lines = text.split('\n');

        for (var i = 0; i < lines.length; i++) {

            var line = lines[i];

            if (line != '') {
                var values = line.split('::');
                relationships.Push({ Next: null, Value: { left: values[0], right: values[1]} });
            }
        }

        this.Render();
        return true;

    };

    this.Render = function () {

        formatDisplay.html('');

        relationships.Visit(

            function (count, mapping) {

                formatDisplay.append(

                    '<div id="relationship_' + count + '">' +

                        leftDropDown(mapping.left, count) +

                        '&nbsp;join on&nbsp;' +

                        rightDropDown(mapping.right, count) +

                        '&nbsp;' +

                        deleteButton(count) +

                    '</div>'

                );
            }

        );

    };

    var leftDropDown = function (selectedValue, index) {

        var returnValue = '<select class="left" onchange="var currentValue = $(\'#relationship_' + index + ' select.left option:selected\').val(); var relationship = ' + name + '.GetRelationship(' + index + '); relationship.Value.left = currentValue; ' + name + '.Commit(); ">';

        for (var i = 0; i < leftSideKeys.length; i++) {

            var key = leftSideKeys[i];

            var selectedPlaceholder = '>';
            if (selectedValue == key) {

                selectedPlaceholder = ' selected="selected">';

            }

            returnValue += '<option value="' + key + '"' + selectedPlaceholder + key + "</option>";

        }

        returnValue += '</select>';

        return returnValue;

    };

    var rightDropDown = function (selectedValue, index) {

        var returnValue = '<select class="right" onchange="var currentValue = $(\'#relationship_' + index + ' select.right option:selected\').val(); var relationship = ' + name + '.GetRelationship(' + index + '); relationship.Value.right = currentValue; ' + name + '.Commit(); ">';

        for (var i = 0; i < rightSideKeys.length; i++) {

            var key = rightSideKeys[i];

            var selectedPlaceholder = '>';
            if (selectedValue == key) {

                selectedPlaceholder = ' selected="selected">';

            }

            returnValue += '<option value="' + key + '"' + selectedPlaceholder + key + "</option>";

        }

        returnValue += '</select>';

        return returnValue;

    };

    var deleteButton = function (index) {

        return '<a href="javascript:;" onclick="' + name + '.DeleteRelationship(' + index + ');return false;">Delete</a>';

    };
}